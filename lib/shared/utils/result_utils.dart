/// Result 패턴을 위한 공통 유틸리티
class Result<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final Exception? error;

  const Result._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.error,
  });

  /// 성공 결과 생성
  factory Result.success(String message, T data) {
    return Result._(isSuccess: true, message: message, data: data);
  }

  /// 실패 결과 생성
  factory Result.failure(String message, [Exception? error]) {
    return Result._(isSuccess: false, message: message, error: error);
  }

  /// 성공 여부 확인
  bool get isFailure => !isSuccess;

  /// 데이터가 있는지 확인
  bool get hasData => data != null;
}

/// Result 확장 메서드들
extension ResultExtensions<T> on Result<T> {
  /// 성공 시에만 실행할 함수
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data!);
    }
    return this;
  }

  /// 실패 시에만 실행할 함수
  Result<T> onFailure(
    void Function(String message, Exception? error) callback,
  ) {
    if (isFailure) {
      callback(message, error);
    }
    return this;
  }

  /// 데이터 변환 (성공 시에만)
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        final newData = mapper(data!);
        return Result.success(message, newData);
      } catch (e) {
        return Result.failure(
          'データ変換に失敗しました: ${e.toString()}',
          e is Exception ? e : Exception(e.toString()),
        );
      }
    }
    return Result.failure(message, error);
  }

  /// 다른 Result로 변환 (실패 시에도)
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    if (isSuccess && data != null) {
      return mapper(data!);
    }
    return Result.failure(message, error);
  }
}

/// Result 생성 헬퍼 함수들
class ResultHelper {
  ResultHelper._();

  /// 비동기 작업을 Result로 래핑
  static Future<Result<T>> wrapAsync<T>(
    Future<T> Function() asyncFunction, {
    String? successMessage,
    String? failureMessage,
  }) async {
    try {
      final data = await asyncFunction();
      return Result.success(successMessage ?? '操作が完了しました', data);
    } catch (e) {
      return Result.failure(
        failureMessage ?? '操作に失敗しました: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 동기 작업을 Result로 래핑
  static Result<T> wrapSync<T>(
    T Function() syncFunction, {
    String? successMessage,
    String? failureMessage,
  }) {
    try {
      final data = syncFunction();
      return Result.success(successMessage ?? '操作が完了しました', data);
    } catch (e) {
      return Result.failure(
        failureMessage ?? '操作に失敗しました: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 조건부 성공/실패 Result 생성
  static Result<T> conditional<T>(
    bool condition,
    T data, {
    String? successMessage,
    String? failureMessage,
  }) {
    if (condition) {
      return Result.success(successMessage ?? '操作が完了しました', data);
    } else {
      return Result.failure(failureMessage ?? '条件が満たされていません');
    }
  }

  /// null 체크 후 Result 생성
  static Result<T> fromNullable<T>(
    T? data, {
    String? successMessage,
    String? failureMessage,
  }) {
    if (data != null) {
      return Result.success(successMessage ?? 'データが見つかりました', data);
    } else {
      return Result.failure(failureMessage ?? 'データが見つかりませんでした');
    }
  }
}
