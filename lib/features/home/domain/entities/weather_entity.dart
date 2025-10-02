/// WBGT 위험도 레벨
enum WBGTRiskLevel {
  safe, // 안전
  caution, // 주의
  alert, // 경계
  danger, // 위험
  extreme, // 매우 위험
}

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

  /// WBGT (Wet Bulb Globe Temperature) 계산
  /// 간이 공식: WBGT ≈ 0.7 × 습구온도 + 0.3 × 건구온도
  /// 습구온도 근사값 계산을 위해 온도, 습도, 체감온도 사용
  double get wbgt {
    // 체감온도가 습구온도에 가까운 값이므로 이를 활용
    // 실제로는 더 복잡한 계산이 필요하지만 근사값으로 계산
    final wetBulbTemp = temperature - ((100 - humidity) / 5);
    return 0.7 * wetBulbTemp + 0.3 * temperature;
  }

  /// WBGT 기반 위험도 (사람 기준)
  WBGTRiskLevel get humanRiskLevel {
    final wbgtValue = wbgt;
    if (wbgtValue < 26) return WBGTRiskLevel.safe;
    if (wbgtValue < 28) return WBGTRiskLevel.caution;
    if (wbgtValue < 31) return WBGTRiskLevel.alert;
    if (wbgtValue < 33) return WBGTRiskLevel.danger;
    return WBGTRiskLevel.extreme;
  }

  /// WBGT 기반 위험도 (반려견 기준)
  WBGTRiskLevel get dogRiskLevel {
    final wbgtValue = wbgt;
    // 반려견은 사람보다 열에 민감하므로 기준을 낮춤
    if (wbgtValue < 24) return WBGTRiskLevel.safe;
    if (wbgtValue < 26) return WBGTRiskLevel.caution;
    if (wbgtValue < 28) return WBGTRiskLevel.alert;
    if (wbgtValue < 30) return WBGTRiskLevel.danger;
    return WBGTRiskLevel.extreme;
  }

  /// 반려견 산책 권장사항
  String get dogWalkingRecommendation {
    switch (dogRiskLevel) {
      case WBGTRiskLevel.safe:
        return '정상적인 산책 가능';
      case WBGTRiskLevel.caution:
        return '짧은 산책만, 그늘 위주';
      case WBGTRiskLevel.alert:
        return '산책 최소화, 단두종/노령견은 금지';
      case WBGTRiskLevel.danger:
        return '외출 금지, 실내 놀이로 대체';
      case WBGTRiskLevel.extreme:
        return '절대 외출 금지, 실내 냉방 필수';
    }
  }

  /// 위험 상황 여부 (모달 표시 필요)
  bool get isDangerous {
    return humanRiskLevel == WBGTRiskLevel.danger || humanRiskLevel == WBGTRiskLevel.extreme;
  }

  /// 풍속 레벨
  String get windLevel {
    if (windSpeed < 1) return '무풍';
    if (windSpeed < 3) return '약풍';
    if (windSpeed < 6) return '산들바람';
    if (windSpeed < 10) return '보통바람';
    if (windSpeed < 15) return '강한바람';
    return '매우강한바람';
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
