import '../../../../shared/shared.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class GetAppSettingsUseCase {
  final SettingsRepository _repository;

  const GetAppSettingsUseCase(this._repository);

  /// 앱 설정 가져오기
  Future<Result<AppSettingsEntity>> call() async {
    final result = await _repository.getAppSettings();
    if (result.isSuccess) {
      return Result.success(result.message, result.data);
    } else {
      return Result.failure(result.message);
    }
  }
}
