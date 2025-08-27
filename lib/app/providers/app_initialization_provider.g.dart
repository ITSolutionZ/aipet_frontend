// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appInitializationHash() => r'370ea87285d5ea8ca324fce8da381e33fd698b19';

/// 앱 초기화 상태 관리
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
