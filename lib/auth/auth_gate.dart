import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/notes_page.dart';
import 'auth_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SupabaseClient _sb;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _sb = Supabase.instance.client;
    _authSub = _sb.auth.onAuthStateChange.listen((AuthState state) {
      if (!mounted) return;
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _sb.auth.currentSession;
    if (session == null) {
      return const AuthPage();
    }
    return const NotesPage();
  }
}
