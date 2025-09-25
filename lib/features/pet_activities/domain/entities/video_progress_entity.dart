/// 비디오 진행률 엔티티
class VideoProgressEntity {
  final String videoId;
  final int currentPositionSec;
  final int totalDurationSec;
  final double progress; // 0.0 ~ 1.0
  final bool isCompleted;
  final DateTime lastWatchedAt;
  final DateTime updatedAt;

  const VideoProgressEntity({
    required this.videoId,
    required this.currentPositionSec,
    required this.totalDurationSec,
    required this.progress,
    this.isCompleted = false,
    required this.lastWatchedAt,
    required this.updatedAt,
  });

  /// JSON에서 VideoProgressEntity 생성
  factory VideoProgressEntity.fromJson(Map<String, dynamic> json) {
    return VideoProgressEntity(
      videoId: json['videoId'] as String,
      currentPositionSec: json['currentPositionSec'] as int,
      totalDurationSec: json['totalDurationSec'] as int,
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastWatchedAt: DateTime.parse(json['lastWatchedAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// VideoProgressEntity를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'currentPositionSec': currentPositionSec,
      'totalDurationSec': totalDurationSec,
      'progress': progress,
      'isCompleted': isCompleted,
      'lastWatchedAt': lastWatchedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 진행률 계산
  double get calculatedProgress {
    if (totalDurationSec == 0) return 0.0;
    return (currentPositionSec / totalDurationSec).clamp(0.0, 1.0);
  }

  /// 남은 시간 계산 (초)
  int get remainingTimeSec {
    return (totalDurationSec - currentPositionSec).clamp(0, totalDurationSec);
  }

  /// 남은 시간을 시:분:초 형식으로 반환
  String get remainingTimeFormatted {
    final hours = remainingTimeSec ~/ 3600;
    final minutes = (remainingTimeSec % 3600) ~/ 60;
    final seconds = remainingTimeSec % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 진행률 업데이트
  VideoProgressEntity updateProgress(int newPositionSec) {
    final newProgress = (newPositionSec / totalDurationSec).clamp(0.0, 1.0);
    final isCompleted = newProgress >= 0.95; // 95% 이상이면 완료로 간주

    return VideoProgressEntity(
      videoId: videoId,
      currentPositionSec: newPositionSec,
      totalDurationSec: totalDurationSec,
      progress: newProgress,
      isCompleted: isCompleted,
      lastWatchedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 진행률 복사
  VideoProgressEntity copyWith({
    String? videoId,
    int? currentPositionSec,
    int? totalDurationSec,
    double? progress,
    bool? isCompleted,
    DateTime? lastWatchedAt,
    DateTime? updatedAt,
  }) {
    return VideoProgressEntity(
      videoId: videoId ?? this.videoId,
      currentPositionSec: currentPositionSec ?? this.currentPositionSec,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoProgressEntity && other.videoId == videoId;
  }

  @override
  int get hashCode => videoId.hashCode;

  @override
  String toString() {
    return 'VideoProgressEntity(videoId: $videoId, progress: ${(progress * 100).toStringAsFixed(1)}%, isCompleted: $isCompleted)';
  }
}
