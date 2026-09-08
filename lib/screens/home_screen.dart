import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'teachers_screen.dart';
import 'school_screen.dart';
import 'salary_bill_screen.dart';
import 'form_fill_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        actions: [
          // Language toggle: shows the language you can switch TO.
          TextButton.icon(
            icon: const Icon(Icons.translate, color: Colors.white),
            label: Text(
              state.lang.name == 'hi' ? 'EN' : 'हिं',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.read<AppState>().toggleLanguage(),
          ),
          IconButton(
            tooltip: s.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppState>().signOut(),
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(schoolName: state.school.name, greeting: s.namaste,
                    hint: s.setSchoolHint),
                const SizedBox(height: 16),
                _MenuCard(
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  title: s.makeSalaryBill,
                  subtitle: s.makeSalaryBillSub,
                  onTap: () => _open(context, const SalaryBillScreen()),
                ),
                if (state.aiEnabled)
                  _MenuCard(
                    icon: Icons.auto_fix_high,
                    color: Colors.deepPurple,
                    title: s.formAutoFill,
                    subtitle: s.formAutoFillSub,
                    onTap: () => _open(context, const FormFillScreen()),
                  ),
                _MenuCard(
                  icon: Icons.people,
                  color: Colors.orange,
                  title: s.teachers,
                  subtitle: '${state.teachers.length} ${s.recordsSaved}',
                  onTap: () => _open(context, const TeachersScreen()),
                ),
                _MenuCard(
                  icon: Icons.school,
                  color: Colors.blue,
                  title: s.schoolDetails,
                  subtitle: state.school.name.isEmpty
                      ? s.notSetYet
                      : state.school.name,
                  onTap: () => _open(context, const SchoolScreen()),
                ),
              ],
            ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Header extends StatelessWidget {
  final String schoolName;
  final String greeting;
  final String hint;
  const _Header(
      {required this.schoolName, required this.greeting, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.waving_hand, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    schoolName.isEmpty ? hint : schoolName,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
