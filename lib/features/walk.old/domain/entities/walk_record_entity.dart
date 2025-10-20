import 'dart:math' as math;

import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';

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

    final double lat1Rad = _toRadians(lat1);
    final double lat2Rad = _toRadians(lat2);
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);

  /// UI에서 사용할 제목
  String get title => '$petNameの散歩';

  /// UI에서 사용할 날짜 문자열
  String get dateString {
    final date = startTime;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 펫 이미지 경로 (기본값)
  String? get petImage {
    // 펫 이미지 시스템에서 펫 ID로 이미지 조회
    // 현재는 기본 이미지 반환, 추후 펫 프로필 서비스 연동 예정
    return 'assets/images/pets/default_pet.png';
  }

  /// 시간 문자열 (HH:MM 형식)
  String get timeString {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 전체 날짜시간 문자열
  String get fullDateTimeString {
    return '$dateString $timeString';
  }

  /// 포맷된 거리 문자열
  String get formattedDistance {
    final dist = calculatedDistance;
    if (dist < 1000) {
      return '${dist.toStringAsFixed(0)}m';
    } else {
      return '${(dist / 1000).toStringAsFixed(2)}km';
    }
  }

  /// 포맷된 시간 문자열
  String get formattedDuration {
    final duration = calculatedDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours時間$minutes分';
    } else {
      return '$minutes分';
    }
  }

  /// 소유자 이름 (기본값)
  String get ownerName {
    // 실제 소유자 정보 연동 (사용자 프로필 서비스에서 조회)
    // 현재는 기본값 반환, 추후 사용자 프로필 서비스 연동 예정
    return 'ペットの飼い主';
  }

  /// 소유자 아바타 (기본값)
  String? get ownerAvatar {
    // 실제 소유자 아바타 연동 (사용자 프로필 서비스에서 조회)
    // 현재는 기본 아바타 반환, 추후 사용자 프로필 서비스 연동 예정
    return 'assets/images/avatars/default_avatar.png';
  }

  /// JSON에서 엔티티 생성
  factory WalkRecordEntity.fromJson(Map<String, dynamic> json) {
    return WalkRecordEntity(
      id: json['id'] as String,
      petId: json['petId'] as String,
      petName: json['petName'] as String,
      startTime: json['startTime'] is DateTime
          ? json['startTime'] as DateTime
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] is DateTime
          ? json['endTime'] as DateTime?
          : json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] is Duration
          ? json['duration'] as Duration?
          : json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      distance: json['distance'] as double?,
      route:
          (json['route'] as List<dynamic>?)
              ?.map((e) => WalkLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      status: json['status'] is WalkStatus
          ? json['status'] as WalkStatus
          : WalkStatus.values.firstWhere(
              (s) => s.toString().split('.').last == json['status'],
              orElse: () => WalkStatus.completed,
            ),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 엔티티를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'distance': distance,
      'route': route.map((e) => e.toJson()).toList(),
      'notes': notes,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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
