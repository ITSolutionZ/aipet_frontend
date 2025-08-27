/// 비디오 진행도 엔티티
class VideoProgressEntity {
  final String videoId; // 트릭 ID 또는 비디오 식별자
  final int lastPositionSec; // 마지막 재생 위치 (초)
  final DateTime updatedAt;

  const VideoProgressEntity({
    required this.videoId,
    required this.lastPositionSec,
    required this.updatedAt,
  });

  VideoProgressEntity copyWith({
    String? videoId,
    int? lastPositionSec,
    DateTime? updatedAt,
  }) {
    return VideoProgressEntity(
      videoId: videoId ?? this.videoId,
      lastPositionSec: lastPositionSec ?? this.lastPositionSec,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 마지막 위치를 MM:SS 형식으로 포맷
  String get formattedTime {
    final minutes = lastPositionSec ~/ 60;
    final seconds = lastPositionSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 마지막 위치를 HH:MM:SS 형식으로 포맷 (1시간 이상인 경우)
  String get formattedTimeWithHours {
    final hours = lastPositionSec ~/ 3600;
    final minutes = (lastPositionSec % 3600) ~/ 60;
    final seconds = lastPositionSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return formattedTime;
  }

  /// 진행도가 유효한지 확인 (5초 이상인 경우만 유효)
  bool get isValidProgress {
    return lastPositionSec >= 5;
  }

  /// 이어보기 제안 메시지
  String get resumeMessage {
    return '$formattedTimeから再生しますか？';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoProgressEntity &&
          runtimeType == other.runtimeType &&
          videoId == other.videoId &&
          lastPositionSec == other.lastPositionSec &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      videoId.hashCode ^ lastPositionSec.hashCode ^ updatedAt.hashCode;

  @override
  String toString() {
    return 'VideoProgressEntity(videoId: $videoId, position: $formattedTime, updatedAt: $updatedAt)';
  }
}
