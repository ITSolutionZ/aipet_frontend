/// 🎯 공통 Result 패턴
///
/// 모든 Feature에서 일관된 성공/실패 처리를 위한 Result 패턴을 정의합니다.
/// Railway-oriented programming 원칙을 따릅니다.
library;

/// 공통 Result 타입
sealed class Result<T> {
  const Result();

  /// 성공 여부 확인
  bool get isSuccess => this is Success<T>;

  /// 실패 여부 확인
  bool get isFailure => this is Failure<T>;

  /// 성공 시 데이터 반환, 실패 시 null
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// 실패 시 에러 반환, 성공 시 null
  String? get errorOrNull => isFailure ? (this as Failure<T>).message : null;

  /// 성공 시 데이터 반환, 실패 시 기본값
  T dataOr(T defaultValue) =>
      isSuccess ? (this as Success<T>).data : defaultValue;

  /// 성공 시 데이터 반환, 실패 시 예외 발생
  T get dataOrThrow {
    if (isSuccess) {
      return (this as Success<T>).data;
    } else {
      final failure = this as Failure<T>;
      throw Exception(failure.message);
    }
  }

  /// 성공 시 변환, 실패 시 그대로 반환
  Result<U> map<U>(U Function(T data) transform) {
    if (isSuccess) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e) {
        return Failure('変換中にエラーが発生しました: ${e.toString()}');
      }
    } else {
      return Failure((this as Failure<T>).message);
    }
  }

  /// 성공 시 비동기 변환, 실패 시 그대로 반환
  Future<Result<U>> mapAsync<U>(Future<U> Function(T data) transform) async {
    if (isSuccess) {
      try {
        final result = await transform((this as Success<T>).data);
        return Success(result);
      } catch (e) {
        return Failure('非同期変換中にエラーが発生しました: ${e.toString()}');
      }
    } else {
      return Failure((this as Failure<T>).message);
    }
  }

  /// 성공 시 체이닝, 실패 시 그대로 반환
  Result<U> flatMap<U>(Result<U> Function(T data) transform) {
    if (isSuccess) {
      return transform((this as Success<T>).data);
    } else {
      return Failure((this as Failure<T>).message);
    }
  }

  /// 성공 시 비동기 체이닝, 실패 시 그대로 반환
  Future<Result<U>> flatMapAsync<U>(
    Future<Result<U>> Function(T data) transform,
  ) async {
    if (isSuccess) {
      return transform((this as Success<T>).data);
    } else {
      return Failure((this as Failure<T>).message);
    }
  }

  /// 성공 시 콜백 실행
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// 실패 시 콜백 실행
  Result<T> onFailure(void Function(String message) callback) {
    if (isFailure) {
      callback((this as Failure<T>).message);
    }
    return this;
  }

  /// 성공 시 비동기 콜백 실행
  Future<Result<T>> onSuccessAsync(
    Future<void> Function(T data) callback,
  ) async {
    if (isSuccess) {
      await callback((this as Success<T>).data);
    }
    return this;
  }

  /// 실패 시 비동기 콜백 실행
  Future<Result<T>> onFailureAsync(
    Future<void> Function(String message) callback,
  ) async {
    if (isFailure) {
      await callback((this as Failure<T>).message);
    }
    return this;
  }

  /// 성공 시 다른 값 반환, 실패 시 기본값 반환
  U fold<U>(
    U Function(T data) onSuccess,
    U Function(String message) onFailure,
  ) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).message);
    }
  }

  /// 성공 시 다른 값 반환, 실패 시 기본값 반환 (비동기)
  Future<U> foldAsync<U>(
    Future<U> Function(T data) onSuccess,
    Future<U> Function(String message) onFailure,
  ) async {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).message);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Success(data: ${(this as Success<T>).data})';
    } else {
      return 'Failure(message: ${(this as Failure<T>).message})';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Result<T> &&
        other.isSuccess == isSuccess &&
        (isSuccess
            ? (other as Success<T>).data == (this as Success<T>).data
            : (other as Failure<T>).message == (this as Failure<T>).message);
  }

  @override
  int get hashCode => isSuccess
      ? (this as Success<T>).data.hashCode
      : (this as Failure<T>).message.hashCode;
}

