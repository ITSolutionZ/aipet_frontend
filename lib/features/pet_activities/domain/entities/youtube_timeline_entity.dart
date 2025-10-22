/// 유튜브 비디오 타임라인 섹션 엔티티
class YouTubeTimelineEntity {
  final String id;
  final String videoId; // YouTube 비디오 ID
  final String title; // 섹션 제목
  final String? description; // 섹션 설명
  final int startTimeSec; // 시작 시간 (초)
  final int endTimeSec; // 종료 시간 (초)
  final String? thumbnailUrl; // 섹션 썸네일
  final DateTime createdAt;
  final DateTime updatedAt;

  const YouTubeTimelineEntity({
    required this.id,
    required this.videoId,
    required this.title,
    this.description,
    required this.startTimeSec,
    required this.endTimeSec,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  YouTubeTimelineEntity copyWith({
    String? id,
    String? videoId,
    String? title,
    String? description,
    int? startTimeSec,
    int? endTimeSec,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YouTubeTimelineEntity(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTimeSec: startTimeSec ?? this.startTimeSec,
      endTimeSec: endTimeSec ?? this.endTimeSec,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 섹션 지속 시간 (초)
  int get durationSec => endTimeSec - startTimeSec;

  /// 시작 시간을 MM:SS 또는 HH:MM:SS 형식으로 포맷
  String get formattedStartTime {
    final hours = startTimeSec ~/ 3600;
    final minutes = (startTimeSec % 3600) ~/ 60;
    final seconds = startTimeSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 종료 시간을 MM:SS 또는 HH:MM:SS 형식으로 포맷
  String get formattedEndTime {
    final hours = endTimeSec ~/ 3600;
    final minutes = (endTimeSec % 3600) ~/ 60;
    final seconds = endTimeSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 지속 시간을 MM:SS 또는 HH:MM:SS 형식으로 포맷
  String get formattedDuration {
    final hours = durationSec ~/ 3600;
    final minutes = (durationSec % 3600) ~/ 60;
    final seconds = durationSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 섹션 시간 범위 문자열
  String get timeRange => '$formattedStartTime - $formattedEndTime';

  /// 썸네일 URL 생성 (YouTube API 사용)
  String get thumbnailUrlGenerated {
    if (thumbnailUrl != null) return thumbnailUrl!;
    return 'https://img.youtube.com/vi/$videoId/0.jpg?t=$startTimeSec';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YouTubeTimelineEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          videoId == other.videoId &&
          title == other.title &&
          description == other.description &&
          startTimeSec == other.startTimeSec &&
          endTimeSec == other.endTimeSec &&
          thumbnailUrl == other.thumbnailUrl &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      videoId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      startTimeSec.hashCode ^
      endTimeSec.hashCode ^
      thumbnailUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'YouTubeTimelineEntity(id: $id, title: $title, timeRange: $timeRange)';
  }
}
