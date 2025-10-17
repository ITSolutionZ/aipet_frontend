/// 공통 에러 클래스들
///
/// 모든 feature에서 공통으로 사용되는 에러 타입들을 정의합니다.
library;

/// 기본 에러 인터페이스
abstract class AppError {
  /// 사용자에게 표시할 메시지
  String get message;

  /// 에러 코드 (로깅/분석용)
  String get code;

  /// 에러 심각도
  ErrorSeverity get severity;
}

/// 에러 심각도 열거형
enum ErrorSeverity {
  low, // 낮음 (경고)
  medium, // 중간 (일반 에러)
  high, // 높음 (심각한 에러)
  critical, // 치명적 (앱 중단 가능)
}

/// 네트워크 관련 에러
class NetworkError extends AppError {
  final String? details;

  NetworkError({this.details});

  @override
  String get message => 'インターネット接続を確認してください';

  @override
  String get code => 'NETWORK_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;
}

/// 서버 에러 (5xx)
class ServerError extends AppError {
  final int? statusCode;
  final String? details;

  ServerError({this.statusCode, this.details});

  @override
  String get message => 'サーバーエラーが発生しました。しばらく経ってから再試行してください';

  @override
  String get code => 'SERVER_ERROR_${statusCode ?? 'UNKNOWN'}';

  @override
  ErrorSeverity get severity => ErrorSeverity.high;
}

/// 클라이언트 에러 (4xx)
class ClientError extends AppError {
  final int statusCode;
  final String reason;
  final String? details;

  ClientError({required this.statusCode, required this.reason, this.details});

  @override
  String get message => reason;

  @override
  String get code => 'CLIENT_ERROR_$statusCode';

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;
}

/// 인증 에러
class AuthenticationError extends AppError {
  final String reason;
  final String? details;

  AuthenticationError(this.reason, {this.details});

  @override
  String get message => reason;

  @override
  String get code => 'AUTH_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.high;
}

/// 권한 에러
class PermissionError extends AppError {
  final String reason;
  final String? details;

  PermissionError(this.reason, {this.details});

  @override
  String get message => reason;

  @override
  String get code => 'PERMISSION_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;
}

/// 유효성 검사 에러
class ValidationError extends AppError {
  final String field;
  final String reason;
  final String? details;

  ValidationError({required this.field, required this.reason, this.details});

  @override
  String get message => reason;

  @override
  String get code => 'VALIDATION_ERROR_$field';

  @override
  ErrorSeverity get severity => ErrorSeverity.low;
}

/// 파일 관련 에러
class FileError extends AppError {
  final String reason;
  final String? details;

  FileError(this.reason, {this.details});

  @override
  String get message => reason;

  @override
  String get code => 'FILE_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;
}

/// 데이터베이스 에러
class DatabaseError extends AppError {
  final String reason;
  final String? details;

  DatabaseError(this.reason, {this.details});

  @override
  String get message => reason;

  @override
  String get code => 'DATABASE_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.high;
}

/// 비즈니스 로직 에러
class BusinessLogicError extends AppError {
  final String reason;
  final String? details;

  BusinessLogicError(this.reason, {this.details});

  @override
  String get message => reason;

  @override
  String get code => 'BUSINESS_LOGIC_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;
}

/// 타임아웃 에러
class TimeoutError extends AppError {
  final String? details;

  TimeoutError({this.details});

  @override
  String get message => '操作がタイムアウトしました。しばらく経ってから再試行してください';

  @override
  String get code => 'TIMEOUT_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.medium;
}

/// 캐시 에러
class CacheError extends AppError {
  final String reason;
  final String? details;

  CacheError(this.reason, {this.details});

  @override
  String get message => reason;

  @override
  String get code => 'CACHE_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.low;
}

/// 알 수 없는 에러
class UnknownError extends AppError {
  final String? details;

  UnknownError({this.details});

  @override
  String get message => '予期しないエラーが発生しました';

  @override
  String get code => 'UNKNOWN_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.high;
}

/// 에러 유틸리티 클래스
class ErrorUtils {
  /// 에러를 AppError로 변환
  static AppError fromException(Exception exception) {
    final message = exception.toString();

    if (message.contains('SocketException') ||
        message.contains('NetworkException')) {
      return NetworkError();
    }

    if (message.contains('TimeoutException')) {
      return TimeoutError();
    }

    if (message.contains('FormatException')) {
      return ValidationError(field: 'format', reason: '無効な形式です');
    }

    if (message.contains('ArgumentError')) {
      return ValidationError(field: 'argument', reason: '無効な引数です');
    }

    return UnknownError(details: message);
  }

  /// 에러 심각도에 따른 처리 여부 확인
  static bool shouldRetry(AppError error) {
    return error.severity == ErrorSeverity.low ||
        error.severity == ErrorSeverity.medium;
  }

  /// 에러 로깅 필요 여부 확인
  static bool shouldLog(AppError error) {
    return error.severity == ErrorSeverity.medium ||
        error.severity == ErrorSeverity.high ||
        error.severity == ErrorSeverity.critical;
  }

  /// 사용자에게 표시할 에러 메시지 생성
  static String getUserFriendlyMessage(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
        return error.message;
      case ErrorSeverity.medium:
        return '${error.message}。しばらく経ってから再試行してください。';
      case ErrorSeverity.high:
        return '${error.message}。アプリを再起動してください。';
      case ErrorSeverity.critical:
        return '重大なエラーが発生しました。サポートにお問い合わせください。';
    }
  }
}
