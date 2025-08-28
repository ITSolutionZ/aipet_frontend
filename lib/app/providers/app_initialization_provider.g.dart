// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appInitializationHash() => r'5c5acf523cc350bc70a0502635649f7b285f966c';

/// 앱 초기화 상태를 관리하는 Provider
///
/// 앱 시작 시 필요한 모든 초기화 작업을 관리하고 상태를 추적합니다.
///
/// Copied from [AppInitialization].
@ProviderFor(AppInitialization)
final appInitializationProvider =
    AutoDisposeNotifierProvider<
      AppInitialization,
      AppInitializationState
    >.internal(
      AppInitialization.new,
      name: r'appInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppInitialization = AutoDisposeNotifier<AppInitializationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
