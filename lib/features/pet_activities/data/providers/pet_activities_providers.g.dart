// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_activities_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petActivitiesRepositoryHash() =>
    r'ad82a077ed54f958cbd22f99c1c9fc7c4bc801b0';

/// 펫 액티비티 리포지토리 프로바이더
///
/// Copied from [petActivitiesRepository].
@ProviderFor(petActivitiesRepository)
final petActivitiesRepositoryProvider =
    AutoDisposeProvider<PetActivitiesRepository>.internal(
      petActivitiesRepository,
      name: r'petActivitiesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$petActivitiesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetActivitiesRepositoryRef =
    AutoDisposeProviderRef<PetActivitiesRepository>;
String _$allTricksHash() => r'fc98c31e77c84c10713e19e433ee7ba59a2838c6';

/// 모든 트릭을 가져오는 프로바이더
///
/// Copied from [allTricks].
@ProviderFor(allTricks)
final allTricksProvider = AutoDisposeFutureProvider<List<TrickEntity>>.internal(
  allTricks,
  name: r'allTricksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTricksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTricksRef = AutoDisposeFutureProviderRef<List<TrickEntity>>;
String _$tricksByPetIdHash() => r'f618f35f12642f528ce1862ec54546d8b06d9dc9';

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

/// 특정 펫의 트릭을 가져오는 프로바이더
///
/// Copied from [tricksByPetId].
@ProviderFor(tricksByPetId)
const tricksByPetIdProvider = TricksByPetIdFamily();

/// 특정 펫의 트릭을 가져오는 프로바이더
///
/// Copied from [tricksByPetId].
class TricksByPetIdFamily extends Family<AsyncValue<List<TrickEntity>>> {
  /// 특정 펫의 트릭을 가져오는 프로바이더
  ///
  /// Copied from [tricksByPetId].
  const TricksByPetIdFamily();

  /// 특정 펫의 트릭을 가져오는 프로바이더
  ///
  /// Copied from [tricksByPetId].
  TricksByPetIdProvider call(String petId) {
    return TricksByPetIdProvider(petId);
  }

  @override
  TricksByPetIdProvider getProviderOverride(
    covariant TricksByPetIdProvider provider,
  ) {
    return call(provider.petId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tricksByPetIdProvider';
}

/// 특정 펫의 트릭을 가져오는 프로바이더
///
/// Copied from [tricksByPetId].
class TricksByPetIdProvider
    extends AutoDisposeFutureProvider<List<TrickEntity>> {
  /// 특정 펫의 트릭을 가져오는 프로바이더
  ///
  /// Copied from [tricksByPetId].
  TricksByPetIdProvider(String petId)
    : this._internal(
        (ref) => tricksByPetId(ref as TricksByPetIdRef, petId),
        from: tricksByPetIdProvider,
        name: r'tricksByPetIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tricksByPetIdHash,
        dependencies: TricksByPetIdFamily._dependencies,
        allTransitiveDependencies:
            TricksByPetIdFamily._allTransitiveDependencies,
        petId: petId,
      );

  TricksByPetIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  Override overrideWith(
    FutureOr<List<TrickEntity>> Function(TricksByPetIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TricksByPetIdProvider._internal(
        (ref) => create(ref as TricksByPetIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TrickEntity>> createElement() {
    return _TricksByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TricksByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TricksByPetIdRef on AutoDisposeFutureProviderRef<List<TrickEntity>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _TricksByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<TrickEntity>>
    with TricksByPetIdRef {
  _TricksByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as TricksByPetIdProvider).petId;
}

String _$registerYouTubeVideoUseCaseHash() =>
    r'd6191bc2f3261bcc956de6db1bd97fadbbc9e927';

/// YouTube 비디오 유스케이스 프로바이더들
///
/// Copied from [registerYouTubeVideoUseCase].
@ProviderFor(registerYouTubeVideoUseCase)
final registerYouTubeVideoUseCaseProvider =
    AutoDisposeProvider<RegisterYouTubeVideoUseCase>.internal(
      registerYouTubeVideoUseCase,
      name: r'registerYouTubeVideoUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$registerYouTubeVideoUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RegisterYouTubeVideoUseCaseRef =
    AutoDisposeProviderRef<RegisterYouTubeVideoUseCase>;
String _$getYouTubeVideosUseCaseHash() =>
    r'e2edc584a6ee8bb22cbb93548dd3cf1ba24f69fc';

/// See also [getYouTubeVideosUseCase].
@ProviderFor(getYouTubeVideosUseCase)
final getYouTubeVideosUseCaseProvider =
    AutoDisposeProvider<GetYouTubeVideosUseCase>.internal(
      getYouTubeVideosUseCase,
      name: r'getYouTubeVideosUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getYouTubeVideosUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetYouTubeVideosUseCaseRef =
    AutoDisposeProviderRef<GetYouTubeVideosUseCase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
