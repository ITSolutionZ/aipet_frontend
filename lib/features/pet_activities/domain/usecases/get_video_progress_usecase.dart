import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';

class GetVideoProgressUseCase {
  final PetActivitiesRepository _repository;

  GetVideoProgressUseCase(this._repository);

  Future<VideoProgressEntity?> call(String videoId) async {
    return _repository.getVideoProgress(videoId);
  }
}
