import 'dart:math' as math;

/// 산책 위치 엔티티
class WalkLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final String? address;

  const WalkLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.address,
  });

  /// Google Maps LatLng 형식으로 변환
  Map<String, double> toLatLng() {
    return {'lat': latitude, 'lng': longitude};
  }

  /// Google Maps Polyline 포인트로 변환
  Map<String, dynamic> toPolylinePoint() {
    return {
      'lat': latitude,
      'lng': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
    };
  }

  /// 두 위치 간의 거리 계산 (미터 단위)
  double distanceTo(WalkLocation other) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final lat1Rad = latitude * (3.14159265359 / 180);
    final lat2Rad = other.latitude * (3.14159265359 / 180);
    final deltaLat = (other.latitude - latitude) * (3.14159265359 / 180);
    final deltaLng = (other.longitude - longitude) * (3.14159265359 / 180);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan(math.sqrt(a) / math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// 복사본 생성
  WalkLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? altitude,
    double? accuracy,
    double? speed,
    double? heading,
    String? address,
  }) {
    return WalkLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'WalkLocation(lat: $latitude, lng: $longitude, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalkLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(latitude, longitude, timestamp);
  }
}
