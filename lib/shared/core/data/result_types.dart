import '../domain/common_errors.dart';

sealed class ResultState<T> {
  const ResultState();

  static Failure<T> failure<T>(AppError error) => Failure<T>(error);
}

class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

class Failure<T> extends ResultState<T> {
  final AppError error;
  const Failure(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure(error: $error)';
}

extension ResultStateExtensions<T> on ResultState<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };

  AppError? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };

  T dataOr(T defaultValue) => switch (this) {
    Success(data: final data) => data,
    Failure() => defaultValue,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(error: final error) => failure(error),
    };
  }

  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(AppError error)? failure,
  }) {
    return switch (this) {
      Success(data: final data) => success?.call(data),
      Failure(error: final error) => failure?.call(error),
    };
  }

  ResultState<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  Future<ResultState<R>> mapAsync<R>(Future<R> Function(T) transform) async {
    return switch (this) {
      Success(data: final data) => Success(await transform(data)),
      Failure(error: final error) => Result.failure(error),
    };
  }

  ResultState<R> flatMap<R>(ResultState<R> Function(T) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(error: final error) => Result.failure(error),
    };
  }
}

typedef Result<T> = ResultState<T>;
