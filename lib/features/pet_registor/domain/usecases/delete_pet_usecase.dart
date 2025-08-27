import '../repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<void> call(String id) async {
    return repository.deletePet(id);
  }
}
