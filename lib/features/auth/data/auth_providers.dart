import 'package:aipet_frontend/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_form_state.dart';

part 'auth_providers.g.dart';

// 홈 화면으로 이동하는 콜백을 위한 프로바이더
@riverpod
class NavigationCallbackNotifier extends _$NavigationCallbackNotifier {
  @override
  Function()? build() => null;

  void setNavigationCallback(Function()? callback) {
    state = callback;
  }
}

// SharedPreferences 인스턴스 프로바이더
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences 초기화 실패: $e');
    // 에러 발생 시 null을 반환하여 메모리 저장 방식으로 fallback
    rethrow;
  }
}

@riverpod
class AuthFormStateNotifier extends _$AuthFormStateNotifier {
  @override
  AuthFormState build() => const AuthFormState();

  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void updateUsername(String username) {
    state = state.copyWith(username: username, error: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  /// 인증 상태 초기화
  void resetState() {
    state = const AuthFormState();
  }

  Future<void> login() async {
    // 개발 중이므로 아무 값이나 넣어도 로그인 성공
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: 실제 로그인 API 호출
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이

      // Remember Me가 체크되어 있으면 이메일만 저장
      if (state.rememberMe) {
        await _saveLoginCredentials();
      }

      // 로그인 성공 처리
      state = state.copyWith(isLoading: false);

      // 홈 화면으로 이동
      final navigationCallback = ref.read(navigationCallbackNotifierProvider);
      if (navigationCallback != null) {
        navigationCallback();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'ログインに失敗しました');
      debugPrint('로그인 실패: $e');
    }
  }

  // Remember Me - 이메일만 저장 (패스워드는 저장하지 않음)
  Future<void> _saveLoginCredentials() async {
    try {
      // 보안상 이메일만 저장하고 패스워드는 저장하지 않음
      await SecureStorageService.setString('saved_email', state.email);
      await SecureStorageService.setBool('remember_me', true);
      // 개발 모드에서만 디버그 출력
      debugPrint('Remember Me 이메일 저장 완료');
    } catch (e) {
      debugPrint('Remember Me 저장 실패: $e');
      // 암호화 저장 실패 시 메모리에만 저장 (임시 해결책)
      _saveToMemory();
    }
  }

  // 저장된 Remember Me 정보 불러오기 (이메일만)
  Future<void> loadSavedCredentials() async {
    try {
      final savedEmail = await SecureStorageService.getString('saved_email');
      final rememberMe =
          await SecureStorageService.getBool('remember_me') ?? false;

      if (rememberMe && savedEmail != null) {
        state = state.copyWith(
          email: savedEmail,
          rememberMe: true,
          // 패스워드는 불러오지 않음 (보안상 이유)
        );
        debugPrint('Remember Me 이메일 불러오기 완료');
      }
    } catch (e) {
      debugPrint('Remember Me 정보 불러오기 실패: $e');
      // 저장소 실패 시 메모리에서 불러오기 (임시 해결책)
      _loadFromMemory();
    }
  }

  // Remember Me 정보 삭제
  Future<void> clearSavedCredentials() async {
    try {
      // 저장된 데이터 삭제
      await SecureStorageService.remove('saved_email');
      await SecureStorageService.setBool('remember_me', false);
      state = state.copyWith(rememberMe: false);
      debugPrint('Remember Me 정보 삭제 완료');
    } catch (e) {
      debugPrint('Remember Me 정보 삭제 실패: $e');
      // 저장소 실패 시 메모리에서 삭제 (임시 해결책)
      _clearFromMemory();
    }
  }

  // 메모리에 임시 저장 (저장소 실패 시 대안) - 이메일만 저장
  static String? _tempEmail;
  static bool _tempRememberMe = false;

  void _saveToMemory() {
    _tempEmail = state.email;
    // 패스워드는 메모리에도 저장하지 않음 (보안상 이유)
    _tempRememberMe = true;
  }

  void _loadFromMemory() {
    if (_tempRememberMe && _tempEmail != null) {
      state = state.copyWith(
        email: _tempEmail!,
        rememberMe: true,
        // 패스워드는 불러오지 않음
      );
      debugPrint('메모리에서 Remember Me 정보 불러오기 완료');
    }
  }

  void _clearFromMemory() {
    _tempEmail = null;
    _tempRememberMe = false;
    state = state.copyWith(rememberMe: false);
    debugPrint('메모리에서 Remember Me 정보 삭제 완료');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
