// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petRepositoryHash() => r'c82d3f0df7db3005bfb32223bf7ae85a28a5da23';

/// PetRepository 프로바이더 (Mockito 버전)
///
/// Mockito를 사용하여 테스트 가능성을 높입니다.
///
/// Copied from [petRepository].
@ProviderFor(petRepository)
final petRepositoryProvider = AutoDisposeProvider<PetRepository>.internal(
  petRepository,
  name: r'petRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetRepositoryRef = AutoDisposeProviderRef<PetRepository>;
String _$legacyPetRepositoryHash() =>
    r'c2c24e6e25668c11c4781db2faaf859f4003911b';

/// Legacy PetRepository 프로바이더 (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
///
/// Copied from [legacyPetRepository].
@ProviderFor(legacyPetRepository)
final legacyPetRepositoryProvider = AutoDisposeProvider<PetRepository>.internal(
  legacyPetRepository,
  name: r'legacyPetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$legacyPetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LegacyPetRepositoryRef = AutoDisposeProviderRef<PetRepository>;
String _$petByIdHash() => r'11f5c8d714dfd31ece700c31a642998ab5216246';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 개별 펫 프로바이더
///
/// Copied from [petById].
@ProviderFor(petById)
const petByIdProvider = PetByIdFamily();

/// 개별 펫 프로바이더
///
/// Copied from [petById].
class PetByIdFamily extends Family<AsyncValue<PetProfileEntity?>> {
  /// 개별 펫 프로바이더
  ///
  /// Copied from [petById].
  const PetByIdFamily();

  /// 개별 펫 프로바이더
  ///
  /// Copied from [petById].
  PetByIdProvider call(String id) {
    return PetByIdProvider(id);
  }

  @override
  PetByIdProvider getProviderOverride(covariant PetByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'petByIdProvider';
}

/// 개별 펫 프로바이더
///
/// Copied from [petById].
class PetByIdProvider extends AutoDisposeFutureProvider<PetProfileEntity?> {
  /// 개별 펫 프로바이더
  ///
  /// Copied from [petById].
  PetByIdProvider(String id)
    : this._internal(
        (ref) => petById(ref as PetByIdRef, id),
        from: petByIdProvider,
        name: r'petByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$petByIdHash,
        dependencies: PetByIdFamily._dependencies,
        allTransitiveDependencies: PetByIdFamily._allTransitiveDependencies,
        id: id,
      );

  PetByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<PetProfileEntity?> Function(PetByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PetByIdProvider._internal(
        (ref) => create(ref as PetByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PetProfileEntity?> createElement() {
    return _PetByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PetByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PetByIdRef on AutoDisposeFutureProviderRef<PetProfileEntity?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PetByIdProviderElement
    extends AutoDisposeFutureProviderElement<PetProfileEntity?>
    with PetByIdRef {
  _PetByIdProviderElement(super.provider);

  @override
  String get id => (origin as PetByIdProvider).id;
}

String _$petsNotifierHash() => r'4300a02d7fd0df49fac89aae6d94d20e8ad879db';

/// 모든 펫 목록 프로바이더
///
/// Copied from [PetsNotifier].
@ProviderFor(PetsNotifier)
final petsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      PetsNotifier,
      List<PetProfileEntity>
    >.internal(
      PetsNotifier.new,
      name: r'petsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$petsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PetsNotifier = AutoDisposeAsyncNotifier<List<PetProfileEntity>>;
String _$selectedPetNotifierHash() =>
    r'056507d4582028fdb899baf59b1ab892bab6b417';

/// 현재 선택된 펫 프로바이더
///
/// Copied from [SelectedPetNotifier].
@ProviderFor(SelectedPetNotifier)
final selectedPetNotifierProvider =
    AutoDisposeNotifierProvider<
      SelectedPetNotifier,
      PetProfileEntity?
    >.internal(
      SelectedPetNotifier.new,
      name: r'selectedPetNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedPetNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedPetNotifier = AutoDisposeNotifier<PetProfileEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
