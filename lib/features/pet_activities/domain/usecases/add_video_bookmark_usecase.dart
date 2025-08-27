import '../entities/video_bookmark_entity.dart';
import '../repositories/pet_activities_repository.dart';

class AddVideoBookmarkUseCase {
  final PetActivitiesRepository _repository;

  AddVideoBookmarkUseCase(this._repository);

  Future<VideoBookmarkEntity> call({
    required String videoId,
    required String youtubeVideoId,
    required int positionSec,
    String? label,
    String? description,
  }) async {
    final bookmark = VideoBookmarkEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      youtubeVideoId: youtubeVideoId,
      positionSec: positionSec,
      label: label,
      description: description,
      createdAt: DateTime.now(),
    );

    return _repository.addVideoBookmark(bookmark);
  }
}
