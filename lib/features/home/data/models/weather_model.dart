import 'package:aipet_frontend/shared/core/services/logger_service.dart';

class WeatherData {
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

  const WeatherData({
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

  factory WeatherData.fromOneCallJson(
    Map<String, dynamic> json,
    String location,
  ) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final weatherList = current['weather'] as List? ?? [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>? ?? {}
        : <String, dynamic>{};

    // UV Index 파싱 개선
    final uvi = current['uvi'];
    double uvIndex = 0.0;

    LoggerService.debug('🌞 One Call API UV Index 파싱 시작:');
    LoggerService.debug('   원본 uvi 데이터: $uvi (타입: ${uvi.runtimeType})');

    if (uvi != null) {
      if (uvi is num) {
        uvIndex = uvi.toDouble();
        LoggerService.debug('   ✅ num 타입으로 파싱: $uvIndex');
      } else if (uvi is String) {
        uvIndex = double.tryParse(uvi) ?? 0.0;
        LoggerService.debug('   ✅ String 타입으로 파싱: $uvIndex');
      } else {
        LoggerService.debug('   ⚠️ 예상치 못한 타입: ${uvi.runtimeType}');
        uvIndex = 0.0;
      }
    } else {
      LoggerService.debug('   ❌ uvi 데이터가 null입니다');
    }

    LoggerService.debug('   최종 UV Index: $uvIndex');

    return WeatherData(
      temperature: (current['temp'] as num?)?.toDouble() ?? 0.0,
      location: location,
      weatherId: weather['id'] as int? ?? 800,
      description: weather['description'] as String? ?? 'Clear sky',
      feelsLike: (current['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: current['humidity'] as int? ?? 0,
      windSpeed: (current['wind_speed'] as num?)?.toDouble() ?? 0.0,
      iconCode: weather['icon'] as String? ?? '01d',
      uvIndex: uvIndex,
      visibility: current['visibility'] as int? ?? 10000,
      pressure: (current['pressure'] as num?)?.toDouble() ?? 1013.25,
    );
  }

  // 기존 JSON 형식 지원 (폴백용)
  factory WeatherData.fromJson(Map<String, dynamic> json, String location) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List? ?? [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>? ?? {}
        : <String, dynamic>{};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final weatherId = weather['id'] as int? ?? 800;

    return WeatherData(
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      location: location,
      weatherId: weatherId,
      description: weather['description'] as String? ?? 'Clear sky',
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      iconCode: weather['icon'] as String? ?? '01d',
      uvIndex: _estimateUvIndex(weatherId), // 날씨 상황 기반 UV Index 추정
      visibility: json['visibility'] as int? ?? 10000,
      pressure: (main['pressure'] as num?)?.toDouble() ?? 1013.25,
    );
  }

  // 날씨 상황과 시간대를 고려한 UV Index 추정
  static double _estimateUvIndex(int weatherId) {
    final now = DateTime.now();
    final hour = now.hour;

    // 야간 (18시~6시): UV Index 0
    if (hour < 6 || hour >= 18) {
      return 0.0;
    }

    // 낮 시간대 기본 UV Index 계산 (위도 35.6도 도쿄 기준)
    double baseUv;
    if (hour >= 11 && hour <= 13) {
      baseUv = 8.0; // 정오 시간대 최고
    } else if (hour >= 10 && hour <= 14) {
      baseUv = 6.0; // 오전/오후
    } else if (hour >= 9 && hour <= 15) {
      baseUv = 4.0; // 이른 오전/늦은 오후
    } else {
      baseUv = 2.0; // 아침/저녁
    }

    // 날씨 상황에 따른 UV Index 보정
    if (weatherId >= 200 && weatherId < 300) {
      return baseUv * 0.3; // 뇌우: 70% 감소
    } else if (weatherId >= 300 && weatherId < 600) {
      return baseUv * 0.4; // 비: 60% 감소
    } else if (weatherId >= 600 && weatherId < 700) {
      return baseUv * 0.2; // 눈: 80% 감소
    } else if (weatherId >= 700 && weatherId < 800) {
      return baseUv * 0.5; // 안개/먼지: 50% 감소
    } else if (weatherId == 800) {
      return baseUv; // 맑음: 그대로
    } else if (weatherId >= 801 && weatherId <= 802) {
      return baseUv * 0.8; // 약간 흐림: 20% 감소
    } else if (weatherId >= 803 && weatherId <= 804) {
      return baseUv * 0.6; // 많이 흐림: 40% 감소
    }

    return baseUv * 0.7; // 기본값
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'location': location,
    'weather_id': weatherId,
    'description': description,
    'feels_like': feelsLike,
    'humidity': humidity,
    'wind_speed': windSpeed,
    'icon_code': iconCode,
    'uv_index': uvIndex,
    'visibility': visibility,
    'pressure': pressure,
  };
}

class WeatherLocation {
  final double latitude;
  final double longitude;
  final String name;

  const WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}
