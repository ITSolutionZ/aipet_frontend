import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';

/// 날씨 데이터 서비스 (비즈니스 로직 담당)
class WeatherService extends BaseLoggingService {
  final OpenWeatherMapHttpClient _httpClient;

  WeatherService({OpenWeatherMapHttpClient? httpClient})
    : _httpClient = httpClient ?? OpenWeatherMapHttpClient(),
      super('weather_service');

  Future<WeatherData?> getCurrentWeather({
    WeatherLocation? location,
    bool userTriggered = false,
  }) async {
    try {
      // 위치가 지정되지 않은 경우 사용자의 실제 GPS 위치 사용
      final weatherLocation = location ?? await _getCurrentLocation();
      if (weatherLocation == null) return null;

      // API 키 확인
      if (AppConfig.current.weatherApiKey.isEmpty &&
          AppConfig.current.baseApiKey.isEmpty) {
        // 테스트 환경에서는 Mock 데이터 사용
        if (AppConfig.current.environment == 'test') {
          return _getMockWeatherData(weatherLocation.name);
        }
        return _getMockWeatherData(weatherLocation.name);
      }

      // OpenWeatherMap API 호출
      final response = await _httpClient.getCurrentWeather(
        latitude: weatherLocation.latitude,
        longitude: weatherLocation.longitude,
        lang: 'ja',
      );

      if (response.isSuccess && response.dataOrNull != null) {
        final data = response.dataOrNull!;
        final weatherData = WeatherData.fromJson(data, weatherLocation.name);
        return weatherData;
      } else {
        return _getMockWeatherData(weatherLocation.name);
      }
    } catch (e) {
      // 기본 API 실패시 목업 데이터 사용
      final weatherLocation = location ?? _getDefaultLocation();
      return _getMockWeatherData(weatherLocation.name);
    }
  }

  Future<WeatherLocation?> _getCurrentLocation() async {
    // 테스트 환경에서는 바로 기본 위치 사용
    if (AppConfig.current.environment == 'test') {
      return _getDefaultLocation();
    }

    try {
      // 실제 GPS 위치를 먼저 시도 (사용자의 현재 위치)
      final realLocation = await _getRealLocation();
      if (realLocation != null) {
        return realLocation;
      }
    } catch (e) {
      // GPS 실패 시 기본 위치 사용
    }

    // GPS 실패 시 기본 위치(도쿄 시나가와구) 사용
    return _getDefaultLocation();
  }

  // 실제 GPS 위치를 가져오는 메서드 (사용자의 현재 위치)
  Future<WeatherLocation?> _getRealLocation() async {
    try {
      // 1. 위치 서비스 활성화 확인
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getDefaultLocation();
      }

      // 2. 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getDefaultLocation();
      }

      // 3. GPS로 실제 사용자 위치 취득
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              return Future.value(
                Position(
                  latitude: 35.6092,
                  longitude: 139.7301,
                  timestamp: DateTime.now(),
                  accuracy: 0.0,
                  altitude: 0.0,
                  altitudeAccuracy: 0.0,
                  heading: 0.0,
                  headingAccuracy: 0.0,
                  speed: 0.0,
                  speedAccuracy: 0.0,
                ),
              );
            },
          );

      // 4. 역지오코딩으로 위치명 가져오기
      final locationName = await _getLocationName(
        position.latitude,
        position.longitude,
      );

      return WeatherLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: locationName,
      );
    } catch (e) {
      return _getDefaultLocation();
    }
  }

  // 위치명을 가져오는 메서드
  Future<String> _getLocationName(double lat, double lon) async {
    try {
      // ✅ 새로운 HTTP 클라이언트의 역지오코딩 사용
      final result = await _httpClient.reverseGeocode(
        latitude: lat,
        longitude: lon,
        lang: 'ja',
      );

      if (result.isSuccess && result.dataOrNull != null) {
        final locationName = result.dataOrNull!;
        return locationName;
      } else {
        return _formatCoordinatesAsLocation(lat, lon);
      }
    } catch (e) {
      return _formatCoordinatesAsLocation(lat, lon);
    }
  }

  // 좌표를 읽기 쉬운 위치명으로 포맷
  String _formatCoordinatesAsLocation(double lat, double lon) {
    // 주요 도시 좌표 기반 추정 (대략적인 위치)
    final estimatedCity = _estimateCityFromCoordinates(lat, lon);
    if (estimatedCity != null) {
      return estimatedCity;
    }

    // 좌표 기반 표시 대신 일본어로 표시
    return '現在地';
  }

  // 좌표로 대략적인 도시 추정 (주요 도시만)
  String? _estimateCityFromCoordinates(double lat, double lon) {
    // 각 도시의 대략적인 범위 (±0.5도 정도)
    const cities = [
      {'name': '東京', 'lat': 35.68, 'lon': 139.76, 'range': 0.8},
      {'name': '大阪', 'lat': 34.69, 'lon': 135.50, 'range': 0.6},
      {'name': '名古屋', 'lat': 35.18, 'lon': 136.91, 'range': 0.5},
      {'name': '福岡', 'lat': 33.59, 'lon': 130.40, 'range': 0.5},
      {'name': '札幌', 'lat': 43.06, 'lon': 141.35, 'range': 0.6},
      {'name': 'ソウル', 'lat': 37.57, 'lon': 126.98, 'range': 0.8},
      {'name': '釜山', 'lat': 35.18, 'lon': 129.08, 'range': 0.5},
    ];

    for (final city in cities) {
      final cityLat = city['lat'] as double;
      final cityLon = city['lon'] as double;
      final range = city['range'] as double;

      // 거리 계산 (간단한 유클리드 거리)
      final distance = ((lat - cityLat).abs() + (lon - cityLon).abs()) / 2;

      if (distance < range) {
        return '${city['name']}付近';
      }
    }

    return null; // 알려진 도시가 아님
  }

  WeatherLocation _getDefaultLocation() {
    // 東京都品川区をデフォルト位置とする
    return const WeatherLocation(
      latitude: 35.6092,
      longitude: 139.7301,
      name: '東京都品川区',
    );
  }

  /// API 실패 시 목업 날씨 데이터 반환
  WeatherData _getMockWeatherData(String locationName) {
    // 시간대에 따른 온도 시뮬레이션
    final now = DateTime.now();
    final hour = now.hour;

    double temperature = 22.0; // 기본 온도
    if (hour >= 6 && hour < 12) {
      temperature = 18.0 + (hour - 6) * 1.5; // 아침: 18-27도
    } else if (hour >= 12 && hour < 18) {
      temperature = 27.0 - (hour - 12) * 0.5; // 오후: 27-24도
    } else if (hour >= 18 && hour < 22) {
      temperature = 24.0 - (hour - 18) * 1.0; // 저녁: 24-20도
    } else {
      temperature =
          20.0 - (hour >= 22 ? hour - 22 : hour + 2) * 0.5; // 밤: 20-16도
    }

    return WeatherData(
      temperature: temperature,
      location: locationName,
      weatherId: 800, // 맑음
      description: '晴れ',
      feelsLike: temperature + 2.0,
      humidity: 65,
      windSpeed: 2.5,
      iconCode: '01d',
      uvIndex: 5.0,
      visibility: 10000,
      pressure: 1013.25,
    );
  }
}
