import '../../../../app/controllers/base_controller.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_error.dart';
import '../../domain/auth_form_state.dart';
import '../../domain/result.dart';
import '../../utils/auth_validator.dart';

/// 인증 작업 결과 (Result 패턴 사용)
typedef AuthControllerResult = Result<String>;

/// 인증 유효성 검사 결과 (Result 패턴 사용)
typedef AuthValidationResult = Result<void>;

class AuthController extends BaseController {
  AuthController(super.ref);

  AuthFormState get currentState => ref.read(authFormStateNotifierProvider);

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

  /// 로그인 처리 (UI 로직 분리)
  Future<AuthControllerResult> login() async {
    try {
      // 유효성 검사
      final validationResult = validateLoginData();
      if (validationResult.isFailure) {
        final error = validationResult.errorOrNull;
        return Result.failure(
          ValidationError(
            field: 'login',
            reason: error?.message ?? 'Validation failed',
          ),
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
          ValidationError(
            field: 'signup',
            reason: error?.message ?? 'Validation failed',
          ),
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

  /// 로그아웃 처리 (목업 구현)
  Future<AuthControllerResult> logout() async {
    try {
      // 저장된 로그인 정보 삭제
      await clearSavedCredentials();

      // 인증 상태 초기화
      ref.read(authFormStateNotifierProvider.notifier).resetState();

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

    // 비밀번호 검증은 UI에서 직접 처리 (AuthFormState에는 패스워드 없음)
    // 실제 검증은 TextFormField의 validator에서 수행

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

    // 사용자명 검증
    final usernameError = AuthValidator.getUsernameErrorMessage(state.username);
    if (usernameError != null) {
      return Result.failure(
        ValidationError(field: 'username', reason: usernameError),
      );
    }

    // 비밀번호 검증은 UI에서 직접 처리 (AuthFormState에는 패스워드 없음)
    // 실제 검증은 TextFormField의 validator에서 수행

    return Result.success(null);
  }

  /// 에러 메시지 초기화
  void clearError() {
    ref.read(authFormStateNotifierProvider.notifier).clearError();
  }
}
