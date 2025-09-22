import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/auth/domain/domain.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/testing/mock_config.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/firebase_auth_repository.dart';
import 'services/auth_config_service.dart';

part 'auth_providers.g.dart';

// Auth Repository 프로바이더
@riverpod
AuthRepository authRepository(Ref ref) {
  if (MockConfig.shouldUseMock) {
    // Mockito Mock 구현체 사용
    return _createMockAuthRepository();
  }

  return AuthRepositoryImpl(
    firebaseRepository: FirebaseAuthRepositoryImpl(),
    ref: ref,
  );
}

/// Mock Repository 생성 (향후 Mockito 폴더에서 import)
AuthRepository _createMockAuthRepository() {
  // TODO: Mockito 구현체로 교체 예정
  // import '../../../shared/testing/mock_data/mockito/repositories/auth_repository_mockito_impl.dart';
  // return AuthRepositoryMockitoImpl();

  throw UnimplementedError(
    'Mockito Auth Repository 구현체가 아직 준비되지 않았습니다. '
    'MockConfig.shouldUseMock을 false로 설정하거나 Mockito 구현체를 완성하세요.'
  );
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

  /// TODO: 개발 완료 후 삭제할 임시 로그인 성공 처리
  /// 현재는 아무 입력값이나 넣어도 로그인 성공으로 처리
  void handleTempLoginSuccess() {
    debugPrint('🚨 AuthFormStateNotifier: 임시 로그인 성공 처리');

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
        state = state.copyWith(isLoading: false, error: result.message);
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
      await SecureStorageService.setString(
        AuthConfigConstants.savedEmailKey,
        state.email,
      );
      await SecureStorageService.setString(
        AuthConfigConstants.rememberMeKey,
        'true',
      );
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
      final savedEmail = await SecureStorageService.getString(
        AuthConfigConstants.savedEmailKey,
      );
      final rememberMe = await SecureStorageService.getString(
        AuthConfigConstants.rememberMeKey,
      );

      if (rememberMe == 'true' && savedEmail != null) {
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
      await SecureStorageService.remove(AuthConfigConstants.savedEmailKey);
      await SecureStorageService.remove(AuthConfigConstants.rememberMeKey);
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
