import 'dart:io';

import 'package:aipet_frontend/shared/core/constants/app_constants.dart';
import 'package:aipet_frontend/shared/core/constants/app_texts.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// API 호출 관련 공통 유틸리티
class ApiUtils {
  ApiUtils._();

  static late final Logger _logger;

  /// Logger 초기화
  static void _initializeLogger() {
    _logger = Logger(
      filter: DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 2,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );
  }

  /// Logger 인스턴스 가져오기 (지연 초기화)
  static Logger get _loggerInstance {
    try {
      return _logger;
    } catch (e) {
      _initializeLogger();
      return _logger;
    }
  }

  /// HTTP 클라이언트 기본 설정
  static http.Client createHttpClient() {
    return http.Client();
  }

  /// Dio 인스턴스 기본 설정
  static Dio createDio({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, String>? headers,
  }) {
    final dio = Dio();

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    dio.options.connectTimeout = connectTimeout ?? AppConstants.apiTimeout;
    dio.options.receiveTimeout = receiveTimeout ?? AppConstants.longTimeout;

    if (headers != null) {
      dio.options.headers.addAll(headers);
    }

    // 기본 인터셉터 추가
    dio.interceptors.add(_createLoggingInterceptor());
    dio.interceptors.add(_createErrorInterceptor());
    dio.interceptors.add(_createRetryInterceptor());

    return dio;
  }

