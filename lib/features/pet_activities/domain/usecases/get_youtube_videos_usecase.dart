import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// YouTube 비디오 목록 조회 유스케이스
class GetYouTubeVideosUseCase {
  final PetActivitiesRepository _repository;

  GetYouTubeVideosUseCase(this._repository);

  /// 특정 펫의 YouTube 비디오 목록을 조회합니다.
  Future<Result<List<YouTubeVideoEntity>>> call(String petId) async {
    try {
      final result = await _repository.getYouTubeVideosByPetId(petId);
      return Result.success('YouTube動画一覧を取得しました', result);
    } catch (error) {
      return Result.failure('YouTube動画一覧の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 태그로 필터링된 YouTube 비디오 목록을 조회합니다.
  Future<Result<List<YouTubeVideoEntity>>> getByTags(String petId, List<String> tags) async {
    try {
      final allVideosResult = await call(petId);
      if (!allVideosResult.isSuccess) {
        return allVideosResult;
      }

      final allVideos = allVideosResult.dataOrNull!;

      if (tags.isEmpty) {
        return Result.success('タグでフィルタリングした動画一覧を取得しました', allVideos);
      }

      final filteredVideos = allVideos.where((video) {
        return video.tags.any((tag) => tags.contains(tag));
      }).toList();

      return Result.success('タグでフィルタリングした動画一覧を取得しました', filteredVideos);
    } catch (error) {
      return Result.failure('タグフィルタリング中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 검색어로 YouTube 비디오를 검색합니다.
  Future<Result<List<YouTubeVideoEntity>>> search(String petId, String query) async {
    try {
      final allVideosResult = await call(petId);
      if (!allVideosResult.isSuccess) {
        return allVideosResult;
      }

      final allVideos = allVideosResult.dataOrNull!;

      if (query.isEmpty) {
        return Result.success('検索結果を取得しました', allVideos);
      }

      final lowerQuery = query.toLowerCase();

      final searchResults = allVideos.where((video) {
        return video.title.toLowerCase().contains(lowerQuery) ||
            video.description?.toLowerCase().contains(lowerQuery) == true ||
            video.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();

      return Result.success('検索結果を取得しました', searchResults);
    } catch (error) {
      return Result.failure('検索中にエラーが発生しました: ${error.toString()}');
    }
  }
}
