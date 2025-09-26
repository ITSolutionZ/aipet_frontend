import 'package:aipet_frontend/shared/entities/settings_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

abstract class SettingsRepository {
  Future<Result<UserProfileEntity>> getUserProfile();
  Future<Result<UserProfileEntity>> updateUserProfile(
    UserProfileEntity profile,
  );
  Future<Result<void>> changePassword(PasswordChangeRequest request);
  Future<Result<void>> deleteAccount();

  Future<Result<AppSettingsEntity>> getAppSettings();
  Future<Result<AppSettingsEntity>> saveAppSettings(AppSettingsEntity settings);

  Future<Result<DataExportResult>> exportAppData();
  Future<Result<void>> importAppData(String filePath);

  Future<Result<void>> clearAppCache();
  Future<Result<int>> getCacheSize();
}
