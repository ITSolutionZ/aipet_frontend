import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class RemoveVideoBookmarkUseCase {
  final PetActivitiesRepository _repository;

  RemoveVideoBookmarkUseCase(this._repository);

  Future<Result<void>> call(String bookmarkId) async {
    try {
      await _repository.removeVideoBookmark(bookmarkId);
      return Result.success('動画ブックマークを削除しました', null);
    } catch (error) {
      return Result.failure('動画ブックマークの削除に失敗しました: ${error.toString()}');
    }
  }
}
