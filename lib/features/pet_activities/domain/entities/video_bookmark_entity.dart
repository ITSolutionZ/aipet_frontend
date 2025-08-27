/// 비디오 북마크 엔티티
class VideoBookmarkEntity {
  final String id;
  final String videoId; // YouTube 비디오 ID
  final String youtubeVideoId; // YouTube 비디오 ID (실제 11자리 ID)
  final int positionSec; // 북마크 위치 (초)
  final String? label; // 북마크 라벨 (선택사항)
  final String? description; // 북마크 설명
  final DateTime createdAt;

  const VideoBookmarkEntity({
    required this.id,
    required this.videoId,
    required this.youtubeVideoId,
    required this.positionSec,
    this.label,
    this.description,
    required this.createdAt,
  });

  VideoBookmarkEntity copyWith({
    String? id,
    String? videoId,
    String? youtubeVideoId,
    int? positionSec,
    String? label,
    String? description,
    DateTime? createdAt,
  }) {
    return VideoBookmarkEntity(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      positionSec: positionSec ?? this.positionSec,
      label: label ?? this.label,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 시간을 MM:SS 형식으로 포맷
  String get formattedTime {
    final minutes = positionSec ~/ 60;
    final seconds = positionSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 시간을 HH:MM:SS 형식으로 포맷 (1시간 이상인 경우)
  String get formattedTimeWithHours {
    final hours = positionSec ~/ 3600;
    final minutes = (positionSec % 3600) ~/ 60;
    final seconds = positionSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return formattedTime;
  }

  /// 북마크 표시용 라벨 (라벨이 없으면 시간 사용)
  String get displayLabel {
    return label?.isNotEmpty == true ? label! : formattedTime;
  }

  /// YouTube URL로 이동 (특정 시간으로)
  String get youtubeUrlWithTime {
    return 'https://www.youtube.com/watch?v=$youtubeVideoId&t=${positionSec}s';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoBookmarkEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          videoId == other.videoId &&
          youtubeVideoId == other.youtubeVideoId &&
          positionSec == other.positionSec &&
          label == other.label &&
          description == other.description &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      videoId.hashCode ^
      youtubeVideoId.hashCode ^
      positionSec.hashCode ^
      label.hashCode ^
      description.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'VideoBookmarkEntity(id: $id, videoId: $videoId, position: $formattedTime, label: $label)';
  }
}
