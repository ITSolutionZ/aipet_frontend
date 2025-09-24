import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';

class GetVideoBookmarksUseCase {
  final PetActivitiesRepository _repository;

  GetVideoBookmarksUseCase(this._repository);

  Future<List<VideoBookmarkEntity>> call(String videoId) async {
    return _repository.getVideoBookmarks(videoId);
  }
}
