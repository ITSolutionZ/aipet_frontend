/// 트릭 도메인 엔티티
///
/// 펫의 트릭 정보를 관리하는 도메인 엔티티입니다.
class TrickEntity {
  final String id;
  final String name;
  final String? petId;
  final DateTime? date;
  final int? progress;
  final String imagePath;
  final bool isCompleted;
  final bool isVideo;
  final String? difficulty;
  final String? duration;
  final String? youtubeUrl; // 유저가 등록한 유튜브 링크
  final String? description; // 트릭 설명
  final DateTime createdAt;
  final int? lastPlayedTimeInSeconds; // 마지막 재생 시점 (초)

  const TrickEntity({
    required this.id,
    required this.name,
    this.petId,
    this.date,
    this.progress,
    required this.imagePath,
    this.isCompleted = false,
    this.isVideo = false,
    this.difficulty,
    this.duration,
    this.youtubeUrl,
    this.description,
    required this.createdAt,
    this.lastPlayedTimeInSeconds,
  });

  TrickEntity copyWith({
    String? id,
    String? name,
    String? petId,
    DateTime? date,
    int? progress,
    String? imagePath,
    bool? isCompleted,
    bool? isVideo,
    String? difficulty,
    String? duration,
    String? youtubeUrl,
    String? description,
    DateTime? createdAt,
    int? lastPlayedTimeInSeconds,
  }) {
    return TrickEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      progress: progress ?? this.progress,
      imagePath: imagePath ?? this.imagePath,
      isCompleted: isCompleted ?? this.isCompleted,
      isVideo: isVideo ?? this.isVideo,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedTimeInSeconds: lastPlayedTimeInSeconds ?? this.lastPlayedTimeInSeconds,
    );
  }

  /// 트릭 완료 처리
  TrickEntity markAsCompleted() {
    return copyWith(isCompleted: true, progress: 100, date: DateTime.now());
  }

  /// 트릭 진행도 업데이트
  TrickEntity updateProgress(int newProgress) {
    final clampedProgress = newProgress.clamp(0, 100);
    return copyWith(
      progress: clampedProgress,
      isCompleted: clampedProgress >= 100,
      date: clampedProgress >= 100 ? DateTime.now() : date,
    );
  }

  /// 난이도 레벨 반환 (1-5)
  int get difficultyLevel {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return 1;
      case 'medium':
        return 3;
      case 'hard':
        return 5;
      default:
        return 2;
    }
  }

  /// 트릭이 최근에 완료되었는지 확인 (7일 이내)
  bool get isRecentlyCompleted {
    if (!isCompleted || date == null) return false;
    final now = DateTime.now();
    final difference = now.difference(date!);
    return difference.inDays <= 7;
  }

  /// 진행도 백분율 반환
  double get progressPercentage {
    if (progress == null) return 0.0;
    return (progress! / 100.0).clamp(0.0, 1.0);
  }

  /// 유튜브 링크가 유효한지 확인
  bool get hasValidYoutubeUrl {
    if (youtubeUrl == null) return false;
    return youtubeUrl!.contains('youtube.com') || youtubeUrl!.contains('youtu.be');
  }

  /// 유튜브 비디오 ID 추출
  String? get youtubeVideoId {
    if (!hasValidYoutubeUrl) return null;
    final regExp = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)');
    final match = regExp.firstMatch(youtubeUrl!);
    return match?.group(1);
  }

  /// 유튜브 썸네일 URL
  String? get youtubeThumbnailUrl {
    final videoId = youtubeVideoId;
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  /// 마지막 재생 시점이 있는지 확인
  bool get hasLastPlayedTime {
    return lastPlayedTimeInSeconds != null && lastPlayedTimeInSeconds! > 0;
  }

  /// 마지막 재생 시점을 MM:SS 형식으로 포맷
  String? get formattedLastPlayedTime {
    if (!hasLastPlayedTime) return null;
    final minutes = lastPlayedTimeInSeconds! ~/ 60;
    final seconds = lastPlayedTimeInSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 유튜브 URL에 마지막 재생 시점 포함
  String? get youtubeUrlWithLastPlayedTime {
    if (youtubeUrl == null || !hasLastPlayedTime) return youtubeUrl;
    
    if (youtubeUrl!.contains('youtube.com/watch')) {
      final separator = youtubeUrl!.contains('?') ? '&' : '?';
      return '$youtubeUrl${separator}t=${lastPlayedTimeInSeconds}s';
    } else if (youtubeUrl!.contains('youtu.be/')) {
      return '$youtubeUrl?t=${lastPlayedTimeInSeconds}s';
    }
    return youtubeUrl;
  }

  /// 마지막 재생 시점 업데이트
  TrickEntity updateLastPlayedTime(int timeInSeconds) {
    return copyWith(lastPlayedTimeInSeconds: timeInSeconds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrickEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          petId == other.petId &&
          date == other.date &&
          progress == other.progress &&
          imagePath == other.imagePath &&
          isCompleted == other.isCompleted &&
          isVideo == other.isVideo &&
          difficulty == other.difficulty &&
          duration == other.duration &&
          youtubeUrl == other.youtubeUrl &&
          description == other.description &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      petId.hashCode ^
      date.hashCode ^
      progress.hashCode ^
      imagePath.hashCode ^
      isCompleted.hashCode ^
      isVideo.hashCode ^
      difficulty.hashCode ^
      duration.hashCode ^
      youtubeUrl.hashCode ^
      description.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'TrickEntity(id: $id, name: $name, isCompleted: $isCompleted, progress: $progress)';
  }
}
