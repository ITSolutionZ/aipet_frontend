// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petRepositoryHash() => r'38ea50ee2d0fe13c8dab0425a788dcc6a7d8a9c0';

/// PetRepository 프로바이더
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
String _$petByIdHash() => r'c1d1b5647625501c81892013f967e6a73222903f';

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

String _$petsNotifierHash() => r'be487b3e5e5c9a369cb5c70e3847e4fe471241f6';

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
