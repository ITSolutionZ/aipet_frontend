class WalkRecordEntity {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final double? distance; // km
  final List<WalkLocation> route;
  final String? petId;
  final String? petName;
  final String? petImage;
  final String? ownerId;
  final String? ownerName;
  final String? ownerAvatar;
  final WalkStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalkRecordEntity({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.duration,
    this.distance,
    required this.route,
    this.petId,
    this.petName,
    this.petImage,
    this.ownerId,
    this.ownerName,
    this.ownerAvatar,
    this.status = WalkStatus.completed,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  WalkRecordEntity copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    double? distance,
    List<WalkLocation>? route,
    String? petId,
    String? petName,
    String? petImage,
    String? ownerId,
    String? ownerName,
    String? ownerAvatar,
    WalkStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalkRecordEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      route: route ?? this.route,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImage: petImage ?? this.petImage,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 산책 시간 문자열 반환
  String get timeString {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 산책 날짜 문자열 반환
  String get dateString {
    final day = startTime.day.toString().padLeft(2, '0');
    final month = startTime.month.toString().padLeft(2, '0');
    final year = startTime.year.toString();
    return '$day.$month.$year';
  }

  /// 전체 날짜 시간 문자열 반환
  String get fullDateTimeString {
    return '$dateString | $timeString';
  }

  /// 산책 시간 포맷팅
  String get formattedDuration {
    if (duration == null) return '--:--';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// 거리 포맷팅
  String get formattedDistance {
    if (distance == null) return '-- km';
    return '${distance!.toStringAsFixed(1)} km';
  }
}

enum WalkStatus {
  inProgress, // 진행 중
  completed, // 완료
  paused, // 일시정지
  cancelled, // 취소
}

class WalkLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? accuracy;

  const WalkLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.accuracy,
  });

  WalkLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? altitude,
    double? accuracy,
  }) {
    return WalkLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}
