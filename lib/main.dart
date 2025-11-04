import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/api_client.dart';
import 'logic/notes_cubit.dart';
import 'auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ConnectinnoApp());
}

class ConnectinnoApp extends StatelessWidget {
  const ConnectinnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotesCubit(api)..initCache()),
      ],
      child: MaterialApp(
        title: 'Connectinno Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: const AuthGate(),
      ),
    );
  }
}

