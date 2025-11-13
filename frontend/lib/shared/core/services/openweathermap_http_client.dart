import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:dio/dio.dart';

/// 🌤️ OpenWeatherMap HTTP 클라이언트
///
/// OpenWeatherMap API와의 기본적인 HTTP 통신을 담당합니다.
/// 각 기능별 서비스에서 이 클라이언트를 사용하여 구체적인 비즈니스 로직을 구현합니다.
class OpenWeatherMapHttpClient extends BaseLoggingService {
  late final Dio _dio;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';

  OpenWeatherMapHttpClient() : super('openweathermap_http_client') {
    _initializeDio();
  }

  /// Dio 인스턴스 초기화
  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logInfo('Weather API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          logError('Weather API Error: ${error.message}', error);
          if (error.response != null) {
            logWarning('Status: ${error.response?.statusCode}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 현재 날씨 정보 가져오기
  Future<Result<Map<String, dynamic>>> getCurrentWeather({
    required double latitude,
    required double longitude,
    String units = 'metric',
    String lang = 'ja',
  }) async {
    final apiKey = _getApiKey();
    if (apiKey.isEmpty) {
      return Result.failure('Weather API 키가 설정되지 않았습니다');
    }

    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': apiKey,
          'units': units,
          'lang': lang,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return Result.success('날씨 정보를 가져왔습니다', response.data);
      } else {
        return Result.failure('날씨 정보 가져오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioException(e));
    } catch (e) {
      logError('Weather API 호출 실패: $e');
      return Result.failure('Weather API 호출 실패: $e');
    }
  }

  /// UV Index 가져오기
  Future<Result<double>> getUVIndex({
    required double latitude,
    required double longitude,
  }) async {
    final apiKey = _getApiKey();
    if (apiKey.isEmpty) {
      return Result.success('UV Index 기본값 사용', 0.0);
    }

    try {
      final response = await _dio.get(
        '/uvi',
        queryParameters: {'lat': latitude, 'lon': longitude, 'appid': apiKey},
      );

      if (response.statusCode == 200 && response.data != null) {
        final uvIndex = response.data['value']?.toDouble() ?? 0.0;
        return Result.success('UV Index를 가져왔습니다', uvIndex);
      } else {
        return Result.success('UV Index 기본값 사용', 0.0);
      }
    } catch (e) {
      logWarning('UV Index 가져오기 실패: $e');
      return Result.success('UV Index 기본값 사용', 0.0);
    }
  }

  /// 역지오코딩 (좌표 → 위치명)
  Future<Result<String>> reverseGeocode({
    required double latitude,
    required double longitude,
    String lang = 'ja',
  }) async {
    final apiKey = _getApiKey();
    if (apiKey.isEmpty) {
      return Result.failure('Weather API 키가 설정되지 않았습니다');
    }

    try {
      final url = Uri.parse(
        '$_geoUrl/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey&lang=$lang',
      );

      final response = await _dio.getUri(url);

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        if (data.isNotEmpty) {
          final location = data.first as Map<String, dynamic>;
          final city = location['name'] as String? ?? '';
          final state = location['state'] as String? ?? '';

          if (state.isNotEmpty && city.isNotEmpty) {
            return Result.success('위치명을 가져왔습니다', '$state $city');
          } else if (city.isNotEmpty) {
            return Result.success('위치명을 가져왔습니다', city);
          } else if (state.isNotEmpty) {
            return Result.success('위치명을 가져왔습니다', state);
          }
        }
      }

      return Result.failure('위치명을 찾을 수 없습니다');
    } catch (e) {
      logWarning('역지오코딩 실패: $e');
      return Result.failure('역지오코딩 실패: $e');
    }
  }

  /// API 키 가져오기 (Primary → Base 순서)
  String _getApiKey() {
    String apiKey = AppConfig.current.weatherApiKey;
    if (apiKey.isEmpty) {
      apiKey = AppConfig.current.baseApiKey;
    }
    return apiKey;
  }

  /// Dio 예외 처리
  String _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'タイムアウトが発生しました';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'ネットワーク接続エラーが発生しました';
    } else if (e.response?.statusCode == 401) {
      return 'APIキーが無効です';
    } else if (e.response?.statusCode == 404) {
      return '位置情報が見つかりません';
    } else {
      return '天気情報の取得中にエラーが発生しました';
    }
  }
}
