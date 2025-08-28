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
  
  const ValidationError({
    required this.field,
    required this.reason,
  });
  
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
  
  const ClientError({
    required this.statusCode,
    required this.reason,
  });
  
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

enum TokenErrorType {
  expired,
  invalid,
  missing,
  refreshFailed,
}

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
class AuthErrorMapper {
  static AuthError fromException(Object error) {
    if (error is AuthError) {
      return error;
    }
    
    // 네트워크 에러 감지 (일반적인 패턴들)
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return const NetworkError();
    }
    
    // HTTP 에러 감지 (실제 구현에서는 더 정교하게)
    if (errorString.contains('http')) {
      return const ServerError();
    }
    
    // 기본적으로 UnknownError로 처리
    return UnknownError(error.toString());
  }
}