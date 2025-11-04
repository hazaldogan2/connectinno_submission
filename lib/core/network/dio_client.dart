import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/auth_storage.dart';

class DioClient {
  DioClient._() {
    final baseUrl =
        dotenv.env['API_BASE_URL'] ?? dotenv.env['API_URL'] ?? 'http://127.0.0.1:8001';

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ));

    // İlk token durumu
    final token = AuthStorage.instance.currentToken;
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    // Token güncellenirse header’ı da güncelle
    _sub = AuthStorage.instance.tokenStream.listen((t) {
      if (t == null || t.isEmpty) {
        _dio.options.headers.remove('Authorization');
      } else {
        _dio.options.headers['Authorization'] = 'Bearer $t';
      }
    });
  }

  static final instance = DioClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  StreamSubscription<String?>? _sub;

  void dispose() => _sub?.cancel();
}


