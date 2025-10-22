/// 유튜브 비디오 북마크 엔티티
class VideoBookmarkEntity {
  final String id;
  final String videoId; // YouTube 비디오 ID
  final String title; // 북마크 제목
  final String? description; // 북마크 설명
  final int positionSec; // 북마크 위치 (초)
  final String? thumbnailUrl; // 해당 위치의 썸네일
  final DateTime createdAt;
  final DateTime updatedAt;

  const VideoBookmarkEntity({
    required this.id,
    required this.videoId,
    required this.title,
    this.description,
    required this.positionSec,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  VideoBookmarkEntity copyWith({
    String? id,
    String? videoId,
    String? title,
    String? description,
    int? positionSec,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoBookmarkEntity(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      description: description ?? this.description,
      positionSec: positionSec ?? this.positionSec,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 시간을 MM:SS 또는 HH:MM:SS 형식으로 포맷
  String get formattedTime {
    final hours = positionSec ~/ 3600;
    final minutes = (positionSec % 3600) ~/ 60;
    final seconds = positionSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 표시용 라벨 (제목 + 시간)
  String get displayLabel {
    return '$title ($formattedTime)';
  }

  /// 썸네일 URL 생성 (YouTube API 사용)
  String get thumbnailUrlGenerated {
    if (thumbnailUrl != null) return thumbnailUrl!;
    return 'https://img.youtube.com/vi/$videoId/0.jpg?t=$positionSec';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoBookmarkEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          videoId == other.videoId &&
          title == other.title &&
          description == other.description &&
          positionSec == other.positionSec &&
          thumbnailUrl == other.thumbnailUrl &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      videoId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      positionSec.hashCode ^
      thumbnailUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'VideoBookmarkEntity(id: $id, title: $title, position: $formattedTime)';
  }
}
