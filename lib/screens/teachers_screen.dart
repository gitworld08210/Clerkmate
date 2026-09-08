import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/teacher.dart';
import '../state/app_state.dart';
import 'teacher_edit_screen.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final teachers = state.teachers;

    return Scaffold(
      appBar: AppBar(title: Text(s.teachers)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(s.add),
        onPressed: () => _edit(context, Teacher()),
      ),
      body: teachers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(s.noTeacherYet, textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              itemCount: teachers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = teachers[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(_initial(t.name))),
                  title: Text(t.name.isEmpty ? s.noName : t.name),
                  subtitle: Text(
                    '${t.designation}  •  ${s.netPay}: ₹${t.netPay.toStringAsFixed(0)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, t),
                  ),
                  onTap: () => _edit(context, t.copy()),
                );
              },
            ),
    );
  }

  String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  void _edit(BuildContext context, Teacher t) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TeacherEditScreen(teacher: t)),
    );
  }

  void _confirmDelete(BuildContext context, Teacher t) {
    final s = context.read<AppState>().s;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteQ),
        content: Text(s.deleteMsg(t.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().deleteTeacher(t.serverId!);
              Navigator.pop(ctx);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}
