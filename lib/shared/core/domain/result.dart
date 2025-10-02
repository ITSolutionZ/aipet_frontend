/// 공통 결과 클래스
///
/// 모든 기능에서 사용할 수 있는 표준화된 결과 반환 패턴을 제공합니다.
/// Clean Architecture 원칙에 따라 도메인 레이어에 위치합니다.
class Result<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final Exception? error;

  const Result._({required this.isSuccess, required this.message, this.data, this.error});

  /// 성공 결과 생성
  factory Result.success(String message, [T? data]) =>
      Result._(isSuccess: true, message: message, data: data);

  /// 실패 결과 생성
  factory Result.failure(String message, [Exception? error]) =>
      Result._(isSuccess: false, message: message, error: error);

  /// 예외로부터 실패 결과 생성
  factory Result.fromException(Exception exception) => Result._(
    isSuccess: false,
    message: _getUserFriendlyErrorMessage(exception),
    error: exception,
  );

  /// 데이터가 있는지 확인
  bool get hasData => data != null;

  /// 에러가 있는지 확인
  bool get hasError => error != null;

  /// 성공 시 데이터 반환, 실패 시 null 반환
  T? get dataOrNull => isSuccess ? data : null;

  /// 성공 시 데이터 반환, 실패 시 기본값 반환
  T dataOr(T defaultValue) => isSuccess ? (data ?? defaultValue) : defaultValue;

  /// 성공 시 데이터 반환, 실패 시 예외 발생
  T get dataOrThrow {
    if (isSuccess) {
      return data!;
    }
    throw error ?? Exception(message);
  }

  /// 사용자 친화적인 에러 메시지 생성
  static String _getUserFriendlyErrorMessage(Exception exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return 'ネットワーク接続を確認してください';
    } else if (message.contains('timeout')) {
      return 'タイムアウトが発生しました。もう一度お試しください';
    } else if (message.contains('unauthorized') || message.contains('401')) {
      return '認証に失敗しました';
    } else if (message.contains('forbidden') || message.contains('403')) {
      return 'アクセスが拒否されました';
    } else if (message.contains('not found') || message.contains('404')) {
      return 'リソースが見つかりません';
    } else if (message.contains('server') || message.contains('500')) {
      return 'サーバーエラーが発生しました';
    } else {
      return '予期しないエラーが発生しました';
    }
  }

  @override
  String toString() {
    return 'Result(isSuccess: $isSuccess, message: $message, data: $data, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other.isSuccess == isSuccess &&
        other.message == message &&
        other.data == data &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(isSuccess, message, data, error);
  }
}

/// 실패 결과를 빠르게 생성하는 헬퍼 함수
Result<T> Failure<T>(String message, [Exception? error]) => Result<T>.failure(message, error);
