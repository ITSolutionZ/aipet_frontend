import 'dart:math' as math;

import 'package:aipet_frontend/shared/entities/walk_location_entity.dart';

/// 산책 추적 성능 최적화 서비스
class WalkTrackingOptimizer {
  WalkTrackingOptimizer._();

  /// 위치 업데이트 필터링 설정
  static const double minDistanceThreshold = 2.0; // 최소 이동 거리 (미터)
  static const Duration minTimeThreshold = Duration(seconds: 3); // 최소 시간 간격
  static const double maxAccuracyThreshold = 50.0; // 최대 허용 정확도 (미터)
  static const double minSpeedThreshold = 0.5; // 최소 속도 (m/s)
  static const double maxReasonableSpeed = 20.0; // 최대 합리적 속도 (m/s)

  /// 위치 데이터가 유효한지 검증
  static bool isValidLocation(WalkLocation location) {
    // 위도/경도가 0인 경우 무시
    if (location.latitude == 0.0 || location.longitude == 0.0) {
      return false;
    }

    // 위도/경도 범위 검증
    if (location.latitude < -90 || location.latitude > 90) {
      return false;
    }
    if (location.longitude < -180 || location.longitude > 180) {
      return false;
    }

    // 정확도가 너무 낮은 경우 무시
    if (location.accuracy != null &&
        location.accuracy! > maxAccuracyThreshold) {
      return false;
    }

    return true;
  }

  /// 새 위치를 추가해야 하는지 결정
  static bool shouldAddLocation(
    WalkLocation newLocation,
    List<WalkLocation> existingRoute,
  ) {
    if (!isValidLocation(newLocation)) {
      return false;
    }

    if (existingRoute.isEmpty) {
      return true;
    }

    final lastLocation = existingRoute.last;

    // 시간 간격 확인
    final timeDiff = newLocation.timestamp.difference(lastLocation.timestamp);
    if (timeDiff < minTimeThreshold) {
      return false;
    }

    // 거리 간격 확인
    final distance = _calculateDistance(lastLocation, newLocation);
    if (distance < minDistanceThreshold) {
      return false;
    }

    // 속도 검증 (비현실적인 속도 필터링)
    if (timeDiff.inMilliseconds > 0) {
      final speed = distance / (timeDiff.inMilliseconds / 1000.0);
      if (speed > maxReasonableSpeed) {
        return false; // 너무 빠른 이동은 GPS 오류일 가능성
      }
      if (speed < minSpeedThreshold && distance < minDistanceThreshold * 2) {
        return false; // 너무 느린 이동은 노이즈일 가능성
      }
    }

    return true;
  }

  /// 경로 압축 (Douglas-Peucker 알고리즘 단순화 버전)
  static List<WalkLocation> compressRoute(
    List<WalkLocation> route, {
    double tolerance = 5.0, // 허용 편차 (미터)
  }) {
    if (route.length <= 2) {
      return route;
    }

    final compressed = <WalkLocation>[];
    compressed.add(route.first);

    for (int i = 1; i < route.length - 1; i++) {
      final prev = compressed.last;
      final current = route[i];
      final next = route[i + 1];

      // 현재 점이 이전-다음 점 사이의 직선에서 얼마나 떨어져 있는지 계산
      final deviation = _calculatePointToLineDistance(prev, next, current);

      if (deviation > tolerance) {
        compressed.add(current);
      }
    }

    compressed.add(route.last);
    return compressed;
  }

  /// 배터리 절약을 위한 적응형 추적 설정
  static LocationTrackingConfig getAdaptiveTrackingConfig({
    required double batteryLevel,
    required bool isCharging,
    required Duration walkDuration,
    required double currentSpeed,
  }) {
    // 배터리 레벨에 따른 기본 설정
    double accuracy = LocationAccuracy.high.value;
    int distanceFilter = 5;
    Duration updateInterval = const Duration(seconds: 2);

    // 배터리가 낮으면 절약 모드
    if (batteryLevel < 0.2 && !isCharging) {
      accuracy = LocationAccuracy.medium.value;
      distanceFilter = 10;
      updateInterval = const Duration(seconds: 5);
    } else if (batteryLevel < 0.5 && !isCharging) {
      accuracy = LocationAccuracy.high.value;
      distanceFilter = 8;
      updateInterval = const Duration(seconds: 3);
    }

    // 속도에 따른 조정
    if (currentSpeed < 1.0) {
      // 정지 상태에서는 업데이트 빈도 줄임
      distanceFilter = 15;
      updateInterval = const Duration(seconds: 10);
    } else if (currentSpeed > 5.0) {
      // 빠른 이동 시에는 더 정확한 추적
      accuracy = LocationAccuracy.best.value;
      distanceFilter = 3;
      updateInterval = const Duration(seconds: 1);
    }

    // 긴 산책에서는 점진적으로 절약 모드로
    if (walkDuration.inHours > 2) {
      distanceFilter = (distanceFilter * 1.5).round();
      updateInterval = Duration(
        milliseconds: (updateInterval.inMilliseconds * 1.3).round(),
      );
    }

    return LocationTrackingConfig(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      updateInterval: updateInterval,
    );
  }

