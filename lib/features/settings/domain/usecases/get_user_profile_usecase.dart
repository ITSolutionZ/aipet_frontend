import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

class GetUserProfileUseCase {
  final SettingsRepository _repository;

  const GetUserProfileUseCase(this._repository);

  /// 사용자 프로필 가져오기
  Future<Result<UserProfileEntity>> call() async {
    final result = await _repository.getUserProfile();
    if (result.isSuccess) {
      return Result.success(result.message, result.data);
    } else {
      return Result.failure(result.message);
    }
  }
}
