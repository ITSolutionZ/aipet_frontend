// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FacilityListNotifier)
const facilityListProvider = FacilityListNotifierProvider._();

final class FacilityListNotifierProvider
    extends $AsyncNotifierProvider<FacilityListNotifier, List<Facility>> {
  const FacilityListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilityListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilityListNotifierHash();

  @$internal
  @override
  FacilityListNotifier create() => FacilityListNotifier();
}

String _$facilityListNotifierHash() =>
    r'fc8853a9779e546b9981cb36f3c81c9ebd0e8575';

abstract class _$FacilityListNotifier extends $AsyncNotifier<List<Facility>> {
  FutureOr<List<Facility>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Facility>>, List<Facility>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Facility>>, List<Facility>>,
              AsyncValue<List<Facility>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FacilityFilterNotifier)
const facilityFilterProvider = FacilityFilterNotifierProvider._();

final class FacilityFilterNotifierProvider
    extends $NotifierProvider<FacilityFilterNotifier, String> {
  const FacilityFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilityFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilityFilterNotifierHash();

  @$internal
  @override
  FacilityFilterNotifier create() => FacilityFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$facilityFilterNotifierHash() =>
    r'91a6723a5721eeb6b64ade31daf4100a798c775b';

abstract class _$FacilityFilterNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SearchQueryNotifier)
const searchQueryProvider = SearchQueryNotifierProvider._();

final class SearchQueryNotifierProvider
    extends $NotifierProvider<SearchQueryNotifier, String> {
  const SearchQueryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryNotifierHash();

  @$internal
  @override
  SearchQueryNotifier create() => SearchQueryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryNotifierHash() =>
    r'568197ef1fbf916dec73e732479bb31def14847a';

abstract class _$SearchQueryNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SearchResultsNotifier)
const searchResultsProvider = SearchResultsNotifierProvider._();

final class SearchResultsNotifierProvider
    extends $NotifierProvider<SearchResultsNotifier, List<Facility>> {
  const SearchResultsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsNotifierHash();

  @$internal
  @override
  SearchResultsNotifier create() => SearchResultsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Facility> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Facility>>(value),
    );
  }
}

String _$searchResultsNotifierHash() =>
    r'd02291f94a4615a4fe05ea0ffba098d95303c2e2';

abstract class _$SearchResultsNotifier extends $Notifier<List<Facility>> {
  List<Facility> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Facility>, List<Facility>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Facility>, List<Facility>>,
              List<Facility>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedFacilityTypeNotifier)
const selectedFacilityTypeProvider = SelectedFacilityTypeNotifierProvider._();

final class SelectedFacilityTypeNotifierProvider
    extends $NotifierProvider<SelectedFacilityTypeNotifier, FacilityType?> {
  const SelectedFacilityTypeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFacilityTypeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFacilityTypeNotifierHash();

  @$internal
  @override
  SelectedFacilityTypeNotifier create() => SelectedFacilityTypeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacilityType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacilityType?>(value),
    );
  }
}

String _$selectedFacilityTypeNotifierHash() =>
    r'882e2f54688530d1e1a237c89b1bd5a72d776e2e';

abstract class _$SelectedFacilityTypeNotifier extends $Notifier<FacilityType?> {
  FacilityType? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FacilityType?, FacilityType?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FacilityType?, FacilityType?>,
              FacilityType?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FacilityRepositoryNotifier)
const facilityRepositoryProvider = FacilityRepositoryNotifierProvider._();

final class FacilityRepositoryNotifierProvider
    extends $NotifierProvider<FacilityRepositoryNotifier, FacilityRepository> {
  const FacilityRepositoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilityRepositoryNotifierHash();

  @$internal
  @override
  FacilityRepositoryNotifier create() => FacilityRepositoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacilityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacilityRepository>(value),
    );
  }
}

String _$facilityRepositoryNotifierHash() =>
    r'3bed20d65f2ec26f1d5432073bbe93d04100415c';

abstract class _$FacilityRepositoryNotifier
    extends $Notifier<FacilityRepository> {
  FacilityRepository build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FacilityRepository, FacilityRepository>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FacilityRepository, FacilityRepository>,
              FacilityRepository,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 근처 시설 조회 Provider (Google Places API + 로컬 저장소)

@ProviderFor(nearbyFacilities)
const nearbyFacilitiesProvider = NearbyFacilitiesProvider._();

/// 근처 시설 조회 Provider (Google Places API + 로컬 저장소)

final class NearbyFacilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<Facility>>>,
          Result<List<Facility>>,
          FutureOr<Result<List<Facility>>>
        >
    with
        $FutureModifier<Result<List<Facility>>>,
        $FutureProvider<Result<List<Facility>>> {
  /// 근처 시설 조회 Provider (Google Places API + 로컬 저장소)
  const NearbyFacilitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyFacilitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyFacilitiesHash();

  @$internal
  @override
  $FutureProviderElement<Result<List<Facility>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<Facility>>> create(Ref ref) {
    return nearbyFacilities(ref);
  }
}

String _$nearbyFacilitiesHash() => r'5be28f599095f9f50957c767b03c3da3bca9e53b';

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)

@ProviderFor(facilitiesByType)
const facilitiesByTypeProvider = FacilitiesByTypeFamily._();

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)

final class FacilitiesByTypeProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<Facility>>>,
          Result<List<Facility>>,
          FutureOr<Result<List<Facility>>>
        >
    with
        $FutureModifier<Result<List<Facility>>>,
        $FutureProvider<Result<List<Facility>>> {
  /// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)
  const FacilitiesByTypeProvider._({
    required FacilitiesByTypeFamily super.from,
    required FacilityType super.argument,
  }) : super(
         retry: null,
         name: r'facilitiesByTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$facilitiesByTypeHash();

  @override
  String toString() {
    return r'facilitiesByTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<List<Facility>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<Facility>>> create(Ref ref) {
    final argument = this.argument as FacilityType;
    return facilitiesByType(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FacilitiesByTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$facilitiesByTypeHash() => r'18a1a6397f852cae1a35431124dc53035cf6a81b';

/// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)

final class FacilitiesByTypeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Result<List<Facility>>>,
          FacilityType
        > {
  const FacilitiesByTypeFamily._()
    : super(
        retry: null,
        name: r'facilitiesByTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 타입별 시설 조회 Provider (Google Places API + 로컬 저장소)

  FacilitiesByTypeProvider call(FacilityType type) =>
      FacilitiesByTypeProvider._(argument: type, from: this);

  @override
  String toString() => r'facilitiesByTypeProvider';
}
