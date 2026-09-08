import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/school_info.dart';
import '../state/app_state.dart';

class SchoolScreen extends StatefulWidget {
  const SchoolScreen({super.key});

  @override
  State<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  late SchoolInfo _s;

  @override
  void initState() {
    super.initState();
    final existing = context.read<AppState>().school;
    _s = existing.copy();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Scaffold(
      appBar: AppBar(title: Text(s.schoolDetails)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(s.schoolName, _s.name, (v) => _s.name = v),
          _field(s.headMaster, _s.headMaster, (v) => _s.headMaster = v),
          _field(s.diseCode, _s.diseCode, (v) => _s.diseCode = v),
          _field(s.address, _s.address, (v) => _s.address = v, lines: 2),
          _field(s.block, _s.block, (v) => _s.block = v),
          _field(s.district, _s.district, (v) => _s.district = v),
          _field(s.contact, _s.contact, (v) => _s.contact = v),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: Text(s.save),
            onPressed: () async {
              await context.read<AppState>().saveSchool(_s);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.schoolSaved)),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String initial, ValueChanged<String> onChanged,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }
}
