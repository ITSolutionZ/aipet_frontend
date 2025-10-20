import 'package:aipet_frontend/features/settings/domain/entities/settings_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class GetUserProfileUseCase {
  final SettingsRepository _repository;

  const GetUserProfileUseCase(this._repository);

  /// 사용자 프로필 가져오기
  Future<Result<UserProfileEntity>> call() async {
    final result = await _repository.getUserProfile();
    if (result.isSuccess) {
      return Result.success('ユーザープロフィールを取得しました', result.dataOrNull);
    } else {
      return Result.failure('ユーザープロフィールの取得に失敗しました');
    }
  }
}
