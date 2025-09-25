import 'package:aipet_frontend/features/walk/domain/entities/walk_location.dart';

/// 산책 기록 엔티티
class WalkRecordEntity {
  final String id;
  final String petId;
  final String petName;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final double? distance;
  final List<WalkLocation> route;
  final String? notes;
  final WalkStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalkRecordEntity({
    required this.id,
    required this.petId,
    required this.petName,
    required this.startTime,
    this.endTime,
    this.duration,
    this.distance,
    this.route = const [],
    this.notes,
    this.status = WalkStatus.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 진행 중인 산책인지 확인
  bool get isActive => status == WalkStatus.inProgress;

  /// 완료된 산책인지 확인
  bool get isCompleted => status == WalkStatus.completed;

  /// 일시정지된 산책인지 확인
  bool get isPaused => status == WalkStatus.paused;

  /// 산책 시간 계산
  Duration get calculatedDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  /// 거리 계산 (미터 단위)
  double get calculatedDistance {
    if (distance != null) return distance!;

    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < route.length; i++) {
      totalDistance += _calculateDistance(
        route[i - 1].latitude,
        route[i - 1].longitude,
        route[i].latitude,
        route[i].longitude,
      );
    }
    return totalDistance;
  }

  /// 두 지점 간의 거리 계산 (Haversine 공식)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();
    final double c = 2 * (a.sqrt()).asin();

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);

  /// 엔티티 복사
  WalkRecordEntity copyWith({
    String? id,
    String? petId,
    String? petName,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    double? distance,
    List<WalkLocation>? route,
    String? notes,
    WalkStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalkRecordEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      route: route ?? this.route,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalkRecordEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WalkRecordEntity(id: $id, petName: $petName, status: $status, distance: $calculatedDistance)';
  }
}

/// 산책 상태 열거형
enum WalkStatus {
  inProgress, // 진행 중
  paused, // 일시정지
  completed, // 완료
  cancelled, // 취소
}
