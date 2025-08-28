import '../../../../app/controllers/base_controller.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_error.dart';
import '../../domain/auth_state.dart';
import '../../domain/result.dart';
import '../../utils/auth_validator.dart';

/// 인증 작업 결과 (Result 패턴 사용)
typedef AuthControllerResult = Result<String>;

/// 인증 유효성 검사 결과 (Result 패턴 사용)
typedef AuthValidationResult = Result<void>;

class AuthController extends BaseController {
  AuthController(super.ref);

  AuthState get currentState => ref.read(authStateNotifierProvider);

  void updateEmail(String email) {
    ref.read(authStateNotifierProvider.notifier).updateEmail(email);
  }

  void updatePassword(String password) {
    ref.read(authStateNotifierProvider.notifier).updatePassword(password);
  }

  void updateConfirmPassword(String confirmPassword) {
    ref
        .read(authStateNotifierProvider.notifier)
        .updateConfirmPassword(confirmPassword);
  }

  void updateUsername(String username) {
    ref.read(authStateNotifierProvider.notifier).updateUsername(username);
  }

  void togglePasswordVisibility() {
    ref.read(authStateNotifierProvider.notifier).togglePasswordVisibility();
  }

  void toggleConfirmPasswordVisibility() {
    ref
        .read(authStateNotifierProvider.notifier)
        .toggleConfirmPasswordVisibility();
  }

  void toggleRememberMe() {
    ref.read(authStateNotifierProvider.notifier).toggleRememberMe();
  }

  /// 로그인 처리 (UI 로직 분리)
  Future<AuthControllerResult> login() async {
    try {
      // 유효성 검사
      final validationResult = validateLoginData();
      if (validationResult.isFailure) {
        final error = validationResult.errorOrNull;
        return Result.failure(
          ValidationError(field: 'login', reason: error?.message ?? 'Validation failed'),
        );
      }

      // TODO: 실제 로그인 API 호출

      return Result.success('ログインが完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.fromError(error);
    }
  }

  /// 회원가입 처리 (UI 로직 분리)
  Future<AuthControllerResult> signup() async {
    try {
      // 유효성 검사
      final validationResult = validateSignupData();
      if (validationResult.isFailure) {
        final error = validationResult.errorOrNull;
        return Result.failure(
          ValidationError(field: 'signup', reason: error?.message ?? 'Validation failed'),
        );
      }

      // TODO: 실제 회원가입 API 호출

      return Result.success('会員登録が完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.fromError(error);
    }
  }

  /// 소셜 로그인 처리 (UI 로직 분리)
  Future<AuthControllerResult> socialLogin(String provider) async {
    try {
      // TODO: 실제 소셜 로그인 API 호출

      return Result.success('$provider ログインが完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.fromError(error);
    }
  }

  /// 저장된 로그인 정보 불러오기
  Future<void> loadSavedCredentials() async {
    try {
      await ref.read(authStateNotifierProvider.notifier).loadSavedCredentials();
    } catch (error) {
      handleError(error);
    }
  }

  /// 저장된 로그인 정보 삭제
  Future<bool> clearSavedCredentials() async {
    try {
      await ref
          .read(authStateNotifierProvider.notifier)
          .clearSavedCredentials();
      return true;
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return false;
    }
  }

  /// 로그아웃 처리 (목업 구현)
  Future<AuthControllerResult> logout() async {
    try {
      // 저장된 로그인 정보 삭제
      await clearSavedCredentials();

      // 인증 상태 초기화
      ref.read(authStateNotifierProvider.notifier).resetState();

      // TODO: Firebase 로그아웃 로직 (추후 구현)
      // await FirebaseAuth.instance.signOut();

      return Result.success('ログアウトが完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.fromError(error);
    }
  }

  /// 로그인 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateLoginData() {
    final state = currentState;

    // 이메일 검증
    final emailError = AuthValidator.getEmailErrorMessage(state.email);
    if (emailError != null) {
      return Result.failure(
        ValidationError(field: 'email', reason: emailError),
      );
    }

    // 비밀번호 검증 (로그인은 빈 값만 체크)
    if (state.password.isEmpty) {
      return Result.failure(
        const ValidationError(field: 'password', reason: 'パスワードを入力してください'),
      );
    }

    return Result.success(null);
  }

  /// 회원가입 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateSignupData() {
    final state = currentState;

    // 이메일 검증
    final emailError = AuthValidator.getEmailErrorMessage(state.email);
    if (emailError != null) {
      return Result.failure(
        ValidationError(field: 'email', reason: emailError),
      );
    }

    // 비밀번호 검증
    final passwordError = AuthValidator.getPasswordErrorMessage(state.password);
    if (passwordError != null) {
      return Result.failure(
        ValidationError(field: 'password', reason: passwordError),
      );
    }

    // 비밀번호 확인 검증
    final confirmPasswordError = AuthValidator.getConfirmPasswordErrorMessage(
      state.password, 
      state.confirmPassword,
    );
    if (confirmPasswordError != null) {
      return Result.failure(
        ValidationError(field: 'confirmPassword', reason: confirmPasswordError),
      );
    }

    // 사용자명 검증
    final usernameError = AuthValidator.getUsernameErrorMessage(state.username);
    if (usernameError != null) {
      return Result.failure(
        ValidationError(field: 'username', reason: usernameError),
      );
    }

    return Result.success(null);
  }


  /// 에러 메시지 초기화
  void clearError() {
    ref.read(authStateNotifierProvider.notifier).clearError();
  }
}
