import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../services/firebase_token_service.dart';
import '../services/logger_service.dart';

/// 백엔드 API 클라이언트
///
/// Firebase ID Token을 자동으로 헤더에 추가하여 백엔드 API를 호출합니다.
class BackendApiClient {
  static BackendApiClient? _instance;
  late final Dio _dio;

  BackendApiClient._() {
    _dio = Dio();
    _setupDio();
  }

  static BackendApiClient get instance {
    if (_instance == null) {
      _instance = BackendApiClient._();
    } else if (kDebugMode) {
      // Hot Restart 시 Base URL이 변경되었으면 재설정
      if (_instance!._dio.options.baseUrl != ApiConfig.fullApiUrl) {
        LoggerService.debug('🔄 API Base URL 변경 감지, Dio 재설정 중...');
        LoggerService.debug('   이전: ${_instance!._dio.options.baseUrl}');
        LoggerService.debug('   현재: ${ApiConfig.fullApiUrl}');
        _instance!._setupDio();
      }
    }
    return _instance!;
  }

  /// 싱글톤 인스턴스 재설정 (주로 테스트용)
  static void resetInstance() {
    _instance = null;
  }

  Dio get dio => _dio;

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.fullApiUrl,
      connectTimeout: ApiConfig.defaultTimeout,
      receiveTimeout: ApiConfig.defaultTimeout,
      sendTimeout: ApiConfig.defaultTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // API 설정 출력
    if (kDebugMode) {
      LoggerService.debug('🌐 ===== Backend API Configuration =====');
      LoggerService.debug('   Base URL: ${ApiConfig.baseUrl}');
      LoggerService.debug('   Full API URL: ${ApiConfig.fullApiUrl}');
      LoggerService.debug('   Platform: ${defaultTargetPlatform.name}');
      LoggerService.debug('   Environment: ${ApiConfig.currentEnvironment.name}');
      LoggerService.debug('   Timeout: ${ApiConfig.defaultTimeout.inSeconds}s');
      LoggerService.debug('=====================================');
    }

    // Firebase ID Token 인터셉터 추가
    _dio.interceptors.addAll([
      FirebaseTokenInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// 현재 로그인 사용자 정보 조회
  ///
  /// Firebase ID Token을 백엔드로 전송하여 사용자 정보를 조회합니다.
  /// Authorization 헤더는 FirebaseTokenInterceptor가 자동으로 추가합니다.
  ///
  /// Returns: 백엔드에서 반환하는 사용자 정보
  Future<Response<Map<String, dynamic>>> getCurrentUser() async {
    if (kDebugMode) {
      LoggerService.debug('📡 [BackendApiClient] GET /auth/me 호출');
    }

    return get<Map<String, dynamic>>('/auth/me');
  }

  /// 사용자 정보 업데이트
  ///
  /// [data] 업데이트할 사용자 정보
  Future<Response<Map<String, dynamic>>> updateCurrentUser(
    Map<String, dynamic> data,
  ) async {
    if (kDebugMode) {
      LoggerService.debug('📡 [BackendApiClient] PATCH /auth/me 호출');
    }

    return patch<Map<String, dynamic>>('/auth/me', data: data);
  }
}

/// Firebase ID Token 인터셉터
///
/// 모든 요청에 Firebase ID Token을 Authorization 헤더로 자동 추가합니다.
class FirebaseTokenInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Firebase ID Token 획득
      final token = await FirebaseTokenService.getIdToken();

      if (token != null) {
        // Authorization 헤더에 Bearer 토큰 추가
        options.headers['Authorization'] = 'Bearer $token';
        print('🔑 Firebase ID Token 헤더 추가: ${token.substring(0, 20)}...');
        if (kDebugMode) {
          LoggerService.debug('🔑 Firebase ID Token 헤더 추가: ${token.substring(0, 20)}...');
        }
      } else {
        print('⚠️ Firebase ID Token이 없습니다. 로그인이 필요할 수 있습니다.');
        if (kDebugMode) {
          LoggerService.debug('⚠️ Firebase ID Token이 없습니다. 로그인이 필요할 수 있습니다.');
        }
        // 토큰이 없으면 에러 반환
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Firebase認証が必要です。ログインしてください。',
          ),
        );
        return;
      }
    } catch (e) {
      print('❌ Firebase Token 획득 실패: $e');
      if (kDebugMode) {
        LoggerService.debug('❌ Firebase Token 획득 실패: $e');
      }
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Firebase認証エラーが発生しました: $e',
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      try {
        // 토큰 갱신
        final newToken = await FirebaseTokenService.getIdToken(
          forceRefresh: true,
        );

        if (newToken != null) {
          // 저장소에도 업데이트
          await FirebaseTokenService.saveTokenToStorage();

          // 재시도
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          final dio = Dio();
          final response = await dio.fetch(opts);

          return handler.resolve(response);
        }
      } catch (e) {
        // 에러 무시
      }
    }

    handler.next(err);
  }
}

/// 로깅 인터셉터
///
/// API 요청/응답을 로그로 출력합니다 (개발 모드만).
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('📡 [API Request] ${options.method} ${options.uri}');
    print('   Headers: ${options.headers}');
    if (kDebugMode) {
      LoggerService.debug('📡 [API Request] ${options.method} ${options.uri}');
      LoggerService.debug('   Headers: ${options.headers}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [API Response] ${response.statusCode}');
    if (kDebugMode) {
      LoggerService.debug('✅ [API Response] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ [API Error] ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('   Error: ${err.message}');
    print('   Response: ${err.response?.data}');
    if (kDebugMode) {
      LoggerService.debug('❌ [API Error] ${err.response?.statusCode} ${err.requestOptions.uri}');
      LoggerService.debug('   Error: ${err.message}');
      LoggerService.debug('   Response: ${err.response?.data}');
    }
    handler.next(err);
  }
}

/// 에러 인터셉터
///
/// API 에러를 처리하고 사용자 친화적인 메시지로 변환합니다.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 에러 처리 (로깅 없음)
    handler.next(err);
  }
}
