import '../domain/auth_constants.dart';

/// 인증 관련 유효성 검사 유틸리티 클래스
class AuthValidator {
  /// 이메일 유효성 검사
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(AuthConstants.emailPattern).hasMatch(email);
  }

  /// 비밀번호 유효성 검사
  static bool isValidPassword(String password) {
    return password.length >= AuthConstants.minPasswordLength &&
           password.length <= AuthConstants.maxPasswordLength;
  }

  /// 사용자명 유효성 검사
  static bool isValidUsername(String username) {
    return username.length >= AuthConstants.minUsernameLength &&
           username.length <= AuthConstants.maxUsernameLength;
  }

  /// 비밀번호 확인
  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword && password.isNotEmpty;
  }

  /// 소셜 로그인 프로바이더 검사
  static bool isSupportedProvider(String provider) {
    return AuthConstants.supportedProviders.contains(provider.toLowerCase());
  }

  /// 이메일 에러 메시지 가져오기
  static String? getEmailErrorMessage(String email) {
    if (email.isEmpty) {
      return AuthConstants.errorMessages['email_required'];
    }
    if (!isValidEmail(email)) {
      return AuthConstants.errorMessages['email_invalid'];
    }
    return null;
  }

  /// 비밀번호 에러 메시지 가져오기
  static String? getPasswordErrorMessage(String password) {
    if (password.isEmpty) {
      return AuthConstants.errorMessages['password_required'];
    }
    if (!isValidPassword(password)) {
      return AuthConstants.errorMessages['password_too_short'];
    }
    return null;
  }

  /// 사용자명 에러 메시지 가져오기
  static String? getUsernameErrorMessage(String username) {
    if (username.isEmpty) {
      return AuthConstants.errorMessages['username_required'];
    }
    if (!isValidUsername(username)) {
      return AuthConstants.errorMessages['username_too_short'];
    }
    return null;
  }

  /// 비밀번호 확인 에러 메시지 가져오기
  static String? getConfirmPasswordErrorMessage(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return AuthConstants.errorMessages['password_required'];
    }
    if (!doPasswordsMatch(password, confirmPassword)) {
      return AuthConstants.errorMessages['password_mismatch'];
    }
    return null;
  }

  // private constructor (유틸리티 클래스)
  const AuthValidator._();
}