import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class SettingsResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const SettingsResult._(this.isSuccess, this.message, this.data);

  factory SettingsResult.success(String message, [dynamic data]) =>
      SettingsResult._(true, message, data);
  factory SettingsResult.failure(String message) =>
      SettingsResult._(false, message, null);
}

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
  Future<SettingsResult> loadUserProfile() async {
    try {
      final profile = await _getUserProfileUseCase.call();
      return SettingsResult.success('사용자 프로필을 로드했습니다', profile);
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 프로필 업데이트
  Future<SettingsResult> updateProfile(UserProfileEntity profile) async {
    try {
      final success = await _updateUserProfileUseCase.call(profile);

      if (success) {
        return SettingsResult.success('프로필이 업데이트되었습니다');
      } else {
        return SettingsResult.failure('프로필 업데이트에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 비밀번호 변경
  Future<SettingsResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return SettingsResult.failure('새 비밀번호가 일치하지 않습니다');
      }

      if (newPassword.length < 6) {
        return SettingsResult.failure('새 비밀번호는 6자 이상이어야 합니다');
      }

      final request = PasswordChangeRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final success = await _changePasswordUseCase.call(request);

      if (success) {
        return SettingsResult.success('비밀번호가 변경되었습니다');
      } else {
        return SettingsResult.failure('비밀번호 변경에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 계정 삭제
  Future<SettingsResult> deleteAccount() async {
    try {
      final success = await _deleteAccountUseCase.call();

      if (success) {
        return SettingsResult.success('계정이 삭제되었습니다');
      } else {
        return SettingsResult.failure('계정 삭제에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 설정 로드
  Future<SettingsResult> loadAppSettings() async {
    try {
      final settings = await _getAppSettingsUseCase.call();
      return SettingsResult.success('앱 설정을 로드했습니다', settings);
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 설정 저장
  Future<SettingsResult> saveAppSettings(AppSettingsEntity settings) async {
    try {
      final success = await _saveAppSettingsUseCase.call(settings);

      if (success) {
        return SettingsResult.success('앱 설정이 저장되었습니다');
      } else {
        return SettingsResult.failure('앱 설정 저장에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 데이터 내보내기
  Future<SettingsResult> exportAppData() async {
    try {
      final result = await _exportAppDataUseCase.call();

      if (result.success) {
        return SettingsResult.success('앱 데이터가 내보내졌습니다', result);
      } else {
        return SettingsResult.failure(result.errorMessage ?? '내보내기에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 데이터 가져오기
  Future<SettingsResult> importAppData(String filePath) async {
    try {
      final success = await _importAppDataUseCase.call(filePath);

      if (success) {
        return SettingsResult.success('앱 데이터가 가져와졌습니다');
      } else {
        return SettingsResult.failure('앱 데이터 가져오기에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 앱 캐시 정리
  Future<SettingsResult> clearAppCache() async {
    try {
      final success = await _clearAppCacheUseCase.call();

      if (success) {
        return SettingsResult.success('캐시가 정리되었습니다');
      } else {
        return SettingsResult.failure('캐시 정리에 실패했습니다');
      }
    } catch (error) {
      handleError(error);
      return SettingsResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
