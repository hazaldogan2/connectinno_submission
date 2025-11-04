import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();
  static final instance = AuthStorage._();

  static const _kToken = 'auth_token';
  final _secure = const FlutterSecureStorage();

  String? _token;
  final _tokenCtrl = StreamController<String?>.broadcast();
  Stream<String?> get tokenStream => _tokenCtrl.stream;
  String? get currentToken => _token;

  Future<void> init() async {
    _token = await _secure.read(key: _kToken);
    _tokenCtrl.add(_token);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _secure.write(key: _kToken, value: token);
    _tokenCtrl.add(_token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _secure.delete(key: _kToken);
    _tokenCtrl.add(_token);
  }

  bool get isLoggedIn => (_token != null && _token!.isNotEmpty);
}

