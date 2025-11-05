import '../../../../shared/shared.dart';

import '../../../../../features/pet_profile/domain/repositories/pet_profile_repository.dart';

class ManageFamilyManagersUseCase {
  final PetProfileRepository repository;

  ManageFamilyManagersUseCase(this.repository);

  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    try {
      final result = await repository.addFamilyManager(petId, userId);
      if (result.isSuccess) {
        return Result.success('家族管理者を追加しました', null);
      } else {
        return Result.failure('家族管理者の追加に失敗しました');
      }
    } catch (error) {
      return Result.failure('ファミリーマネージャーの追加に失敗しました: ${error.toString()}');
    }
  }

  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    try {
      final result = await repository.removeFamilyManager(petId, userId);
      if (result.isSuccess) {
        return Result.success('家族管理者を削除しました', null);
      } else {
        return Result.failure('家族管理者の削除に失敗しました');
      }
    } catch (error) {
      return Result.failure('ファミリーマネージャーの削除に失敗しました: ${error.toString()}');
    }
  }
}
