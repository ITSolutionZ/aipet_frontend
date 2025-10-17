import 'package:aipet_frontend/features/home/data/services/openweathermap_service.dart';
import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather_providers.g.dart';

/// Dio 인스턴스 프로바이더
@riverpod
Dio dio(Ref ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}

/// OpenWeatherMap 서비스 프로바이더
@riverpod
OpenWeatherMapService openWeatherMapService(Ref ref) {
  final dio = ref.watch(dioProvider);

  // 환경 변수에서 API 키 가져오기
  const apiKey = String.fromEnvironment(
    'OPENWEATHERMAP_API_KEY',
    defaultValue: 'eaa2e523190e5b710c357125ad2c1ece', // fallback 키
  );

  return OpenWeatherMapService(dio: dio, apiKey: apiKey);
}

/// 현재 날씨 정보 프로바이더
@riverpod
class CurrentWeather extends _$CurrentWeather {
  @override
  Future<WeatherEntity> build({
    double latitude = 35.6762, // 도쿄 기본 좌표
    double longitude = 139.6503,
  }) async {
    final service = ref.watch(openWeatherMapServiceProvider);

    final result = await service.getCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      // 에러 발생 시 Mock 데이터 반환 (개발용)
      return _getMockWeatherData();
    }
  }

  /// 날씨 데이터 새로고침
  Future<void> refresh({double? latitude, double? longitude}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(openWeatherMapServiceProvider);
      final result = await service.getCurrentWeather(
        latitude: latitude ?? 35.6762,
        longitude: longitude ?? 139.6503,
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        // 에러 발생 시 Mock 데이터 반환
        return _getMockWeatherData();
      }
    });
  }

  /// Mock 날씨 데이터 (API 실패 시 fallback)
  WeatherEntity _getMockWeatherData() {
    return const WeatherEntity(
      temperature: 19.0,
      location: '東京都品川区',
      weatherId: 800, // 맑음
      description: '맑음',
      feelsLike: 19.5,
      humidity: 65,
      windSpeed: 4.1,
      iconCode: '01d', // 낮 맑음
      uvIndex: 4.8,
      visibility: 10000,
      pressure: 1013.25,
    );
  }
}

/// 위치 기반 날씨 정보 프로바이더 (GPS 사용 시)
@riverpod
class LocationBasedWeather extends _$LocationBasedWeather {
  @override
  Future<WeatherEntity> build() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 권한 거부 시 기본 위치 사용
          return _getWeatherWithDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // 권한 영구 거부 시 기본 위치 사용
        return _getWeatherWithDefaultLocation();
      }

      // 현재 위치 가져오기
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 현재 위치로 날씨 정보 가져오기
      final service = ref.read(openWeatherMapServiceProvider);
      final result = await service.getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        return _getWeatherWithDefaultLocation();
      }
    } catch (e) {
      // 에러 발생 시 기본 위치 사용
      return _getWeatherWithDefaultLocation();
    }
  }

  /// 기본 위치로 날씨 가져오기
  Future<WeatherEntity> _getWeatherWithDefaultLocation() async {
    final currentWeather = await ref.watch(
      currentWeatherProvider(latitude: 35.6762, longitude: 139.6503).future,
    );
    return currentWeather;
  }

  /// 위치 기반 날씨 새로고침
  Future<void> refreshWithLocation() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        // 현재 위치 가져오기
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // 현재 위치로 날씨 정보 업데이트
        final service = ref.read(openWeatherMapServiceProvider);
        final result = await service.getCurrentWeather(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (result.isSuccess && result.data != null) {
          return result.data!;
        } else {
          return _getWeatherWithDefaultLocation();
        }
      } catch (e) {
        return _getWeatherWithDefaultLocation();
      }
    });
  }
}
