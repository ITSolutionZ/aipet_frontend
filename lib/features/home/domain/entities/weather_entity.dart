/// Domain layer의 날씨 엔티티
/// 
/// Data layer의 WeatherData와 독립적으로 동작하는 도메인 모델
class WeatherEntity {
  final double temperature;
  final String location;
  final int weatherId;
  final String description;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final double uvIndex;
  final int visibility;
  final double pressure;

  const WeatherEntity({
    required this.temperature,
    required this.location,
    required this.weatherId,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
  });

  /// 날씨 상태 판별 메서드들
  bool get isSunny => weatherId == 800;
  bool get isRainy => weatherId >= 200 && weatherId < 600;
  bool get isCloudy => weatherId >= 801 && weatherId <= 804;
  bool get isSnowy => weatherId >= 600 && weatherId < 700;

  /// UV 지수에 따른 위험도 판별
  String get uvRiskLevel {
    if (uvIndex <= 2) return 'low';
    if (uvIndex <= 5) return 'moderate';
    if (uvIndex <= 7) return 'high';
    if (uvIndex <= 10) return 'very_high';
    return 'extreme';
  }

  /// 산책하기 좋은 날씨인지 판별
  bool get isGoodForWalk {
    return !isRainy && !isSnowy && temperature >= 10 && temperature <= 30;
  }
}

/// 날씨 위치 엔티티
class WeatherLocationEntity {
  final double latitude;
  final double longitude;
  final String name;

  const WeatherLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}