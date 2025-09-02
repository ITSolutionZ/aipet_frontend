import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../../app/config/app_config.dart';
import '../../../../shared/mock_data/mock_data_service.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _oneCallUrl =
      'https://api.openweathermap.org/data/3.0/onecall';
  static const String _geocodingUrl = 'http://api.openweathermap.org/geo/1.0';

  Future<WeatherData?> getCurrentWeather({WeatherLocation? location}) async {
    try {
      final weatherLocation = location ?? await _getCurrentLocation();
      if (weatherLocation == null) return null;

      final apiKey = AppConfig.current.weatherApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Weather API key not found');
      }

      debugPrint(
        '🔑 API 키 상태: ${apiKey.isNotEmpty ? "존재함 (${apiKey.length}자)" : "없음"}',
      );
      debugPrint('🎯 API 키 검증을 위한 One Call API 3.0 시도 중...');

      // One Call 3.0 API 사용
      final url = Uri.parse(
        '$_oneCallUrl?lat=${weatherLocation.latitude}&lon=${weatherLocation.longitude}&appid=$apiKey&units=metric&lang=ja&exclude=minutely,alerts',
      );

      debugPrint('🌐 One Call API 3.0 호출: $url');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      debugPrint('📡 One Call API 3.0 응답: ${response.statusCode}');

      if (response.statusCode == 401) {
        debugPrint('❌ One Call API 401 에러 상세:');
        debugPrint('   - 응답 본문: ${response.body}');
        debugPrint('   - API 키 길이: ${apiKey.length}');
        debugPrint(
          '   - API 키 첫 8자: ${apiKey.length > 8 ? apiKey.substring(0, 8) : 'too_short'}...',
        );
        debugPrint('💡 해결책: OpenWeatherMap 계정에서 One Call API 구독 확인 필요');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint(
          '✅ One Call API 3.0 성공 - UV: ${data['current']['uvi']}, Wind: ${data['current']['wind_speed']}',
        );
        return WeatherData.fromOneCallJson(data, weatherLocation.name);
      } else {
        // 에러 발생 시 기본 API로 폴백 (One Call API 권한 없는 경우)
        debugPrint('❌ One Call API 에러: ${response.statusCode} - 기본 API로 폴백');
        return await _getCurrentWeatherFallback(weatherLocation);
      }
    } catch (e) {
      // One Call API 실패시 기본 API로 폴백 또는 목업 데이터 사용
      try {
        final weatherLocation = location ?? await _getCurrentLocation();
        if (weatherLocation != null) {
          return await _getCurrentWeatherFallback(weatherLocation);
        }
      } catch (fallbackError) {
        // 모든 API 실패시 목업 데이터 사용
        debugPrint('❌ 모든 API 호출 실패 - 목업 데이터 사용');
        final weatherLocation = location ?? _getDefaultLocation();
        return _getMockWeatherData(weatherLocation.name);
      }
      throw Exception('Weather API error: $e');
    }
  }

  // 기본 날씨 API로 폴백
  Future<WeatherData?> _getCurrentWeatherFallback(
    WeatherLocation weatherLocation,
  ) async {
    final apiKey = AppConfig.current.weatherApiKey;
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${weatherLocation.latitude}&lon=${weatherLocation.longitude}&appid=$apiKey&units=metric&lang=ja',
    );

    debugPrint('🔄 기본 API 호출: $url');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    debugPrint('📡 기본 API 응답: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final wind = data['wind'] as Map<String, dynamic>? ?? {};
      final windSpeed = wind['speed'] ?? 0.0;
      final weatherId = (data['weather'] as List).first['id'] as int;
      final estimatedUV = _estimateUvIndex(weatherId);
      debugPrint('✅ 기본 API 성공 - Wind: ${windSpeed}m/s, UV: $estimatedUV (추정값)');
      return WeatherData.fromJson(data, weatherLocation.name);
    } else if (response.statusCode == 401) {
      // API 키 문제시 목업 데이터 사용
      debugPrint('❌ 기본 API 401 에러 - 목업 데이터 사용');
      return _getMockWeatherData(weatherLocation.name);
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  Future<WeatherLocation?> _getCurrentLocation() async {
    try {
      // 실제 GPS 위치를 먼저 시도
      debugPrint('🌍 실제 GPS 위치 취득 시도 중...');
      final realLocation = await _getRealLocation();
      if (realLocation != null) {
        debugPrint('✅ GPS 위치 취득 성공: ${realLocation.name}');
        return realLocation;
      }
    } catch (e) {
      debugPrint('❌ GPS 위치 취득 실패: $e');
    }

    // GPS 실패 시 기본 위치(도쿄 시나가와구) 사용
    debugPrint('🏙️ GPS 실패로 인해 기본 위치(도쿄 시나가와구) 사용');
    return _getDefaultLocation();
  }

  // 실제 GPS 위치를 가져오는 메서드
  Future<WeatherLocation?> _getRealLocation() async {
    try {
      debugPrint('🌍 위치 서비스 확인 시작...');

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ 위치 서비스가 비활성화되어 있습니다. 기본 위치(도쿄) 사용');
        return _getDefaultLocation();
      }
      debugPrint('✅ 위치 서비스 활성화됨');

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 현재 위치 권한: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('🔒 위치 권한 요청 중...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ 위치 권한이 거부되었습니다. 기본 위치(도쿄) 사용');
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ 위치 권한이 영구적으로 거부되었습니다. 기본 위치(도쿄) 사용');
        return _getDefaultLocation();
      }

      debugPrint('📱 GPS 위치 취득 시도 중...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint('✅ GPS 위치 취득 성공: ${position.latitude}, ${position.longitude}');

      final locationName = await _getLocationName(
        position.latitude,
        position.longitude,
      );

      debugPrint('🏷️ 위치명: $locationName');

      return WeatherLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: locationName,
      );
    } catch (e) {
      debugPrint('❌ 위치 취득 실패: $e. 기본 위치(도쿄) 사용');
      return _getDefaultLocation();
    }
  }

  // 위치명을 가져오는 메서드
  Future<String> _getLocationName(double lat, double lon) async {
    try {
      final apiKey = AppConfig.current.weatherApiKey;
      if (apiKey.isEmpty) {
        debugPrint('⚠️ Weather API 키가 없습니다');
        return '現在地';
      }

      debugPrint('🔍 위치명 검색 중: $lat, $lon');
      final url = Uri.parse(
        '$_geocodingUrl/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey&lang=ja',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));
      debugPrint('🌐 Geocoding API 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        debugPrint('📍 Geocoding 데이터: $data');

        if (data.isNotEmpty) {
          final location = data.first as Map<String, dynamic>;
          final city = location['name'] as String? ?? '';
          final state = location['state'] as String? ?? '';
          final country = location['country'] as String? ?? '';

          String locationName;
          if (state.isNotEmpty) {
            locationName = '$state $city';
          } else if (city.isNotEmpty) {
            locationName = city;
          } else if (country.isNotEmpty) {
            locationName = country;
          } else {
            locationName = '現在地';
          }

          debugPrint('✅ 위치명 결정: $locationName');
          return locationName;
        }
      } else {
        debugPrint('❌ Geocoding API 에러: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 위치명 취득 실패: $e');
    }
    return '現在地';
  }

  WeatherLocation _getDefaultLocation() {
    // 東京都品川区をデフォルト位置とする
    debugPrint('🏙️ デフォルト位置를 사용: 東京都品川区');
    return const WeatherLocation(
      latitude: 35.6092,
      longitude: 139.7301,
      name: '東京都品川区',
    );
  }

  // 날씨 상황과 시간대를 고려한 UV Index 추정
  double _estimateUvIndex(int weatherId) {
    final now = DateTime.now();
    final hour = now.hour;

    // 야간 (18시~6시): UV Index 0
    if (hour < 6 || hour >= 18) {
      return 0.0;
    }

    // 낮 시간대 기본 UV Index 계산 (위도 35.6도 도쿄 기준)
    double baseUv;
    if (hour >= 11 && hour <= 13) {
      baseUv = 8.0; // 정오 시간대 최고
    } else if (hour >= 10 && hour <= 14) {
      baseUv = 6.0; // 오전/오후
    } else if (hour >= 9 && hour <= 15) {
      baseUv = 4.0; // 이른 오전/늦은 오후
    } else {
      baseUv = 2.0; // 아침/저녁
    }

    // 날씨 상황에 따른 UV Index 보정
    if (weatherId >= 200 && weatherId < 300) {
      return baseUv * 0.3; // 뇌우: 70% 감소
    } else if (weatherId >= 300 && weatherId < 600) {
      return baseUv * 0.4; // 비: 60% 감소
    } else if (weatherId >= 600 && weatherId < 700) {
      return baseUv * 0.2; // 눈: 80% 감소
    } else if (weatherId >= 700 && weatherId < 800) {
      return baseUv * 0.5; // 안개/먼지: 50% 감소
    } else if (weatherId == 800) {
      return baseUv; // 맑음: 그대로
    } else if (weatherId >= 801 && weatherId <= 802) {
      return baseUv * 0.8; // 약간 흐림: 20% 감소
    } else if (weatherId >= 803 && weatherId <= 804) {
      return baseUv * 0.6; // 많이 흐림: 40% 감소
    }

    return baseUv * 0.7; // 기본값
  }

  /// API 실패 시 목업 날씨 데이터 반환
  WeatherData _getMockWeatherData(String locationName) {
    // 중앙화된 mock_data_service에서 목업 데이터 가져오기
    final mockWeatherInfo = MockDataService.getMockWeatherInfo();

    // 시간대에 따른 온도 시뮬레이션 (기존 로직 유지)
    final now = DateTime.now();
    final hour = now.hour;

    double temperature = mockWeatherInfo.temperature;
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
      description: mockWeatherInfo.condition,
      feelsLike: temperature + 2.0,
      humidity: 65,
      windSpeed: 2.5,
      iconCode: mockWeatherInfo.iconCode,
      uvIndex: _estimateUvIndex(800),
      visibility: 10000,
      pressure: 1013.25,
    );
  }
}
