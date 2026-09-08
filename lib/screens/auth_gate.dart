import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Shows the login screen when logged out, home screen when logged in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isLoggedIn) return const LoginScreen();
    return const HomeScreen();
  }
}
