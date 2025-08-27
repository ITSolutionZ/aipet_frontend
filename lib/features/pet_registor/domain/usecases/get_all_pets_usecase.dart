import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class GetAllPetsUseCase {
  final PetRepository repository;

  GetAllPetsUseCase(this.repository);

  Future<List<PetProfileEntity>> call() async {
    return repository.getAllPets();
  }
}
