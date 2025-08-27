import 'package:flutter/foundation.dart';

/// 애플리케이션 전체의 에러를 관리하는 서비스
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  /// 에러를 처리하고 로깅합니다
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    // 로그 출력
    if (kDebugMode) {
      debugPrint('🔴 Error: $error');
      if (stackTrace != null) {
        debugPrint('📍 StackTrace: $stackTrace');
      }
    }

    // 프로덕션에서는 Crashlytics 등 외부 서비스로 전송
    _reportCrash(error, stackTrace, ErrorSeverity.medium);
  }

  /// 사용자에게 보여줄 에러 메시지를 생성합니다
  String getUserFriendlyMessage(dynamic error) {
    if (error is NetworkException) {
      return 'ネットワーク接続を確認してください。';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is UnauthorizedException) {
      return 'ログインが必要です。';
    } else if (error is DatabaseException) {
      return 'データ保存中にエラーが発生しました。';
    } else if (error is FileException) {
      return 'ファイル処理中にエラーが発生しました。';
    } else if (error is TimeoutException) {
      return 'リクエスト時間が超過しました。';
    } else if (error is ServerException) {
      return 'サーバーエラーが発生しました。しばらくしてから再度お試しください。';
    } else {
      return '一時的なエラーが発生しました。しばらくしてから再度お試しください。';
    }
  }

  /// 에러 심각도에 따른 처리
  void handleErrorWithSeverity(
    dynamic error,
    ErrorSeverity severity, [
    StackTrace? stackTrace,
  ]) {
    switch (severity) {
      case ErrorSeverity.low:
        _handleLowSeverityError(error, stackTrace);
        break;
      case ErrorSeverity.medium:
        _handleMediumSeverityError(error, stackTrace);
        break;
      case ErrorSeverity.high:
        _handleHighSeverityError(error, stackTrace);
        break;
      case ErrorSeverity.critical:
        _handleCriticalError(error, stackTrace);
        break;
    }
  }

  void _handleLowSeverityError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('🟡 Low Severity Error: $error');
    }
  }

  void _handleMediumSeverityError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('🟠 Medium Severity Error: $error');
    }
    // Analytics tracking (목업 구현)
    _trackErrorAnalytics(error, ErrorSeverity.medium);
  }

  void _handleHighSeverityError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('🔴 High Severity Error: $error');
      if (stackTrace != null) {
        debugPrint('📍 StackTrace: $stackTrace');
      }
    }
    // Crash reporting (목업 구현)
    _reportCrash(error, stackTrace, ErrorSeverity.high);
  }

  void _handleCriticalError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('💀 Critical Error: $error');
      if (stackTrace != null) {
        debugPrint('📍 StackTrace: $stackTrace');
      }
    }
    // Immediate crash reporting and user notification (목업 구현)
    _reportCrash(error, stackTrace, ErrorSeverity.critical);
  }

  /// Crash reporting (목업 구현)
  void _reportCrash(
    dynamic error,
    StackTrace? stackTrace,
    ErrorSeverity severity,
  ) {
    if (kDebugMode) {
      debugPrint('📊 Crash Report - Severity: $severity');
      debugPrint('📊 Error: $error');
      if (stackTrace != null) {
        debugPrint('📊 StackTrace: $stackTrace');
      }
      debugPrint('📊 Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('📊 App Version: 1.0.0'); // 실제로는 앱 버전 정보 사용
      debugPrint('📊 Platform: ${defaultTargetPlatform.name}');
    }

    // 프로덕션에서는 Firebase Crashlytics, Sentry 등으로 전송
    // _sendToCrashReportingService(error, stackTrace, severity);
  }

  /// Analytics tracking (목업 구현)
  void _trackErrorAnalytics(dynamic error, ErrorSeverity severity) {
    if (kDebugMode) {
      debugPrint('📈 Analytics - Error Type: ${error.runtimeType}');
      debugPrint('📈 Analytics - Severity: $severity');
      debugPrint(
        '📈 Analytics - Timestamp: ${DateTime.now().toIso8601String()}',
      );
    }

    // 프로덕션에서는 Firebase Analytics, Mixpanel 등으로 전송
    // _sendToAnalyticsService(error, severity);
  }
}

/// 에러 심각도 레벨
enum ErrorSeverity {
  low, // 경고 수준
  medium, // 중간 수준
  high, // 높은 수준
  critical, // 치명적 수준
}

/// 네트워크 관련 에러
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 유효성 검사 에러
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// 인증 관련 에러
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// 데이터베이스 관련 에러
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// 파일 처리 관련 에러
class FileException implements Exception {
  final String message;
  FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}

/// 타임아웃 관련 에러
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// 서버 관련 에러
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
