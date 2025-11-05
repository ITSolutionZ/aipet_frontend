import '../../../../app/config/app_config.dart';
import '../../../../shared/shared.dart';
import '../models/weather_model.dart';
import 'location_service.dart';


/// 날씨 데이터 서비스 (비즈니스 로직 담당)
///
/// 위치 정보와 날씨 API를 조합하여 최終 날씨 데이터를 제공
class WeatherService extends BaseLoggingService {
  final OpenWeatherMapHttpClient _httpClient;
  final LocationService _locationService;

  WeatherService({
    OpenWeatherMapHttpClient? httpClient,
    LocationService? locationService,
  }) : _httpClient = httpClient ?? OpenWeatherMapHttpClient(),
       _locationService = locationService ?? LocationService(),
       super('weather_service');

  /// 現在の天気情報を取得
  ///
  /// [location] 指定位置（nullの場合はGPS位置を使用）
  /// [userTriggered] ユーザーが明示的にリフレッシュしたか
  Future<WeatherData?> getCurrentWeather({
    WeatherLocation? location,
    bool userTriggered = false,
  }) async {
    try {
      // 位置が指定されていない場合、LocationServiceを使用してGPS位置を取得
      final weatherLocation =
          location ?? await _locationService.getCurrentLocation();

      // API キー確認
      if (AppConfig.current.weatherApiKey.isEmpty &&
          AppConfig.current.baseApiKey.isEmpty) {
        logWarning('APIキーが設定されていません');
        return null;
      }

      // OpenWeatherMap API 呼び出し
      final response = await _httpClient.getCurrentWeather(
        latitude: weatherLocation.latitude,
        longitude: weatherLocation.longitude,
        lang: 'ja',
      );

      if (response.isSuccess && response.dataOrNull != null) {
        final data = response.dataOrNull!;
        final weatherData = WeatherData.fromJson(data, weatherLocation.name);
        logDebug('天気情報取得成功: ${weatherData.location}');
        return weatherData;
      } else {
        logWarning('天気API失敗: ${response.message}');
        return null;
      }
    } catch (e) {
      logError('天気情報取得エラー: $e');
      return null;
    }
  }
}
