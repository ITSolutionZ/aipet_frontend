/// 비디오 북마크 엔티티
class VideoBookmarkEntity {
  final String id;
  final String videoId;
  final String title;
  final int positionSec;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VideoBookmarkEntity({
    required this.id,
    required this.videoId,
    required this.title,
    required this.positionSec,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 VideoBookmarkEntity 생성
  factory VideoBookmarkEntity.fromJson(Map<String, dynamic> json) {
    return VideoBookmarkEntity(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      positionSec: json['positionSec'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// VideoBookmarkEntity를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'title': title,
      'positionSec': positionSec,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 북마크 복사
  VideoBookmarkEntity copyWith({
    String? id,
    String? videoId,
    String? title,
    int? positionSec,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoBookmarkEntity(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      positionSec: positionSec ?? this.positionSec,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoBookmarkEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 표시용 라벨 (title과 동일하지만 호환성을 위해 별도 제공)
  String get displayLabel => title;

  /// 포맷된 시간 (MM:SS 형식)
  String get formattedTime {
    final minutes = positionSec ~/ 60;
    final seconds = positionSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'VideoBookmarkEntity(id: $id, videoId: $videoId, title: $title, positionSec: $positionSec)';
  }
}
