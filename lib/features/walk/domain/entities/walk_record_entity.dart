import 'package:aipet_frontend/shared/shared.dart';
import 'walk_location_entity.dart';

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
  String get timeString => DateTimeUtils.formatTime(startTime);

  /// 산책 날짜 문자열 반환
  String get dateString => DateTimeUtils.formatDate(startTime);

  /// 전체 날짜 시간 문자열 반환
  String get fullDateTimeString => DateTimeUtils.formatDateTime(startTime);

  /// 산책 시간 포맷팅
  String get formattedDuration => DateTimeUtils.formatDurationSafe(duration);

  /// 거리 포맷팅
  String get formattedDistance => DateTimeUtils.formatDistance(distance);

  /// JSON에서 WalkRecordEntity 생성
  factory WalkRecordEntity.fromJson(Map<String, dynamic> json) {
    return WalkRecordEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      distance: (json['distance'] as num?)?.toDouble(),
      route:
          (json['route'] as List<dynamic>?)
              ?.map((e) => WalkLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      petId: json['petId'] as String?,
      petName: json['petName'] as String?,
      petImage: json['petImage'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerAvatar: json['ownerAvatar'] as String?,
      status: WalkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalkStatus.completed,
      ),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

enum WalkStatus {
  inProgress, // 진행 중
  completed, // 완료
  paused, // 일시정지
  cancelled, // 취소
}
