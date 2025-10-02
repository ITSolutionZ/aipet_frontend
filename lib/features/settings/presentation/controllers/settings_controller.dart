import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/settings/data/data.dart';
import 'package:aipet_frontend/features/settings/domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// Settings 기능 전용 Controller
///
/// 사용자 프로필, 앱 설정, 계정 관리 등의 CRUD 작업을 처리합니다.
/// BaseController를 상속받아 에러 처리와 리소스 관리를 자동화합니다.
class SettingsController extends BaseController {
  SettingsController(super.ref);

  // ✅ Riverpod Provider를 통한 의존성 주입 (Mockito 데이터 사용)
  late final GetUserProfileUseCase _getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);
  late final UpdateUserProfileUseCase _updateUserProfileUseCase = ref.read(
    updateUserProfileUseCaseProvider,
  );
  late final ChangePasswordUseCase _changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
  late final GetAppSettingsUseCase _getAppSettingsUseCase = ref.read(getAppSettingsUseCaseProvider);
  late final SaveAppSettingsUseCase _saveAppSettingsUseCase = ref.read(
    saveAppSettingsUseCaseProvider,
  );
  late final DeleteAccountUseCase _deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
  late final ExportAppDataUseCase _exportAppDataUseCase = ref.read(exportAppDataUseCaseProvider);
  late final ImportAppDataUseCase _importAppDataUseCase = ref.read(importAppDataUseCaseProvider);
  late final ClearAppCacheUseCase _clearAppCacheUseCase = ref.read(clearAppCacheUseCaseProvider);

  /// 사용자 프로필 로드
  Future<Result<Map<String, dynamic>>> loadUserProfile() async {
    final result = await safeExecute<Result<Map<String, dynamic>>>(() async {
      final useCaseResult = await _getUserProfileUseCase.call();
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, useCaseResult.dataOrNull);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('プロフィールの読み込みに失敗しました');
  }

  /// 프로필 업데이트
  Future<Result<Map<String, dynamic>>> updateProfile(Map<String, dynamic> profile) async {
    final result = await safeExecute<Result<Map<String, dynamic>>>(() async {
      final useCaseResult = await _updateUserProfileUseCase.call(profile);
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, useCaseResult.dataOrNull!);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('プロフィールの更新に失敗しました');
  }

  /// 비밀번호 변경
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // ✅ BaseController의 검증 메서드 활용
    if (newPassword != confirmPassword) {
      return Result.failure('새 비밀번호가 일치하지 않습니다');
    }

    if (newPassword.length < 6) {
      return Result.failure('새 비밀번호는 6자 이상이어야 합니다');
    }

    final result = await safeExecute<Result<void>>(() async {
      final request = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

      final useCaseResult = await _changePasswordUseCase.call(request);
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, null);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('パスワードの変更に失敗しました');
  }

  /// 계정 삭제
  Future<Result<void>> deleteAccount() async {
    final result = await safeExecute<Result<void>>(() async {
      final useCaseResult = await _deleteAccountUseCase.call();
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, null);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('アカウントの削除に失敗しました');
  }

  /// 앱 설정 로드
  Future<Result<Map<String, dynamic>>> loadAppSettings() async {
    final result = await safeExecute<Result<Map<String, dynamic>>>(() async {
      final useCaseResult = await _getAppSettingsUseCase.call();
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, useCaseResult.dataOrNull!);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('アプリ設定の読み込みに失敗しました');
  }

  /// 앱 설정 저장
  Future<Result<Map<String, dynamic>>> saveAppSettings(Map<String, dynamic> settings) async {
    final result = await safeExecute<Result<Map<String, dynamic>>>(() async {
      final useCaseResult = await _saveAppSettingsUseCase.call(settings);
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, useCaseResult.dataOrNull!);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('アプリ設定の保存に失敗しました');
  }

  /// 앱 데이터 내보내기
  Future<Result<Result>> exportAppData() async {
    final result = await safeExecute<Result<Result>>(() async {
      final useCaseResult = await _exportAppDataUseCase.call();
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, useCaseResult.dataOrNull!);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('データのエクスポートに失敗しました');
  }

  /// 앱 데이터 가져오기
  Future<Result<void>> importAppData(String filePath) async {
    final result = await safeExecute<Result<void>>(() async {
      final useCaseResult = await _importAppDataUseCase.call(filePath);
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, null);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('データのインポートに失敗しました');
  }

  /// 앱 캐시 정리
  Future<Result<void>> clearAppCache() async {
    final result = await safeExecute<Result<void>>(() async {
      final useCaseResult = await _clearAppCacheUseCase.call();
      if (useCaseResult.isSuccess) {
        return Result.success(useCaseResult.message, null);
      } else {
        return Result.failure(useCaseResult.message);
      }
    });

    return result ?? Result.failure('キャッシュのクリアに失敗しました');
  }
}
