// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 초기화 상태를 관리하는 Provider
///
/// 앱 시작 시 필요한 모든 초기화 작업을 관리하고 상태를 추적합니다.

@ProviderFor(AppInitialization)
const appInitializationProvider = AppInitializationProvider._();

/// 앱 초기화 상태를 관리하는 Provider
///
/// 앱 시작 시 필요한 모든 초기화 작업을 관리하고 상태를 추적합니다.
final class AppInitializationProvider
    extends $NotifierProvider<AppInitialization, AppInitializationState> {
  /// 앱 초기화 상태를 관리하는 Provider
  ///
  /// 앱 시작 시 필요한 모든 초기화 작업을 관리하고 상태를 추적합니다.
  const AppInitializationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInitializationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInitializationHash();

  @$internal
  @override
  AppInitialization create() => AppInitialization();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppInitializationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppInitializationState>(value),
    );
  }
}

String _$appInitializationHash() => r'42ff1f976fac2c979bdc201c79c0f633e3ee93ea';

/// 앱 초기화 상태를 관리하는 Provider
///
/// 앱 시작 시 필요한 모든 초기화 작업을 관리하고 상태를 추적합니다.

abstract class _$AppInitialization extends $Notifier<AppInitializationState> {
  AppInitializationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AppInitializationState, AppInitializationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppInitializationState, AppInitializationState>,
              AppInitializationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
