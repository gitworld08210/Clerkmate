import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../models/teacher.dart';
import '../services/pdf_service.dart';
import '../services/file_utils.dart';
import '../state/app_state.dart';

class SalaryBillScreen extends StatefulWidget {
  const SalaryBillScreen({super.key});

  @override
  State<SalaryBillScreen> createState() => _SalaryBillScreenState();
}

class _SalaryBillScreenState extends State<SalaryBillScreen> {
  late int _month;
  late int _year;
  int _totalDays = 30;

  final Map<String, int> _presentDays = {};
  final Map<String, Teacher> _working = {};
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _totalDays = DateUtils.getDaysInMonth(_year, _month);
  }

  void _syncTeachers(List<Teacher> teachers) {
    for (final t in teachers) {
      final id = t.serverId!;
      _working.putIfAbsent(id, () => t.copy());
      _presentDays.putIfAbsent(id, () => _totalDays);
      if (_selected.isEmpty) _selected.add(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final teachers = state.teachers;
    _syncTeachers(teachers);

    return Scaffold(
      appBar: AppBar(title: Text(s.makeSalaryBill)),
      body: teachers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(s.addTeachersFirst, textAlign: TextAlign.center),
              ),
            )
          : Column(
              children: [
                _monthBar(s),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (_, i) => _teacherTile(s, teachers[i]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: teachers.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(s.generatePdf(_selected.length)),
                  onPressed: _selected.isEmpty ? null : _askLangThenGenerate,
                ),
              ),
            ),
    );
  }

  Widget _monthBar(S s) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: InputDecoration(labelText: s.month),
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                            DateFormat('MMMM').format(DateTime(2000, m))),
                      ))
                  .toList(),
              onChanged: (v) => setState(() {
                _month = v!;
                _totalDays = DateUtils.getDaysInMonth(_year, _month);
              }),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: '$_year',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.year),
              onChanged: (v) => setState(() {
                _year = int.tryParse(v) ?? _year;
                _totalDays = DateUtils.getDaysInMonth(_year, _month);
              }),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: TextFormField(
              key: ValueKey('days_$_totalDays'),
              initialValue: '$_totalDays',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.totalDays),
              onChanged: (v) =>
                  setState(() => _totalDays = int.tryParse(v) ?? _totalDays),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherTile(S s, Teacher t) {
    final id = t.serverId!;
    final w = _working[id]!;
    final present = _presentDays[id]!;
    final line =
        SalaryLine(teacher: w, presentDays: present, totalDays: _totalDays);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: Checkbox(
          value: _selected.contains(id),
          onChanged: (v) => setState(() {
            v == true ? _selected.add(id) : _selected.remove(id);
          }),
        ),
        title: Text(w.name.isEmpty ? s.noName : w.name),
        subtitle: Text(
            '${s.presentDays} $present/$_totalDays  •  ${s.netPay}: ₹${line.netPay.toStringAsFixed(0)}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Row(
            children: [
              Text('${s.presentDays}: '),
              Expanded(
                child: Slider(
                  min: 0,
                  max: _totalDays.toDouble(),
                  divisions: _totalDays,
                  value: present.clamp(0, _totalDays).toDouble(),
                  label: '$present',
                  onChanged: (v) =>
                      setState(() => _presentDays[id] = v.round()),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text('$present/$_totalDays',
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _editNum(s.basic, w.basic, (v) => setState(() => w.basic = v)),
          _editNum(s.da, w.da, (v) => setState(() => w.da = v)),
          _editNum(s.hra, w.hra, (v) => setState(() => w.hra = v)),
          _editNum(s.medical, w.medical, (v) => setState(() => w.medical = v)),
          _editNum(s.gis, w.gis, (v) => setState(() => w.gis = v)),
          _editNum(s.cpf, w.cpf, (v) => setState(() => w.cpf = v)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${s.gross} ₹${line.gross.toStringAsFixed(0)}  −  '
              '${s.deductions} ₹${line.deductions.toStringAsFixed(0)}  =  '
              '${s.netPay} ₹${line.netPay.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editNum(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        initialValue: value == 0 ? '' : value.toStringAsFixed(0),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(labelText: label, prefixText: '₹ '),
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }

  /// Ask the user which language they want the PDF's labels in, then build.
  Future<void> _askLangThenGenerate() async {
    final s = context.read<AppState>().s;
    final chosen = await showDialog<Lang>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.pdfLanguageTitle),
        content: Text(s.pdfLanguageSub),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, Lang.hi),
            child: Text(s.hindi),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, Lang.en),
            child: Text(s.english),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    await _generate(chosen);
  }

  Future<void> _generate(Lang pdfLang) async {
    final state = context.read<AppState>();
    final s = state.s;
    final lines = _selected.map((id) {
      return SalaryLine(
        teacher: _working[id]!,
        presentDays: _presentDays[id]!,
        totalDays: _totalDays,
      );
    }).toList();

    final bytes = await PdfService.buildSalaryBill(
      school: state.school,
      lines: lines,
      month: _month,
      year: _year,
      lang: pdfLang,
    );

    final monthName = DateFormat('MMM_yyyy').format(DateTime(_year, _month));
    final file = await FileUtils.save(bytes, 'SalaryBill_$monthName.pdf');

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(s.salaryBillPreview),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () =>
                  FileUtils.share(file, text: 'Salary Bill $monthName'),
            ),
          ],
        ),
        body: PdfPreview(
          build: (_) => bytes,
          canChangePageFormat: false,
          canChangeOrientation: false,
        ),
      ),
    ));
  }
}
