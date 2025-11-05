import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../../../../features/settings/domain/entities/settings_entity.dart';
import '../../../../../features/settings/domain/usecases/change_password_usecase.dart';
import '../../../../../features/settings/domain/usecases/clear_app_cache_usecase.dart';
import '../../../../../features/settings/domain/usecases/delete_account_usecase.dart';
import '../../../../../features/settings/domain/usecases/export_app_data_usecase.dart';
import '../../../../../features/settings/domain/usecases/get_app_settings_usecase.dart';
import '../../../../../features/settings/domain/usecases/get_user_profile_usecase.dart';
import '../../../../../features/settings/domain/usecases/import_app_data_usecase.dart';
import '../../../../../features/settings/domain/usecases/save_app_settings_usecase.dart';
import '../../../../../features/settings/domain/usecases/update_user_profile_usecase.dart';
import '../../../../../features/settings/presentation/controllers/settings_controller.dart';

part 'settings_providers.g.dart';

// Repository 프로바이더
@riverpod
SettingsRepositoryImpl settingsRepository(Ref ref) {
  return SettingsRepositoryImpl();
}

// UseCase 프로바이더들
@riverpod
GetUserProfileUseCase getUserProfileUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetUserProfileUseCase(repository);
}

@riverpod
UpdateUserProfileUseCase updateUserProfileUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
}

@riverpod
GetAppSettingsUseCase getAppSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetAppSettingsUseCase(repository);
}

@riverpod
SaveAppSettingsUseCase saveAppSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SaveAppSettingsUseCase(repository);
}

@riverpod
ChangePasswordUseCase changePasswordUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ChangePasswordUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return DeleteAccountUseCase(repository);
}

@riverpod
ExportAppDataUseCase exportAppDataUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ExportAppDataUseCase(repository);
}

@riverpod
ImportAppDataUseCase importAppDataUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ImportAppDataUseCase(repository);
}

@riverpod
ClearAppCacheUseCase clearAppCacheUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ClearAppCacheUseCase(repository);
}

// 사용자 프로필 프로바이더
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfileEntity> build() async {
    final useCase = ref.watch(getUserProfileUseCaseProvider);
    final result = await useCase();
    if (result.isSuccess) {
      return result.dataOrNull!;
    } else {
      throw Exception(result.error);
    }
  }

  /// 프로필 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getUserProfileUseCaseProvider);
      final result = await useCase();
      if (result.isSuccess) {
        return result.dataOrNull!;
      } else {
        throw Exception(result.error);
      }
    });
  }

  /// 프로필 업데이트
  Future<bool> updateProfile(UserProfileEntity profile) async {
    final useCase = ref.read(updateUserProfileUseCaseProvider);
    final result = await useCase(profile);
    if (result.isSuccess) {
      await refresh();
      return true;
    } else {
      return false;
    }
  }
}

// 앱 설정 프로바이더
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  Future<AppSettingsEntity> build() async {
    final useCase = ref.watch(getAppSettingsUseCaseProvider);
    final result = await useCase();
    if (result.isSuccess) {
      return result.dataOrNull!;
    } else {
      throw Exception(result.error);
    }
  }

  /// 설정 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getAppSettingsUseCaseProvider);
      final result = await useCase();
      if (result.isSuccess) {
        return result.dataOrNull!;
      } else {
        throw Exception(result.error);
      }
    });
  }

  /// 설정 저장
  Future<bool> saveSettings(AppSettingsEntity settings) async {
    final useCase = ref.read(saveAppSettingsUseCaseProvider);
    final result = await useCase(settings);
    if (result.isSuccess) {
      state = AsyncValue.data(settings);
      return true;
    } else {
      return false;
    }
  }
}

// Settings Controller 프로바이더
@riverpod
SettingsController settingsController(Ref ref) {
  return SettingsController(ref as WidgetRef);
}
