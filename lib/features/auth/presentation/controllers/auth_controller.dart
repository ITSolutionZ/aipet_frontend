import 'package:flutter/foundation.dart';

import '../../../../shared/shared.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_form_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

/// 인증 작업 결과 (Result 패턴 사용)
typedef AuthControllerResult = Result<String>;

/// 인증 유효성 검사 결과 (Result 패턴 사용)
typedef AuthValidationResult = Result<void>;

class AuthController extends FormController<AuthFormState> {
  late final LoginUseCase _loginUseCase;
  late final SignupUseCase _signupUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthController(super.ref) {
    final repository = ref.read(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    _signupUseCase = SignupUseCase(repository);
    _logoutUseCase = LogoutUseCase(repository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(repository);
  }

  AuthFormState get currentState => ref.read(authFormStateNotifierProvider);

  @override
  AuthFormState get formData => currentState;

  @override
  bool get isFormValid {
    final state = currentState;
    return state.email.isNotEmpty &&
        state.username.isNotEmpty &&
        state.error == null;
  }

  @override
  bool get canSubmit => isFormValid && !currentState.isLoading;

  @override
  void initializeForm() {
    // 폼 초기화 로직
    ref.read(authFormStateNotifierProvider.notifier).resetState();
  }

  void updateEmail(String email) {
    ref.read(authFormStateNotifierProvider.notifier).updateEmail(email);
  }

  void updateUsername(String username) {
    ref.read(authFormStateNotifierProvider.notifier).updateUsername(username);
  }

  void togglePasswordVisibility() {
    ref.read(authFormStateNotifierProvider.notifier).togglePasswordVisibility();
  }

  void toggleConfirmPasswordVisibility() {
    ref
        .read(authFormStateNotifierProvider.notifier)
        .toggleConfirmPasswordVisibility();
  }

  void toggleRememberMe() {
    ref.read(authFormStateNotifierProvider.notifier).toggleRememberMe();
  }

  /// TODO: 개발 완료 후 삭제할 임시 로그인 성공 처리
  /// 현재는 아무 입력값이나 넣어도 로그인 성공으로 처리
  void handleTempLoginSuccess() {
    debugPrint('🚨 임시 로그인 성공 처리 - 실제 인증 로직 우회');

    // 로딩 상태 해제 및 에러 초기화
    ref.read(authFormStateNotifierProvider.notifier).handleTempLoginSuccess();
  }

  /// 로그인 처리 (UseCase 패턴 사용)
  Future<AuthControllerResult> login({String? password}) async {
    try {
      // 유효성 검사
      final validationResult = validateLoginData();
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.message);
      }

      // 비밀번호가 제공되지 않은 경우 기본 처리
      if (password == null || password.isEmpty) {
        return Result.failure('パスワードを入力してください');
      }

      // UseCase를 통한 로그인 실행
      final result = await _loginUseCase.call(
        email: currentState.email,
        password: password,
      );

      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 회원가입 처리 (UseCase 패턴 사용)
  Future<AuthControllerResult> signup({
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // 유효성 검사
      final validationResult = validateSignupData();
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.message);
      }

      // UseCase를 통한 회원가입 실행
      final result = await _signupUseCase.call(
        email: currentState.email,
        password: password,
        confirmPassword: confirmPassword,
        displayName: currentState.username,
      );

      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// Google 로그인 처리
  Future<AuthControllerResult> loginWithGoogle() async {
    try {
      final result = await _loginUseCase.loginWithGoogle();

      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// Apple 로그인 처리
  Future<AuthControllerResult> loginWithApple() async {
    try {
      final result = await _loginUseCase.loginWithApple();

      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// LINE 로그인 처리
  Future<AuthControllerResult> loginWithLine() async {
    try {
      final result = await _loginUseCase.loginWithLine();

      if (result.isSuccess) {
        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 저장된 로그인 정보 불러오기
  Future<void> loadSavedCredentials() async {
    try {
      await ref
          .read(authFormStateNotifierProvider.notifier)
          .loadSavedCredentials();
    } catch (error) {
      handleError(error);
    }
  }

  /// 저장된 로그인 정보 삭제
  Future<bool> clearSavedCredentials() async {
    try {
      await ref
          .read(authFormStateNotifierProvider.notifier)
          .clearSavedCredentials();
      return true;
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return false;
    }
  }

  /// 로그아웃 처리 (UseCase 패턴 사용)
  Future<AuthControllerResult> logout() async {
    try {
      // UseCase를 통한 로그아웃 실행
      final result = await _logoutUseCase.call();

      if (result.isSuccess) {
        // 저장된 로그인 정보 삭제
        await clearSavedCredentials();

        // 인증 상태 초기화
        ref.read(authFormStateNotifierProvider.notifier).resetState();

        return Result.success(result.message);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 로그인 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateLoginData() {
    final state = currentState;

    // 이메일 검증 (공통 ValidationService 사용)
    final emailResult = ValidationService.validateEmail(state.email);
    if (!emailResult.isSuccess) {
      return Result.failure(emailResult.message);
    }

    // 비밀번호 검증은 UI에서 직접 처리 (AuthFormState에는 패스워드 없음)
    // 실제 검증은 TextFormField의 validator에서 수행

    return Result.success('유효성 검사가 완료되었습니다');
  }

  /// 회원가입 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateSignupData() {
    final state = currentState;

    // 이메일 검증 (공통 ValidationService 사용)
    final emailResult = ValidationService.validateEmail(state.email);
    if (!emailResult.isSuccess) {
      return Result.failure(emailResult.message);
    }

    // 사용자명 검증 (공통 ValidationService 사용)
    final usernameResult = ValidationService.validateUsername(state.username);
    if (!usernameResult.isSuccess) {
      return Result.failure(usernameResult.message);
    }

    // 비밀번호 검증은 UI에서 직접 처리 (AuthFormState에는 패스워드 없음)
    // 실제 검증은 TextFormField의 validator에서 수행

    return Result.success('유효성 검사가 완료되었습니다');
  }

  /// 에러 메시지 초기화
  void clearError() {
    ref.read(authFormStateNotifierProvider.notifier).clearError();
  }

  @override
  void resetForm() {
    ref.read(authFormStateNotifierProvider.notifier).resetState();
  }

  /// 현재 사용자 정보 가져오기
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      return await _getCurrentUserUseCase.call();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 로그인 상태 확인
  Future<Result<bool>> isLoggedIn() async {
    try {
      return await _getCurrentUserUseCase.isLoggedIn();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 이메일 인증 상태 확인
  Future<Result<bool>> isEmailVerified() async {
    try {
      return await _getCurrentUserUseCase.isEmailVerified();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  @override
  Future<Result<void>> submitForm() async {
    // 로그인 폼 제출 (기본 동작) - 패스워드는 별도로 제공되어야 함
    return Result.failure('submitFormではなく、login()メソッドを直接使用してください');
  }
}
