import 'package:flutter/services.dart';

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

  /// 날씨 아이콘 이름 매핑 (OpenWeatherMap weather ID 기반)
  String getWeatherIconName(int weatherId, {required bool isDay}) {
    // 뇌우 (200-299)
    if (weatherId >= 200 && weatherId < 300) {
      if (weatherId >= 200 && weatherId <= 202) {
        return isDay ? 'thunderstorms-day-rain' : 'thunderstorms-night-rain';
      } else if (weatherId >= 210 && weatherId <= 212) {
        return isDay ? 'thunderstorms-day' : 'thunderstorms-night';
      } else if (weatherId >= 221 && weatherId <= 232) {
        return 'thunderstorms';
      }
      return 'thunderstorms';
    }
    
    // 이슬비 (300-399)
    if (weatherId >= 300 && weatherId < 400) {
      if (weatherId >= 300 && weatherId <= 321) {
        return isDay ? 'partly-cloudy-day-drizzle' : 'partly-cloudy-night-drizzle';
      }
      return 'drizzle';
    }
    
    // 비 (500-599)
    if (weatherId >= 500 && weatherId < 600) {
      if (weatherId == 500 || weatherId == 501) {
        return isDay ? 'partly-cloudy-day-rain' : 'partly-cloudy-night-rain';
      } else if (weatherId >= 502 && weatherId <= 504) {
        return 'rain';
      } else if (weatherId == 511) {
        return 'sleet';
      } else if (weatherId >= 520 && weatherId <= 531) {
        return 'rain';
      }
      return 'rain';
    }
    
    // 눈 (600-699)
    if (weatherId >= 600 && weatherId < 700) {
      if (weatherId == 600 || weatherId == 601) {
        return isDay ? 'partly-cloudy-day-snow' : 'partly-cloudy-night-snow';
      } else if (weatherId == 602) {
        return 'snow';
      } else if (weatherId >= 611 && weatherId <= 616) {
        return 'sleet';
      } else if (weatherId >= 620 && weatherId <= 622) {
        return 'snow';
      }
      return 'snow';
    }
    
    // 대기 현상 (700-799)
    if (weatherId >= 700 && weatherId < 800) {
      if (weatherId == 701 || weatherId == 741) {
        return isDay ? 'partly-cloudy-day-fog' : 'partly-cloudy-night-fog';
      } else if (weatherId == 711) {
        return isDay ? 'partly-cloudy-day-smoke' : 'partly-cloudy-night-smoke';
      } else if (weatherId == 721) {
        return isDay ? 'partly-cloudy-day-haze' : 'partly-cloudy-night-haze';
      } else if (weatherId == 731 || weatherId == 751 || weatherId == 761) {
        return 'dust';
      } else if (weatherId == 762) {
        return 'smoke';
      } else if (weatherId == 771) {
        return 'wind';
      } else if (weatherId == 781) {
        return 'tornado';
      }
      return 'mist';
    }
    
    // 맑음 (800)
    if (weatherId == 800) {
      return isDay ? 'clear-day' : 'clear-night';
    }
    
    // 구름 (801-809)
    if (weatherId >= 801 && weatherId < 900) {
      if (weatherId == 801) {
        return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
      } else if (weatherId == 802) {
        return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
      } else if (weatherId == 803) {
        return isDay ? 'overcast-day' : 'overcast-night';
      } else if (weatherId == 804) {
        return 'overcast';
      }
      return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
    }
    
    // 기본값
    return isDay ? 'clear-day' : 'clear-night';
  }

  /// SVG 콘텐츠 로드 (폴백 메커니즘 포함)
  Future<WeatherResult> loadWeatherIcon(String iconName) async {
    final fallbackIcons = [
      iconName,
      'clear-day',
      'not-available'
    ];

    for (final fallbackIcon in fallbackIcons) {
      try {
        final svgString = await rootBundle.loadString(
          'assets/meteocons/design/fill/animation-ready/$fallbackIcon.svg',
        );
        if (fallbackIcon != iconName) {
          // 폴백 아이콘을 사용했음을 디버그 로그로 남김
          handleError('Original icon $iconName not found, using fallback: $fallbackIcon');
        }
        return WeatherResult.success('날씨 아이콘이 로드되었습니다', svgString);
      } catch (e) {
        // 다음 폴백 아이콘 시도
        continue;
      }
    }

    // 모든 폴백이 실패한 경우
    handleError('All weather icon fallbacks failed for: $iconName');
    return WeatherResult.failure('날씨 아이콘 로드에 실패했습니다');
  }

  /// HTML 콘텐츠 생성
  String generateWeatherIconHtml(String svgContent, double size) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: transparent;
      overflow: hidden;
    }
    svg {
      width: 100%;
      height: 100%;
      min-width: ${size}px;
      min-height: ${size}px;
    }
  </style>
</head>
<body>
  $svgContent
</body>
</html>''';
  }

  /// 오류 시 폴백 HTML 생성
  String generateFallbackHtml(String iconName) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #ff0000;
      color: white;
      font-family: Arial, sans-serif;
      font-size: 12px;
    }
  </style>
</head>
<body>
  ERROR: $iconName
</body>
</html>''';
  }


  /// 현재 시간이 낮인지 확인
  bool isDayTime() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 6 && hour < 18;
  }

  /// 현재 날씨 데이터 가져오기
  Future<WeatherResult> getCurrentWeather() async {
    try {
      final weatherData = await _weatherService.getCurrentWeather();
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

      final weatherData = _currentWeatherData!;
      final prompt = '''以下の天気データを基に、ペットの散歩について１つの短い日本語文で実用的なアドバイスをしてください。

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
      final shortAdvice = cleanAdvice.length > 15 ? cleanAdvice.substring(0, 15) : cleanAdvice;
      
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

    // 온도 기준
    if (temp >= 30) {
      return WeatherResult.success('더위 주의', '暑いので短時間で');
    } else if (temp >= 25) {
      return WeatherResult.success('온화함', '日陰を選んで散歩');
    } else if (temp >= 20) {
      return WeatherResult.success('쾌적함', '今日は散歩に最適です');
    } else if (temp >= 10) {
      return WeatherResult.success('서늘함', '軽い運動がおすすめ');
    } else if (temp >= 0) {
      return WeatherResult.success('추움', '防寒対策をしっかり');
    } else {
      return WeatherResult.success('매우 추움', '短時間の外出を');
    }
  }
}
