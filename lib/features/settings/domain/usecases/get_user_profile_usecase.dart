import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class GetUserProfileUseCase {
  final SettingsRepository _repository;

  const GetUserProfileUseCase(this._repository);

  /// 사용자 프로필 가져오기
  Future<UserProfileEntity> call() async {
    return _repository.getUserProfile();
  }
}
