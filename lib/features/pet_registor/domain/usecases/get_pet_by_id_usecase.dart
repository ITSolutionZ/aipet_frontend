import '../../../../shared/shared.dart';
import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class GetPetByIdUseCase {
  final PetRepository repository;

  GetPetByIdUseCase(this.repository);

  Future<Result<PetProfileEntity?>> call(String id) async {
    try {
      final result = await repository.getPetById(id);
      if (result.isSuccess) {
        return Result.success(result.message, result.data);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      return Result.failure('Failed to get pet: ${error.toString()}');
    }
  }
}
