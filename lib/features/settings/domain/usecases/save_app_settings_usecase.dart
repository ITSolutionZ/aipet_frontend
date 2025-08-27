import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class SaveAppSettingsUseCase {
  final SettingsRepository _repository;

  const SaveAppSettingsUseCase(this._repository);

  /// 앱 설정 저장
  Future<bool> call(AppSettingsEntity settings) async {
    return _repository.saveAppSettings(settings);
  }
}
