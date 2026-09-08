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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: const Text('ClerkMate'),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.translate, color: cs.onPrimaryContainer),
                      label: Text(
                        state.lang.name == 'hi' ? 'EN' : 'हिं',
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () =>
                          context.read<AppState>().toggleLanguage(),
                    ),
                    IconButton(
                      tooltip: s.logout,
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AppState>().signOut(),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _SchoolBanner(
                      title: state.school.name.isEmpty
                          ? s.namaste
                          : state.school.name,
                      subtitle: state.school.name.isEmpty
                          ? s.setSchoolHint
                          : (state.school.district.isEmpty
                              ? s.appTagline
                              : state.school.district),
                      email: state.userEmail,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.98,
                    ),
                    delegate: SliverChildListDelegate([
                      _Tile(
                        icon: Icons.receipt_long,
                        color: const Color(0xFF2E7D32),
                        title: s.makeSalaryBill,
                        subtitle: s.makeSalaryBillSub,
                        onTap: () => _open(context, const SalaryBillScreen()),
                      ),
                      _Tile(
                        icon: Icons.description,
                        color: const Color(0xFF6A1B9A),
                        title: s.formAutoFill,
                        subtitle: s.formAutoFillSub,
                        onTap: () => _open(context, const FormFillScreen()),
                      ),
                      _Tile(
                        icon: Icons.groups,
                        color: const Color(0xFFEF6C00),
                        title: s.teachers,
                        subtitle: '${state.teachers.length} ${s.recordsSaved}',
                        onTap: () => _open(context, const TeachersScreen()),
                      ),
                      _Tile(
                        icon: Icons.apartment,
                        color: const Color(0xFF1565C0),
                        title: s.schoolDetails,
                        subtitle: state.school.name.isEmpty
                            ? s.notSetYet
                            : state.school.name,
                        onTap: () => _open(context, const SchoolScreen()),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _SchoolBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String email;
  const _SchoolBanner(
      {required this.title, required this.subtitle, required this.email});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: const Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
