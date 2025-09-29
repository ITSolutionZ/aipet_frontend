import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';

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
      title: label ?? 'Bookmark',
      positionSec: positionSec,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _repository.addVideoBookmark(bookmark);
  }
}
