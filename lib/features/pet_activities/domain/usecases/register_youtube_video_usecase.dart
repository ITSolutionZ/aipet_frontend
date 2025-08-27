import '../entities/youtube_video_entity.dart';
import '../repositories/pet_activities_repository.dart';
import '../../../../shared/mock_data/mock_data_service.dart';

/// YouTube 비디오 등록 유스케이스
class RegisterYouTubeVideoUseCase {
  final PetActivitiesRepository _repository;

  RegisterYouTubeVideoUseCase(this._repository);

  /// YouTube 비디오를 등록합니다.
  Future<YouTubeVideoEntity> call({
    required String youtubeUrl,
    required String title,
    required String petId,
    String? description,
    List<String> tags = const [],
  }) async {
    // YouTube URL에서 비디오 ID 추출
    final videoId = YouTubeVideoEntity.extractVideoId(youtubeUrl);
    if (videoId == null || videoId.isEmpty) {
      throw Exception('유효하지 않은 YouTube URL입니다.');
    }

    // YouTube API를 통해 비디오 정보 가져오기 (모의 구현)
    final videoInfo = await _getYouTubeVideoInfo(videoId);

    final video = YouTubeVideoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      youtubeUrl: youtubeUrl,
      youtubeVideoId: videoId,
      title: title.isNotEmpty ? title : videoInfo['title'] ?? 'Untitled Video',
      description: description ?? videoInfo['description'],
      thumbnailUrl: YouTubeVideoEntity.generateThumbnailUrl(videoId),
      durationSeconds: videoInfo['duration'] ?? 0,
      petId: petId,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _repository.registerYouTubeVideo(video);
  }

  /// YouTube API를 통해 비디오 정보를 가져옵니다 (모의 구현)
  Future<Map<String, dynamic>> _getYouTubeVideoInfo(String videoId) async {
    // 실제 구현에서는 YouTube Data API v3을 사용
    // 여기서는 MockDataService에서 모의 데이터 반환
    await Future.delayed(const Duration(milliseconds: 500));

    return MockDataService.getMockYouTubeVideoInfo(videoId);
  }
}
