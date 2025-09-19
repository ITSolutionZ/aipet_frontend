import '../../../../shared/shared.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateUserProfileUseCase {
  final SettingsRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  /// 사용자 프로필 업데이트
  Future<Result<UserProfileEntity>> call(UserProfileEntity profile) async {
    final result = await _repository.updateUserProfile(profile);
    if (result.isSuccess) {
      return Result.success(result.message, result.data);
    } else {
      return Result.failure(result.message);
    }
  }
}
