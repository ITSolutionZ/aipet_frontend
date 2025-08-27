import '../entities/video_progress_entity.dart';
import '../repositories/pet_activities_repository.dart';

class SaveVideoProgressUseCase {
  final PetActivitiesRepository _repository;

  SaveVideoProgressUseCase(this._repository);

  Future<VideoProgressEntity> call({
    required String videoId,
    required int positionSec,
  }) async {
    final progress = VideoProgressEntity(
      videoId: videoId,
      lastPositionSec: positionSec,
      updatedAt: DateTime.now(),
    );

    return _repository.saveVideoProgress(progress);
  }
}
