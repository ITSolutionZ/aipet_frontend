import 'dart:math' as math;

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/services/walk_route_service.dart';

/// 디코딩 결과를 담는 클래스
class _DecodeResult {
  final int value;
  final int index;

  const _DecodeResult(this.value, this.index);
}

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
    if (route.isEmpty) return '';

    // Google Maps Polyline 인코딩 알고리즘 구현
    final encoded = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final location in route) {
      // 위도와 경도를 정수로 변환 (소수점 5자리까지 정밀도)
      final lat = (location.latitude * 1e5).round();
      final lng = (location.longitude * 1e5).round();

      // 차이값 계산
      final deltaLat = lat - prevLat;
      final deltaLng = lng - prevLng;

      // 인코딩
      _encodeNumber(deltaLat, encoded);
      _encodeNumber(deltaLng, encoded);

      prevLat = lat;
      prevLng = lng;
    }

    return encoded.toString();
  }

  /// Google Maps Polyline 인코딩 알고리즘
  void _encodeNumber(int value, StringBuffer encoded) {
    // 부호 비트 처리
    int v = value << 1;
    if (value < 0) {
      v = ~v;
    }

    // 5비트씩 나누어 인코딩
    while (v >= 0x20) {
      encoded.writeCharCode(((v & 0x1f) | 0x20) + 63);
      v >>= 5;
    }
    encoded.writeCharCode(v + 63);
  }

  @override
  List<WalkLocation> decodePolyline(String encodedPolyline) {
    if (encodedPolyline.isEmpty) return [];

    // Google Maps Polyline 디코딩 알고리즘 구현
    final locations = <WalkLocation>[];
    int index = 0;
    int lat = 0;
    int lng = 0;
    final now = DateTime.now();

    while (index < encodedPolyline.length) {
      // 위도 디코딩
      final deltaLat = _decodeNumber(encodedPolyline, index);
      index = deltaLat.index;
      lat += deltaLat.value;

      // 경도 디코딩
      final deltaLng = _decodeNumber(encodedPolyline, index);
      index = deltaLng.index;
      lng += deltaLng.value;

      // 정밀도 복원 (소수점 5자리)
      final latitude = lat / 1e5;
      final longitude = lng / 1e5;

      locations.add(
        WalkLocation(
          latitude: latitude,
          longitude: longitude,
          timestamp: now.add(Duration(minutes: locations.length)),
        ),
      );
    }

    return locations;
  }

  /// Google Maps Polyline 디코딩 알고리즘
  _DecodeResult _decodeNumber(String encoded, int index) {
    int result = 0;
    int shift = 0;
    int byte;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    // 부호 비트 처리
    final value = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    return _DecodeResult(value, index);
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
      final smoothedLng = (prev.longitude + curr.longitude + next.longitude) / 3;

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
        math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }
}
