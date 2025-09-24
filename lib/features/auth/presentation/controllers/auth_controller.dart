import 'package:aipet_frontend/features/auth/data/auth_providers.dart';
import 'package:aipet_frontend/features/auth/domain/auth_form_state.dart';
import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

/// 인증 작업 결과 타입 (Result 패턴 사용)
///
/// 인증 관련 작업의 성공/실패 결과를 담는 타입입니다.
typedef AuthControllerResult = Result<String>;

/// 인증 유효성 검사 결과 타입 (Result 패턴 사용)
///
/// 폼 입력 데이터의 유효성 검사 결과를 담는 타입입니다.
typedef AuthValidationResult = Result<void>;

/// 인증 컨트롤러
///
/// 인증 관련 비즈니스 로직을 관리하는 컨트롤러입니다.
/// UseCase 패턴을 사용하여 인증 로직을 처리하고,
/// 폼 상태 관리를 담당합니다.
class AuthController extends FormController<AuthFormState> {
  /// 로그인 UseCase
  late final LoginUseCase _loginUseCase;

  /// 회원가입 UseCase
  late final SignupUseCase _signupUseCase;

  /// 로그아웃 UseCase
  late final LogoutUseCase _logoutUseCase;

  /// 현재 사용자 정보 조회 UseCase
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  /// 소셜 로그인 UseCase
  late final SocialLoginUseCase _socialLoginUseCase;

  /// 생성자
  ///
  /// [ref] Riverpod Ref 객체
  AuthController(super.ref) {
    final repository = ref.read(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    _signupUseCase = SignupUseCase(repository);
    _logoutUseCase = LogoutUseCase(repository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    _socialLoginUseCase = SocialLoginUseCase(repository);
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

  /// 실제 로그인 성공 처리
  ///
  /// 인증 성공 시 호출되어 폼 상태를 업데이트합니다.
  /// 로딩 상태를 해제하고 에러를 초기화합니다.
  void handleLoginSuccess() {
    debugPrint('✅ AuthController: 로그인 성공 처리');

    // 폼 상태 업데이트
    ref.read(authFormStateNotifierProvider.notifier).handleLoginSuccess();
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
      final result = await _socialLoginUseCase.loginWithGoogle();

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
      final result = await _socialLoginUseCase.loginWithApple();

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
      final result = await _socialLoginUseCase.loginWithLine();

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
