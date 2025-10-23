import 'package:aipet_frontend/features/settings/data/services/local_user_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/domain/entities/user_profile_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_controller.g.dart';

/// 사용자 프로필 상태
class UserProfileState {
  final UserProfileEntity? profile;
  final bool isLoading;
  final String? error;

  const UserProfileState({this.profile, this.isLoading = false, this.error});

  UserProfileState copyWith({
    UserProfileEntity? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 사용자 프로필 컨트롤러
@riverpod
class UserProfileController extends _$UserProfileController {
  final LocalUserService _userService = LocalUserService();

  @override
  UserProfileState build() {
    // build()에서는 비동기 작업을 피하고, 필요시 외부에서 loadProfile() 호출
    return const UserProfileState();
  }

  /// 프로필 로드 (외부에서 호출)
  Future<void> loadProfile() async {
    _loadProfile();
  }

  /// 프로필 로드
  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _userService.loadUserProfile();

      // 프로필이 없으면 기본 사용자 생성
      if (profile == null) {
        LoggerService.debug('👤 사용자 프로필이 없음. 기본 사용자 생성 중...');
        final defaultProfile = await _userService.createUserProfile(
          userName: 'ゲストユーザー',
          email: 'guest@example.com',
        );
        await _userService.saveUserProfile(defaultProfile);
        state = state.copyWith(profile: defaultProfile, isLoading: false);
        LoggerService.debug('👤 기본 사용자 생성 완료: ${defaultProfile.userName}');
      } else {
        state = state.copyWith(profile: profile, isLoading: false);
        LoggerService.debug('👤 기존 사용자 프로필 로드 완료: ${profile.userName}');
      }
    } catch (e) {
      LoggerService.debug('❌ 프로필 로드 실패: $e');
      state = state.copyWith(isLoading: false, error: '프로필 로드 실패: $e');
    }
  }

  /// 프로필 저장
  Future<bool> saveProfile({
    required String userName,
    required String email,
    String? nameKatakana,
    String? contact,
    String? profileImage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      UserProfileEntity profile;

      if (state.profile != null) {
        // 기존 프로필 업데이트
        profile = state.profile!.copyWith(
          userName: userName,
          email: email,
          nameKatakana: nameKatakana,
          contact: contact,
          profileImage: profileImage,
          updatedAt: DateTime.now(),
        );
      } else {
        // 새 프로필 생성
        profile = await _userService.createUserProfile(
          userName: userName,
          email: email,
          nameKatakana: nameKatakana,
          contact: contact,
          profileImage: profileImage,
        );
      }

      final success = await _userService.saveUserProfile(profile);

      if (success) {
        state = state.copyWith(profile: profile, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: '프로필 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '프로필 저장 실패: $e');
      return false;
    }
  }

  /// 프로필 필드 업데이트
  void updateField(String field, String value) {
    if (state.profile == null) return;

    final profile = state.profile!;
    UserProfileEntity updatedProfile;

    switch (field) {
      case 'userName':
        updatedProfile = profile.copyWith(userName: value);
        break;
      case 'email':
        updatedProfile = profile.copyWith(email: value);
        break;
      case 'nameKatakana':
        updatedProfile = profile.copyWith(nameKatakana: value);
        break;
      case 'contact':
        updatedProfile = profile.copyWith(contact: value);
        break;
      default:
        return;
    }

    state = state.copyWith(profile: updatedProfile);
  }

  /// 프로필 새로고침
  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}
