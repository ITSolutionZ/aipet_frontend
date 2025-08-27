import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase(this.repository);

  Future<PetProfileEntity> call(PetProfileEntity pet) async {
    return repository.updatePet(pet);
  }
}
