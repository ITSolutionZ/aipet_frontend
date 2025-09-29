import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class DeletePetUseCase {
  final PetProfileRepository repository;

  DeletePetUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    try {
      final result = await repository.deletePet(id);
      if (result.isSuccess) {
        return Success(result.dataOrNull, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ペットの削除に失敗しました: ${error.toString()}');
    }
  }
}
