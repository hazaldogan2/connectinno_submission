import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/auth/auth_storage.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<void> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token not take');
    }
    await AuthStorage.instance.saveToken(token);
  }

  Future<void> register(String email, String password) async {
    await login(email, password);
  }

  Future<void> logout() async {
    await AuthStorage.instance.clearToken();
  }

  Future<bool> hasToken() async {
    return AuthStorage.instance.isLoggedIn;
  }

  String? get currentToken => AuthStorage.instance.currentToken;
}
