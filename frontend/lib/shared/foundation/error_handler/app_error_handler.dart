/// 🎯 공통 에러 핸들러
///
/// 모든 Feature에서 일관된 에러 처리를 위한 공통 에러 핸들러입니다.
/// 에러 로깅, 사용자 친화적 메시지 변환, 복구 전략 등을 제공합니다.
library;

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/foundation/errors/errors.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';

/// 공통 에러 핸들러
class AppErrorHandler extends BaseLoggingService {
  static AppErrorHandler? _instance;

  AppErrorHandler._() : super('app_error_handler');

  static AppErrorHandler get instance {
    _instance ??= AppErrorHandler._();
    return _instance!;
  }

  /// 에러를 적절한 AppException 타입으로 변환
  static AppException convertToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is Exception) {
      final message = error.toString();

      // 네트워크 관련 에러 판별
      if (message.contains('network') ||
          message.contains('connection') ||
          message.contains('timeout') ||
          message.contains('SocketException') ||
          message.contains('HttpException')) {
        return NetworkException(message, originalError: error);
      }

      // 인증 관련 에러 판별
      if (message.contains('auth') ||
          message.contains('FirebaseAuth') ||
          message.contains('401') ||
          message.contains('Unauthorized')) {
        return AuthenticationException(message, originalError: error);
      }

      // 권한 관련 에러 판별
      if (message.contains('permission') ||
          message.contains('403') ||
          message.contains('Forbidden')) {
        return AuthorizationException(message, originalError: error);
      }

      // 검증 관련 에러 판별
      if (message.contains('validation') ||
          message.contains('invalid') ||
          message.contains('format')) {
        return ValidationException(message, originalError: error);
      }

      // 저장소 관련 에러 판별
      if (message.contains('storage') ||
          message.contains('SharedPreferences') ||
          message.contains('save') ||
          message.contains('load') ||
          message.contains('delete')) {
        return StorageException(message, originalError: error);
      }

      // 캐시 관련 에러 판별
      if (message.contains('cache') || message.contains('expired')) {
        return CacheException(message, originalError: error);
      }

      // 설정 관련 에러 판별
      if (message.contains('config') || message.contains('setting')) {
        return ConfigurationException(message, originalError: error);
      }

      // 데이터 파싱 관련 에러 판별
      if (message.contains('parsing') ||
          message.contains('json') ||
          message.contains('format')) {
        return DataParsingException(message, originalError: error);
      }

      // 기본 BusinessLogicException으로 변환
      return BusinessLogicException(message, originalError: error);
    }

    // 알 수 없는 에러
    return UnexpectedException('Unknown error: $error', originalError: error);
  }

  /// 에러 메시지를 사용자 친화적으로 변환
  static String getUserFriendlyMessage(AppException error) {
    switch (error.runtimeType) {
      case NetworkException _:
        return AppErrorCode.networkConnectionFailed.userFriendlyMessage;
      case AuthenticationException _:
        return AppErrorCode.authenticationFailed.userFriendlyMessage;
      case AuthorizationException _:
        return AppErrorCode.authorizationDenied.userFriendlyMessage;
      case ValidationException _:
        return AppErrorCode.validationFailed.userFriendlyMessage;
      case StorageException _:
        return AppErrorCode.storageReadFailed.userFriendlyMessage;
      case CacheException _:
        return AppErrorCode.cacheMiss.userFriendlyMessage;
      case ConfigurationException _:
        return AppErrorCode.configurationMissing.userFriendlyMessage;
      case DataParsingException _:
        return AppErrorCode.parsingFailed.userFriendlyMessage;
      case BusinessLogicException _:
        return AppErrorCode.businessRuleViolation.userFriendlyMessage;
      case ExternalApiException _:
        return AppErrorCode.apiRequestFailed.userFriendlyMessage;
      case UnexpectedException _:
        return AppErrorCode.unexpectedError.userFriendlyMessage;
      default:
        return AppErrorCode.unknownError.userFriendlyMessage;
    }
  }

  /// 에러 로깅용 상세 정보 추출
  static Map<String, dynamic> getErrorDetails(AppException error) {
    return {
      'type': error.runtimeType.toString(),
      'message': error.message,
      'code': error.code,
      'timestamp': error.timestamp.toIso8601String(),
      'context': error.context,
      'originalError': error.originalError?.toString(),
      'stackTrace': error.originalError is Exception
          ? (error.originalError as Exception).toString()
          : null,
    };
  }

  /// 에러를 Result로 변환
  static Result toResult<T>(AppException error) {
    return Result.fromException(error);
  }

  /// 예외를 Result로 변환
  static Result exceptionToResult<T>(Exception exception) {
    final appException = convertToAppException(exception);
    return Result.fromException(appException);
  }

  /// 동적 에러를 Result로 변환
  static Result dynamicToResult<T>(dynamic error) {
    if (error is AppException) {
      return Result.fromException(error);
    } else if (error is Exception) {
      final appException = convertToAppException(error);
      return Result.fromException(appException);
    } else {
      final appException = UnexpectedException('Unexpected error: $error');
      return Result.fromException(appException as AppException);
    }
  }

  /// 에러 복구 전략
  static Future<Result> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Exception)? retryCondition,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final result = await operation();
        return Result.success('Success', result);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        // 재시도 조건 확인
        if (retryCondition != null && !retryCondition(lastException)) {
          break;
        }

        // 마지막 시도가 아니면 대기
        if (attempts < maxRetries) {
          await Future.delayed(delay * attempts); // 지수 백오프
        }
      }
    }

    return Result.fromException(lastException!);
  }

  /// 에러 복구 전략 (동기)
  static Result withRetrySync<T>(
    T Function() operation, {
    int maxRetries = 3,
    bool Function(Exception)? retryCondition,
  }) {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final result = operation();
        return Result.success('Success', result);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        // 재시도 조건 확인
        if (retryCondition != null && !retryCondition(lastException)) {
          break;
        }
      }
    }

    return Result.fromException(lastException!);
  }

  /// 에러 처리 및 로깅
  void handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? additionalContext,
  }) {
    final appException = convertToAppException(error);
    final errorDetails = getErrorDetails(appException);

    // 추가 컨텍스트 병합
    if (context != null || additionalContext != null) {
      errorDetails['handlingContext'] = {
        'context': context,
        'additionalContext': additionalContext,
      };
    }

    // 에러 로깅
    logError('Error handled: ${appException.message}', appException);
    logDebug('Error details: $errorDetails');

    // 필요시 추가 처리 (크래시 리포팅, 분석 등)
    _reportError(appException, errorDetails);
  }

  /// 에러 리포팅 (크래시 리포팅 서비스 연동)
  void _reportError(AppException error, Map<String, dynamic> details) {
    // Firebase Crashlytics, Sentry 등 크래시 리포팅 서비스 연동
    try {
      // Firebase Crashlytics 연동 (필요시 구현)
      // FirebaseCrashlytics.instance.recordError(error, StackTrace.current);

      // Sentry 연동 (필요시 구현)
      // Sentry.captureException(error);

      // 기본 로깅 수행
      logInfo('Error reported to crash analytics: ${error.runtimeType}');
      logError('Error details for reporting: $details', error);
    } catch (reportingError) {
      logError(
        'Failed to report error to analytics: $reportingError',
        reportingError,
      );
    }
  }

  /// 에러 메트릭 수집
  void collectErrorMetrics(AppException error) {
    // 에러 메트릭 수집 (Firebase Analytics 등)
    try {
      // Firebase Analytics 연동 (필요시 구현)
      // FirebaseAnalytics.instance.logEvent(
      //   name: 'error_occurred',
      //   parameters: {
      //     'error_type': error.runtimeType.toString(),
      //     'error_code': error.code,
      //     'error_message': error.message,
      //   },
      // );

      // 기본 메트릭 로깅
      logDebug('Error metrics collected: ${error.runtimeType}');
      logInfo(
        'Error metrics: type=${error.runtimeType}, code=${error.code}, message=${error.message}',
      );
    } catch (metricsError) {
      logError('Failed to collect error metrics: $metricsError', metricsError);
    }
  }

  /// 에러 발생 빈도 추적
  final Map<String, int> _errorFrequency = {};

  void trackErrorFrequency(AppException error) {
    final key = error.runtimeType.toString();
    _errorFrequency[key] = (_errorFrequency[key] ?? 0) + 1;

    logDebug('Error frequency updated: $key = ${_errorFrequency[key]}');
  }

  /// 에러 발생 빈도 조회
  Map<String, int> get errorFrequency => Map.unmodifiable(_errorFrequency);

  /// 에러 빈도 초기화
  void clearErrorFrequency() {
    _errorFrequency.clear();
    logInfo('Error frequency cleared');
  }
}

