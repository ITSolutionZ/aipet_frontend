import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class GetAllPetsUseCase {
  final PetProfileRepository repository;

  GetAllPetsUseCase(this.repository);

  Future<Result<List<PetProfileEntity>>> call() async {
    try {
      final result = await repository.getAllPets();
      if (result.isSuccess) {
        return Success(result.dataOrNull!, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ペット一覧の取得に失敗しました: ${error.toString()}');
    }
  }
}
