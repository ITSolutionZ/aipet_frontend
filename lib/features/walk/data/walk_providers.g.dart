// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walkRepositoryHash() => r'23150736b318e48e42c1292230e1d72c61f0b043';

/// WalkRepository 프로바이더 (Mockito 버전)
///
/// Google Maps API는 실제 사용하되, 나머지 로직은 Mockito를 통해 테스트 가능
///
/// Copied from [walkRepository].
@ProviderFor(walkRepository)
final walkRepositoryProvider = AutoDisposeProvider<WalkRepository>.internal(
  walkRepository,
  name: r'walkRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$walkRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalkRepositoryRef = AutoDisposeProviderRef<WalkRepository>;
String _$legacyWalkRepositoryHash() =>
    r'dddc96496f1c1fc9f3cdfdc55af6dd5647e371a3';

/// Legacy WalkRepository 프로바이더 (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
///
/// Copied from [legacyWalkRepository].
@ProviderFor(legacyWalkRepository)
final legacyWalkRepositoryProvider =
    AutoDisposeProvider<WalkRepository>.internal(
      legacyWalkRepository,
      name: r'legacyWalkRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$legacyWalkRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LegacyWalkRepositoryRef = AutoDisposeProviderRef<WalkRepository>;
String _$walkRecordsNotifierHash() =>
    r'a2fb2196272bf426dc82877cc39119c3894b8324';

/// See also [WalkRecordsNotifier].
@ProviderFor(WalkRecordsNotifier)
final walkRecordsProvider =
    AutoDisposeNotifierProvider<
      WalkRecordsNotifier,
      List<WalkRecordEntity>
    >.internal(
      WalkRecordsNotifier.new,
      name: r'walkRecordsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$walkRecordsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WalkRecordsNotifier = AutoDisposeNotifier<List<WalkRecordEntity>>;
String _$currentWalkNotifierHash() =>
    r'6d77e16a457d52d289afdfcc10c632c473106bb7';

/// See also [CurrentWalkNotifier].
@ProviderFor(CurrentWalkNotifier)
final currentWalkProvider =
    AutoDisposeNotifierProvider<
      CurrentWalkNotifier,
      WalkRecordEntity?
    >.internal(
      CurrentWalkNotifier.new,
      name: r'currentWalkProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentWalkNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentWalkNotifier = AutoDisposeNotifier<WalkRecordEntity?>;
String _$selectedPetNotifierHash() =>
    r'9256aa8c03bb3ce5faa2205779e87190fe2931b5';

/// See also [SelectedPetNotifier].
@ProviderFor(SelectedPetNotifier)
final selectedPetNotifierProvider =
    AutoDisposeNotifierProvider<SelectedPetNotifier, PetInfo?>.internal(
      SelectedPetNotifier.new,
      name: r'selectedPetNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedPetNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedPetNotifier = AutoDisposeNotifier<PetInfo?>;
String _$mapExpandedNotifierHash() =>
    r'8430de25fd5ee62fa25923f379a5fdaa9edf21c3';

/// See also [MapExpandedNotifier].
@ProviderFor(MapExpandedNotifier)
final mapExpandedProvider =
    AutoDisposeNotifierProvider<MapExpandedNotifier, bool>.internal(
      MapExpandedNotifier.new,
      name: r'mapExpandedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mapExpandedNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MapExpandedNotifier = AutoDisposeNotifier<bool>;
String _$locationTrackingNotifierHash() =>
    r'5413808500159410587660761c1d68fd9bc497e6';

/// See also [LocationTrackingNotifier].
@ProviderFor(LocationTrackingNotifier)
final locationTrackingProvider =
    AutoDisposeNotifierProvider<LocationTrackingNotifier, bool>.internal(
      LocationTrackingNotifier.new,
      name: r'locationTrackingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationTrackingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationTrackingNotifier = AutoDisposeNotifier<bool>;
String _$currentLocationNotifierHash() =>
    r'4868415da7d6eef5070a9ebbc0d2bbc5cd29ec42';

/// See also [CurrentLocationNotifier].
@ProviderFor(CurrentLocationNotifier)
final currentLocationNotifierProvider =
    AutoDisposeNotifierProvider<
      CurrentLocationNotifier,
      WalkLocation?
    >.internal(
      CurrentLocationNotifier.new,
      name: r'currentLocationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentLocationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentLocationNotifier = AutoDisposeNotifier<WalkLocation?>;
String _$walkStatsNotifierHash() => r'214f1f5aa2ecd6ed899506edf7218caf26f25c29';

/// See also [WalkStatsNotifier].
@ProviderFor(WalkStatsNotifier)
final walkStatsNotifierProvider =
    AutoDisposeNotifierProvider<WalkStatsNotifier, WalkStats>.internal(
      WalkStatsNotifier.new,
      name: r'walkStatsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$walkStatsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WalkStatsNotifier = AutoDisposeNotifier<WalkStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
