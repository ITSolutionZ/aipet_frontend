import '../../../shared/shared.dart';

/// 🎯 고급 타입 안전성 시스템
///
/// 제네릭 타입 제약, sealed 클래스, 타입 가드 등을 활용한
/// 엔터프라이즈급 타입 안전성을 제공합니다.

/// 타입 안전한 ID 래퍼
sealed class TypedId<T> {
  final String value;

  const TypedId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypedId<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$T($value)';
}

/// AI 메시지 ID
final class AiMessageId extends TypedId<AiMessageId> {
  const AiMessageId(super.value);

  factory AiMessageId.generate() =>
      AiMessageId('ai_${DateTime.now().millisecondsSinceEpoch}');
}

/// Auth 사용자 ID
final class AuthUserId extends TypedId<AuthUserId> {
  const AuthUserId(super.value);
}

/// Facility ID
final class FacilityId extends TypedId<FacilityId> {
  const FacilityId(super.value);
}

/// Pet ID
final class PetId extends TypedId<PetId> {
  const PetId(super.value);
}

/// 타입 안전한 상태 래퍼
sealed class State<T> {
  const State();

  /// 상태가 로딩 중인지 확인
  bool get isLoading => this is Loading<T>;

  /// 상태가 성공인지 확인
  bool get isSuccess => this is Success<T>;

  /// 상태가 실패인지 확인
  bool get isFailure => this is Failure<T>;

  /// 상태가 초기인지 확인
  bool get isInitial => this is Initial<T>;

  /// 성공 시 데이터 반환
  T? get data => switch (this) {
    Success<T>(data: final data) => data,
    _ => null,
  };

  /// 실패 시 에러 반환
  AppException? get error => switch (this) {
    Failure<T>(error: final error) => error,
    _ => null,
  };
}

/// 초기 상태
final class Initial<T> extends State<T> {
  const Initial();
}

/// 로딩 상태
final class Loading<T> extends State<T> {
  final String? message;

  const Loading([this.message]);
}

/// 성공 상태
final class Success<T> extends State<T> {
  @override
  final T data;
  final String? message;

  const Success(this.data, [this.message]);
}

/// 실패 상태
final class Failure<T> extends State<T> {
  @override
  final AppException error;
  final String? message;

  const Failure(this.error, [this.message]);
}

/// 타입 안전한 옵셔널 래퍼
sealed class Optional<T> {
  const Optional();

  /// 값이 있는지 확인
  bool get isPresent => this is Some<T>;

  /// 값이 없는지 확인
  bool get isEmpty => this is None<T>;

  /// 값 반환 (없으면 null)
  T? get value => switch (this) {
    Some<T>(value: final value) => value,
    None<T>() => null,
  };

  /// 값 반환 (없으면 기본값)
  T orElse(T defaultValue) => switch (this) {
    Some<T>(value: final value) => value,
    None<T>() => defaultValue,
  };

  /// 값 반환 (없으면 계산된 기본값)
  T orElseGet(T Function() defaultValueSupplier) => switch (this) {
    Some<T>(value: final value) => value,
    None<T>() => defaultValueSupplier(),
  };

  /// 값이 있으면 변환, 없으면 None 반환
  Optional<U> map<U>(U Function(T value) transform) => switch (this) {
    Some<T>(value: final value) => Some(transform(value)),
    None<T>() => const None(),
  };

  /// 값이 있으면 변환, 없으면 기본값
  Optional<U> mapOr<U>(U Function(T value) transform, U defaultValue) =>
      switch (this) {
        Some<T>(value: final value) => Some(transform(value)),
        None<T>() => Some(defaultValue),
      };

  /// 값이 있으면 변환, 없으면 계산된 기본값
  Optional<U> mapOrElse<U>(
    U Function(T value) transform,
    U Function() defaultValueSupplier,
  ) => switch (this) {
    Some<T>(value: final value) => Some(transform(value)),
    None<T>() => Some(defaultValueSupplier()),
  };
}

/// 값이 있음
final class Some<T> extends Optional<T> {
  @override
  final T value;

