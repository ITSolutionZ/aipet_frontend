import 'dart:math' as math;

/// 지리적 위치 관련 유틸리티 클래스
class GeoUtils {
  GeoUtils._();

  /// 지구 반지름 (킬로미터)
  static const double earthRadiusKm = 6371.0;

  /// 지구 반지름 (미터)
  static const double earthRadiusM = 6371000.0;

  /// 도(degree)를 라디안(radian)으로 변환
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Haversine 공식을 사용하여 두 지점 간의 거리 계산 (킬로미터)
  ///
  /// [lat1], [lon1]: 첫 번째 지점의 위도, 경도
  /// [lat2], [lon2]: 두 번째 지점의 위도, 경도
  ///
  /// Returns: 거리 (킬로미터)
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1Rad) *
            math.cos(lat2Rad);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Haversine 공식을 사용하여 두 지점 간의 거리 계산 (미터)
  ///
  /// [lat1], [lon1]: 첫 번째 지점의 위도, 경도
  /// [lat2], [lon2]: 두 번째 지점의 위도, 경도
  ///
  /// Returns: 거리 (미터)
  static double calculateDistanceM(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateDistanceKm(lat1, lon1, lat2, lon2) * 1000.0;
  }

  /// 경로상의 모든 지점을 고려하여 총 거리 계산 (킬로미터)
  ///
  /// [coordinates]: [[lat, lon], [lat, lon], ...] 형태의 좌표 리스트
  ///
  /// Returns: 총 거리 (킬로미터)
  static double calculateRouteDistanceKm(List<List<double>> coordinates) {
    if (coordinates.length < 2) return 0.0;

    double totalDistance = 0.0;

    for (int i = 1; i < coordinates.length; i++) {
      final prev = coordinates[i - 1];
      final curr = coordinates[i];

      totalDistance += calculateDistanceKm(
        prev[0],
        prev[1], // lat1, lon1
        curr[0],
        curr[1], // lat2, lon2
      );
    }

    return totalDistance;
  }

  /// 경로상의 모든 지점을 고려하여 총 거리 계산 (미터)
  ///
  /// [coordinates]: [[lat, lon], [lat, lon], ...] 형태의 좌표 리스트
  ///
  /// Returns: 총 거리 (미터)
  static double calculateRouteDistanceM(List<List<double>> coordinates) {
    return calculateRouteDistanceKm(coordinates) * 1000.0;
  }

  /// 베어링(방향각) 계산
  ///
  /// [lat1], [lon1]: 시작점의 위도, 경도
  /// [lat2], [lon2]: 도착점의 위도, 경도
  ///
  /// Returns: 베어링 (0-360도)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = bearing * (180.0 / math.pi); // 라디안을 도로 변환
    bearing = (bearing + 360.0) % 360.0; // 0-360 범위로 정규화

    return bearing;
  }

  /// 두 지점의 중점 계산
  ///
  /// [lat1], [lon1]: 첫 번째 지점의 위도, 경도
  /// [lat2], [lon2]: 두 번째 지점의 위도, 경도
  ///
  /// Returns: [위도, 경도] 형태의 중점 좌표
  static List<double> calculateMidpoint(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);
    final dLon = _toRadians(lon2 - lon1);

    final bx = math.cos(lat2Rad) * math.cos(dLon);
    final by = math.cos(lat2Rad) * math.sin(dLon);

    final lat3Rad = math.atan2(
      math.sin(lat1Rad) + math.sin(lat2Rad),
      math.sqrt((math.cos(lat1Rad) + bx) * (math.cos(lat1Rad) + bx) + by * by),
    );

    final lon3Rad = _toRadians(lon1) + math.atan2(by, math.cos(lat1Rad) + bx);

    final lat3 = lat3Rad * (180.0 / math.pi);
    final lon3 = lon3Rad * (180.0 / math.pi);

    return [lat3, lon3];
  }

  /// 속도 계산 (km/h)
  ///
  /// [distanceKm]: 거리 (킬로미터)
  /// [durationMs]: 소요 시간 (밀리초)
  ///
  /// Returns: 속도 (km/h)
  static double calculateSpeedKmh(double distanceKm, int durationMs) {
    if (durationMs <= 0) return 0.0;

    final durationHours = durationMs / (1000 * 60 * 60);
    return distanceKm / durationHours;
  }

  /// 좌표가 유효한지 검증
  ///
  /// [latitude]: 위도 (-90 ~ 90)
  /// [longitude]: 경도 (-180 ~ 180)
  ///
  /// Returns: 유효하면 true, 그렇지 않으면 false
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  /// 거리 포맷팅 (미터 단위를 km로 변환하여 포맷팅)
  ///
  /// [distanceM]: 거리 (미터)
  ///
  /// Returns: 포맷된 거리 문자열 (km 단위)
  static String formatDistanceKm(double distanceM) {
    final distanceKm = distanceM / 1000.0;
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// 거리 포맷팅 (자동으로 단위 선택)
  ///
  /// [distanceM]: 거리 (미터)
  ///
  /// Returns: 포맷된 거리 문자열 (예: "1.2km", "350m")
  static String formatDistanceAuto(double distanceM) {
    if (distanceM >= 1000) {
      return '${(distanceM / 1000).toStringAsFixed(1)}km';
    } else {
      return '${distanceM.round()}m';
    }
  }

  /// 속도 포맷팅
  ///
  /// [speedKmh]: 속도 (km/h)
  ///
  /// Returns: 포맷된 속도 문자열 (예: "5.2km/h")
  static String formatSpeed(double speedKmh) {
    return '${speedKmh.toStringAsFixed(1)}km/h';
  }
}
