import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionBadge extends StatelessWidget {
  const SessionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    return Row(children: [
      const Icon(Icons.verified_user, size: 18),
      const SizedBox(width: 6),
      Text(user.email ?? user.id, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 10),
      TextButton(
        onPressed: () => Supabase.instance.client.auth.signOut(),
        child: const Text('Logout', style: TextStyle(color: Colors.white)),
      ),
    ]);
  }
}