/// 성공 결과
class Success<T> extends Result<T> {
  final T data;
  final String? message;

  const Success(this.data, [this.message]);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;
}

/// 실패 결과
class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  final String? code;

  const Failure(this.message, {this.exception, this.code});

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;
}

/// Result 팩토리 함수들
class ResultFactory {
  /// 성공 결과 생성
  static Result<T> success<T>(T data, [String? message]) {
    return Success(data, message);
  }

  /// 실패 결과 생성
  static Result<T> failure<T>(
    String message, {
    Exception? exception,
    String? code,
  }) {
    return Failure(message, exception: exception, code: code);
  }

  /// 예외로부터 실패 결과 생성
  static Result<T> fromException<T>(Exception exception) {
    return Failure(
      exception.toString().replaceFirst('Exception: ', ''),
      exception: exception,
    );
  }

  /// AppException으로부터 실패 결과 생성
  static Result<T> fromAppException<T>(AppException exception) {
    return Failure(
      exception.message,
      exception: exception,
      code: exception.code,
    );
  }

  /// 여러 Result를 하나로 결합 (모든 것이 성공해야 성공)
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final failures = results.where((r) => r.isFailure).toList();
    if (failures.isNotEmpty) {
      return Failure(
        '複数の操作が失敗しました: ${failures.map((f) => f.errorOrNull).join(', ')}',
      );
    }

    final data = results.map((r) => (r as Success<T>).data).toList();
    return Success(data);
  }

  /// 여러 Result를 하나로 결합 (비동기)
  static Future<Result<List<T>>> combineAsync<T>(
    List<Future<Result<T>>> results,
  ) async {
    final awaitedResults = await Future.wait(results);
    return combine(awaitedResults);
  }

  /// 조건부 성공/실패
  static Result<T> conditional<T>(
    bool condition,
    T data,
    String failureMessage,
  ) {
    return condition ? Success(data) : Failure(failureMessage);
  }

  /// null 체크 후 성공/실패
  static Result<T> fromNullable<T>(T? data, String failureMessage) {
    return data != null ? Success(data) : Failure(failureMessage);
  }

  /// 비동기 작업을 Result로 래핑
  static Future<Result<T>> wrapAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      return fromException(Exception(e.toString()));
    }
  }

  /// 동기 작업을 Result로 래핑
  static Result<T> wrap<T>(T Function() operation) {
    try {
      final result = operation();
      return Success(result);
    } catch (e) {
      return fromException(Exception(e.toString()));
    }
  }
}

/// Result 확장 메서드들
extension ResultExtensions<T> on Result<T> {
  /// 성공 시 데이터 반환, 실패 시 null
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// 성공 시 데이터 반환, 실패 시 기본값
  T dataOr(T defaultValue) =>
      isSuccess ? (this as Success<T>).data : defaultValue;

  /// 성공 시 데이터 반환, 실패 시 예외 발생
  T get dataOrThrow {
    if (isSuccess) {
      return (this as Success<T>).data;
    } else {
      throw Exception((this as Failure<T>).message);
    }
  }

  /// 성공 시 데이터 반환, 실패 시 계산된 기본값
  T dataOrElse(T Function() defaultValue) {
    return isSuccess ? (this as Success<T>).data : defaultValue();
  }
}

/// Result<T> 확장 메서드들
extension ResultExtensions<T> on Result<T> {
  /// Result<T>를 Future<Result<T>>로 변환
  Future<Result<T>> toFuture() {
    return Future.value(this);
  }
}

/// Future<Result<T>> 확장 메서드들
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// 성공 시 데이터 반환, 실패 시 기본값
  Future<T> dataOr(T defaultValue) async {
    final result = await this;
    return result.dataOr(defaultValue);
  }

  /// 성공 시 데이터 반환, 실패 시 null
  Future<T?> dataOrNull() async {
    final result = await this;
    return result.dataOrNull;
  }

  /// 성공 시 데이터 반환, 실패 시 예외 발생
  Future<T> dataOrThrow() async {
    final result = await this;
    return result.dataOrThrow;
  }

  /// 성공 시 데이터 반환, 실패 시 계산된 기본값
  Future<T> dataOrElse(T Function() defaultValue) async {
    final result = await this;
    return result.dataOrElse(defaultValue);
  }
}
