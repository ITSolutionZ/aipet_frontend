// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 스플래시 Repository Provider

@ProviderFor(splashRepository)
const splashRepositoryProvider = SplashRepositoryProvider._();

/// 스플래시 Repository Provider

final class SplashRepositoryProvider
    extends
        $FunctionalProvider<
          SplashRepository,
          SplashRepository,
          SplashRepository
        >
    with $Provider<SplashRepository> {
  /// 스플래시 Repository Provider
  const SplashRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashRepositoryHash();

  @$internal
  @override
  $ProviderElement<SplashRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SplashRepository create(Ref ref) {
    return splashRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplashRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplashRepository>(value),
    );
  }
}

String _$splashRepositoryHash() => r'89da06c2948df192ff41ba131dd4008faba9f393';

/// 스플래시 UseCase Provider들

@ProviderFor(manageSplashSequenceUseCase)
const manageSplashSequenceUseCaseProvider =
    ManageSplashSequenceUseCaseProvider._();

/// 스플래시 UseCase Provider들

final class ManageSplashSequenceUseCaseProvider
    extends
        $FunctionalProvider<
          ManageSplashSequenceUseCase,
          ManageSplashSequenceUseCase,
          ManageSplashSequenceUseCase
        >
    with $Provider<ManageSplashSequenceUseCase> {
  /// 스플래시 UseCase Provider들
  const ManageSplashSequenceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageSplashSequenceUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageSplashSequenceUseCaseHash();

  @$internal
  @override
  $ProviderElement<ManageSplashSequenceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ManageSplashSequenceUseCase create(Ref ref) {
    return manageSplashSequenceUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManageSplashSequenceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManageSplashSequenceUseCase>(value),
    );
  }
}

String _$manageSplashSequenceUseCaseHash() =>
    r'834471e69ff111d4b2578490d8c31c915f89fe61';

@ProviderFor(getSplashConfigUseCase)
const getSplashConfigUseCaseProvider = GetSplashConfigUseCaseProvider._();

final class GetSplashConfigUseCaseProvider
    extends
        $FunctionalProvider<
          GetSplashConfigUseCase,
          GetSplashConfigUseCase,
          GetSplashConfigUseCase
        >
    with $Provider<GetSplashConfigUseCase> {
  const GetSplashConfigUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSplashConfigUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSplashConfigUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSplashConfigUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSplashConfigUseCase create(Ref ref) {
    return getSplashConfigUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSplashConfigUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSplashConfigUseCase>(value),
    );
  }
}

String _$getSplashConfigUseCaseHash() =>
    r'50f9b0fc220df43ddee8dd015f6227e9b56fc7e0';

/// 스플래시 설정 Provider

@ProviderFor(splashConfig)
const splashConfigProvider = SplashConfigProvider._();

/// 스플래시 설정 Provider

final class SplashConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<SplashEntity>,
          SplashEntity,
          FutureOr<SplashEntity>
        >
    with $FutureModifier<SplashEntity>, $FutureProvider<SplashEntity> {
  /// 스플래시 설정 Provider
  const SplashConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashConfigHash();

  @$internal
  @override
  $FutureProviderElement<SplashEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SplashEntity> create(Ref ref) {
    return splashConfig(ref);
  }
}

String _$splashConfigHash() => r'2706786331e2026a3a99b8cd1a9567a74d81254e';

/// 스플래시 상태 관리 Notifier

@ProviderFor(SplashStateNotifier)
const splashStateProvider = SplashStateNotifierProvider._();

/// 스플래시 상태 관리 Notifier
final class SplashStateNotifierProvider
    extends $NotifierProvider<SplashStateNotifier, SplashState> {
  /// 스플래시 상태 관리 Notifier
  const SplashStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashStateNotifierHash();

  @$internal
  @override
  SplashStateNotifier create() => SplashStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplashState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplashState>(value),
    );
  }
}

String _$splashStateNotifierHash() =>
    r'ce3c88494fae991c22fa7ae6d8b4b4eef192f5fe';

/// 스플래시 상태 관리 Notifier

abstract class _$SplashStateNotifier extends $Notifier<SplashState> {
  SplashState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SplashState, SplashState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplashState, SplashState>,
              SplashState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 스플래시 Controller Provider

@ProviderFor(SplashControllerNotifier)
const splashControllerProvider = SplashControllerNotifierProvider._();

/// 스플래시 Controller Provider
final class SplashControllerNotifierProvider
    extends $NotifierProvider<SplashControllerNotifier, void> {
  /// 스플래시 Controller Provider
  const SplashControllerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashControllerNotifierHash();

  @$internal
  @override
  SplashControllerNotifier create() => SplashControllerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$splashControllerNotifierHash() =>
    r'0cf50abb305d931b41bab49a587d0f27b9af3089';

/// 스플래시 Controller Provider

abstract class _$SplashControllerNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
