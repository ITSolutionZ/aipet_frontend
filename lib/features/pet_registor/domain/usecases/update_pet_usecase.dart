import '../../../../shared/shared.dart';
import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.updatePet(pet);
      if (result.isSuccess) {
        return Result.success('ペット情報が更新されました', result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      return Result.failure('ペットの更新に失敗しました: ${error.toString()}');
    }
  }
}
