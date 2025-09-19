import '../../../../shared/shared.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class SaveAppSettingsUseCase {
  final SettingsRepository _repository;

  const SaveAppSettingsUseCase(this._repository);

  /// 앱 설정 저장
  Future<Result<AppSettingsEntity>> call(AppSettingsEntity settings) async {
    final result = await _repository.saveAppSettings(settings);
    if (result.isSuccess) {
      return Result.success(result.message, result.data);
    } else {
      return Result.failure(result.message);
    }
  }
}
