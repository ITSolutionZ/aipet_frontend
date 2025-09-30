import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:dio/dio.dart';

/// OpenWeatherMap One Call API 서비스
class OpenWeatherMapService {
  final Dio _dio;
  final String _apiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  OpenWeatherMapService({
    required Dio dio,
    required String apiKey,
  }) : _dio = dio, _apiKey = apiKey;

  /// 현재 날씨 및 예보 정보 가져오기
  Future<WeatherEntity> getCurrentWeather({
    required double latitude,
    required double longitude,
    String units = 'metric',
    String lang = 'ko',
  }) async {
    try {
      // 현재 날씨 정보 가져오기
      final weatherResponse = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': units,
          'lang': lang,
        },
      );

      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to load weather data: ${weatherResponse.statusCode}');
      }

      // UV Index 정보 가져오기 (별도 API)
      double uvIndex = 0.0;
      try {
        final uvResponse = await _dio.get(
          '$_baseUrl/uvi',
          queryParameters: {
            'lat': latitude,
            'lon': longitude,
            'appid': _apiKey,
          },
        );
        if (uvResponse.statusCode == 200) {
          uvIndex = uvResponse.data['value']?.toDouble() ?? 0.0;
        }
      } catch (e) {
        // UV 데이터 실패 시 기본값 사용
        uvIndex = 0.0;
      }

      return _parseWeatherData(weatherResponse.data, latitude, longitude, uvIndex);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// API 응답 데이터를 WeatherEntity로 변환
  WeatherEntity _parseWeatherData(Map<String, dynamic> data, double lat, double lon, [double uvIndex = 0.0]) {
    final main = data['main'] as Map<String, dynamic>;
    final weather = (data['weather'] as List).first as Map<String, dynamic>;
    final wind = data['wind'] as Map<String, dynamic>? ?? {};

    // 위치 정보 (역지오코딩 또는 기본값)
    final location = data['name'] ?? _getLocationName(lat, lon);

    return WeatherEntity(
      temperature: main['temp']?.toDouble() ?? 0.0,
      location: location,
      weatherId: weather['id']?.toInt() ?? 0,
      description: weather['description'] ?? '',
      feelsLike: main['feels_like']?.toDouble() ?? 0.0,
      humidity: main['humidity']?.toInt() ?? 0,
      windSpeed: wind['speed']?.toDouble() ?? 0.0,
      iconCode: weather['icon'] ?? '01d',
      uvIndex: uvIndex,
      visibility: data['visibility']?.toInt() ?? 10000,
      pressure: main['pressure']?.toDouble() ?? 1013.25,
    );
  }

  /// 위치명 반환 (간단한 매핑, 실제로는 역지오코딩 API 사용 권장)
  String _getLocationName(double lat, double lon) {
    // 도쿄 지역 체크 (예시)
    if (lat >= 35.0 && lat <= 36.0 && lon >= 139.0 && lon <= 140.0) {
      return '東京都品川区';
    }
    // 기본값
    return '현재 위치';
  }

  /// OpenWeatherMap 아이콘 코드를 Meteocons 파일명으로 매핑
  static String getMeteoconIcon(String openWeatherIcon) {
    // OpenWeatherMap 아이콘 코드 매핑
    final iconMap = {
      // 맑음 (Clear sky)
      '01d': 'clear-day',
      '01n': 'clear-night',

      // 약간 흐림 (Few clouds: 11-25%)
      '02d': 'partly-cloudy-day',
      '02n': 'partly-cloudy-night',

      // 흩어진 구름 (Scattered clouds: 25-50%)
      '03d': 'cloudy',
      '03n': 'cloudy',

      // 깨진 구름 (Broken clouds: 51-84%)
      '04d': 'overcast',
      '04n': 'overcast',

      // 소나기 (Shower rain)
      '09d': 'drizzle',
      '09n': 'drizzle',

      // 비 (Rain)
      '10d': 'rain',
      '10n': 'rain',

      // 천둥번개 (Thunderstorm)
      '11d': 'thunderstorms',
      '11n': 'thunderstorms',

      // 눈 (Snow)
      '13d': 'snow',
      '13n': 'snow',

      // 안개/박무 (Mist, Fog, Haze)
      '50d': 'fog',
      '50n': 'fog',
    };

    return iconMap[openWeatherIcon] ?? 'not-available';
  }

  /// 날씨 ID 기반 상세 아이콘 매핑 (더 정확한 매핑을 위해)
  static String getDetailedMeteoconIcon(int weatherId, String iconCode) {
    final isDayTime = iconCode.endsWith('d');

    // 2xx: 천둥번개
    if (weatherId >= 200 && weatherId < 300) {
      if (weatherId == 200 || weatherId == 201 || weatherId == 202) {
        return isDayTime ? 'thunderstorms-day-rain' : 'thunderstorms-night-rain';
      }
      return isDayTime ? 'thunderstorms-day' : 'thunderstorms-night';
    }

    // 3xx: 이슬비
    if (weatherId >= 300 && weatherId < 400) {
      return isDayTime ? 'partly-cloudy-day-drizzle' : 'partly-cloudy-night-drizzle';
    }

    // 5xx: 비
    if (weatherId >= 500 && weatherId < 600) {
      if (weatherId == 500 || weatherId == 501) {
        return isDayTime ? 'partly-cloudy-day-rain' : 'partly-cloudy-night-rain';
      }
      return 'rain';
    }

    // 6xx: 눈
    if (weatherId >= 600 && weatherId < 700) {
      if (weatherId == 600 || weatherId == 601) {
        return isDayTime ? 'partly-cloudy-day-snow' : 'partly-cloudy-night-snow';
      }
      if (weatherId == 611 || weatherId == 612 || weatherId == 613) {
        return 'sleet';
      }
      return 'snow';
    }

    // 7xx: 대기 현상 (안개, 연무 등)
    if (weatherId >= 700 && weatherId < 800) {
      if (weatherId == 701 || weatherId == 741) {
        return 'fog';
      }
      if (weatherId == 721) {
        return isDayTime ? 'haze-day' : 'haze-night';
      }
      if (weatherId == 731 || weatherId == 751 || weatherId == 761) {
        return isDayTime ? 'dust-day' : 'dust-night';
      }
      return 'fog';
    }

    // 800: 맑음
    if (weatherId == 800) {
      return isDayTime ? 'clear-day' : 'clear-night';
    }

    // 80x: 구름
    if (weatherId > 800 && weatherId < 900) {
      if (weatherId == 801) {
        return isDayTime ? 'partly-cloudy-day' : 'partly-cloudy-night';
      }
      if (weatherId == 802) {
        return 'cloudy';
      }
      return 'overcast';
    }

    // 기본값 (기존 매핑 사용)
    return getMeteoconIcon(iconCode);
  }
}