/// 날씨 엔티티
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

  /// 산책하기 좋은 날씨인지 판단
  bool get isGoodForWalking {
    return temperature >= 10 &&
        temperature <= 30 &&
        !description.toLowerCase().contains('rain') &&
        windSpeed <= 10.0;
  }

  /// UV 지수 위험도
  String get uvIndexLevel {
    if (uvIndex <= 2) return '低い';
    if (uvIndex <= 5) return '中程度';
    if (uvIndex <= 7) return '高い';
    if (uvIndex <= 10) return '非常に高い';
    return '極めて高い';
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
