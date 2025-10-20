import 'package:aipet_frontend/features/ai/domain/errors/ai_errors.dart';
import 'package:aipet_frontend/features/auth/domain/auth_error.dart';
import 'package:aipet_frontend/shared/core/services/common_error_service.dart';
import 'package:aipet_frontend/shared/core/services/error_handler_service.dart';

/// 🎯 통합 에러 핸들러
///
/// AI와 Auth 기능의 에러 처리를 통합하여 일관된 에러 관리를 제공합니다.
/// 기존의 AiException과 AuthError를 공통 ErrorHandlerService로 변환합니다.
class UnifiedErrorHandler {
  static final ErrorHandlerService _errorHandler = ErrorHandlerService();

  /// AI 에러를 공통 에러로 변환
  static Future<void> handleAiError(
    AiException error, {
    Map<String, dynamic>? context,
  }) async {
    final severity = _mapAiErrorToSeverity(error);
    final type = _mapAiErrorToType(error);

    await _errorHandler.handleError(
      error,
      message: error.message,
      severity: severity,
      type: type,
      context: {'service': 'ai', 'errorCode': error.code, ...?context},
    );
  }

  /// Auth 에러를 공통 에러로 변환
  static Future<void> handleAuthError(
    AuthError error, {
    Map<String, dynamic>? context,
  }) async {
    final severity = _mapAuthErrorToSeverity(error);
    final type = _mapAuthErrorToType(error);

    await _errorHandler.handleError(
      error,
      message: error.message,
      severity: severity,
      type: type,
      context: {'service': 'auth', 'errorCode': error.code, ...?context},
    );
  }

  /// AI 에러 심각도 매핑
  static ErrorSeverity _mapAiErrorToSeverity(AiException error) {
    if (error is AiOpenAIException) {
      return ErrorSeverity.high; // API 에러는 높은 심각도
    } else if (error is AiNetworkException) {
      return ErrorSeverity.medium; // 네트워크 에러는 중간 심각도
    } else if (error is AiContentValidationException) {
      return ErrorSeverity.low; // 콘텐츠 검증 에러는 낮은 심각도
    } else if (error is AiLocalStorageException) {
      return ErrorSeverity.medium; // 저장소 에러는 중간 심각도
    }
    return ErrorSeverity.medium;
  }

  /// AI 에러 타입 매핑
  static ErrorType _mapAiErrorToType(AiException error) {
    if (error is AiNetworkException) {
      return ErrorType.network;
    } else if (error is AiOpenAIException) {
      return ErrorType.authentication; // API 키 관련
    } else if (error is AiContentValidationException) {
      return ErrorType.validation;
    } else if (error is AiLocalStorageException) {
      return ErrorType.database; // 로컬 저장소
    }
    return ErrorType.unknown;
  }

  /// Auth 에러 심각도 매핑
  static ErrorSeverity _mapAuthErrorToSeverity(AuthError error) {
    if (error is NetworkError) {
      return ErrorSeverity.medium;
    } else if (error is AuthenticationError) {
      return ErrorSeverity.high;
    } else if (error is TokenError) {
      return ErrorSeverity.high;
    } else if (error is ServerError) {
      return ErrorSeverity.high;
    } else if (error is ValidationError) {
      return ErrorSeverity.low;
    } else if (error is StorageError) {
      return ErrorSeverity.medium;
    }
    return ErrorSeverity.medium;
  }

  /// Auth 에러 타입 매핑
  static ErrorType _mapAuthErrorToType(AuthError error) {
    if (error is NetworkError) {
      return ErrorType.network;
    } else if (error is AuthenticationError || error is TokenError) {
      return ErrorType.authentication;
    } else if (error is ValidationError) {
      return ErrorType.validation;
    } else if (error is StorageError) {
      return ErrorType.database;
    } else if (error is ServerError) {
      return ErrorType.network; // 서버 에러는 네트워크 타입으로 분류
    }
    return ErrorType.unknown;
  }

  /// 통합 에러 처리 (AI 또는 Auth 에러 자동 감지)
  static Future<void> handleUnifiedError(
    dynamic error, {
    Map<String, dynamic>? context,
  }) async {
    if (error is AiException) {
      await handleAiError(error, context: context);
    } else if (error is AuthError) {
      await handleAuthError(error, context: context);
    } else {
      // 기타 에러는 공통 에러 핸들러로 처리
      await _errorHandler.handleError(
        error,
        context: {'service': 'unknown', ...?context},
      );
    }
  }

  /// 에러 히스토리 조회 (AI/Auth 구분)
  static List<ErrorInfo> getErrorHistoryByService(String service) {
    return _errorHandler
        .getErrorHistory()
        .where((error) => error.context?['service'] == service)
        .toList();
  }

  /// AI 에러 통계
  static Map<String, int> getAiErrorStatistics() {
    final aiErrors = getErrorHistoryByService('ai');
    return {
      'total_ai_errors': aiErrors.length,
      'openai_errors': aiErrors
          .where(
            (e) =>
                e.context?['errorCode']?.toString().contains('OPENAI') ?? false,
          )
          .length,
      'network_errors': aiErrors
          .where((e) => e.type == ErrorType.network)
          .length,
      'validation_errors': aiErrors
          .where((e) => e.type == ErrorType.validation)
          .length,
    };
  }

  /// Auth 에러 통계
  static Map<String, int> getAuthErrorStatistics() {
    final authErrors = getErrorHistoryByService('auth');
    return {
      'total_auth_errors': authErrors.length,
      'authentication_errors': authErrors
          .where((e) => e.type == ErrorType.authentication)
          .length,
      'network_errors': authErrors
          .where((e) => e.type == ErrorType.network)
          .length,
      'validation_errors': authErrors
          .where((e) => e.type == ErrorType.validation)
          .length,
    };
  }
}
