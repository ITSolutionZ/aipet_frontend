import 'package:flutter/services.dart';

import '../../../../app/controllers/base_controller.dart';

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

  /// 날씨 아이콘 이름 매핑
  String getWeatherIconName(int weatherId, {required bool isDay}) {
    if (weatherId >= 200 && weatherId < 300) return 'thunderstorms';
    if (weatherId >= 300 && weatherId < 400) return 'drizzle';
    if (weatherId >= 500 && weatherId < 600) return 'rain';
    if (weatherId >= 600 && weatherId < 700) return 'snow';
    if (weatherId == 701 || weatherId == 741) return 'fog';
    if (weatherId == 711) return 'smoke';
    if (weatherId == 721) return 'haze';
    if (weatherId == 731 || weatherId == 761) return 'dust';
    if (weatherId == 781) return 'tornado';
    if (weatherId == 800) return isDay ? 'clear-day' : 'clear-night';
    if (weatherId == 801) return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
    return 'wind';
  }

  /// SVG 콘텐츠 로드
  Future<WeatherResult> loadWeatherIcon(String iconName) async {
    try {
      final svgString = await rootBundle.loadString(
        'assets/meteocons/design/fill/animation-ready/$iconName.svg',
      );
      return WeatherResult.success('날씨 아이콘이 로드되었습니다', svgString);
    } catch (e) {
      handleError(e);
      return WeatherResult.failure('날씨 아이콘 로드에 실패했습니다: $e');
    }
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

  /// 날씨 메시지 생성
  String generateWeatherMessage(int temperature) {
    if (temperature >= 30) {
      return '今日は暑いです';
    } else if (temperature >= 20) {
      return '今は少し暑いです';
    } else if (temperature >= 10) {
      return '快適な気温です';
    } else {
      return '今日は寒いです';
    }
  }

  /// 현재 시간이 낮인지 확인
  bool isDayTime() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 6 && hour < 18;
  }
}