// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splashRepositoryHash() => r'89da06c2948df192ff41ba131dd4008faba9f393';

/// 스플래시 Repository Provider
///
/// Copied from [splashRepository].
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
String _$manageSplashSequenceUseCaseHash() =>
    r'834471e69ff111d4b2578490d8c31c915f89fe61';

/// 스플래시 UseCase Provider들
///
/// Copied from [manageSplashSequenceUseCase].
@ProviderFor(manageSplashSequenceUseCase)
final manageSplashSequenceUseCaseProvider =
    AutoDisposeProvider<ManageSplashSequenceUseCase>.internal(
      manageSplashSequenceUseCase,
      name: r'manageSplashSequenceUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manageSplashSequenceUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ManageSplashSequenceUseCaseRef =
    AutoDisposeProviderRef<ManageSplashSequenceUseCase>;
String _$getSplashConfigUseCaseHash() =>
    r'50f9b0fc220df43ddee8dd015f6227e9b56fc7e0';

/// See also [getSplashConfigUseCase].
@ProviderFor(getSplashConfigUseCase)
final getSplashConfigUseCaseProvider =
    AutoDisposeProvider<GetSplashConfigUseCase>.internal(
      getSplashConfigUseCase,
      name: r'getSplashConfigUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getSplashConfigUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSplashConfigUseCaseRef =
    AutoDisposeProviderRef<GetSplashConfigUseCase>;
String _$splashConfigHash() => r'944b909d7d1d3a3dd52c47ec93d53dc635f044db';

/// 스플래시 설정 Provider
///
/// Copied from [splashConfig].
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
String _$splashControllerHash() => r'950a154ea77b28434b27375d708080f4a079b12e';

/// 스플래시 Controller Provider
///
/// Copied from [splashController].
@ProviderFor(splashController)
final splashControllerProvider = AutoDisposeProvider<SplashController>.internal(
  splashController,
  name: r'splashControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashControllerRef = AutoDisposeProviderRef<SplashController>;
String _$splashStateNotifierHash() =>
    r'ce3c88494fae991c22fa7ae6d8b4b4eef192f5fe';

/// 스플래시 상태 관리 Notifier
///
/// Copied from [SplashStateNotifier].
@ProviderFor(SplashStateNotifier)
final splashStateNotifierProvider =
    AutoDisposeNotifierProvider<SplashStateNotifier, SplashState>.internal(
      SplashStateNotifier.new,
      name: r'splashStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$splashStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SplashStateNotifier = AutoDisposeNotifier<SplashState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
