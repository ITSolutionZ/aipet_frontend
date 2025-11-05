import '../../../../shared/shared.dart';

import '../../../../../features/pet_profile/domain/repositories/pet_profile_repository.dart';

class GetPetProfileUseCase {
  final PetProfileRepository repository;

  GetPetProfileUseCase(this.repository);

  Future<Result<PetProfileEntity?>> call(String id) async {
    try {
      final result = await repository.getPetById(id);
      if (result.isSuccess) {
        return Result.success('ペットプロフィールを取得しました', result.dataOrNull);
      } else {
        return Result.failure('ペットプロフィールの取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('ペットプロフィールの取得に失敗しました: ${error.toString()}');
    }
  }
}
