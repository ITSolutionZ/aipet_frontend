import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class GetVideoProgressUseCase {
  final PetActivitiesRepository _repository;

  GetVideoProgressUseCase(this._repository);

  Future<Result<VideoProgressEntity?>> call(String videoId) async {
    try {
      final result = await _repository.getVideoProgress(videoId);
      return Result.success('動画の進捗を取得しました', result);
    } catch (error) {
      return Result.failure('動画の進捗取得に失敗しました: ${error.toString()}');
    }
  }
}
