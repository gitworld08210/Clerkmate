import 'dart:io';

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

/// A field in the form being filled.
class _Field {
  final String label;
  final TextEditingController controller;
  _Field(this.label, String value) : controller = TextEditingController(text: value);
}

/// Fillable form: works fully manually (no AI needed). Fields are pre-filled
/// from the saved school/teacher data. AI reading is an optional extra.
class FormFillScreen extends StatefulWidget {
  const FormFillScreen({super.key});

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {
  final List<_Field> _fields = [];
  bool _busy = false;
  bool _started = false;

  @override
  void dispose() {
    for (final f in _fields) {
      f.controller.dispose();
    }
    super.dispose();
  }

  // Build the default field set, pre-filled from the school record.
  void _startBlank() {
    final s = context.read<AppState>().school;
    _setFields({
      'School Name': s.name,
      'Head Master / Principal': s.headMaster,
      'DISE / UDISE Code': s.diseCode,
      'Address': s.address,
      'Block': s.block,
      'District': s.district,
      'Date': '',
      'Subject': '',
      'Details': '',
    });
    setState(() => _started = true);
  }

  void _setFields(Map<String, String> values) {
    for (final f in _fields) {
      f.controller.dispose();
    }
    _fields
      ..clear()
      ..addAll(values.entries.map((e) => _Field(e.key, e.value)));
  }

  Map<String, String> get _current =>
      {for (final f in _fields) f.label: f.controller.text};

  Future<void> _readWithAi() async {
    final state = context.read<AppState>();
    final s = state.s;
    final gemini = GeminiService(state.geminiApiKey);
    if (!gemini.hasKey) {
      _msg(s.aiUnavailable);
      return;
    }
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

    setState(() => _busy = true);
    try {
      final extracted = await gemini.extractFields(
        fileBytes: bytes,
        mimeType: _mimeFor(f.extension ?? ''),
        wantedFields: _current.keys.toList(),
      );
      final merged = {..._current};
      extracted.forEach((k, v) {
        if (v.trim().isNotEmpty) merged[k] = v.trim();
      });
      setState(() => _setFields(merged));
      _msg(s.aiDone);
    } catch (e) {
      _msg('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mimeFor(String ext) => switch (ext.toLowerCase()) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        _ => 'image/jpeg',
      };

  Future<void> _addField() async {
    final s = context.read<AppState>().s;
    final ctrl = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.addField),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: s.fieldLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(s.add)),
        ],
      ),
    );
    if (label != null && label.isNotEmpty) {
      setState(() => _fields.add(_Field(label, '')));
    }
  }

  Future<Lang?> _askLang() {
    final s = context.read<AppState>().s;
    return showDialog<Lang>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.pdfLanguageTitle),
        content: Text(s.pdfLanguageSub),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, Lang.hi), child: Text(s.hindi)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, Lang.en),
              child: Text(s.english)),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    final lang = await _askLang();
    if (lang == null || !mounted) return;
    final s = context.read<AppState>().s;
    final bytes = await PdfService.buildFilledForm(
      title: s.formAutoFill,
      fields: _current,
      lang: lang,
    );
    final file = await FileUtils.save(bytes, 'FilledForm.pdf');
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(s.exportPdf), actions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => FileUtils.share(file)),
        ]),
        body: PdfPreview(build: (_) => bytes),
      ),
    ));
  }

  Future<void> _exportExcel() async {
    final bytes = ExcelService.buildFieldsSheet(_current);
    final file = await FileUtils.save(bytes, 'FormData.xlsx');
    await FileUtils.share(file, text: 'Form data (Excel)');
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;

    if (!_started) {
      // auto-start with the blank template on first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_started) _startBlank();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.formAutoFill)),
      body: !_started
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s.autoFilledNote)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.aiEnabled)
                  OutlinedButton.icon(
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_fix_high),
                    label: Text(s.useAi),
                    onPressed: _busy ? null : _readWithAi,
                  ),
                if (state.aiEnabled) const SizedBox(height: 12),
                Text(s.formFields,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._fields.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: f.controller,
                        decoration: InputDecoration(labelText: f.label),
                      ),
                    )),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(s.addField),
                  onPressed: _addField,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(s.exportPdf),
                        onPressed: _exportPdf,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.table_chart),
                        label: Text(s.exportExcel),
                        onPressed: _exportExcel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
