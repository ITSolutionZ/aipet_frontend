import 'dart:math' as math;

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:geolocator/geolocator.dart';

/// Live Walk 거리 계산 헬퍼
class LiveWalkDistanceCalculator {
  /// 두 위치 사이의 거리 계산 (미터 단위)
  static double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  /// 경로의 총 거리 계산 (미터 단위)
  static double calculateTotalDistance(List<WalkLocation> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < route.length; i++) {
      final prev = route[i - 1];
      final curr = route[i];
      totalDistance += Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );
    }
    return totalDistance;
  }

  /// 평균 속도 계산 (km/h)
  static double calculateAverageSpeed(
    double distanceInMeters,
    Duration duration,
  ) {
    if (duration.inSeconds == 0) return 0.0;
    final distanceInKm = distanceInMeters / 1000;
    final timeInHours = duration.inSeconds / 3600;
    return distanceInKm / timeInHours;
  }

  /// 칼로리 계산 (간단한 추정)
  static double calculateCalories(double distanceInMeters, Duration duration) {
    // 1km당 약 50 칼로리 소모 가정
    final distanceInKm = distanceInMeters / 1000;
    return distanceInKm * 50;
  }

  /// 두 위치 사이의 방향 계산 (도 단위)
  static double calculateBearing(WalkLocation from, WalkLocation to) {
    final lat1 = _toRadians(from.latitude);
    final lon1 = _toRadians(from.longitude);
    final lat2 = _toRadians(to.latitude);
    final lon2 = _toRadians(to.longitude);

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return (_toDegrees(math.atan2(y, x)) + 360) % 360;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
