import 'auth_error.dart';

/// Railway-oriented programming 패턴의 Result 타입
/// 에러를 타입 안전하게 처리하기 위한 클래스
sealed class Result<T> {
  const Result();
  
  /// 성공 케이스 생성자
  factory Result.success(T value) = Success<T>;
  
  /// 실패 케이스 생성자  
  factory Result.failure(AuthError error) = Failure<T>;
  
  /// Exception을 자동으로 AuthError로 변환하여 실패 케이스 생성
  factory Result.fromError(Object error) {
    return Failure(AuthErrorMapper.fromException(error));
  }
  
  /// 성공인지 확인
  bool get isSuccess => this is Success<T>;
  
  /// 실패인지 확인
  bool get isFailure => this is Failure<T>;
  
  /// 성공 시 값 반환, 실패 시 null
  T? get valueOrNull => switch (this) {
    Success(value: final value) => value,
    Failure() => null,
  };
  
  /// 실패 시 에러 반환, 성공 시 null
  AuthError? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };
  
  /// 값 또는 기본값 반환
  T valueOr(T defaultValue) => valueOrNull ?? defaultValue;
  
  /// map 함수 - 성공 시에만 변환 함수 적용
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }
  
  /// flatMap 함수 - 성공 시에만 변환 함수 적용 (중첩 Result 방지)
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return switch (this) {
      Success(value: final value) => transform(value),
      Failure(error: final error) => Result.failure(error),
    };
  }
  
  /// 에러 매핑
  Result<T> mapError(AuthError Function(AuthError) transform) {
    return switch (this) {
      Success(value: final value) => Result.success(value),
      Failure(error: final error) => Result.failure(transform(error)),
    };
  }
  
  /// fold 함수 - 성공/실패 케이스 모두 처리
  R fold<R>(
    R Function(T) onSuccess,
    R Function(AuthError) onFailure,
  ) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      Failure(error: final error) => onFailure(error),
    };
  }
}

/// 성공 케이스
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'Success($value)';
}

/// 실패 케이스
final class Failure<T> extends Result<T> {
  final AuthError error;
  const Failure(this.error);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && other.error == error;

  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'Failure($error)';
}


/// Result를 사용하는 비동기 함수들을 위한 확장
extension ResultFuture<T> on Future<Result<T>> {
  /// 비동기 map
  Future<Result<R>> mapAsync<R>(Future<R> Function(T) transform) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => Result.success(await transform(value)),
      Failure(error: final error) => Result.failure(error),
    };
  }
  
  /// 비동기 flatMap
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success(value: final value) => await transform(value),
      Failure(error: final error) => Result.failure(error),
    };
  }
}

/// 여러 Result를 조합하는 유틸리티
class ResultUtils {
  /// 두 Result를 조합 - 둘 다 성공해야 성공
  static Result<(T1, T2)> combine2<T1, T2>(
    Result<T1> result1,
    Result<T2> result2,
  ) {
    return switch ((result1, result2)) {
      (Success(value: final v1), Success(value: final v2)) => 
        Result.success((v1, v2)),
      (Failure(error: final error), _) => Result.failure(error),
      (_, Failure(error: final error)) => Result.failure(error),
    };
  }
  
  /// 세 Result를 조합
  static Result<(T1, T2, T3)> combine3<T1, T2, T3>(
    Result<T1> result1,
    Result<T2> result2,
    Result<T3> result3,
  ) {
    return combine2(combine2(result1, result2), result3).map(
      (combined) => (combined.$1.$1, combined.$1.$2, combined.$2),
    );
  }
}