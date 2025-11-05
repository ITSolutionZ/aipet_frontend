import '../../../../shared/shared.dart';

import '../../../../../features/pet_profile/domain/repositories/pet_profile_repository.dart';

class CreatePetUseCase {
  final PetProfileRepository repository;

  CreatePetUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.createPet(pet);
      if (result.isSuccess) {
        return Result.success('ペットを登録しました', result.dataOrNull!);
      } else {
        return Result.failure('ペットの登録に失敗しました');
      }
    } catch (error) {
      return Result.failure('ペットの作成に失敗しました: ${error.toString()}');
    }
  }
}
