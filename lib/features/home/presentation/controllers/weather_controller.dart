import '../../../../app/controllers/base_controller.dart';
import '../../../ai/data/services/openai_service.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/weather_service.dart';

class WeatherResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const WeatherResult._(this.isSuccess, this.message, this.data);

  factory WeatherResult.success(String message, [dynamic data]) =>
      WeatherResult._(true, message, data);
  factory WeatherResult.failure(String message) =>
      WeatherResult._(false, message, null);
}

class WeatherController extends BaseController {
  WeatherController(super.ref);

  final WeatherService _weatherService = WeatherService();
  final OpenAIService _openAIService = OpenAIService();
  WeatherData? _currentWeatherData;
  String? _cachedWalkingAdvice;
  DateTime? _adviceCacheTime;
  static const Duration _adviceCacheValidDuration = Duration(hours: 1); // 산책 조언 1시간 캐시

  // 아이콘 관련 메서드들은 WeatherIconController로 분리됨

  /// 현재 시간이 낮인지 확인
  bool isDayTime() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 6 && hour < 18;
  }

  /// 현재 날씨 데이터 가져오기
  Future<WeatherResult> getCurrentWeather({bool userTriggered = false}) async {
    try {
      final weatherData = await _weatherService.getCurrentWeather(
        userTriggered: userTriggered,
      );
      if (weatherData != null) {
        _currentWeatherData = weatherData;
        return WeatherResult.success('날씨 정보를 가져왔습니다', weatherData);
      } else {
        return WeatherResult.failure('날씨 정보를 가져올 수 없습니다');
      }
    } catch (e) {
      handleError(e);
      return WeatherResult.failure('날씨 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 캐시된 날씨 데이터 반환
  WeatherData? get cachedWeatherData => _currentWeatherData;

  /// 날씨 데이터가 있는지 확인
  bool get hasWeatherData => _currentWeatherData != null;

  /// 날씨 기반 산책 조언 생성
  Future<WeatherResult> generateWalkingAdvice() async {
    try {
      if (_currentWeatherData == null) {
        return WeatherResult.failure('날씨 데이터가 없습니다');
      }

      // 캐시된 조언 확인
      if (_isAdviceCacheValid()) {
        return WeatherResult.success('캐시된 산책 조언', _cachedWalkingAdvice!);
      }

      final weatherData = _currentWeatherData!;
      final prompt =
          '''以下の天気データを基に、ペットの散歩について１つの短い日本語文で実用的なアドバイスをしてください。

天気情報:
気温: ${weatherData.temperature.round()}°C
体感温度: ${weatherData.feelsLike.round()}°C
湿度: ${weatherData.humidity}%
風速: ${weatherData.windSpeed.toStringAsFixed(1)}m/s
UV指数: ${weatherData.uvIndex.toStringAsFixed(1)}
天気: ${weatherData.description}

回答条件:
- １文のみ
- 15文字以内
- ペットの安全最優先
- 日本語のみ
- 絵文字禁止
- 説明不要

例: 今日は散歩に最適です''';

      final advice = await _openAIService.generateResponse(prompt);

      // 応答から最初の文のみ抽出（句読点で区切り）
      String cleanAdvice = advice.trim();

      // 改行があれば最初の行のみ
      if (cleanAdvice.contains('\n')) {
        cleanAdvice = cleanAdvice.split('\n').first.trim();
      }

      // 句点で区切って最初の文のみ
      if (cleanAdvice.contains('。')) {
        cleanAdvice = '${cleanAdvice.split('。').first.trim()}。';
      }

      // 15文字制限
      final shortAdvice = cleanAdvice.length > 15
          ? cleanAdvice.substring(0, 15)
          : cleanAdvice;

      // 조언 캐시 업데이트
      _updateAdviceCache(shortAdvice);

      return WeatherResult.success('산책 조언을 생성했습니다', shortAdvice);
    } catch (e) {
      handleError(e);
      // 폴백: 온도 기반 간단한 조언
      return _getFallbackWalkingAdvice();
    }
  }

  /// OpenAI 실패 시 사용할 폴백 조언
  WeatherResult _getFallbackWalkingAdvice() {
    if (_currentWeatherData == null) {
      return WeatherResult.success('기본 조언', '今日も散歩を楽しもう');
    }

    final temp = _currentWeatherData!.temperature;

    // 온도 기반 조언
    if (temp >= 30.0) {
      return WeatherResult.success('온도 기반 조언', '暑いので短時間で');
    } else if (temp >= 25.0) {
      return WeatherResult.success('온도 기반 조언', '日陰を選んで散歩');
    } else if (temp >= 20.0) {
      return WeatherResult.success('온도 기반 조언', '今日は散歩に最適です');
    } else if (temp >= 10.0) {
      return WeatherResult.success('온도 기반 조언', '軽い運動がおすすめ');
    } else if (temp >= 0.0) {
      return WeatherResult.success('온도 기반 조언', '防寒対策をしっかり');
    } else {
      return WeatherResult.success('온도 기반 조언', '短時間の外出を');
    }
  }

  /// 산책 조언 캐시가 유효한지 확인
  bool _isAdviceCacheValid() {
    if (_cachedWalkingAdvice == null || _adviceCacheTime == null) {
      return false;
    }

    final now = DateTime.now();
    if (now.difference(_adviceCacheTime!).abs() > _adviceCacheValidDuration) {
      return false;
    }

    return true;
  }

  /// 산책 조언 캐시 업데이트
  void _updateAdviceCache(String advice) {
    _cachedWalkingAdvice = advice;
    _adviceCacheTime = DateTime.now();
  }

  /// 캐시 클리어
  void clearAdviceCache() {
    _cachedWalkingAdvice = null;
    _adviceCacheTime = null;
  }
}
