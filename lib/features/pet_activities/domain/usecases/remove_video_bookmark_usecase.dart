import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';

class RemoveVideoBookmarkUseCase {
  final PetActivitiesRepository _repository;

  RemoveVideoBookmarkUseCase(this._repository);

  Future<void> call(String bookmarkId) async {
    return _repository.removeVideoBookmark(bookmarkId);
  }
}
