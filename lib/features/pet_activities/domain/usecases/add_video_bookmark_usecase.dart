import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class AddVideoBookmarkUseCase {
  final PetActivitiesRepository _repository;

  AddVideoBookmarkUseCase(this._repository);

  Future<Result<VideoBookmarkEntity>> call({
    required String videoId,
    required String youtubeVideoId,
    required int positionSec,
    String? label,
    String? description,
  }) async {
    try {
      final bookmark = VideoBookmarkEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        videoId: videoId,
        title: label ?? 'Bookmark',
        positionSec: positionSec,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _repository.addVideoBookmark(bookmark);
      return Result.success('動画ブックマークを追加しました', result);
    } catch (error) {
      return Result.failure('動画ブックマークの追加に失敗しました: ${error.toString()}');
    }
  }
}
