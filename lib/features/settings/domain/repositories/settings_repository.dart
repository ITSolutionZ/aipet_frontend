import '../entities/user_profile_entity.dart';

abstract class SettingsRepository {
  Future<UserProfileEntity> getUserProfile();
  Future<bool> updateUserProfile(UserProfileEntity profile);
  Future<bool> changePassword(PasswordChangeRequest request);
  Future<bool> deleteAccount();

  Future<AppSettingsEntity> getAppSettings();
  Future<bool> saveAppSettings(AppSettingsEntity settings);

  Future<DataExportResult> exportAppData();
  Future<bool> importAppData(String filePath);

  Future<bool> clearAppCache();
  Future<int> getCacheSize();
}
