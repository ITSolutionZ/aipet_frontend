import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class ManageFamilyManagersUseCase {
  final PetProfileRepository repository;

  ManageFamilyManagersUseCase(this.repository);

  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    try {
      final result = await repository.addFamilyManager(petId, userId);
      if (result.isSuccess) {
        return Success(result.dataOrNull, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ファミリーマネージャーの追加に失敗しました: ${error.toString()}');
    }
  }

  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    try {
      final result = await repository.removeFamilyManager(petId, userId);
      if (result.isSuccess) {
        return Success(result.dataOrNull, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ファミリーマネージャーの削除に失敗しました: ${error.toString()}');
    }
  }
}
