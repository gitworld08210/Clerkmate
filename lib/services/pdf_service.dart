import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/strings.dart';
import '../models/teacher.dart';
import '../models/school_info.dart';

/// Result of prorating a teacher's salary for a given month.
class SalaryLine {
  final Teacher teacher;
  final int presentDays;
  final int totalDays;

  SalaryLine({
    required this.teacher,
    required this.presentDays,
    required this.totalDays,
  });

  double get factor => totalDays == 0 ? 0 : presentDays / totalDays;

  double get basic => teacher.basic * factor;
  double get da => teacher.da * factor;
  double get hra => teacher.hra * factor;
  double get medical => teacher.medical * factor;
  double get otherAllowance => teacher.otherAllowance * factor;
  double get gross => basic + da + hra + medical + otherAllowance;

  double get gis => teacher.gis;
  double get cpf => teacher.cpf;
  double get otherDeduction => teacher.otherDeduction;
  double get deductions => gis + cpf + otherDeduction;

  double get netPay => gross - deductions;
}

/// PDF-specific labels in both languages.
class _PdfLabels {
  final Lang lang;
  const _PdfLabels(this.lang);
  String _(String hi, String en) => lang == Lang.hi ? hi : en;

  String get salaryBill => _('वेतन विपत्र', 'SALARY BILL');
  String get sno => _('क्र.', 'S.No');
  String get name => _('नाम', 'Name');
  String get desig => _('पद', 'Desig.');
  String get days => _('दिन', 'Days');
  String get basic => _('मूल', 'Basic');
  String get da => _('महंगाई भत्ता', 'DA');
  String get hra => _('मकान भत्ता', 'HRA');
  String get medical => _('चिकित्सा', 'Med.');
  String get other => _('अन्य', 'Other');
  String get gross => _('कुल आय', 'Gross');
  String get gis => 'GIS';
  String get cpf => 'CPF';
  String get othDed => _('अन्य कटौती', 'Oth.Ded');
  String get deduct => _('कुल कटौती', 'Deduct');
  String get netPay => _('शुद्ध वेतन', 'Net Pay');
  String get bankAc => _('बैंक खाता', 'Bank A/C');
  String get ifsc => 'IFSC';
  String get total => _('योग', 'TOTAL');
  String get preparedBy => _('तैयारकर्ता', 'Prepared by');
  String get headMaster => _('प्रधानाध्यापक', 'Head Master / Principal');
}

class PdfService {
  static pw.Font? _devFont;

  /// Loads a Devanagari-capable font once, so Hindi renders in the PDF.
  static Future<pw.Font?> _hindiFont() async {
    if (_devFont != null) return _devFont;
    try {
      final data =
          await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
      _devFont = pw.Font.ttf(data);
    } catch (_) {
      _devFont = null; // fall back to default (English still fine)
    }
    return _devFont;
  }

  static pw.ThemeData _theme(pw.Font? hindi) {
    if (hindi == null) return pw.ThemeData.base();
    return pw.ThemeData.withFont(base: hindi, bold: hindi);
  }

  /// Builds a salary bill PDF. [lang] controls the label language in the PDF.
  static Future<Uint8List> buildSalaryBill({
    required SchoolInfo school,
    required List<SalaryLine> lines,
    required int month,
    required int year,
    required Lang lang,
  }) async {
    final doc = pw.Document();
    final L = _PdfLabels(lang);
    final hindi = lang == Lang.hi ? await _hindiFont() : null;
    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));
    final nf = NumberFormat('#,##0', 'en_IN');

    String money(double v) => nf.format(v.round());
    double sum(double Function(SalaryLine) f) =>
        lines.fold(0.0, (a, l) => a + f(l));

    doc.addPage(
      pw.MultiPage(
        theme: _theme(hindi),
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(18),
        build: (context) => [
          pw.Center(
            child: pw.Column(children: [
              pw.Text(
                school.name.isEmpty ? 'SCHOOL NAME' : school.name,
                style: pw.TextStyle(
                    fontSize: 15, fontWeight: pw.FontWeight.bold),
              ),
              if (school.address.isNotEmpty)
                pw.Text(school.address,
                    style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Text('${L.salaryBill} — $monthName',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
            ]),
          ),
          pw.SizedBox(height: 10),
          _salaryTable(L, lines, money, sum),
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${L.preparedBy}: __________________'),
              pw.Column(children: [
                pw.Text(school.headMaster.isEmpty
                    ? '__________________'
                    : school.headMaster),
                pw.Text(L.headMaster, style: const pw.TextStyle(fontSize: 9)),
              ]),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _salaryTable(
    _PdfLabels L,
    List<SalaryLine> lines,
    String Function(double) money,
    double Function(double Function(SalaryLine)) sum,
  ) {
    final headers = [
      L.sno, L.name, L.desig, L.days, L.basic, L.da, L.hra, L.medical,
      L.other, L.gross, L.gis, L.cpf, L.othDed, L.deduct, L.netPay,
      L.bankAc, L.ifsc,
    ];

    final rows = <pw.TableRow>[];
    rows.add(_row(headers, header: true));

    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      rows.add(_row([
        '${i + 1}',
        l.teacher.name,
        l.teacher.designation,
        '${l.presentDays}/${l.totalDays}',
        money(l.basic),
        money(l.da),
        money(l.hra),
        money(l.medical),
        money(l.otherAllowance),
        money(l.gross),
        money(l.gis),
        money(l.cpf),
        money(l.otherDeduction),
        money(l.deductions),
        money(l.netPay),
        l.teacher.bankAcNo,
        l.teacher.ifsc,
      ]));
    }

    rows.add(_row([
      '',
      L.total,
      '',
      '',
      money(sum((l) => l.basic)),
      money(sum((l) => l.da)),
      money(sum((l) => l.hra)),
      money(sum((l) => l.medical)),
      money(sum((l) => l.otherAllowance)),
      money(sum((l) => l.gross)),
      money(sum((l) => l.gis)),
      money(sum((l) => l.cpf)),
      money(sum((l) => l.otherDeduction)),
      money(sum((l) => l.deductions)),
      money(sum((l) => l.netPay)),
      '',
      '',
    ], header: true));

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  static pw.TableRow _row(List<String> cells, {bool header = false}) {
    return pw.TableRow(
      decoration:
          header ? const pw.BoxDecoration(color: PdfColors.grey300) : null,
      children: cells
          .map((c) => pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: pw.Text(
                  c,
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight:
                        header ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              ))
          .toList(),
    );
  }

  /// Builds a clean, freshly-typed PDF from key/value fields.
  static Future<Uint8List> buildFilledForm({
    required String title,
    required Map<String, String> fields,
    required Lang lang,
  }) async {
    final doc = pw.Document();
    final hindi = lang == Lang.hi ? await _hindiFont() : null;
    doc.addPage(
      pw.MultiPage(
        theme: _theme(hindi),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Center(
            child: pw.Text(title,
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
            },
            children: fields.entries
                .map((e) => pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(e.key,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(e.value),
                      ),
                    ]))
                .toList(),
          ),
        ],
      ),
    );
    return doc.save();
  }
}
