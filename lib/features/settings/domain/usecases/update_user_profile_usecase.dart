import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

class UpdateUserProfileUseCase {
  final SettingsRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  /// 사용자 프로필 업데이트
  Future<Result<UserProfileEntity>> call(UserProfileEntity profile) async {
    final result = await _repository.updateUserProfile(profile);
    if (result.isSuccess) {
      return Success(result.dataOrNull!, result.errorOrNull);
    } else {
      return Result.failure(result.errorOrNull ?? 'Unknown error');
    }
  }
}
