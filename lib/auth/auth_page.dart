import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() => {_busy = true, _error = null});
    final sb = Supabase.instance.client;
    try {
      if (_isLogin) {
        await sb.auth.signInWithPassword(email: _email.text.trim(), password: _pass.text);
      } else {
        await sb.auth.signUp(email: _email.text.trim(), password: _pass.text);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = Supabase.instance.client;
    final session = sb.auth.currentSession;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        actions: [
          if (session != null)
            TextButton(
              onPressed: () async => sb.auth.signOut(),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_isLogin ? 'Login' : 'Sign Up', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 12),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_isLogin ? 'Login' : 'Create account'),
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'Need an account? Sign up' : 'Have an account? Login'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
