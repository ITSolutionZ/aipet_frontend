import 'package:dio/dio.dart';


import '../../../../shared/shared.dart';
import '../../domain/domain.dart';


/// OpenWeatherMap One Call API 서비스
class OpenWeatherMapService {
  final Dio _dio;
  final String _apiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  OpenWeatherMapService({required Dio dio, required String apiKey})
    : _dio = dio,
      _apiKey = apiKey;

  /// 현在天気および予報情報を取得
  Future<Result<WeatherEntity>> getCurrentWeather({
    required double latitude,
    required double longitude,
    String units = 'metric',
    String lang = 'ko',
  }) async {
    try {
      // 現在天気情報を取得
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
        return Result.failure('天気情報の取得に失敗しました (${weatherResponse.statusCode})');
      }

      // UV Index 情報を取得（別API）
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
        // UV데이터 실패時は기본값 사용
        LoggerService.debug('UV Index取得失敗: $e');
        uvIndex = 0.0;
      }

      final weatherEntity = _parseWeatherData(
        weatherResponse.data,
        latitude,
        longitude,
        uvIndex,
      );

      return Result.success('天気情報を取得しました', weatherEntity);
    } on DioException catch (e) {
      LoggerService.debug('OpenWeatherMap API Error (Dio): ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Result.failure(
          'タイムアウトが発生しました',
          Exception('Timeout: ${e.message}'),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return Result.failure(
          'ネットワーク接続エラーが発生しました',
          Exception('Connection Error: ${e.message}'),
        );
      } else if (e.response?.statusCode == 401) {
        return Result.failure(
          'APIキーが無効です',
          Exception('Unauthorized: ${e.message}'),
        );
      } else if (e.response?.statusCode == 404) {
        return Result.failure(
          '位置情報が見つかりません',
          Exception('Not Found: ${e.message}'),
        );
      } else {
        return Result.failure(
          '天気情報の取得中にエラーが発生しました',
          Exception('Dio Error: ${e.message}'),
        );
      }
    } catch (e) {
      LoggerService.debug('OpenWeatherMap API Error: $e');
      return Result.failure(
        '予期しないエラーが発生しました',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// API 응답 데이터를 WeatherEntity로 변환
  WeatherEntity _parseWeatherData(
    Map<String, dynamic> data,
    double lat,
    double lon, [
    double uvIndex = 0.0,
  ]) {
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
}
