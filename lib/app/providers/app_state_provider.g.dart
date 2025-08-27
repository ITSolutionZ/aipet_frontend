// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appStateHash() => r'61bd04d66a1e6f6493361cae94ccb7114cd7dcde';

/// 앱 전체 상태 관리
///
/// Copied from [AppState].
@ProviderFor(AppState)
final appStateProvider =
    AutoDisposeNotifierProvider<AppState, AppStateData>.internal(
      AppState.new,
      name: r'appStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppState = AutoDisposeNotifier<AppStateData>;
String _$navigationStateHash() => r'c2ad8376d95e8af2e8c63da925cca74b64e062d3';

/// 네비게이션 상태 관리
///
/// Copied from [NavigationState].
@ProviderFor(NavigationState)
final navigationStateProvider =
    AutoDisposeNotifierProvider<NavigationState, NavigationStateData>.internal(
      NavigationState.new,
      name: r'navigationStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$navigationStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NavigationState = AutoDisposeNotifier<NavigationStateData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
