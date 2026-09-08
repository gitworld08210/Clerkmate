import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/teacher.dart';
import '../state/app_state.dart';

class TeacherEditScreen extends StatefulWidget {
  final Teacher teacher;
  const TeacherEditScreen({super.key, required this.teacher});

  @override
  State<TeacherEditScreen> createState() => _TeacherEditScreenState();
}

class _TeacherEditScreenState extends State<TeacherEditScreen> {
  late Teacher t;

  @override
  void initState() {
    super.initState();
    t = widget.teacher;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.serverId == null ? s.newTeacher : s.editTeacher),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(s.basicDetails),
          _text(s.name, t.name, (v) => t.name = v),
          _text(s.designation, t.designation, (v) => t.designation = v),
          _text(s.govtRollNo, t.govtRollNo, (v) => t.govtRollNo = v),
          _text(s.schoolRollNo, t.schoolRollNo, (v) => t.schoolRollNo = v),
          _text(s.dob, t.dob, (v) => t.dob = v),
          _text(s.doj, t.doj, (v) => t.doj = v),
          _text(s.gradePay, t.gradePay, (v) => t.gradePay = v),
          _section(s.earnings),
          _num(s.basic, t.basic, (v) => t.basic = v),
          _num(s.da, t.da, (v) => t.da = v),
          _num(s.hra, t.hra, (v) => t.hra = v),
          _num(s.medical, t.medical, (v) => t.medical = v),
          _num(s.otherAllowance, t.otherAllowance, (v) => t.otherAllowance = v),
          _section(s.deductions),
          _num(s.gis, t.gis, (v) => t.gis = v),
          _num(s.cpf, t.cpf, (v) => t.cpf = v),
          _num(s.otherDeduction, t.otherDeduction, (v) => t.otherDeduction = v),
          _section(s.bankDetails),
          _text(s.bankAcNo, t.bankAcNo, (v) => t.bankAcNo = v),
          _text(s.ifsc, t.ifsc, (v) => t.ifsc = v),
          _text(s.bankName, t.bankName, (v) => t.bankName = v),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${s.gross}: ₹${t.grossEarnings.toStringAsFixed(2)}'),
                  Text(
                      '${s.deductions}: ₹${t.totalDeductions.toStringAsFixed(2)}'),
                  Text('${s.netPay}: ₹${t.netPay.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: Text(s.save),
            onPressed: () async {
              await context.read<AppState>().saveTeacher(t);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
      );

  Widget _text(String label, String initial, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initial,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _num(String label, double initial, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initial == 0 ? '' : initial.toStringAsFixed(0),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        decoration: InputDecoration(labelText: label, prefixText: '₹ '),
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
        onEditingComplete: () => setState(() {}),
      ),
    );
  }
}
