import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class CreatePetUseCase {
  final PetRepository repository;

  CreatePetUseCase(this.repository);

  Future<PetProfileEntity> call(PetProfileEntity pet) async {
    return repository.createPet(pet);
  }
}
