import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';

class SaveVideoProgressUseCase {
  final PetActivitiesRepository _repository;

  SaveVideoProgressUseCase(this._repository);

  Future<VideoProgressEntity> call({
    required String videoId,
    required int positionSec,
  }) async {
    final progress = VideoProgressEntity(
      videoId: videoId,
      currentPositionSec: positionSec,
      totalDurationSec: 0, // TODO: 실제 비디오 길이를 가져와야 함
      progress: 0.0, // TODO: 실제 진행률을 계산해야 함
      lastWatchedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _repository.saveVideoProgress(progress);
  }
}
