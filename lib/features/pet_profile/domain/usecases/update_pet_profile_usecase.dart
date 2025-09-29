import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class UpdatePetProfileUseCase {
  final PetProfileRepository repository;

  UpdatePetProfileUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.updatePet(pet);
      if (result.isSuccess) {
        return Result.success('ペットプロフィールを更新しました', result.dataOrNull!);
      } else {
        return Result.failure('ペットプロフィールの更新に失敗しました');
      }
    } catch (error) {
      return Result.failure('ペットプロフィールの更新に失敗しました: ${error.toString()}');
    }
  }
}
