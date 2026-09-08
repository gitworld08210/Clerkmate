import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/gemini_service.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';
import '../services/file_utils.dart';
import '../state/app_state.dart';

/// The default logical fields we try to detect in a school form.
const _defaultFields = <String>[
  'School Name',
  'Head Master / Principal',
  'Employee Name',
  'Designation',
  'DISE Code',
  'Account Number',
  'IFSC',
  'Date',
  'Address',
];

class FormFillScreen extends StatefulWidget {
  const FormFillScreen({super.key});

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {
  String? _fileName;
  Uint8List? _fileBytes;
  String? _mimeType;

  bool _busy = false;
  String _status = '';
  Map<String, TextEditingController> _fields = {};

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    final bytes =
        f.bytes ?? (f.path != null ? await File(f.path!).readAsBytes() : null);
    if (bytes == null) return;
    setState(() {
      _fileName = f.name;
      _fileBytes = bytes;
      _mimeType = _mimeFor(f.extension ?? '');
      _status = '';
    });
  }

  String _mimeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _runAi() async {
    final state = context.read<AppState>();
    final s = state.s;
    final gemini = GeminiService(state.geminiApiKey);
    if (!gemini.hasKey) {
      _showMsg(s.aiUnavailable);
      return;
    }
    if (_fileBytes == null) {
      _showMsg(s.uploadFirst);
      return;
    }

    setState(() {
      _busy = true;
      _status = s.aiReading;
    });

    try {
      final result = await gemini.extractFields(
        fileBytes: _fileBytes!,
        mimeType: _mimeType!,
        wantedFields: _defaultFields,
      );

      // Fill blanks from our own school DB so the clean PDF is complete.
      final sc = state.school;
      final merged = <String, String>{};
      for (final key in _defaultFields) {
        var v = (result[key] ?? '').trim();
        if (v.isEmpty) {
          v = _fromDb(key, sc.name, sc.headMaster, sc.diseCode, sc.address);
        }
        merged[key] = v;
      }

      setState(() {
        _fields = {
          for (final e in merged.entries)
            e.key: TextEditingController(text: e.value)
        };
        _status = s.aiDone;
      });
    } catch (e) {
      _showMsg('Error: $e');
      setState(() => _status = '');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fromDb(String key, String name, String hm, String dise, String addr) {
    switch (key) {
      case 'School Name':
        return name;
      case 'Head Master / Principal':
        return hm;
      case 'DISE Code':
        return dise;
      case 'Address':
        return addr;
      default:
        return '';
    }
  }

  Map<String, String> get _currentFields =>
      {for (final e in _fields.entries) e.key: e.value.text};

  Future<Lang?> _askLang() {
    final s = context.read<AppState>().s;
    return showDialog<Lang>(
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
  }

  Future<void> _exportPdf() async {
    final lang = await _askLang();
    if (lang == null || !mounted) return;
    final s = context.read<AppState>().s;
    final bytes = await PdfService.buildFilledForm(
      title: 'Form — ${_fileName ?? 'ClerkMate'}',
      fields: _currentFields,
      lang: lang,
    );
    final file = await FileUtils.save(bytes, 'FilledForm.pdf');
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(s.cleanPdf), actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => FileUtils.share(file),
          ),
        ]),
        body: PdfPreview(build: (_) => bytes),
      ),
    ));
  }

  Future<void> _exportExcel() async {
    final bytes = ExcelService.buildFieldsSheet(_currentFields);
    final file = await FileUtils.save(bytes, 'FormData.xlsx');
    await FileUtils.share(file, text: 'Form data (Excel)');
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Scaffold(
      appBar: AppBar(title: Text(s.formAutoFill)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.step1Upload,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(_fileName ?? s.chooseFile),
                    onPressed: _busy ? null : _pickFile,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_fix_high),
            label: Text(s.step2Ai),
            onPressed: _busy ? null : _runAi,
          ),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_status,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary)),
            ),
          const SizedBox(height: 12),
          if (_fields.isNotEmpty) ...[
            Text(s.step3Check,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._fields.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: e.value,
                    decoration: InputDecoration(labelText: e.key),
                  ),
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(s.cleanPdf),
                    onPressed: _exportPdf,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart),
                    label: Text(s.excel),
                    onPressed: _exportExcel,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
