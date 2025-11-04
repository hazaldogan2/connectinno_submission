import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  SecureStore._();
  static final instance = SecureStore._();
  final _s = const FlutterSecureStorage();

  Future<void> writeToken(String token) => _s.write(key: 'token', value: token);
  Future<String?> readToken() => _s.read(key: 'token');
  Future<void> deleteToken() => _s.delete(key: 'token');
}
