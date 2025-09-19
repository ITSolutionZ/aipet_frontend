// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_favorite_mock_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiFavoriteMockDataHash() =>
    r'29120d1049d466313f3c15e8ebfc1089728b861d';

/// AI 즐겨찾기 QA Mock 데이터 프로바이더
///
/// 실제 API 연계 전까지 사용하는 즐겨찾기 Mock 데이터를 중앙 관리합니다.
///
/// Copied from [aiFavoriteMockData].
@ProviderFor(aiFavoriteMockData)
final aiFavoriteMockDataProvider =
    AutoDisposeProvider<List<AiFavoriteQaEntity>>.internal(
      aiFavoriteMockData,
      name: r'aiFavoriteMockDataProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiFavoriteMockDataHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiFavoriteMockDataRef =
    AutoDisposeProviderRef<List<AiFavoriteQaEntity>>;
String _$aiFavoritesByCategoryHash() =>
    r'a9e46c088e1cd233f6aec543a2ebdd0d62fa55a9';

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

/// 즐겨찾기 카테고리별 목록 프로바이더
///
/// Copied from [aiFavoritesByCategory].
@ProviderFor(aiFavoritesByCategory)
const aiFavoritesByCategoryProvider = AiFavoritesByCategoryFamily();

/// 즐겨찾기 카테고리별 목록 프로바이더
///
/// Copied from [aiFavoritesByCategory].
class AiFavoritesByCategoryFamily extends Family<List<AiFavoriteQaEntity>> {
  /// 즐겨찾기 카테고리별 목록 프로바이더
  ///
  /// Copied from [aiFavoritesByCategory].
  const AiFavoritesByCategoryFamily();

  /// 즐겨찾기 카테고리별 목록 프로바이더
  ///
  /// Copied from [aiFavoritesByCategory].
  AiFavoritesByCategoryProvider call(String categoryId) {
    return AiFavoritesByCategoryProvider(categoryId);
  }

  @override
  AiFavoritesByCategoryProvider getProviderOverride(
    covariant AiFavoritesByCategoryProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'aiFavoritesByCategoryProvider';
}

/// 즐겨찾기 카테고리별 목록 프로바이더
///
/// Copied from [aiFavoritesByCategory].
class AiFavoritesByCategoryProvider
    extends AutoDisposeProvider<List<AiFavoriteQaEntity>> {
  /// 즐겨찾기 카테고리별 목록 프로바이더
  ///
  /// Copied from [aiFavoritesByCategory].
  AiFavoritesByCategoryProvider(String categoryId)
    : this._internal(
        (ref) =>
            aiFavoritesByCategory(ref as AiFavoritesByCategoryRef, categoryId),
        from: aiFavoritesByCategoryProvider,
        name: r'aiFavoritesByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$aiFavoritesByCategoryHash,
        dependencies: AiFavoritesByCategoryFamily._dependencies,
        allTransitiveDependencies:
            AiFavoritesByCategoryFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  AiFavoritesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    List<AiFavoriteQaEntity> Function(AiFavoritesByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AiFavoritesByCategoryProvider._internal(
        (ref) => create(ref as AiFavoritesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<AiFavoriteQaEntity>> createElement() {
    return _AiFavoritesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiFavoritesByCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AiFavoritesByCategoryRef
    on AutoDisposeProviderRef<List<AiFavoriteQaEntity>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _AiFavoritesByCategoryProviderElement
    extends AutoDisposeProviderElement<List<AiFavoriteQaEntity>>
    with AiFavoritesByCategoryRef {
  _AiFavoritesByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as AiFavoritesByCategoryProvider).categoryId;
}

String _$aiFavoritesByPetHash() => r'fbb0f027072b81ae0c635bda0754e6b9741fa3b6';

/// 즐겨찾기 펫별 목록 프로바이더
///
/// Copied from [aiFavoritesByPet].
@ProviderFor(aiFavoritesByPet)
const aiFavoritesByPetProvider = AiFavoritesByPetFamily();

/// 즐겨찾기 펫별 목록 프로바이더
///
/// Copied from [aiFavoritesByPet].
class AiFavoritesByPetFamily extends Family<List<AiFavoriteQaEntity>> {
  /// 즐겨찾기 펫별 목록 프로바이더
  ///
  /// Copied from [aiFavoritesByPet].
  const AiFavoritesByPetFamily();

  /// 즐겨찾기 펫별 목록 프로바이더
  ///
  /// Copied from [aiFavoritesByPet].
  AiFavoritesByPetProvider call(String petId) {
    return AiFavoritesByPetProvider(petId);
  }

  @override
  AiFavoritesByPetProvider getProviderOverride(
    covariant AiFavoritesByPetProvider provider,
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
  String? get name => r'aiFavoritesByPetProvider';
}

/// 즐겨찾기 펫별 목록 프로바이더
///
/// Copied from [aiFavoritesByPet].
class AiFavoritesByPetProvider
    extends AutoDisposeProvider<List<AiFavoriteQaEntity>> {
  /// 즐겨찾기 펫별 목록 프로바이더
  ///
  /// Copied from [aiFavoritesByPet].
  AiFavoritesByPetProvider(String petId)
    : this._internal(
        (ref) => aiFavoritesByPet(ref as AiFavoritesByPetRef, petId),
        from: aiFavoritesByPetProvider,
        name: r'aiFavoritesByPetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$aiFavoritesByPetHash,
        dependencies: AiFavoritesByPetFamily._dependencies,
        allTransitiveDependencies:
            AiFavoritesByPetFamily._allTransitiveDependencies,
        petId: petId,
      );

  AiFavoritesByPetProvider._internal(
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
    List<AiFavoriteQaEntity> Function(AiFavoritesByPetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AiFavoritesByPetProvider._internal(
        (ref) => create(ref as AiFavoritesByPetRef),
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
  AutoDisposeProviderElement<List<AiFavoriteQaEntity>> createElement() {
    return _AiFavoritesByPetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiFavoritesByPetProvider && other.petId == petId;
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
mixin AiFavoritesByPetRef on AutoDisposeProviderRef<List<AiFavoriteQaEntity>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _AiFavoritesByPetProviderElement
    extends AutoDisposeProviderElement<List<AiFavoriteQaEntity>>
    with AiFavoritesByPetRef {
  _AiFavoritesByPetProviderElement(super.provider);

  @override
  String get petId => (origin as AiFavoritesByPetProvider).petId;
}

String _$aiGeneralFavoritesHash() =>
    r'e552cfab42e855bc2cba2ffd03603073403ef787';

/// 일반 상담 즐겨찾기 목록 프로바이더 (펫이 지정되지 않은 경우)
///
/// Copied from [aiGeneralFavorites].
@ProviderFor(aiGeneralFavorites)
final aiGeneralFavoritesProvider =
    AutoDisposeProvider<List<AiFavoriteQaEntity>>.internal(
      aiGeneralFavorites,
      name: r'aiGeneralFavoritesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiGeneralFavoritesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiGeneralFavoritesRef =
    AutoDisposeProviderRef<List<AiFavoriteQaEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
