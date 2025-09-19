import '../../../../shared/shared.dart';
import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class CreatePetUseCase {
  final PetRepository repository;

  CreatePetUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.createPet(pet);
      if (result.isSuccess) {
        return Result.success(result.message, result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      return Result.failure('ペットの作成に失敗しました: ${error.toString()}');
    }
  }
}
