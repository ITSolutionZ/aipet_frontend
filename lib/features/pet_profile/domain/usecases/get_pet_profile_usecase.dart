import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class GetPetProfileUseCase {
  final PetProfileRepository repository;

  GetPetProfileUseCase(this.repository);

  Future<Result<PetProfileEntity?>> call(String id) async {
    try {
      final result = await repository.getPetById(id);
      if (result.isSuccess) {
        return Success(result.dataOrNull, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ペットプロフィールの取得に失敗しました: ${error.toString()}');
    }
  }
}
