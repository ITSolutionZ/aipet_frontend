import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    try {
      final result = await repository.deletePet(id);
      if (result.isSuccess) {
        return Result.success('ペットを削除しました', null);
      } else {
        return Result.failure('ペットの削除に失敗しました');
      }
    } catch (error) {
      return Result.failure('ペットの削除に失敗しました: ${error.toString()}');
    }
  }
}
