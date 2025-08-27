import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_app_settings_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/save_app_settings_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../repositories/settings_repository_impl.dart';

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

// 사용자 프로필 프로바이더
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfileEntity> build() async {
    final useCase = ref.watch(getUserProfileUseCaseProvider);
    return useCase();
  }

  /// 프로필 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getUserProfileUseCaseProvider);
      return useCase();
    });
  }

  /// 프로필 업데이트
  Future<bool> updateProfile(UserProfileEntity profile) async {
    final useCase = ref.read(updateUserProfileUseCaseProvider);
    final success = await useCase(profile);
    if (success) {
      await refresh();
    }
    return success;
  }
}

// 앱 설정 프로바이더
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  Future<AppSettingsEntity> build() async {
    final useCase = ref.watch(getAppSettingsUseCaseProvider);
    return useCase();
  }

  /// 설정 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getAppSettingsUseCaseProvider);
      return useCase();
    });
  }

  /// 설정 저장
  Future<bool> saveSettings(AppSettingsEntity settings) async {
    final useCase = ref.read(saveAppSettingsUseCaseProvider);
    final success = await useCase(settings);
    if (success) {
      state = AsyncValue.data(settings);
    }
    return success;
  }
}
