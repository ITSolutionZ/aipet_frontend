import '../../../../shared/shared.dart';
import '../entities/user_profile_entity.dart' as settings_entities;

abstract class SettingsRepository {
  Future<Result<settings_entities.UserProfileEntity>> getUserProfile();
  Future<Result<settings_entities.UserProfileEntity>> updateUserProfile(
    settings_entities.UserProfileEntity profile,
  );
  Future<Result<void>> changePassword(
    settings_entities.PasswordChangeRequest request,
  );
  Future<Result<void>> deleteAccount();

  Future<Result<settings_entities.AppSettingsEntity>> getAppSettings();
  Future<Result<settings_entities.AppSettingsEntity>> saveAppSettings(
    settings_entities.AppSettingsEntity settings,
  );

  Future<Result<settings_entities.DataExportResult>> exportAppData();
  Future<Result<void>> importAppData(String filePath);

  Future<Result<void>> clearAppCache();
  Future<Result<int>> getCacheSize();
}
