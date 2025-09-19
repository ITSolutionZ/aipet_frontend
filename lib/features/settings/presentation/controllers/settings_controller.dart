import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class SettingsController extends BaseController {
  SettingsController(super.ref);

  // Repository 및 UseCase 인스턴스 (목업 데이터 사용)
  late final SettingsRepository _repository = SettingsRepositoryImpl();
  late final GetUserProfileUseCase _getUserProfileUseCase =
      GetUserProfileUseCase(_repository);
  late final UpdateUserProfileUseCase _updateUserProfileUseCase =
      UpdateUserProfileUseCase(_repository);
  late final ChangePasswordUseCase _changePasswordUseCase =
      ChangePasswordUseCase(_repository);
  late final GetAppSettingsUseCase _getAppSettingsUseCase =
      GetAppSettingsUseCase(_repository);
  late final SaveAppSettingsUseCase _saveAppSettingsUseCase =
      SaveAppSettingsUseCase(_repository);
  late final DeleteAccountUseCase _deleteAccountUseCase = DeleteAccountUseCase(
    _repository,
  );
  late final ExportAppDataUseCase _exportAppDataUseCase = ExportAppDataUseCase(
    _repository,
  );
  late final ImportAppDataUseCase _importAppDataUseCase = ImportAppDataUseCase(
    _repository,
  );
  late final ClearAppCacheUseCase _clearAppCacheUseCase = ClearAppCacheUseCase(
    _repository,
  );

  /// 사용자 프로필 로드
  Future<Result<UserProfileEntity>> loadUserProfile() async {
    try {
      final result = await _getUserProfileUseCase.call();
      if (result.isSuccess) {
        return Result.success(result.message, result.data);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 프로필 업데이트
  Future<Result<UserProfileEntity>> updateProfile(
    UserProfileEntity profile,
  ) async {
    try {
      final result = await _updateUserProfileUseCase.call(profile);
      if (result.isSuccess) {
        return Result.success(result.message, result.data);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 비밀번호 변경
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return Result.failure('새 비밀번호가 일치하지 않습니다');
      }

      if (newPassword.length < 6) {
        return Result.failure('새 비밀번호는 6자 이상이어야 합니다');
      }

      final request = PasswordChangeRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final result = await _changePasswordUseCase.call(request);
      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 계정 삭제
  Future<Result<void>> deleteAccount() async {
    try {
      final result = await _deleteAccountUseCase.call();
      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 설정 로드
  Future<Result<AppSettingsEntity>> loadAppSettings() async {
    try {
      final result = await _getAppSettingsUseCase.call();
      if (result.isSuccess) {
        return Result.success(result.message, result.data);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 설정 저장
  Future<Result<AppSettingsEntity>> saveAppSettings(
    AppSettingsEntity settings,
  ) async {
    try {
      final result = await _saveAppSettingsUseCase.call(settings);
      if (result.isSuccess) {
        return Result.success(result.message, result.data);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 데이터 내보내기
  Future<Result<DataExportResult>> exportAppData() async {
    try {
      final result = await _exportAppDataUseCase.call();
      if (result.isSuccess) {
        return Result.success(result.message, result.data);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 데이터 가져오기
  Future<Result<void>> importAppData(String filePath) async {
    try {
      final result = await _importAppDataUseCase.call(filePath);
      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 캐시 정리
  Future<Result<void>> clearAppCache() async {
    try {
      final result = await _clearAppCacheUseCase.call();
      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
