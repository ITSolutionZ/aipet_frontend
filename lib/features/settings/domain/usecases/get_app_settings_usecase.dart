import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class GetAppSettingsUseCase {
  final SettingsRepository _repository;

  const GetAppSettingsUseCase(this._repository);

  /// 앱 설정 가져오기
  Future<AppSettingsEntity> call() async {
    return _repository.getAppSettings();
  }
}
