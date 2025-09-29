import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'retry_interceptor.dart'; // Changed
import 'secure_storage.dart';
import 'token_refresh_interceptor.dart'; // Changed

/// Dio 클라이언트 설정 및 인터셉터 관리
class DioClient {
  static Dio? _instance;

  /// Dio 인스턴스 싱글톤
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Dio 인스턴스 생성 및 설정
  static Dio _createDio() {
    final config = AppConfig.current;

    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: Duration(milliseconds: config.apiTimeoutMs),
        receiveTimeout: Duration(milliseconds: config.apiTimeoutMs),
        sendTimeout: Duration(milliseconds: config.apiTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가 - 순서 중요! // Changed
    dio.interceptors.addAll([
      const RetryInterceptor(), // Changed: 재시도 인터셉터 먼저
      TokenRefreshInterceptor(dio: dio), // Changed: 토큰 갱신 인터셉터
      _AuthInterceptor(), // 기존 인증 인터셉터
      if (config.enableLogging) _LoggingInterceptor(), // 로깅은 마지막
    ]);

    return dio;
  }

  /// Dio 인스턴스 재설정 (테스트용)
  static void reset() {
    _instance = null;
  }
}

/// 인증 인터셉터 - 모든 요청에 서버 JWT 자동 부착
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final serverJWT = await SecureStorage.getServerJWT();
      if (serverJWT != null && serverJWT.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $serverJWT';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auth Interceptor Error: $e');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Changed: async 추가
    // 401 Unauthorized인 경우 저장된 토큰 삭제
    if (err.response?.statusCode == 401) {
      await SecureStorage.deleteServerJWT(); // Changed: await 추가
      if (kDebugMode) {
        debugPrint('401 Unauthorized - Deleting stored server JWT');
      }
    }
    handler.next(err);
  }
}

/// 로깅 인터셉터 - 디버그 모드에서만 동작
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    debugPrint('📝 Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('📦 Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    debugPrint('📦 Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    debugPrint('📦 Error: ${err.message}');
    handler.next(err);
  }
}
