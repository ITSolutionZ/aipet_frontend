library;

import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/auth_repository.dart';
import '../presentation/state/auth_form_state.dart';
import 'repositories/firebase_auth_real_impl.dart';
import 'repositories/local_auth_impl.dart';

/// AuthRepository Provider
///
/// 모든 모드: 로컬 전용 (LocalAuthImpl)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // 🚧 로컬 전용 구현체 사용 (Debug + Release)
  LoggerService.debug('🔐 [Auth] 로컬 전용 인증 사용');
  return LocalAuthImpl();
  
  // Firebase Auth는 추후 백엔드 연동 시 활성화
  // return FirebaseAuthRealImpl();
});

/// AuthFormState Provider
///
/// 로그인/회원가입 폼 상태 관리
final authFormStateNotifierProvider =
    NotifierProvider<AuthFormStateNotifier, AuthFormState>(
      AuthFormStateNotifier.new,
    );

/// AuthFormStateNotifier
///
/// 폼 상태 관리 로직
class AuthFormStateNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateUsername(String username) {
    state = state.copyWith(username: username);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
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

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetState() {
    state = const AuthFormState();
  }

  /// 로그인 성공 처리
  void handleLoginSuccess() {
    state = state.copyWith(isLoading: false, error: null);
  }

  /// 저장된 로그인 정보 불러오기
  Future<void> loadSavedCredentials() async {
    // TODO: SecureStorage에서 저장된 이메일 불러오기
    // 개발 모드에서는 스킵
  }

  /// 저장된 로그인 정보 삭제
  Future<void> clearSavedCredentials() async {
    // TODO: SecureStorage에서 저장된 정보 삭제
    // 개발 모드에서는 스킵
  }
}
