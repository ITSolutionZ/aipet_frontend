// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoLoadWeatherHash() => r'e36e8ad7ee044870560895146d0a319ecaa41ca9';

/// 날씨 데이터 자동 로드 Provider
///
/// 앱 시작시 자동으로 날씨 데이터를 로드하고
/// 필요한 경우에만 업데이트를 수행
///
/// Copied from [autoLoadWeather].
@ProviderFor(autoLoadWeather)
final autoLoadWeatherProvider = AutoDisposeFutureProvider<void>.internal(
  autoLoadWeather,
  name: r'autoLoadWeatherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoLoadWeatherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutoLoadWeatherRef = AutoDisposeFutureProviderRef<void>;
String _$weatherNotifierHash() => r'9b86d11c379c1715c8f1dadc357b906c41ded8ad';

/// 중앙화된 날씨 데이터 Provider
///
/// 모든 Weather API 호출을 중앙에서 관리하여:
/// - API 호출 최적화 (중복 요청 방지)
/// - 통합 캐싱 전략
/// - 메모리 효율성
/// - 에러 처리 일원화
///
/// Copied from [WeatherNotifier].
@ProviderFor(WeatherNotifier)
final weatherNotifierProvider =
    AutoDisposeNotifierProvider<
      WeatherNotifier,
      AsyncValue<WeatherData?>
    >.internal(
      WeatherNotifier.new,
      name: r'weatherNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weatherNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WeatherNotifier = AutoDisposeNotifier<AsyncValue<WeatherData?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