/// 에러 처리 확장 메서드들
extension ErrorHandlingExtensions<T> on Future<T> Function() {
  /// Future를 Result로 래핑하고 에러 처리
  Future<Result> toResult() async {
    try {
      final result = await this();
      return Result.success('Success', result);
    } catch (e) {
      return AppErrorHandler.dynamicToResult(e);
    }
  }

  /// 재시도 로직과 함께 실행
  Future<Result> withRetry({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Exception)? retryCondition,
  }) async {
    return AppErrorHandler.withRetry(
      this,
      maxRetries: maxRetries,
      delay: delay,
      retryCondition: retryCondition,
    );
  }
}

/// 동기 함수 에러 처리 확장 메서드들
extension SyncErrorHandlingExtensions<T> on T Function() {
  /// 동기 함수를 Result로 래핑하고 에러 처리
  Result toResult() {
    try {
      final result = this();
      return Result.success('Success', result);
    } catch (e) {
      return AppErrorHandler.dynamicToResult(e);
    }
  }

  /// 재시도 로직과 함께 실행
  Result withRetry({
    int maxRetries = 3,
    bool Function(Exception)? retryCondition,
  }) {
    return AppErrorHandler.withRetrySync(
      this,
      maxRetries: maxRetries,
      retryCondition: retryCondition,
    );
  }
}
