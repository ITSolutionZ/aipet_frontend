import '../entities/youtube_video_entity.dart';
import '../repositories/pet_activities_repository.dart';

/// YouTube 비디오 목록 조회 유스케이스
class GetYouTubeVideosUseCase {
  final PetActivitiesRepository _repository;

  GetYouTubeVideosUseCase(this._repository);

  /// 특정 펫의 YouTube 비디오 목록을 조회합니다.
  Future<List<YouTubeVideoEntity>> call(String petId) async {
    return _repository.getYouTubeVideosByPetId(petId);
  }

  /// 태그로 필터링된 YouTube 비디오 목록을 조회합니다.
  Future<List<YouTubeVideoEntity>> getByTags(String petId, List<String> tags) async {
    final allVideos = await _repository.getYouTubeVideosByPetId(petId);
    
    if (tags.isEmpty) {
      return allVideos;
    }
    
    return allVideos.where((video) {
      return video.tags.any((tag) => tags.contains(tag));
    }).toList();
  }

  /// 검색어로 YouTube 비디오를 검색합니다.
  Future<List<YouTubeVideoEntity>> search(String petId, String query) async {
    final allVideos = await _repository.getYouTubeVideosByPetId(petId);
    
    if (query.isEmpty) {
      return allVideos;
    }
    
    final lowerQuery = query.toLowerCase();
    
    return allVideos.where((video) {
      return video.title.toLowerCase().contains(lowerQuery) ||
          video.description?.toLowerCase().contains(lowerQuery) == true ||
          video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}