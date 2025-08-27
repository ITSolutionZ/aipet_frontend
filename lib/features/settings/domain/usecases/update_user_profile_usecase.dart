import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateUserProfileUseCase {
  final SettingsRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  /// 사용자 프로필 업데이트
  Future<bool> call(UserProfileEntity profile) async {
    return _repository.updateUserProfile(profile);
  }
}
