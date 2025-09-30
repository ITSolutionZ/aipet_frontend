/// 🎯 공통 앱 예외 클래스 계층구조
///
/// 모든 Feature에서 일관된 에러 처리를 위한 공통 예외 클래스들을 정의합니다.
/// 타입 안전성과 명확한 에러 분류를 제공합니다.
library;

/// 공통 앱 예외 기본 클래스
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  AppException(this.message, {this.code, this.originalError, DateTime? timestamp, this.context})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }

  /// 에러 세부 정보를 Map으로 반환
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'originalError': originalError?.toString(),
    };
  }
}

/// 네트워크 관련 예외
class NetworkException extends AppException {
  NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// 인증 관련 예외
class AuthenticationException extends AppException {
  AuthenticationException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

/// 권한 관련 예외
class AuthorizationException extends AppException {
  AuthorizationException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() => 'AuthorizationException: $message';
}

/// 데이터 검증 관련 예외
class ValidationException extends AppException {
  final String? field;
  final String? validationRule;

  ValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.field,
    this.validationRule,
  });

  @override
  String toString() => 'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

/// 데이터 저장소 관련 예외
class StorageException extends AppException {
  final String? operation;
  final String? dataType;

  StorageException(
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
      'StorageException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// 캐시 관련 예외
class CacheException extends AppException {
  final String? cacheKey;
  final String? operation;

  CacheException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.cacheKey,
    this.operation,
  });

  @override
  String toString() => 'CacheException: $message${cacheKey != null ? ' (Key: $cacheKey)' : ''}';
}

/// 설정 관련 예외
class ConfigurationException extends AppException {
  final String? configKey;
  final String? expectedType;

  ConfigurationException(
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
      'ConfigurationException: $message${configKey != null ? ' (Config: $configKey)' : ''}';
}

/// 데이터 파싱 관련 예외
class DataParsingException extends AppException {
  final String? dataType;
  final String? expectedFormat;

  DataParsingException(
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
      'DataParsingException: $message${dataType != null ? ' (Type: $dataType)' : ''}';
}

/// 비즈니스 로직 관련 예외
class BusinessLogicException extends AppException {
  final String? operation;

  BusinessLogicException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.operation,
  });

  @override
  String toString() =>
      'BusinessLogicException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// 외부 API 관련 예외
class ExternalApiException extends AppException {
  final int? statusCode;
  final String? endpoint;
  final String? httpMethod;

  ExternalApiException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
    this.statusCode,
    this.endpoint,
    this.httpMethod,
  });

  @override
  String toString() =>
      'ExternalApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// 예상치 못한 예외
class UnexpectedException extends AppException {
  UnexpectedException(
    super.message, {
    super.code,
    super.originalError,
    super.timestamp,
    super.context,
  });

  @override
  String toString() => 'UnexpectedException: $message';
}
