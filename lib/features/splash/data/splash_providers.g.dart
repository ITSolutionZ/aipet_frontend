// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splashRepositoryHash() => r'89da06c2948df192ff41ba131dd4008faba9f393';

/// See also [splashRepository].
@ProviderFor(splashRepository)
final splashRepositoryProvider = AutoDisposeProvider<SplashRepository>.internal(
  splashRepository,
  name: r'splashRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashRepositoryRef = AutoDisposeProviderRef<SplashRepository>;
String _$splashConfigHash() => r'bcf6346c8c25a10f44de83069c25e96e9aec1787';

/// See also [splashConfig].
@ProviderFor(splashConfig)
final splashConfigProvider = AutoDisposeFutureProvider<SplashEntity>.internal(
  splashConfig,
  name: r'splashConfigProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashConfigRef = AutoDisposeFutureProviderRef<SplashEntity>;
String _$splashSequenceNotifierHash() =>
    r'75c960910ff08b4d6a801c9b66ac0a3dbaade571';

/// See also [SplashSequenceNotifier].
@ProviderFor(SplashSequenceNotifier)
final splashSequenceNotifierProvider =
    AutoDisposeNotifierProvider<SplashSequenceNotifier, SplashState>.internal(
      SplashSequenceNotifier.new,
      name: r'splashSequenceNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$splashSequenceNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SplashSequenceNotifier = AutoDisposeNotifier<SplashState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
