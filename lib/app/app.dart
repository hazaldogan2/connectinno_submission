import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../core/auth/auth_storage.dart';
import '../features/auth/representation/login_page.dart';
import '../features/notes/presentation/pages/notes_page.dart';
import '../features/auth/data/auth_repository.dart';

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  bool _ready = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _loggedIn = AuthStorage.instance.isLoggedIn;
    AuthStorage.instance.tokenStream.listen((t) {
      if (!mounted) return;
      setState(() => _loggedIn = (t != null && t.isNotEmpty));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        home: const _Splash(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: _loggedIn
          ? const _Shell(child: NotesPage())
          : LoginPage(onLoggedIn: () => setState(() => _loggedIn = true)),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Uygulama kabuğu: AppBar + Logout
class _Shell extends StatelessWidget {
  const _Shell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectinno Notes'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthRepository().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginPage(onLoggedIn: () => Navigator.of(_).pushReplacement(
                          MaterialPageRoute(builder: (_) => const _Shell(child: NotesPage())),
                        )),
                  ),
                      (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: child,
    );
  }
}

