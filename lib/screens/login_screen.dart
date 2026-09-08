import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final s = state.s;
    final email = _email.text.trim();
    final pass = _password.text;
    if (email.isEmpty || pass.length < 6) {
      _msg(s.loginValidation);
      return;
    }
    setState(() => _busy = true);
    try {
      if (_isSignUp) {
        await state.signUp(email, pass);
        if (!mounted) return;
        _msg(s.signUpDone);
      } else {
        await state.signIn(email, pass);
      }
    } catch (e) {
      _msg(_friendly(e, s));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Turns raw Supabase auth errors into short, readable messages.
  String _friendly(Object e, s) {
    final t = e.toString().toLowerCase();
    if (t.contains('email_not_confirmed') || t.contains('not confirmed')) {
      return s.errEmailNotConfirmed;
    }
    if (t.contains('invalid login') || t.contains('invalid_credentials')) {
      return s.errInvalidCredentials;
    }
    if (t.contains('already registered') || t.contains('already been registered')) {
      return s.errAlreadyRegistered;
    }
    // Fallback: strip the noisy wrapper text.
    final raw = e.toString();
    final match = RegExp(r'message:\s*([^,]+)').firstMatch(raw);
    return '${s.loginFailed}: ${match?.group(1) ?? raw}';
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.translate, color: Colors.white),
              label: Text(
                state.lang.name == 'hi' ? 'EN' : 'हिं',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () => context.read<AppState>().toggleLanguage(),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school,
                    size: 56, color: Color(0xFF1565C0)),
              ),
              const SizedBox(height: 16),
              Text(s.appName,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(s.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text(_isSignUp ? s.createAccount : s.loginTitle,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: s.email,
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: s.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isSignUp ? s.signUp : s.login),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? s.haveAccount : s.noAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
