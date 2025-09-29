import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class UpdatePetUseCase {
  final PetProfileRepository repository;

  UpdatePetUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.updatePet(pet);
      if (result.isSuccess) {
        return Success(result.dataOrNull!, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ペットの更新に失敗しました: ${error.toString()}');
    }
  }
}
