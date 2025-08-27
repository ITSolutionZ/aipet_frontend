import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class GetPetByIdUseCase {
  final PetRepository repository;

  GetPetByIdUseCase(this.repository);

  Future<PetProfileEntity?> call(String id) async {
    return repository.getPetById(id);
  }
}
