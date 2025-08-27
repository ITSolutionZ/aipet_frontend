import '../../../../app/controllers/base_controller.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_state.dart';

/// 인증 작업 결과
class AuthControllerResult {
  final bool isSuccess;
  final String message;

  const AuthControllerResult._(this.isSuccess, this.message);

  factory AuthControllerResult.success(String message) =>
      AuthControllerResult._(true, message);
  factory AuthControllerResult.failure(String message) =>
      AuthControllerResult._(false, message);
}

/// 인증 유효성 검사 결과
class AuthValidationResult {
  final bool isValid;
  final String errorMessage;

  const AuthValidationResult._(this.isValid, this.errorMessage);

  factory AuthValidationResult.valid() =>
      const AuthValidationResult._(true, '');
  factory AuthValidationResult.invalid(String message) =>
      AuthValidationResult._(false, message);
}

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
      if (!validationResult.isValid) {
        return AuthControllerResult.failure(validationResult.errorMessage);
      }

      // TODO: 실제 로그인 API 호출

      return AuthControllerResult.success('ログインが完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return AuthControllerResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 회원가입 처리 (UI 로직 분리)
  Future<AuthControllerResult> signup() async {
    try {
      // 유효성 검사
      final validationResult = validateSignupData();
      if (!validationResult.isValid) {
        return AuthControllerResult.failure(validationResult.errorMessage);
      }

      // TODO: 실제 회원가입 API 호출

      return AuthControllerResult.success('会員登録が完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return AuthControllerResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 소셜 로그인 처리 (UI 로직 분리)
  Future<AuthControllerResult> socialLogin(String provider) async {
    try {
      // TODO: 실제 소셜 로그인 API 호출

      return AuthControllerResult.success('$provider ログインが完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return AuthControllerResult.failure(getUserFriendlyErrorMessage(error));
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

      return AuthControllerResult.success('ログアウトが完了しました。');
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return AuthControllerResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 로그인 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateLoginData() {
    final state = currentState;

    if (state.email.isEmpty) {
      return AuthValidationResult.invalid('メールアドレスを入力してください');
    }

    if (!_isValidEmail(state.email)) {
      return AuthValidationResult.invalid('正しいメールアドレスを入力してください');
    }

    if (state.password.isEmpty) {
      return AuthValidationResult.invalid('パスワードを入力してください');
    }

    return AuthValidationResult.valid();
  }

  /// 회원가입 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateSignupData() {
    final state = currentState;

    if (state.email.isEmpty) {
      return AuthValidationResult.invalid('メールアドレスを入力してください');
    }

    if (!_isValidEmail(state.email)) {
      return AuthValidationResult.invalid('正しいメールアドレスを入力してください');
    }

    if (state.password.isEmpty) {
      return AuthValidationResult.invalid('パスワードを入力してください');
    }

    if (state.password.length < 6) {
      return AuthValidationResult.invalid('パスワードは6文字以上である必要があります');
    }

    if (state.confirmPassword.isEmpty) {
      return AuthValidationResult.invalid('パスワード確認を入力してください');
    }

    if (state.password != state.confirmPassword) {
      return AuthValidationResult.invalid('パスワードが一致しません');
    }

    if (state.username.isEmpty) {
      return AuthValidationResult.invalid('ユーザー名は2文字以上である必要があります');
    }

    if (state.username.length < 2) {
      return AuthValidationResult.invalid('ユーザー名は2文字以上である必要があります');
    }

    return AuthValidationResult.valid();
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 에러 메시지 초기화
  void clearError() {
    ref.read(authStateNotifierProvider.notifier).clearError();
  }
}
