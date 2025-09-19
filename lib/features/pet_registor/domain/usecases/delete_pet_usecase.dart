import '../../../../shared/shared.dart';
import '../repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    try {
      final result = await repository.deletePet(id);
      if (result.isSuccess) {
        return Result.success('펫이 성공적으로 삭제되었습니다', null);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }
}
