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
    _instance ??= BackendApiClient._();
    return _instance!;
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

    // Firebase ID Token 인터셉터 추가
    _dio.interceptors.addAll([
      FirebaseTokenInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    if (kDebugMode) {
      LoggerService.debug('🚀 BackendApiClient 초기화 완료');
      LoggerService.debug('   Base URL: ${ApiConfig.fullApiUrl}');
    }
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

        if (kDebugMode) {
          LoggerService.debug(
            '🔑 Firebase ID Token 헤더 추가: ${token.substring(0, 20)}...',
          );
        }
      } else {
        if (kDebugMode) {
          LoggerService.debug('⚠️ Firebase ID Token이 없습니다 (로그인 필요)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ Firebase ID Token 추가 실패: $e');
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        LoggerService.debug('🔄 401 에러 - Firebase ID Token 갱신 시도');
      }

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

          if (kDebugMode) {
            LoggerService.debug('✅ 토큰 갱신 후 요청 재시도 성공');
          }

          return handler.resolve(response);
        }
      } catch (e) {
        if (kDebugMode) {
          LoggerService.debug('❌ 토큰 갱신 실패: $e');
        }
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
    if (kDebugMode) {
      LoggerService.debug('📡 [API Request] ${options.method} ${options.uri}');
      if (options.data != null) {
        LoggerService.debug('   Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      LoggerService.debug(
        '✅ [API Response] ${response.statusCode} ${response.requestOptions.uri}',
      );
      if (response.data != null) {
        LoggerService.debug('   Data: ${response.data}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      LoggerService.debug(
        '❌ [API Error] ${err.response?.statusCode} ${err.requestOptions.uri}',
      );
      LoggerService.debug('   Message: ${err.message}');
      if (err.response?.data != null) {
        LoggerService.debug('   Error Data: ${err.response?.data}');
      }
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
    String errorMessage = 'エラーが発生しました';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'タイムアウトが発生しました';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = '認証に失敗しました';
        } else if (statusCode == 403) {
          errorMessage = 'アクセスが拒否されました';
        } else if (statusCode == 404) {
          errorMessage = 'リソースが見つかりません';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'サーバーエラーが発生しました';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'リクエストがキャンセルされました';
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        errorMessage = 'ネットワークエラーが発生しました';
        break;
      default:
        errorMessage = '予期しないエラーが発生しました';
    }

    if (kDebugMode) {
      LoggerService.debug('🔍 [Error Interceptor] $errorMessage');
    }

    handler.next(err);
  }
}
