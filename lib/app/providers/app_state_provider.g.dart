// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 전체 상태를 관리하는 Provider
///
/// 앱의 전역 상태를 관리하며, 로딩, 에러, 시간, 온라인 상태 등을 추적합니다.

@ProviderFor(AppState)
const appStateProvider = AppStateProvider._();

/// 앱 전체 상태를 관리하는 Provider
///
/// 앱의 전역 상태를 관리하며, 로딩, 에러, 시간, 온라인 상태 등을 추적합니다.
final class AppStateProvider extends $NotifierProvider<AppState, AppStateData> {
  /// 앱 전체 상태를 관리하는 Provider
  ///
  /// 앱의 전역 상태를 관리하며, 로딩, 에러, 시간, 온라인 상태 등을 추적합니다.
  const AppStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStateHash();

  @$internal
  @override
  AppState create() => AppState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppStateData>(value),
    );
  }
}

String _$appStateHash() => r'61bd04d66a1e6f6493361cae94ccb7114cd7dcde';

/// 앱 전체 상태를 관리하는 Provider
///
/// 앱의 전역 상태를 관리하며, 로딩, 에러, 시간, 온라인 상태 등을 추적합니다.

abstract class _$AppState extends $Notifier<AppStateData> {
  AppStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppStateData, AppStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppStateData, AppStateData>,
              AppStateData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 네비게이션 상태 관리

@ProviderFor(NavigationState)
const navigationStateProvider = NavigationStateProvider._();

/// 네비게이션 상태 관리
final class NavigationStateProvider
    extends $NotifierProvider<NavigationState, NavigationStateData> {
  /// 네비게이션 상태 관리
  const NavigationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationStateHash();

  @$internal
  @override
  NavigationState create() => NavigationState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationStateData>(value),
    );
  }
}

String _$navigationStateHash() => r'c2ad8376d95e8af2e8c63da925cca74b64e062d3';

/// 네비게이션 상태 관리

abstract class _$NavigationState extends $Notifier<NavigationStateData> {
  NavigationStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NavigationStateData, NavigationStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationStateData, NavigationStateData>,
              NavigationStateData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
