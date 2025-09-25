/// 산책 위치 정보 엔티티
class WalkLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? accuracy;
  final double? speed;

  const WalkLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.accuracy,
    this.speed,
  });

  /// JSON에서 WalkLocation 생성
  factory WalkLocation.fromJson(Map<String, dynamic> json) {
    return WalkLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      speed: json['speed']?.toDouble(),
    );
  }

  /// WalkLocation을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
    };
  }

  /// 두 위치 간의 거리 계산 (미터 단위)
  double distanceTo(WalkLocation other) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);

    final double a =
        (dLat / 2).sin() * (dLat / 2).sin() +
        latitude.cos() *
            other.latitude.cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();
    final double c = 2 * (a.sqrt()).asin();

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);

  /// 위치 복사
  WalkLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? altitude,
    double? accuracy,
    double? speed,
  }) {
    return WalkLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
    );
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
  int get hashCode => Object.hash(latitude, longitude, timestamp);

  @override
  String toString() {
    return 'WalkLocation(lat: $latitude, lng: $longitude, time: $timestamp)';
  }
}