  /// 위치 데이터 평활화 (이동 평균)
  static WalkLocation smoothLocation(
    WalkLocation newLocation,
    List<WalkLocation> recentLocations, {
    int windowSize = 3,
  }) {
    if (recentLocations.length < windowSize) {
      return newLocation;
    }

    final window = [...recentLocations.takeLast(windowSize - 1), newLocation];

    final avgLat =
        window.map((l) => l.latitude).reduce((a, b) => a + b) / window.length;
    final avgLng =
        window.map((l) => l.longitude).reduce((a, b) => a + b) / window.length;

    return newLocation.copyWith(latitude: avgLat, longitude: avgLng);
  }

  /// 메모리 사용량 최적화를 위한 경로 정리
  static List<WalkLocation> pruneRoute(
    List<WalkLocation> route, {
    int maxPoints = 1000,
    Duration maxAge = const Duration(hours: 6),
  }) {
    if (route.length <= maxPoints) {
      return route;
    }

    final now = DateTime.now();
    final cutoffTime = now.subtract(maxAge);

    // 오래된 점들 제거
    final recentRoute = route
        .where((location) => location.timestamp.isAfter(cutoffTime))
        .toList();

    if (recentRoute.length <= maxPoints) {
      return recentRoute;
    }

    // 균등하게 샘플링
    final interval = recentRoute.length ~/ maxPoints;
    final prunedRoute = <WalkLocation>[];

    for (int i = 0; i < recentRoute.length; i += interval) {
      prunedRoute.add(recentRoute[i]);
    }

    // 마지막 점은 항상 포함
    if (prunedRoute.last != recentRoute.last) {
      prunedRoute.add(recentRoute.last);
    }

    return prunedRoute;
  }

  /// 두 위치 간의 거리 계산 (미터)
  static double _calculateDistance(WalkLocation from, WalkLocation to) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final lat1Rad = from.latitude * (math.pi / 180);
    final lat2Rad = to.latitude * (math.pi / 180);
    final deltaLat = (to.latitude - from.latitude) * (math.pi / 180);
    final deltaLng = (to.longitude - from.longitude) * (math.pi / 180);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// 점에서 직선까지의 거리 계산 (Douglas-Peucker용)
  static double _calculatePointToLineDistance(
    WalkLocation lineStart,
    WalkLocation lineEnd,
    WalkLocation point,
  ) {
    final A = point.latitude - lineStart.latitude;
    final B = point.longitude - lineStart.longitude;
    final C = lineEnd.latitude - lineStart.latitude;
    final D = lineEnd.longitude - lineStart.longitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      return _calculateDistance(lineStart, point);
    }

    final param = dot / lenSq;

    final WalkLocation nearest;
    if (param < 0) {
      nearest = lineStart;
    } else if (param > 1) {
      nearest = lineEnd;
    } else {
      nearest = WalkLocation(
        latitude: lineStart.latitude + param * C,
        longitude: lineStart.longitude + param * D,
        timestamp: point.timestamp,
      );
    }

    return _calculateDistance(point, nearest);
  }
}

/// 위치 추적 설정 클래스
class LocationTrackingConfig {
  final double accuracy;
  final int distanceFilter;
  final Duration updateInterval;

  const LocationTrackingConfig({
    required this.accuracy,
    required this.distanceFilter,
    required this.updateInterval,
  });
}

/// 위치 정확도 열거형
enum LocationAccuracy {
  lowest(0),
  low(1),
  medium(2),
  high(3),
  best(4),
  bestForNavigation(5);

  const LocationAccuracy(this.value);
  final double value;
}

/// List 확장 메서드
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
