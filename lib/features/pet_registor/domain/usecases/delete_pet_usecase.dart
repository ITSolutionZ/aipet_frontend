import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    try {
      final result = await repository.deletePet(id);
      if (result.isSuccess) {
        return const Success(null, '펫이 성공적으로 삭제되었습니다');
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }
}
