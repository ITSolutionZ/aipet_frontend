import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class GetVideoBookmarksUseCase {
  final PetActivitiesRepository _repository;

  GetVideoBookmarksUseCase(this._repository);

  Future<Result<List<VideoBookmarkEntity>>> call(String videoId) async {
    try {
      final result = await _repository.getVideoBookmarks(videoId);
      return Result.success('動画ブックマークを取得しました', result);
    } catch (error) {
      return Result.failure('動画ブックマークの取得に失敗しました: ${error.toString()}');
    }
  }
}
