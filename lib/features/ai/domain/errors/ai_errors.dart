/// 🎯 AI 관련 에러 타입 정의
///
/// AI 모듈에서 발생할 수 있는 모든 에러 타입을 정의합니다.
/// 공통 에러 처리 시스템을 확장하여 AI 전용 에러를 제공합니다.
library;

import '../../../../shared/shared.dart';

/// AI 관련 기본 예외 클래스 (공통 시스템 확장)
abstract class AiException extends AppException {
  AiException(super.message, {super.code, super.originalError, super.timestamp, super.context});

  @override
  String toString() => 'AiException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 네트워크 관련 에러
class AiNetworkException extends AiException {
  AiNetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() => 'AiNetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// OpenAI API 관련 에러
class AiOpenAIException extends AiException {
  final int? statusCode;
  final String? errorType;

  AiOpenAIException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.statusCode,
    this.errorType,
  });

  @override
  String toString() =>
      'AiOpenAIException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// 콘텐츠 검증 관련 에러
class AiContentValidationException extends AiException {
  final String? reason;
  final double? confidence;

  AiContentValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.reason,
    this.confidence,
  });

  @override
  String toString() =>
      'AiContentValidationException: $message${reason != null ? ' (Reason: $reason)' : ''}';
}

/// 로컬 저장소 관련 에러
class AiLocalStorageException extends AiException {
  final String? operation;
  final String? dataType;

  AiLocalStorageException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.operation,
    this.dataType,
  });

  @override
  String toString() =>
      'AiLocalStorageException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// 캐시 관련 에러
class AiCacheException extends AiException {
  final String? cacheKey;
  final String? operation;

  AiCacheException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.cacheKey,
    this.operation,
  });

  @override
  String toString() => 'AiCacheException: $message${cacheKey != null ? ' (Key: $cacheKey)' : ''}';
}

/// 설정 관련 에러
class AiConfigException extends AiException {
  final String? configKey;
  final String? expectedType;

  AiConfigException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.configKey,
    this.expectedType,
  });

  @override
  String toString() =>
      'AiConfigException: $message${configKey != null ? ' (Config: $configKey)' : ''}';
}

/// 데이터 파싱 관련 에러
class AiDataParsingException extends AiException {
  final String? dataType;
  final String? expectedFormat;

  AiDataParsingException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.dataType,
    this.expectedFormat,
  });

  @override
  String toString() =>
      'AiDataParsingException: $message${dataType != null ? ' (Type: $dataType)' : ''}';
}

/// 사용자 입력 관련 에러
class AiInputValidationException extends AiException {
  final String? field;
  final String? validationRule;

  AiInputValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.field,
    this.validationRule,
  });

  @override
  String toString() =>
      'AiInputValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

/// 비즈니스 로직 관련 에러
class AiBusinessLogicException extends AiException {
  final String? operation;

  AiBusinessLogicException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.operation,
  });

  @override
  String toString() =>
      'AiBusinessLogicException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// AI 에러 핸들러 (공통 시스템 확장)
class AiErrorHandler {
  /// AI 에러를 공통 시스템으로 변환
  static AppException convertToAppException(AiException error) {
    // AI 에러는 이미 AppException을 상속하므로 그대로 반환
    return error;
  }

  /// 에러를 적절한 AiException 타입으로 변환
  static AiException convertToAiException(dynamic error) {
    if (error is AiException) {
      return error;
    }

    if (error is Exception) {
      final message = error.toString();

      // 네트워크 관련 에러 판별
      if (message.contains('network') ||
          message.contains('connection') ||
          message.contains('timeout')) {
        return AiNetworkException(message, originalError: error);
      }

      // OpenAI API 관련 에러 판별
      if (message.contains('OpenAI') ||
          message.contains('API key') ||
          message.contains('401') ||
          message.contains('429')) {
        return AiOpenAIException(message, originalError: error);
      }

      // 콘텐츠 검증 관련 에러 판별
      if (message.contains('content') ||
          message.contains('validation') ||
          message.contains('pet')) {
        return AiContentValidationException(message, originalError: error);
      }

      // 로컬 저장소 관련 에러 판별
      if (message.contains('storage') ||
          message.contains('SharedPreferences') ||
          message.contains('save') ||
          message.contains('load')) {
        return AiLocalStorageException(message, originalError: error);
      }

      // 기본 AiException으로 변환
      return AiBusinessLogicException(message, originalError: error);
    }

    // 알 수 없는 에러
    return AiBusinessLogicException('Unknown error: $error', originalError: error);
  }

  /// 에러 메시지를 사용자 친화적으로 변환
  static String getUserFriendlyMessage(AiException error) {
    switch (error.runtimeType) {
      case AiNetworkException:
        return AiErrorCode.openaiApiServerError.userFriendlyMessage;
      case AiOpenAIException:
        return AiErrorCode.openaiApiServerError.userFriendlyMessage;
      case AiContentValidationException:
        return AiErrorCode.contentNotPetRelated.userFriendlyMessage;
      case AiLocalStorageException:
        return AiErrorCode.chatHistoryLoadFailed.userFriendlyMessage;
      case AiCacheException:
        return AppErrorCode.cacheMiss.userFriendlyMessage;
      case AiConfigException:
        return AppErrorCode.configurationMissing.userFriendlyMessage;
      case AiDataParsingException:
        return AppErrorCode.parsingFailed.userFriendlyMessage;
      case AiInputValidationException:
        return AppErrorCode.validationFailed.userFriendlyMessage;
      case AiBusinessLogicException:
        return AppErrorCode.businessRuleViolation.userFriendlyMessage;
      default:
        return AppErrorCode.unexpectedError.userFriendlyMessage;
    }
  }

  /// 에러 로깅용 상세 정보 추출
  static Map<String, dynamic> getErrorDetails(AiException error) {
    return {
      'type': error.runtimeType.toString(),
      'message': error.message,
      'code': error.code,
      'timestamp': error.timestamp.toIso8601String(),
      'context': error.context,
      'originalError': error.originalError?.toString(),
    };
  }
}
