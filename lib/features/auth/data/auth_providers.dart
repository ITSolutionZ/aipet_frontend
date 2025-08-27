import 'package:aipet_frontend/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_state.dart';

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
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState();

  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, error: null);
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
    state = const AuthState();
  }

  Future<void> login() async {
    // 개발 중이므로 아무 값이나 넣어도 로그인 성공
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: 실제 로그인 API 호출
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이

      // Remember Me가 체크되어 있으면 로그인 정보 저장
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
    }
  }

  // 로그인 정보 저장 (암호화된 SharedPreferences 사용)
  Future<void> _saveLoginCredentials() async {
    try {
      // 민감한 데이터는 암호화하여 저장
      await SecureStorageService.setString('saved_email', state.email);
      await SecureStorageService.setString('saved_password', state.password);
      await SecureStorageService.setBool('remember_me', true);
      debugPrint('로그인 정보 암호화 저장됨: ${state.email}');
    } catch (e) {
      debugPrint('로그인 정보 암호화 저장 실패: $e');
      // 암호화 저장 실패 시 메모리에만 저장 (임시 해결책)
      _saveToMemory();
    }
  }

  // 저장된 로그인 정보 불러오기
  Future<void> loadSavedCredentials() async {
    try {
      // 암호화된 데이터에서 불러오기
      final savedEmail = await SecureStorageService.getString('saved_email');
      final savedPassword = await SecureStorageService.getString(
        'saved_password',
      );
      final rememberMe =
          await SecureStorageService.getBool('remember_me') ?? false;

      if (rememberMe && savedEmail != null && savedPassword != null) {
        state = state.copyWith(
          email: savedEmail,
          password: savedPassword,
          rememberMe: true,
        );
        debugPrint('암호화된 로그인 정보 불러오기 완료: $savedEmail');
      }
    } catch (e) {
      debugPrint('암호화된 로그인 정보 불러오기 실패: $e');
      // 암호화 저장소 실패 시 메모리에서 불러오기 (임시 해결책)
      _loadFromMemory();
    }
  }

  // 저장된 로그인 정보 삭제
  Future<void> clearSavedCredentials() async {
    try {
      // 암호화된 데이터 삭제
      await SecureStorageService.remove('saved_email');
      await SecureStorageService.remove('saved_password');
      await SecureStorageService.setBool('remember_me', false);
      state = state.copyWith(rememberMe: false);
      debugPrint('암호화된 로그인 정보 삭제 완료');
    } catch (e) {
      debugPrint('암호화된 로그인 정보 삭제 실패: $e');
      // 암호화 저장소 실패 시 메모리에서 삭제 (임시 해결책)
      _clearFromMemory();
    }
  }

  // 메모리에 임시 저장 (SharedPreferences 실패 시 대안)
  static String? _tempEmail;
  static String? _tempPassword;
  static bool _tempRememberMe = false;

  void _saveToMemory() {
    _tempEmail = state.email;
    _tempPassword = state.password;
    _tempRememberMe = true;
  }

  void _loadFromMemory() {
    if (_tempRememberMe && _tempEmail != null && _tempPassword != null) {
      state = state.copyWith(
        email: _tempEmail!,
        password: _tempPassword!,
        rememberMe: true,
      );
      debugPrint('메모리에서 로그인 정보 불러오기 완료: $_tempEmail');
    }
  }

  void _clearFromMemory() {
    _tempEmail = null;
    _tempPassword = null;
    _tempRememberMe = false;
    state = state.copyWith(rememberMe: false);
    debugPrint('메모리에서 로그인 정보 삭제 완료');
  }

  // 로그인/회원가입 로직은 AuthController로 이동
  // 여기서는 상태 관리만 담당

  void clearError() {
    state = state.copyWith(error: null);
  }
}
