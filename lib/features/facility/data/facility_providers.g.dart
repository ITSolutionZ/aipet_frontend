// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nearbyFacilitiesHash() => r'5be28f599095f9f50957c767b03c3da3bca9e53b';

/// 근처 시설 조회 Provider (Google Places API + 로컬 저장소)
///
/// Copied from [nearbyFacilities].
@ProviderFor(nearbyFacilities)
final nearbyFacilitiesProvider =
    AutoDisposeFutureProvider<Result<List<Facility>>>.internal(
      nearbyFacilities,
      name: r'nearbyFacilitiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nearbyFacilitiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NearbyFacilitiesRef =
    AutoDisposeFutureProviderRef<Result<List<Facility>>>;
String _$facilitiesByTypeHash() => r'18a1a6397f852cae1a35431124dc53035cf6a81b';

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

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
///
/// Copied from [facilitiesByType].
@ProviderFor(facilitiesByType)
const facilitiesByTypeProvider = FacilitiesByTypeFamily();

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
///
/// Copied from [facilitiesByType].
class FacilitiesByTypeFamily
    extends Family<AsyncValue<Result<List<Facility>>>> {
  /// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
  ///
  /// Copied from [facilitiesByType].
  const FacilitiesByTypeFamily();

  /// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
  ///
  /// Copied from [facilitiesByType].
  FacilitiesByTypeProvider call(FacilityType type) {
    return FacilitiesByTypeProvider(type);
  }

  @override
  FacilitiesByTypeProvider getProviderOverride(
    covariant FacilitiesByTypeProvider provider,
  ) {
    return call(provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'facilitiesByTypeProvider';
}

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
///
/// Copied from [facilitiesByType].
class FacilitiesByTypeProvider
    extends AutoDisposeFutureProvider<Result<List<Facility>>> {
  /// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
  ///
  /// Copied from [facilitiesByType].
  FacilitiesByTypeProvider(FacilityType type)
    : this._internal(
        (ref) => facilitiesByType(ref as FacilitiesByTypeRef, type),
        from: facilitiesByTypeProvider,
        name: r'facilitiesByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$facilitiesByTypeHash,
        dependencies: FacilitiesByTypeFamily._dependencies,
        allTransitiveDependencies:
            FacilitiesByTypeFamily._allTransitiveDependencies,
        type: type,
      );

  FacilitiesByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final FacilityType type;

  @override
  Override overrideWith(
    FutureOr<Result<List<Facility>>> Function(FacilitiesByTypeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FacilitiesByTypeProvider._internal(
        (ref) => create(ref as FacilitiesByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Result<List<Facility>>> createElement() {
    return _FacilitiesByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FacilitiesByTypeProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FacilitiesByTypeRef
    on AutoDisposeFutureProviderRef<Result<List<Facility>>> {
  /// The parameter `type` of this provider.
  FacilityType get type;
}

class _FacilitiesByTypeProviderElement
    extends AutoDisposeFutureProviderElement<Result<List<Facility>>>
    with FacilitiesByTypeRef {
  _FacilitiesByTypeProviderElement(super.provider);

  @override
  FacilityType get type => (origin as FacilitiesByTypeProvider).type;
}

String _$facilityListNotifierHash() =>
    r'fc8853a9779e546b9981cb36f3c81c9ebd0e8575';

/// See also [FacilityListNotifier].
@ProviderFor(FacilityListNotifier)
final facilityListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      FacilityListNotifier,
      List<Facility>
    >.internal(
      FacilityListNotifier.new,
      name: r'facilityListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$facilityListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FacilityListNotifier = AutoDisposeAsyncNotifier<List<Facility>>;
String _$facilityFilterNotifierHash() =>
    r'91a6723a5721eeb6b64ade31daf4100a798c775b';

/// See also [FacilityFilterNotifier].
@ProviderFor(FacilityFilterNotifier)
final facilityFilterNotifierProvider =
    AutoDisposeNotifierProvider<FacilityFilterNotifier, String>.internal(
      FacilityFilterNotifier.new,
      name: r'facilityFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$facilityFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FacilityFilterNotifier = AutoDisposeNotifier<String>;
String _$searchQueryNotifierHash() =>
    r'568197ef1fbf916dec73e732479bb31def14847a';

/// See also [SearchQueryNotifier].
@ProviderFor(SearchQueryNotifier)
final searchQueryNotifierProvider =
    AutoDisposeNotifierProvider<SearchQueryNotifier, String>.internal(
      SearchQueryNotifier.new,
      name: r'searchQueryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchQueryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchQueryNotifier = AutoDisposeNotifier<String>;
String _$searchResultsNotifierHash() =>
    r'd02291f94a4615a4fe05ea0ffba098d95303c2e2';

/// See also [SearchResultsNotifier].
@ProviderFor(SearchResultsNotifier)
final searchResultsNotifierProvider =
    AutoDisposeNotifierProvider<SearchResultsNotifier, List<Facility>>.internal(
      SearchResultsNotifier.new,
      name: r'searchResultsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchResultsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchResultsNotifier = AutoDisposeNotifier<List<Facility>>;
String _$selectedFacilityTypeNotifierHash() =>
    r'882e2f54688530d1e1a237c89b1bd5a72d776e2e';

/// See also [SelectedFacilityTypeNotifier].
@ProviderFor(SelectedFacilityTypeNotifier)
final selectedFacilityTypeNotifierProvider =
    AutoDisposeNotifierProvider<
      SelectedFacilityTypeNotifier,
      FacilityType?
    >.internal(
      SelectedFacilityTypeNotifier.new,
      name: r'selectedFacilityTypeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedFacilityTypeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedFacilityTypeNotifier = AutoDisposeNotifier<FacilityType?>;
String _$facilityRepositoryNotifierHash() =>
    r'3bed20d65f2ec26f1d5432073bbe93d04100415c';

/// See also [FacilityRepositoryNotifier].
@ProviderFor(FacilityRepositoryNotifier)
final facilityRepositoryNotifierProvider =
    AutoDisposeNotifierProvider<
      FacilityRepositoryNotifier,
      FacilityRepository
    >.internal(
      FacilityRepositoryNotifier.new,
      name: r'facilityRepositoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$facilityRepositoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FacilityRepositoryNotifier = AutoDisposeNotifier<FacilityRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
