/// YouTube 비디오 엔티티
class YouTubeVideoEntity {
  final String id;
  final String youtubeUrl;
  final String youtubeVideoId; // YouTube 비디오 ID (URL에서 추출)
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int durationSeconds; // 비디오 총 길이 (초)
  final String petId; // 펫 ID
  final List<String> tags; // 트릭 태그 (예: 'sit', 'shake', 'roll')
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const YouTubeVideoEntity({
    required this.id,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.petId,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });
  
  YouTubeVideoEntity copyWith({
    String? id,
    String? youtubeUrl,
    String? youtubeVideoId,
    String? title,
    String? description,
    String? thumbnailUrl,
    int? durationSeconds,
    String? petId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YouTubeVideoEntity(
      id: id ?? this.id,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      petId: petId ?? this.petId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// YouTube 비디오 ID를 URL에서 추출하는 정적 메소드
  static String? extractVideoId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }
  
  /// YouTube 썸네일 URL 생성
  static String generateThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }
  
  /// 비디오 길이를 MM:SS 또는 HH:MM:SS 형식으로 포맷
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// 태그들을 문자열로 결합
  String get tagsString {
    return tags.join(', ');
  }
  
  /// YouTube 비디오가 유효한지 확인
  bool get isValidYouTubeVideo {
    return youtubeVideoId.isNotEmpty && youtubeVideoId.length == 11;
  }
  
  /// 특정 시간으로 이동하는 YouTube URL 생성
  String getYouTubeUrlWithTime(int startTimeSeconds) {
    return '$youtubeUrl&t=${startTimeSeconds}s';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YouTubeVideoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          youtubeUrl == other.youtubeUrl &&
          youtubeVideoId == other.youtubeVideoId &&
          title == other.title &&
          description == other.description &&
          thumbnailUrl == other.thumbnailUrl &&
          durationSeconds == other.durationSeconds &&
          petId == other.petId &&
          tags.toString() == other.tags.toString() &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      youtubeUrl.hashCode ^
      youtubeVideoId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      thumbnailUrl.hashCode ^
      durationSeconds.hashCode ^
      petId.hashCode ^
      tags.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'YouTubeVideoEntity(id: $id, title: $title, videoId: $youtubeVideoId, duration: $formattedDuration)';
  }
}