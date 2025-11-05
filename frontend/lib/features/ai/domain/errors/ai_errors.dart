library;

import '../../../../shared/shared.dart';
/// 🎯 AI 관련 에러 타입 정의
///
/// AI 모듈에서 발생할 수 있는 모든 에러 타입을 정의합니다.
/// 공통 에러 처리 시스템을 확장하여 AI 전용 에러를 제공합니다.


/// AI 관련 기본 예외 클래스 (공통 시스템 확장)
abstract class AiException extends AppException {
  AiException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() =>
      'AiException: $message${code != null ? ' (Code: $code)' : ''}';
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
  String toString() =>
      'AiNetworkException: $message${code != null ? ' (Code: $code)' : ''}';
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
  AiContentValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() => 'AiContentValidationException: $message';
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
  String toString() =>
      'AiCacheException: $message${cacheKey != null ? ' (Key: $cacheKey)' : ''}';
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

// ✅ AiErrorHandler 클래스 제거 완료
// 대신 다음을 사용:
// - Shared ErrorHandlingService: 일반 에러 처리
// - Shared ApiErrorHandler: API 에러 처리
// - AiException: AI feature 특화 에러 타입 유지 (AppException 상속)
// - Result<T> 패턴: 타입 안전한 에러 핸들링

/// AI feature에서 에러 처리 시 다음 패턴 사용:
/// ```dart
///
/// try {
///   // AI 작업
/// } catch (error, stackTrace) {
///   await ErrorHandlingService.handleAsync(
///     Future.error(error, stackTrace),
///     context: 'AI.Operation',
///     showUserMessage: true,
///   );
/// }
/// ```
