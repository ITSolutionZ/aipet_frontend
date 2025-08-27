import 'dart:math' as math;

import '../../domain/entities/walk_location_entity.dart';
import '../../domain/services/walk_route_service.dart';

/// 산책 경로 서비스 구현체
class WalkRouteServiceImpl implements WalkRouteService {
  @override
  double calculateTotalDistance(List<WalkLocation> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < route.length; i++) {
      totalDistance += route[i - 1].distanceTo(route[i]);
    }
    return totalDistance;
  }

  @override
  Duration calculateTotalDuration(List<WalkLocation> route) {
    if (route.length < 2) return Duration.zero;

    final startTime = route.first.timestamp;
    final endTime = route.last.timestamp;
    return endTime.difference(startTime);
  }

  @override
  double calculateAverageSpeed(List<WalkLocation> route) {
    final distance = calculateTotalDistance(route);
    final duration = calculateTotalDuration(route);

    if (duration.inSeconds == 0) return 0.0;
    return distance / duration.inSeconds;
  }

  @override
  String encodePolyline(List<WalkLocation> route) {
    // TODO: Google Maps Polyline 인코딩 구현
    // 현재는 목업으로 빈 문자열 반환
    if (route.isEmpty) return '';

    // 간단한 목업 인코딩 (실제로는 Google Maps Polyline 알고리즘 사용)
    final points = route
        .map(
          (location) =>
              '${location.latitude.toStringAsFixed(6)},${location.longitude.toStringAsFixed(6)}',
        )
        .join('|');

    return points;
  }

  @override
  List<WalkLocation> decodePolyline(String encodedPolyline) {
    // TODO: Google Maps Polyline 디코딩 구현
    // 현재는 목업으로 빈 리스트 반환
    if (encodedPolyline.isEmpty) return [];

    // 간단한 목업 디코딩
    final points = encodedPolyline.split('|');
    final locations = <WalkLocation>[];
    final now = DateTime.now();

    for (int i = 0; i < points.length; i++) {
      final coords = points[i].split(',');
      if (coords.length == 2) {
        final lat = double.tryParse(coords[0]) ?? 0.0;
        final lng = double.tryParse(coords[1]) ?? 0.0;

        locations.add(
          WalkLocation(
            latitude: lat,
            longitude: lng,
            timestamp: now.add(Duration(minutes: i)),
          ),
        );
      }
    }

    return locations;
  }

  @override
  List<WalkLocation> optimizeRoute(List<WalkLocation> route) {
    if (route.length < 3) return route;

    final optimized = <WalkLocation>[route.first];

    for (int i = 1; i < route.length - 1; i++) {
      final prev = route[i - 1];
      final curr = route[i];
      final next = route[i + 1];

      // 중복점 제거 (같은 위치에 있는 점들)
      if (prev.distanceTo(curr) < 5.0) continue; // 5미터 이내는 중복으로 간주

      // 노이즈 제거 (급격한 방향 변화)
      final angle1 = _calculateBearing(prev, curr);
      final angle2 = _calculateBearing(curr, next);
      final angleDiff = (angle2 - angle1).abs();

      if (angleDiff > 45.0) {
        // 45도 이상의 급격한 방향 변화
        optimized.add(curr);
      }
    }

    optimized.add(route.last);
    return optimized;
  }

  @override
  List<WalkLocation> smoothRoute(List<WalkLocation> route) {
    if (route.length < 3) return route;

    final smoothed = <WalkLocation>[route.first];

    for (int i = 1; i < route.length - 1; i++) {
      final prev = route[i - 1];
      final curr = route[i];
      final next = route[i + 1];

      // 3점 평균으로 스무딩
      final smoothedLat = (prev.latitude + curr.latitude + next.latitude) / 3;
      final smoothedLng =
          (prev.longitude + curr.longitude + next.longitude) / 3;

      smoothed.add(
        WalkLocation(
          latitude: smoothedLat,
          longitude: smoothedLng,
          timestamp: curr.timestamp,
          altitude: curr.altitude,
          accuracy: curr.accuracy,
          speed: curr.speed,
          heading: curr.heading,
          address: curr.address,
        ),
      );
    }

    smoothed.add(route.last);
    return smoothed;
  }

  /// 두 점 간의 방향각 계산 (도 단위)
  double _calculateBearing(WalkLocation from, WalkLocation to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final deltaLng = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }
}
