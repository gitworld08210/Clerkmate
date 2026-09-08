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
      _msg('${s.loginFailed}: ${_clean(e)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _clean(Object e) {
    final t = e.toString();
    return t.replaceAll('AuthException(message: ', '').replaceAll(')', '');
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
              const Icon(Icons.school, size: 64, color: Color(0xFF1565C0)),
              const SizedBox(height: 12),
              Text(s.appName,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              Text(_isSignUp ? s.createAccount : s.loginTitle,
                  style: const TextStyle(fontSize: 15)),
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
