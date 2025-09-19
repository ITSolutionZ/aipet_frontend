import '../../../../shared/shared.dart';
import '../entities/pet_profile_entity.dart';
import '../repositories/pet_repository.dart';

class GetAllPetsUseCase {
  final PetRepository repository;

  GetAllPetsUseCase(this.repository);

  Future<Result<List<PetProfileEntity>>> call() async {
    try {
      final result = await repository.getAllPets();
      if (result.isSuccess) {
        return Result.success(result.message, result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      return Result.failure('ペット一覧の取得に失敗しました: ${error.toString()}');
    }
  }
}