  /// 로깅 인터셉터 생성
  static InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _loggerInstance.i('🌐 API Request: ${options.method} ${options.uri}');
        if (options.data != null) {
          _loggerInstance.d('📤 Request Data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        _loggerInstance.i(
          '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        _logError('❌ API Error: ${error.message}', error);
        if (error.response != null) {
          _loggerInstance.w(
            '📥 Error Response: ${error.response?.statusCode} ${error.response?.data}',
          );
        }
        handler.next(error);
      },
    );
  }

  /// 에러 처리 인터셉터 생성
  static InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final processedError = _handleDioException(error);
        handler.reject(processedError);
      },
    );
  }

  /// 재시도 인터셉터 생성
  static InterceptorsWrapper _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
          if (retryCount < AppConstants.maxRetryAttempts) {
            error.requestOptions.extra['retryCount'] = retryCount + 1;

            // 지수 백오프 지연
            final delay = Duration(
              seconds:
                  (AppConstants.exponentialBackoffBase.inSeconds *
                          (retryCount + 1))
                      .toInt(),
            );

            await Future.delayed(delay);

            try {
              final response = await Dio().fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // 재시도 실패 시 원래 에러로 처리
            }
          }
        }

        handler.next(error);
      },
    );
  }

  /// 재시도가 필요한지 확인
  static bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode;

    // 재시도하지 않을 에러들
    if (statusCode == 401 || statusCode == 403 || statusCode == 400) {
      return false;
    }

    // 재시도할 에러들
    if (statusCode == 429 || (statusCode != null && statusCode >= 500)) {
      return true;
    }

    // 네트워크 에러
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }

  /// Dio 예외를 사용자 친화적인 메시지로 변환
  static DioException _handleDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    String message;

    switch (statusCode) {
      case 400:
        message = AppTexts.validationError;
        break;
      case 401:
        message = AppTexts.apiUnauthorized;
        break;
      case 403:
        message = AppTexts.forbiddenError;
        break;
      case 404:
        message = AppTexts.notFoundError;
        break;
      case 429:
        message = AppTexts.apiRateLimit;
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        message = AppTexts.serverError;
        break;
      case null:
        if (error.type == DioExceptionType.connectionTimeout) {
          message = AppTexts.timeoutError;
        } else if (error.type == DioExceptionType.receiveTimeout) {
          message = AppTexts.timeoutError;
        } else if (error.type == DioExceptionType.connectionError) {
          message = AppTexts.connectionError;
        } else {
          message = AppTexts.networkError;
        }
        break;
      default:
        message = AppTexts.apiError;
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: message,
      message: message,
    );
  }

  /// HTTP 상태 코드를 사용자 친화적인 메시지로 변환
  static String getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return AppTexts.validationError;
      case 401:
        return AppTexts.unauthorizedError;
      case 403:
        return AppTexts.forbiddenError;
      case 404:
        return AppTexts.notFoundError;
      case 429:
        return AppTexts.apiRateLimit;
      case 500:
      case 502:
      case 503:
      case 504:
        return AppTexts.serverError;
      default:
        return AppTexts.apiError;
    }
  }

  /// 네트워크 연결 상태 확인
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// API 응답을 Result로 래핑
  static Result<T> wrapApiResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = fromJson(response.body as Map<String, dynamic>);
        return Result.success(AppTexts.success, data);
      } catch (e) {
        return Result.failure('データの解析に失敗しました: ${e.toString()}');
      }
    } else {
      final errorMessage = getHttpErrorMessage(response.statusCode);
      return Result.failure(errorMessage);
    }
  }

  /// Dio 응답을 Result로 래핑
  static Result<T> wrapDioResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      try {
        final data = fromJson(response.data as Map<String, dynamic>);
        return Result.success(AppTexts.success, data);
      } catch (e) {
        return Result.failure('データの解析に失敗しました: ${e.toString()}');
      }
    } else {
      final errorMessage = getHttpErrorMessage(response.statusCode ?? 500);
      return Result.failure(errorMessage);
    }
  }

  /// API 호출을 Result로 래핑 (비동기)
  static Future<Result<T>> wrapApiCall<T>(
    Future<T> Function() apiCall, {
    String? successMessage,
    String? failureMessage,
  }) async {
    try {
      final data = await apiCall();
      return Result.success(successMessage ?? AppTexts.success, data);
    } catch (e) {
      String errorMessage = failureMessage ?? AppTexts.error;

      if (e is DioException) {
        errorMessage = e.message ?? AppTexts.apiError;
      } else if (e is SocketException) {
        errorMessage = AppTexts.connectionError;
      } else if (e is HttpException) {
        errorMessage = AppTexts.networkError;
      }

      return Result.failure(
        errorMessage,
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 요청 헤더 생성
  static Map<String, String> createHeaders({
    String? contentType,
    String? authorization,
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': contentType ?? 'application/json',
      'Accept': 'application/json',
    };

    if (authorization != null) {
      headers['Authorization'] = authorization;
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Bearer 토큰 헤더 생성
  static Map<String, String> createBearerHeaders(String token) {
    return createHeaders(authorization: 'Bearer $token');
  }

  /// API 키 헤더 생성
  static Map<String, String> createApiKeyHeaders(String apiKey) {
    return createHeaders(authorization: apiKey);
  }

  /// 쿼리 파라미터를 URL에 추가
  static String addQueryParams(String baseUrl, Map<String, dynamic> params) {
    if (params.isEmpty) return baseUrl;

    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, dynamic>.from(uri.queryParameters);
    newParams.addAll(params);

    return uri.replace(queryParameters: newParams).toString();
  }

  /// 파일 업로드를 위한 FormData 생성
  static FormData createFormData({
    required Map<String, dynamic> fields,
    List<MapEntry<String, MultipartFile>>? files,
  }) {
    final formData = FormData();

    // 일반 필드 추가
    fields.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    // 파일 추가
    if (files != null) {
      formData.files.addAll(files);
    }

    return formData;
  }

  /// 파일 크기 검증
  static bool isValidFileSize(int fileSizeBytes) {
    return fileSizeBytes <= AppConstants.maxFileSizeBytes;
  }

  /// 이미지 파일 크기 검증
  static bool isValidImageSize(int fileSizeBytes) {
    return fileSizeBytes <= AppConstants.maxImageSizeBytes;
  }

  /// 파일 타입 검증
  static bool isValidFileType(String fileName, List<String> allowedTypes) {
    final extension = fileName.toLowerCase().split('.').last;
    return allowedTypes.any((type) => type.toLowerCase() == '.$extension');
  }

  /// 이미지 파일 타입 검증
  static bool isValidImageType(String fileName) {
    return isValidFileType(fileName, AppConstants.allowedImageTypes);
  }

  /// 에러 로깅
  static void _logError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _loggerInstance.e(message, error: error, stackTrace: stackTrace);

    // Sentry를 사용한 에러 추적
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('service', 'api_utils');
          scope.setExtra('api_error', {
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
          });
        },
      );
    } else {
      Sentry.captureMessage(
        message,
        level: SentryLevel.error,
        withScope: (scope) {
          scope.setTag('service', 'api_utils');
          scope.setExtra('api_error', {
            'timestamp': DateTime.now().toIso8601String(),
          });
        },
      );
    }
  }
}