  const Some(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Some<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

/// 값이 없음
final class None<T> extends Optional<T> {
  const None();

  @override
  bool operator ==(Object other) => identical(this, other) || other is None<T>;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None()';
}

/// 타입 안전한 Either 타입
sealed class Either<L, R> {
  const Either();

  /// 왼쪽 값인지 확인
  bool get isLeft => this is Left<L, R>;

  /// 오른쪽 값인지 확인
  bool get isRight => this is Right<L, R>;

  /// 왼쪽 값 반환 (없으면 null)
  L? get left => switch (this) {
    Left<L, R>(value: final value) => value,
    Right<L, R>() => null,
  };

  /// 오른쪽 값 반환 (없으면 null)
  R? get right => switch (this) {
    Left<L, R>() => null,
    Right<L, R>(value: final value) => value,
  };

  /// 값에 따라 변환
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) =>
      switch (this) {
        Left<L, R>(value: final value) => onLeft(value),
        Right<L, R>(value: final value) => onRight(value),
      };

  /// 오른쪽 값만 변환
  Either<L, U> map<U>(U Function(R right) transform) => switch (this) {
    Left<L, R>(value: final value) => Left(value),
    Right<L, R>(value: final value) => Right(transform(value)),
  };

  /// 왼쪽 값만 변환
  Either<U, R> mapLeft<U>(U Function(L left) transform) => switch (this) {
    Left<L, R>(value: final value) => Left(transform(value)),
    Right<L, R>(value: final value) => Right(value),
  };
}

/// 왼쪽 값
final class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Left<L, R> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// 오른쪽 값
final class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Right<L, R> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

/// 타입 가드 유틸리티
class TypeGuards {
  /// null이 아닌지 확인
  static bool isNotNull<T>(T? value) => value != null;

  /// 빈 문자열이 아닌지 확인
  static bool isNotEmpty(String? value) => value != null && value.isNotEmpty;

  /// 빈 리스트가 아닌지 확인
  static bool isNotEmptyList<T>(List<T>? list) =>
      list != null && list.isNotEmpty;

  /// 유효한 이메일인지 확인
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  /// 유효한 전화번호인지 확인
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// 유효한 URL인지 확인
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// 타입 안전한 빌더 패턴
class TypeSafeBuilder<T> {
  T? _value;
  final List<String> _errors = [];

  TypeSafeBuilder();

  /// 값 설정
  TypeSafeBuilder<T> withValue(T value) {
    _value = value;
    return this;
  }

  /// 검증 추가
  TypeSafeBuilder<T> validate(
    bool Function(T value) validator,
    String errorMessage,
  ) {
    if (_value != null && !validator(_value as T)) {
      _errors.add(errorMessage);
    }
    return this;
  }

  /// 빌드
  Result<T> build() {
    if (_errors.isNotEmpty) {
      return Result.failure('Validation failed: ${_errors.join(', ')}');
    }

    if (_value == null) {
      return Result.failure('Value is required');
    }

    return Result.success('Success', _value as T);
  }
}

/// 타입 안전한 확장 메서드들
extension TypeSafetyExtensions on Object? {
  /// null이 아닌지 확인하고 타입 캐스팅
  T? as<T>() => this is T ? this as T : null;

  /// null이 아니고 타입이 맞으면 반환, 아니면 기본값
  T asOr<T>(T defaultValue) => this is T ? this as T : defaultValue;

  /// null이 아니고 타입이 맞으면 반환, 아니면 계산된 기본값
  T asOrElse<T>(T Function() defaultValueSupplier) =>
      this is T ? this as T : defaultValueSupplier();
}

/// 리스트 타입 안전성 확장
extension ListTypeSafetyExtensions<T> on List<T>? {
  /// null이 아니고 비어있지 않으면 반환
  List<T>? get nonEmpty => this?.isNotEmpty == true ? this : null;

  /// 첫 번째 요소가 타입 U인지 확인하고 반환
  U? firstAs<U>() =>
      this?.isNotEmpty == true && this!.first is U ? this!.first as U : null;

  /// 마지막 요소가 타입 U인지 확인하고 반환
  U? lastAs<U>() =>
      this?.isNotEmpty == true && this!.last is U ? this!.last as U : null;
}

/// 맵 타입 안전성 확장
extension MapTypeSafetyExtensions<K, V> on Map<K, V>? {
  /// 키로 값을 안전하게 가져오기
  T? getAs<T>(K key) => this?[key] is T ? this![key] as T : null;

  /// 키로 값을 안전하게 가져오기 (기본값 포함)
  T getAsOr<T>(K key, T defaultValue) =>
      this?[key] is T ? this![key] as T : defaultValue;
}
