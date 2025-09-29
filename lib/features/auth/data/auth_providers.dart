import 'package:aipet_frontend/features/auth/domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/firebase_auth_real_impl.dart';
import 'services/auth_config_service.dart';

part 'auth_providers.g.dart';

// Auth Repository 프로바이더
@riverpod
AuthRepository authRepository(Ref ref) {
  // 실제 Firebase Auth 구현체 사용
  // 개발 환경에서는 Mock 모드를 지원하지만, 기본적으로는 실제 Firebase Auth 사용
  return FirebaseAuthRealImpl();
}

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
    // 에러 발생 시 rethrow
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

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
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

  /// 실제 로그인 성공 처리
  ///
  /// 인증 성공 시 호출되어 상태를 업데이트합니다.
  /// 로딩 상태를 해제하고 에러를 초기화합니다.
  void handleLoginSuccess() {
    debugPrint('✅ AuthFormStateNotifier: 로그인 성공 처리');

    // 로딩 상태 해제 및 에러 초기화
    state = state.copyWith(isLoading: false, error: null);
  }

  Future<void> login() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Auth Repository를 통한 로그인 처리
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.signInWithEmailAndPassword(
        state.email,
        state.password,
      );

      if (result.isSuccess) {
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
      } else {
        state = state.copyWith(isLoading: false, error: result.error?.toString());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'ログインに失敗しました');
      debugPrint('로그인 실패: $e');
    }
  }

  /// Remember Me - 이메일만 저장 (패스워드는 저장하지 않음)
  ///
  /// 보안상 이메일만 저장하고 패스워드는 저장하지 않습니다.
  /// SecureStorage 실패 시에도 안전하게 처리됩니다.
  Future<void> _saveLoginCredentials() async {
    try {
      // 보안상 이메일만 저장하고 패스워드는 저장하지 않음
      await SecureStorageService.setString(
        AuthConfigConstants.savedEmailKey,
        state.email,
      );
      await SecureStorageService.setString(
        AuthConfigConstants.rememberMeKey,
        'true',
      );

      if (kDebugMode) {
        debugPrint('Remember Me 이메일 저장 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remember Me 저장 실패: $e');
      }

      // SecureStorage 실패 시 상태만 업데이트 (메모리 저장 제거)
      // 사용자가 다음에 앱을 재시작하면 다시 입력하도록 함
      state = state.copyWith(rememberMe: false);

      // 사용자에게 저장 실패 알림 (선택사항)
      // showError('ログイン情報の保存に失敗しました');
    }
  }

  /// 저장된 Remember Me 정보 불러오기 (이메일만)
  ///
  /// SecureStorage에서 저장된 이메일 정보를 불러옵니다.
  /// 패스워드는 보안상 이유로 저장하지 않습니다.
  Future<void> loadSavedCredentials() async {
    try {
      final savedEmail = await SecureStorageService.getString(
        AuthConfigConstants.savedEmailKey,
      );
      final rememberMe = await SecureStorageService.getString(
        AuthConfigConstants.rememberMeKey,
      );

      if (rememberMe == 'true' && savedEmail != null && savedEmail.isNotEmpty) {
        state = state.copyWith(
          email: savedEmail,
          rememberMe: true,
          // 패스워드는 불러오지 않음 (보안상 이유)
        );

        if (kDebugMode) {
          debugPrint('Remember Me 이메일 불러오기 완료');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remember Me 정보 불러오기 실패: $e');
      }

      // SecureStorage 실패 시 상태 초기화
      state = state.copyWith(rememberMe: false);
    }
  }

  /// Remember Me 정보 삭제
  ///
  /// SecureStorage와 상태에서 저장된 Remember Me 정보를 삭제합니다.
  Future<void> clearSavedCredentials() async {
    try {
      // 저장된 데이터 삭제
      await Future.wait([
        SecureStorageService.remove(AuthConfigConstants.savedEmailKey),
        SecureStorageService.remove(AuthConfigConstants.rememberMeKey),
      ]);

      state = state.copyWith(rememberMe: false);

      if (kDebugMode) {
        debugPrint('Remember Me 정보 삭제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remember Me 정보 삭제 실패: $e');
      }

      // SecureStorage 실패 시에도 상태는 초기화
      state = state.copyWith(rememberMe: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
