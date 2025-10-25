import 'dart:convert';

import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const String _geocodingUrl = 'https://api.openweathermap.org/geo/1.0';

  Future<WeatherData?> getCurrentWeather({
    WeatherLocation? location,
    bool userTriggered = false,
  }) async {
    try {
      LoggerService.debug(
        '🌤️ =============[ WeatherService 호출 ]=============',
      );
      LoggerService.debug(
        '📍 전달받은 위치: ${location != null ? '${location.name} (${location.latitude}, ${location.longitude})' : 'null - ユーザーのGPS位置を使用'}',
      );
      LoggerService.debug('👤 사용자 직접 요청: $userTriggered');

      // 위치가 지정되지 않은 경우 사용자의 실제 GPS 위치 사용
      final weatherLocation = location ?? await _getCurrentLocation();
      LoggerService.debug(
        '📍 최종 사용 위치: ${weatherLocation?.name ?? 'null'} (${weatherLocation?.latitude}, ${weatherLocation?.longitude})',
      );
      if (weatherLocation == null) return null;

      // Primary API 키 확인, 없으면 Base API 키 사용
      String apiKey = AppConfig.current.weatherApiKey;
      if (apiKey.isEmpty) {
        LoggerService.debug('⚠️ Primary Weather API 키 없음 - Base API 키 시도');
        apiKey = AppConfig.current.baseApiKey;
      }

      if (apiKey.isEmpty) {
        // 테스트 환경에서는 Mock 데이터 사용
        if (AppConfig.current.environment == 'test') {
          LoggerService.debug('🧪 테스트 환경 - Mock 날씨 데이터 사용');
          return _getMockWeatherData(weatherLocation.name);
        }
        LoggerService.debug('❌ 모든 Weather API 키가 없음 - Mock 데이터 사용');
        return _getMockWeatherData(weatherLocation.name);
      }

      LoggerService.debug('🔑 Weather API 키 상태: 설정됨');
      LoggerService.debug('🎯 기본 API 호출 시작...');

      // 기본 API 직접 사용 (One Call API 3.0 스킵)
      return await _getCurrentWeatherFallback(weatherLocation);
    } catch (e) {
      // 기본 API 실패시 목업 데이터 사용
      LoggerService.debug('❌ 날씨 API 호출 실패: $e');
      LoggerService.debug('🔄 목업 데이터 사용');
      final weatherLocation = location ?? _getDefaultLocation();
      return _getMockWeatherData(weatherLocation.name);
    }
  }

  // 기본 날씨 API로 폴백
  Future<WeatherData?> _getCurrentWeatherFallback(
    WeatherLocation weatherLocation,
  ) async {
    // Primary API 키 확인, 없으면 Base API 키 사용
    String apiKey = AppConfig.current.weatherApiKey;
    if (apiKey.isEmpty) {
      LoggerService.debug('⚠️ Fallback: Primary API 키 없음 - Base API 키 시도');
      apiKey = AppConfig.current.baseApiKey;
    }

    if (apiKey.isEmpty) {
      LoggerService.debug('❌ Fallback: 모든 API 키 없음 - Mock 데이터 반환');
      return _getMockWeatherData(weatherLocation.name);
    }
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${weatherLocation.latitude}&lon=${weatherLocation.longitude}&appid=$apiKey&units=metric&lang=ja',
    );

    LoggerService.debug('🔄 기본 API 호출: $url');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    LoggerService.debug('📡 기본 API 응답: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;

      LoggerService.debug('📊 基本 API 응답 데이터:');
      LoggerService.debug(
        '  - 위치: ${weatherLocation.name} (${weatherLocation.latitude}, ${weatherLocation.longitude})',
      );
      LoggerService.debug('  - 현재 온도: ${data['main']?['temp']}°C');
      LoggerService.debug('  - 날씨: ${data['weather']?[0]?['description']}');

      final weatherData = WeatherData.fromJson(data, weatherLocation.name);

      LoggerService.debug(
        '✅ 基本 API 날씨 데이터 생성 완료: ${weatherData.location}, ${weatherData.temperature}°C',
      );
      // _lastRequestTime = DateTime.now();
      return weatherData;
    } else if (response.statusCode == 401) {
      // API 키 문제시 목업 데이터 사용
      LoggerService.debug('❌ 기본 API 401 에러 - 목업 데이터 사용');
      return _getMockWeatherData(weatherLocation.name);
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  Future<WeatherLocation?> _getCurrentLocation() async {
    // 현재 환경 및 설정 로깅
    LoggerService.debug('🔍 =============[ ユーザー位置取得 開始 ]=============');
    LoggerService.debug('🌍 現在環境: ${AppConfig.current.environment}');
    LoggerService.debug(
      '🔑 Weather API キー設定状態: ${AppConfig.current.weatherApiKey.isNotEmpty ? '設定済み' : '未設定'}',
    );

    // 테스트 환경에서는 바로 기본 위치 사용
    if (AppConfig.current.environment == 'test') {
      LoggerService.debug('🧪 テスト環境 - デフォルト位置(東京)使用');
      return _getDefaultLocation();
    }

    try {
      // 실제 GPS 위치를 먼저 시도 (사용자의 현재 위치)
      LoggerService.debug('📍 ユーザーの実際のGPS位置取得を試行中...');
      final realLocation = await _getRealLocation();
      if (realLocation != null) {
        LoggerService.debug(
          '✅ GPS位置取得成功: ${realLocation.name} (${realLocation.latitude}, ${realLocation.longitude})',
        );
        return realLocation;
      }
    } catch (e) {
      LoggerService.debug('❌ GPS位置取得失敗: $e');
    }

    // GPS 실패 시 기본 위치(도쿄 시나가와구) 사용
    LoggerService.debug('🏙️ GPS失敗のためデフォルト位置(東京都品川区)を使用');
    return _getDefaultLocation();
  }

  // 실제 GPS 위치를 가져오는 메서드 (사용자의 현재 위치)
  Future<WeatherLocation?> _getRealLocation() async {
    try {
      LoggerService.debug('🌍 位置サービス確認開始...');

      // 1. 위치 서비스 활성화 확인
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        LoggerService.debug('❌ 位置サービスが無効です。デフォルト位置を使用します。');
        return _getDefaultLocation();
      }
      LoggerService.debug('✅ 位置サービスが有効です');

      // 2. 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      LoggerService.debug('📍 現在の位置権限: $permission');

      if (permission == LocationPermission.denied) {
        LoggerService.debug('🔒 位置権限をリクエスト中...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          LoggerService.debug('❌ 位置権限が拒否されました。デフォルト位置を使用します。');
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        LoggerService.debug('❌ 位置権限が永久に拒否されました。設定から権限を有効にしてください。');
        return _getDefaultLocation();
      }

      // 3. GPS로 실제 사용자 위치 취득
      LoggerService.debug('📱 ユーザーのGPS位置を取得中... (精度: high, タイムアウト: 10秒)');
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high, // 높은 정확도로 변경
              timeLimit: Duration(seconds: 10),
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              LoggerService.debug('❌ GPS位置取得タイムアウト - デフォルト位置を使用');
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
      LoggerService.debug(
        '📍 取得した座標: (${position.latitude}, ${position.longitude}), 精度: ${position.accuracy}m',
      );
      final locationName = await _getLocationName(
        position.latitude,
        position.longitude,
      );

      LoggerService.debug('✅ ユーザーGPS位置取得成功: $locationName');
      return WeatherLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: locationName,
      );
    } catch (e) {
      LoggerService.debug('❌ 位置取得エラー: $e - デフォルト位置を使用');
      return _getDefaultLocation();
    }
  }

  // 위치명을 가져오는 메서드
  Future<String> _getLocationName(double lat, double lon) async {
    try {
      // Primary API 키 확인, 없으면 Base API 키 사용
      String apiKey = AppConfig.current.weatherApiKey;
      if (apiKey.isEmpty) {
        apiKey = AppConfig.current.baseApiKey;
      }

      if (apiKey.isEmpty) {
        LoggerService.debug('⚠️ Weather API キーがありません - 座標を使用します');
        return _formatCoordinatesAsLocation(lat, lon);
      }

      LoggerService.debug('🔍 位置名検索中: ($lat, $lon)');
      final url = Uri.parse(
        '$_geocodingUrl/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey&lang=ja',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              LoggerService.debug('❌ Geocoding APIタイムアウト - 座標を使用');
              return http.Response('timeout', 408);
            },
          );

      LoggerService.debug('🌐 Geocoding API 応答: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        LoggerService.debug('📍 Geocoding データ: ${data.length}件');

        if (data.isNotEmpty) {
          final location = data.first as Map<String, dynamic>;
          final city = location['name'] as String? ?? '';
          final state = location['state'] as String? ?? '';
          final country = location['country'] as String? ?? '';

          LoggerService.debug('📍 取得した位置情報: 国=$country, 州/県=$state, 市=$city');

          // 위치명 생성 (모든 국가 지원)
          String locationName;
          if (state.isNotEmpty && city.isNotEmpty) {
            locationName = '$state $city';
          } else if (state.isNotEmpty) {
            locationName = state;
          } else if (city.isNotEmpty) {
            locationName = city;
          } else if (country.isNotEmpty) {
            locationName = country;
          } else {
            // 모든 정보가 없으면 좌표 사용
            locationName = _formatCoordinatesAsLocation(lat, lon);
          }

          LoggerService.debug('✅ 位置名確定: $locationName ($country)');
          return locationName;
        } else {
          LoggerService.debug('⚠️ Geocoding データが空 - 座標を使用');
          return _formatCoordinatesAsLocation(lat, lon);
        }
      } else if (response.statusCode == 401) {
        LoggerService.debug('❌ Geocoding API認証エラー (401) - 座標を使用');
        return _formatCoordinatesAsLocation(lat, lon);
      } else {
        LoggerService.debug(
          '❌ Geocoding APIエラー: ${response.statusCode} - 座標を使用',
        );
        return _formatCoordinatesAsLocation(lat, lon);
      }
    } catch (e) {
      LoggerService.debug('❌ 位置名取得失敗: $e - 座標を使用');
      return _formatCoordinatesAsLocation(lat, lon);
    }
  }

  // 좌표를 읽기 쉬운 위치명으로 포맷
  String _formatCoordinatesAsLocation(double lat, double lon) {
    // 주요 도시 좌표 기반 추정 (대략적인 위치)
    final estimatedCity = _estimateCityFromCoordinates(lat, lon);
    if (estimatedCity != null) {
      LoggerService.debug('📍 推定位置: $estimatedCity (座標: $lat, $lon)');
      return estimatedCity;
    }

    // 좌표 기반 표시 (fallback)
    final latStr = lat.abs().toStringAsFixed(2);
    final lonStr = lon.abs().toStringAsFixed(2);
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';

    final locationName = '$latStr°$latDir $lonStr°$lonDir';
    LoggerService.debug('📍 座標ベース位置名: $locationName');
    return locationName;
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
      {'name': 'Seoul', 'lat': 37.57, 'lon': 126.98, 'range': 0.8},
      {'name': 'Busan', 'lat': 35.18, 'lon': 129.08, 'range': 0.5},
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
    LoggerService.debug('🏙️ デフォルト位置를 사용: 東京都品川区');
    return const WeatherLocation(
      latitude: 35.6092,
      longitude: 139.7301,
      name: '東京都品川区',
    );
  }

  // 마지막 API 요청 시간 추적 (향후 사용 예정)
  // static DateTime? _lastRequestTime;

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
