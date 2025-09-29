import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class UpdateUserProfileUseCase {
  final SettingsRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  /// 사용자 프로필 업데이트
  Future<Result<UserProfileEntity>> call(UserProfileEntity profile) async {
    final result = await _repository.updateUserProfile(profile);
    if (result.isSuccess) {
      return Result.success('ユーザープロフィールを更新しました', result.dataOrNull!);
    } else {
      return Result.failure('ユーザープロフィールの更新に失敗しました');
    }
  }
}
