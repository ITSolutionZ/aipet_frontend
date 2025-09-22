/// 🎯 날씨 유틸리티
///
/// 날씨 관련 데이터 변환 및 계산 유틸리티
class WeatherUtils {
  /// UV 지수에 따른 MeteoconsIcon 이름 반환
  static String getUvIndexIcon(double uvIndex) {
    final uvLevel = uvIndex.round().clamp(0, 11);

    switch (uvLevel) {
      case 0:
        return 'uv-index';
      case 1:
        return 'uv-index-1';
      case 2:
        return 'uv-index-2';
      case 3:
        return 'uv-index-3';
      case 4:
        return 'uv-index-4';
      case 5:
        return 'uv-index-5';
      case 6:
        return 'uv-index-6';
      case 7:
        return 'uv-index-7';
      case 8:
        return 'uv-index-8';
      case 9:
        return 'uv-index-9';
      case 10:
        return 'uv-index-10';
      case 11:
        return 'uv-index-11';
      default:
        return 'uv-index';
    }
  }

  /// 풍속(m/s)을 Beaufort 스케일로 변환 (0-12)
  static int getBeaufortScale(double windSpeedMs) {
    if (windSpeedMs < 0.3) return 0; // 고요함
    if (windSpeedMs < 1.6) return 1; // 실바람
    if (windSpeedMs < 3.4) return 2; // 남실바람
    if (windSpeedMs < 5.5) return 3; // 산들바람
    if (windSpeedMs < 8.0) return 4; // 건들바람
    if (windSpeedMs < 10.8) return 5; // 흔들바람
    if (windSpeedMs < 13.9) return 6; // 된바람
    if (windSpeedMs < 17.2) return 7; // 센바람
    if (windSpeedMs < 20.8) return 8; // 큰바람
    if (windSpeedMs < 24.5) return 9; // 큰센바람
    if (windSpeedMs < 28.5) return 10; // 노대바람
    if (windSpeedMs < 32.7) return 11; // 왕바람
    return 12; // 태풍
  }

  /// Beaufort 스케일에 따른 wind 아이콘 이름 반환
  static String getWindIcon(double windSpeedMs) {
    final beaufortScale = getBeaufortScale(windSpeedMs);
    return 'wind-beaufort-$beaufortScale';
  }

  /// UV 지수 위험도 레벨 반환
  static String getUvIndexLevel(double uvIndex) {
    if (uvIndex <= 2) return '低い';
    if (uvIndex <= 5) return '中程度';
    if (uvIndex <= 7) return '高い';
    if (uvIndex <= 10) return '非常に高い';
    return '極めて高い';
  }

  /// UV 지수에 따른 색상 반환
  static String getUvIndexColor(double uvIndex) {
    if (uvIndex <= 2) return 'green';
    if (uvIndex <= 5) return 'yellow';
    if (uvIndex <= 7) return 'orange';
    if (uvIndex <= 10) return 'red';
    return 'purple';
  }

  /// 풍속을 km/h로 변환
  static double convertWindSpeedToKmh(double windSpeedMs) {
    return windSpeedMs * 3.6;
  }

  /// 풍속을 mph로 변환
  static double convertWindSpeedToMph(double windSpeedMs) {
    return windSpeedMs * 2.237;
  }

  /// 온도를 화씨로 변환
  static double convertCelsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// 온도를 켈빈으로 변환
  static double convertCelsiusToKelvin(double celsius) {
    return celsius + 273.15;
  }

  /// 산책 적합도 점수 계산 (0-100)
  static int calculateWalkingScore({
    required double temperature,
    required double uvIndex,
    required double windSpeed,
    required double humidity,
  }) {
    int score = 100;

    // 온도 점수 (15-25도가 최적)
    if (temperature < 5 || temperature > 35) {
      score -= 30;
    } else if (temperature < 10 || temperature > 30) {
      score -= 20;
    } else if (temperature < 15 || temperature > 25) {
      score -= 10;
    }

    // UV 지수 점수 (0-5가 적합)
    if (uvIndex > 8) {
      score -= 25;
    } else if (uvIndex > 6) {
      score -= 15;
    } else if (uvIndex > 4) {
      score -= 5;
    }

    // 풍속 점수 (5m/s 이하가 적합)
    if (windSpeed > 15) {
      score -= 20;
    } else if (windSpeed > 10) {
      score -= 10;
    } else if (windSpeed > 5) {
      score -= 5;
    }

    // 습도 점수 (30-70%가 적합)
    if (humidity < 20 || humidity > 90) {
      score -= 15;
    } else if (humidity < 30 || humidity > 80) {
      score -= 10;
    } else if (humidity < 40 || humidity > 70) {
      score -= 5;
    }

    return score.clamp(0, 100);
  }

  /// 산책 조언 생성
  static String generateWalkingAdvice({
    required double temperature,
    required double uvIndex,
    required double windSpeed,
    required double humidity,
  }) {
    final score = calculateWalkingScore(
      temperature: temperature,
      uvIndex: uvIndex,
      windSpeed: windSpeed,
      humidity: humidity,
    );

    if (score >= 80) {
      return '今日は散歩に最適な天気です！';
    } else if (score >= 60) {
      return '散歩に適した天気ですが、注意が必要です。';
    } else if (score >= 40) {
      return '散歩は可能ですが、短時間に留めることをお勧めします。';
    } else {
      return '今日の散歩は避けることをお勧めします。';
    }
  }
}
