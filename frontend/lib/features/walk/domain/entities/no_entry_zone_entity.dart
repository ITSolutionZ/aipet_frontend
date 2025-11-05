import 'dart:math' as math;

/// 금지구역 엔티티
class NoEntryZone {
  final String id;
  final double latitude;
  final double longitude;
  final double radiusMeters; // 기본 5m
  final String? description;
  final DateTime createdAt;

  const NoEntryZone({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 5.0,
    this.description,
    required this.createdAt,
  });

  /// 현재 위치와의 거리 계산 (미터 단위) - Haversine 공식
  double distanceToPoint(double latitude, double longitude) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final lat1Rad = this.latitude * (math.pi / 180);
    final lat2Rad = latitude * (math.pi / 180);
    final deltaLat = (latitude - this.latitude) * (math.pi / 180);
    final deltaLng = (longitude - this.longitude) * (math.pi / 180);

    final a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(deltaLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// 범위 내에 있는지 확인
  bool isWithinRadius(double latitude, double longitude) {
    return distanceToPoint(latitude, longitude) <= radiusMeters;
  }

  /// JSON에서 생성
  factory NoEntryZone.fromJson(Map<String, dynamic> json) {
    return NoEntryZone(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 5.0,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 복사본 생성
  NoEntryZone copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? description,
    DateTime? createdAt,
  }) {
    return NoEntryZone(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NoEntryZone(id: $id, lat: $latitude, lng: $longitude, radius: $radiusMeters)';
  }
}
