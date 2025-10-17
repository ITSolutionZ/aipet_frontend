/// 인증 관련 에러를 타입 안전하게 분류
sealed class AuthError {
  const AuthError();

  /// 사용자에게 표시할 메시지
  String get message;

  /// 에러 코드 (로깅/분석용)
  String get code;
}

/// 네트워크 관련 에러
class NetworkError extends AuthError {
  const NetworkError();

  @override
  String get message => 'インターネット接続を確認してください';

  @override
  String get code => 'NETWORK_ERROR';
}

/// 유효성 검사 에러
class ValidationError extends AuthError {
  final String field;
  final String reason;

  const ValidationError({required this.field, required this.reason});

  @override
  String get message => reason;

  @override
  String get code => 'VALIDATION_ERROR_$field';
}

/// 인증 실패 에러
class AuthenticationError extends AuthError {
  final String reason;

  const AuthenticationError(this.reason);

  @override
  String get message => reason;

  @override
  String get code => 'AUTH_ERROR';
}

/// 서버 에러 (5xx)
class ServerError extends AuthError {
  final int? statusCode;

  const ServerError({this.statusCode});

  @override
  String get message => 'サーバーエラーが発生しました。しばらく経ってから再試行してください';

  @override
  String get code => 'SERVER_ERROR_${statusCode ?? 'UNKNOWN'}';
}

/// 클라이언트 에러 (4xx)
class ClientError extends AuthError {
  final int statusCode;
  final String reason;

  const ClientError({required this.statusCode, required this.reason});

  @override
  String get message => reason;

  @override
  String get code => 'CLIENT_ERROR_$statusCode';
}

/// 토큰 관련 에러
class TokenError extends AuthError {
  final TokenErrorType type;

  const TokenError(this.type);

  @override
  String get message {
    switch (type) {
      case TokenErrorType.expired:
        return 'セッションが期限切れです。再度ログインしてください';
      case TokenErrorType.invalid:
        return '認証情報が不正です。再度ログインしてください';
      case TokenErrorType.missing:
        return 'ログインが必要です';
      case TokenErrorType.refreshFailed:
        return 'セッションの更新に失敗しました。再度ログインしてください';
    }
  }

  @override
  String get code => 'TOKEN_ERROR_${type.name.toUpperCase()}';
}

enum TokenErrorType { expired, invalid, missing, refreshFailed }

/// 저장소 관련 에러
class StorageError extends AuthError {
  final String operation;

  const StorageError(this.operation);

  @override
  String get message => 'データの保存に失敗しました';

  @override
  String get code => 'STORAGE_ERROR_$operation';
}

/// 알 수 없는 에러
class UnknownError extends AuthError {
  final String details;

  const UnknownError(this.details);

  @override
  String get message => '予期しないエラーが発生しました';

  @override
  String get code => 'UNKNOWN_ERROR';
}

/// Exception을 AuthError로 변환하는 유틸리티
///
/// 다양한 종류의 예외를 AuthError 타입으로 변환하여
/// 일관된 에러 처리를 가능하게 합니다.
class AuthErrorMapper {
  /// Exception을 AuthError로 변환
  ///
  /// [error] 변환할 예외 객체
  ///
  /// Returns: 해당하는 AuthError 타입
  static AuthError fromException(Object error) {
    // 이미 AuthError인 경우 그대로 반환
    if (error is AuthError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    // 네트워크 관련 에러 감지
    if (_isNetworkError(errorString)) {
      return const NetworkError();
    }

    // HTTP 상태 코드별 에러 분류
    final httpError = _parseHttpError(errorString);
    if (httpError != null) {
      return httpError;
    }

    // 토큰 관련 에러 감지
    final tokenError = _parseTokenError(errorString);
    if (tokenError != null) {
      return tokenError;
    }

    // 기본적으로 UnknownError로 처리
    return UnknownError(error.toString());
  }

  /// 네트워크 에러인지 확인
  ///
  /// [errorString] 에러 메시지 (소문자)
  ///
  /// Returns: 네트워크 에러 여부
  static bool _isNetworkError(String errorString) {
    final networkKeywords = [
      'network',
      'connection',
      'socket',
      'timeout',
      'unreachable',
      'dns',
      'no internet',
      'connection refused',
      'connection reset',
    ];

    return networkKeywords.any((keyword) => errorString.contains(keyword));
  }

  /// HTTP 에러 파싱
  ///
  /// [errorString] 에러 메시지 (소문자)
  ///
  /// Returns: HTTP 에러 또는 null
  static AuthError? _parseHttpError(String errorString) {
    // HTTP 상태 코드 추출
    final statusCodeMatch = RegExp(r'(\d{3})').firstMatch(errorString);
    if (statusCodeMatch != null) {
      final statusCode = int.tryParse(statusCodeMatch.group(1)!);
      if (statusCode != null) {
        if (statusCode >= 500) {
          return ServerError(statusCode: statusCode);
        } else if (statusCode >= 400) {
          return ClientError(
            statusCode: statusCode,
            reason: _getHttpErrorMessage(statusCode),
          );
        }
      }
    }

    // HTTP 키워드 기반 분류
    if (errorString.contains('http') || errorString.contains('api')) {
      return const ServerError();
    }

    return null;
  }

  /// 토큰 관련 에러 파싱
  ///
  /// [errorString] 에러 메시지 (소문자)
  ///
  /// Returns: 토큰 에러 또는 null
  static AuthError? _parseTokenError(String errorString) {
    if (errorString.contains('token')) {
      if (errorString.contains('expired') || errorString.contains('expire')) {
        return const TokenError(TokenErrorType.expired);
      } else if (errorString.contains('invalid') ||
          errorString.contains('malformed')) {
        return const TokenError(TokenErrorType.invalid);
      } else if (errorString.contains('missing') ||
          errorString.contains('null')) {
        return const TokenError(TokenErrorType.missing);
      } else if (errorString.contains('refresh') ||
          errorString.contains('renew')) {
        return const TokenError(TokenErrorType.refreshFailed);
      }
    }

    return null;
  }

  /// HTTP 상태 코드에 따른 에러 메시지 반환
  ///
  /// [statusCode] HTTP 상태 코드
  ///
  /// Returns: 사용자 친화적인 에러 메시지
  static String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'リクエストが不正です';
      case 401:
        return '認証が必要です';
      case 403:
        return 'アクセスが拒否されました';
      case 404:
        return 'リソースが見つかりません';
      case 409:
        return 'リソースが競合しています';
      case 422:
        return '入力データが無効です';
      case 429:
        return 'リクエストが多すぎます。しばらくしてから再試行してください';
      case 500:
        return 'サーバー内部エラーが発生しました';
      case 502:
        return 'ゲートウェイエラーが発生しました';
      case 503:
        return 'サービスが利用できません';
      case 504:
        return 'ゲートウェイタイムアウトが発生しました';
      default:
        return 'HTTPエラーが発生しました ($statusCode)';
    }
  }
}
