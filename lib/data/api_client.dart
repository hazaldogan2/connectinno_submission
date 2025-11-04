import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  final String base = dotenv.env['API_BASE_URL']!;
  final _supabase = Supabase.instance.client;

  Future<Map<String, String>> _headers() async {
    final token = _supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> listNotes({String? q}) async {
    final uri = Uri.parse('$base/notes').replace(queryParameters: {
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    });
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List;
    }
    throw Exception('List notes failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
    bool pinned = false,
  }) async {
    final res = await http.post(
      Uri.parse('$base/notes'),
      headers: await _headers(),
      body: jsonEncode({'title': title, 'content': content, 'pinned': pinned}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create note failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> updateNote({
    required String id,
    String? title,
    String? content,
    bool? pinned,
  }) async {
    final res = await http.put(
      Uri.parse('$base/notes/$id'),
      headers: await _headers(),
      body: jsonEncode({
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (pinned != null) 'pinned': pinned,
      }),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update note failed: ${res.statusCode} ${res.body}');
  }

  Future<void> deleteNote(String id) async {
    final res = await http.delete(
      Uri.parse('$base/notes/$id'),
      headers: await _headers(),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Delete note failed: ${res.statusCode} ${res.body}');
    }
  }
}
