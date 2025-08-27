// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splashAnimationTimerHash() =>
    r'2572e6336c0b2df2021af5f65dd8388f7cb22ada';

/// See also [splashAnimationTimer].
@ProviderFor(splashAnimationTimer)
final splashAnimationTimerProvider = AutoDisposeFutureProvider<void>.internal(
  splashAnimationTimer,
  name: r'splashAnimationTimerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashAnimationTimerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashAnimationTimerRef = AutoDisposeFutureProviderRef<void>;
String _$splashStateHash() => r'5a99f12dd8914a30723cf18e3b305350b9ad9a8d';

/// See also [SplashState].
@ProviderFor(SplashState)
final splashStateProvider =
    AutoDisposeNotifierProvider<SplashState, SplashStateData>.internal(
      SplashState.new,
      name: r'splashStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$splashStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SplashState = AutoDisposeNotifier<SplashStateData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
