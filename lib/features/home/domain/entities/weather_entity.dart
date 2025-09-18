import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_entity.freezed.dart';

/// Domain layer의 날씨 엔티티
///
/// Data layer의 WeatherData와 독립적으로 동작하는 도메인 모델
@freezed
class WeatherEntity with _$WeatherEntity {
  const factory WeatherEntity({
    required double temperature,
    required String location,
    required int weatherId,
    required String description,
    required double feelsLike,
    required int humidity,
    required double windSpeed,
    required String iconCode,
    required double uvIndex,
    required int visibility,
    required double pressure,
  }) = _WeatherEntity;

  const WeatherEntity._();

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
@freezed
class WeatherLocationEntity with _$WeatherLocationEntity {
  const factory WeatherLocationEntity({
    required double latitude,
    required double longitude,
    required String name,
  }) = _WeatherLocationEntity;
}
