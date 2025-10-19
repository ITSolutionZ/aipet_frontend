import 'package:flutter/foundation.dart';

/// 🔒 환경별 설정 관리 시스템
///
/// 개발/스테이징/프로덕션 환경을 안전하게 구분하고 관리합니다.
class EnvironmentConfig {
  /// 현재 환경 타입
  static EnvironmentType get currentEnvironment {
    if (kReleaseMode) {
      return EnvironmentType.production;
    } else if (kDebugMode) {
      return EnvironmentType.development;
    } else {
      return EnvironmentType.staging;
    }
  }

  /// 개발 환경 여부
  static bool get isDevelopment =>
      currentEnvironment == EnvironmentType.development;

  /// 스테이징 환경 여부
  static bool get isStaging => currentEnvironment == EnvironmentType.staging;

  /// 프로덕션 환경 여부
  static bool get isProduction =>
      currentEnvironment == EnvironmentType.production;

  /// Mock 모드 허용 여부
  ///
  /// 개발 환경에서만 Mock 모드 사용을 허용합니다.
  static bool get isMockModeAllowed {
    return isDevelopment && _isMockModeEnabled;
  }

  /// Mock 모드 활성화 여부 (환경 변수로 제어)
  static bool get _isMockModeEnabled {
    const mockMode = String.fromEnvironment('MOCK_MODE', defaultValue: 'false');
    return mockMode.toLowerCase() == 'true';
  }

  /// 디버그 로깅 허용 여부
  ///
  /// 프로덕션 환경에서는 디버그 로깅을 비활성화합니다.
  static bool get isDebugLoggingAllowed {
    return !isProduction;
  }

  /// API 엔드포인트 URL
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'http://localhost:3000/api',
        );
      case EnvironmentType.staging:
        return const String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: 'https://staging-api.aipet.com/api',
        );
      case EnvironmentType.production:
        return const String.fromEnvironment(
          'PROD_API_URL',
          defaultValue: 'https://api.aipet.com/api',
        );
    }
  }

  /// Firebase 프로젝트 ID
  static String get firebaseProjectId {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return const String.fromEnvironment(
          'DEV_FIREBASE_PROJECT_ID',
          defaultValue: 'aipet-dev',
        );
      case EnvironmentType.staging:
        return const String.fromEnvironment(
          'STAGING_FIREBASE_PROJECT_ID',
          defaultValue: 'aipet-staging',
        );
      case EnvironmentType.production:
        return const String.fromEnvironment(
          'PROD_FIREBASE_PROJECT_ID',
          defaultValue: 'aipet-prod',
        );
    }
  }

  /// OpenAI API 키
  static String get openaiApiKey {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return const String.fromEnvironment(
          'DEV_OPENAI_API_KEY',
          defaultValue: '',
        );
      case EnvironmentType.staging:
        return const String.fromEnvironment(
          'STAGING_OPENAI_API_KEY',
          defaultValue: '',
        );
      case EnvironmentType.production:
        return const String.fromEnvironment(
          'PROD_OPENAI_API_KEY',
          defaultValue: '',
        );
    }
  }

  /// 로그 레벨 설정
  static LogLevel get logLevel {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return LogLevel.debug;
      case EnvironmentType.staging:
        return LogLevel.info;
      case EnvironmentType.production:
        return LogLevel.warning;
    }
  }

  /// 보안 검증 활성화 여부
  static bool get isSecurityValidationEnabled {
    return isProduction || isStaging;
  }

  /// 성능 모니터링 활성화 여부
  static bool get isPerformanceMonitoringEnabled {
    return isProduction;
  }

  /// 에러 리포팅 활성화 여부
  static bool get isErrorReportingEnabled {
    return isProduction || isStaging;
  }

  /// 캐시 TTL 설정 (초)
  static int get cacheTtlSeconds {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return 60; // 1분
      case EnvironmentType.staging:
        return 300; // 5분
      case EnvironmentType.production:
        return 1800; // 30분
    }
  }

  /// API 타임아웃 설정 (초)
  static int get apiTimeoutSeconds {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return 30;
      case EnvironmentType.staging:
        return 20;
      case EnvironmentType.production:
        return 15;
    }
  }

  /// 재시도 횟수 설정
  static int get maxRetryAttempts {
    switch (currentEnvironment) {
      case EnvironmentType.development:
        return 5;
      case EnvironmentType.staging:
        return 3;
      case EnvironmentType.production:
        return 2;
    }
  }

  /// 환경별 설정 검증
  static void validateConfiguration() {
    if (isProduction) {
      _validateProductionConfig();
    } else if (isStaging) {
      _validateStagingConfig();
    }
  }

  /// 프로덕션 설정 검증
  static void _validateProductionConfig() {
    // 필수 환경 변수 검증
    if (openaiApiKey.isEmpty) {
      throw const EnvironmentConfigException(
        'OpenAI API key is not configured for production',
        code: 'MISSING_OPENAI_API_KEY',
      );
    }

    if (firebaseProjectId.isEmpty) {
      throw const EnvironmentConfigException(
        'Firebase project ID is not configured for production',
        code: 'MISSING_FIREBASE_PROJECT_ID',
      );
    }

    // Mock 모드 비활성화 검증
    if (_isMockModeEnabled) {
      throw const EnvironmentConfigException(
        'Mock mode is not allowed in production environment',
        code: 'MOCK_MODE_FORBIDDEN_IN_PRODUCTION',
      );
    }
  }

  /// 스테이징 설정 검증
  static void _validateStagingConfig() {
    // 스테이징 환경에서의 기본 검증
    if (apiBaseUrl.contains('localhost')) {
      throw const EnvironmentConfigException(
        'Localhost API URL is not allowed in staging environment',
        code: 'INVALID_STAGING_API_URL',
      );
    }
  }

  /// 환경 정보 출력 (디버그용)
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'environment': currentEnvironment.name,
      'isDevelopment': isDevelopment,
      'isStaging': isStaging,
      'isProduction': isProduction,
      'isMockModeAllowed': isMockModeAllowed,
      'isDebugLoggingAllowed': isDebugLoggingAllowed,
      'apiBaseUrl': apiBaseUrl,
      'firebaseProjectId': firebaseProjectId,
      'logLevel': logLevel.name,
      'cacheTtlSeconds': cacheTtlSeconds,
      'apiTimeoutSeconds': apiTimeoutSeconds,
      'maxRetryAttempts': maxRetryAttempts,
    };
  }
}

/// 환경 타입 열거형
enum EnvironmentType { development, staging, production }

/// 로그 레벨 열거형
enum LogLevel { debug, info, warning, error }

/// 환경 설정 예외 클래스
class EnvironmentConfigException implements Exception {
  final String message;
  final String code;

  const EnvironmentConfigException(this.message, {required this.code});

  @override
  String toString() => 'EnvironmentConfigException($code): $message';
}
