import '../../../shared/shared.dart';

/// 인증 관련 유효성 검사 유틸리티 클래스 (shared 유틸리티 사용)
class AuthValidator {
  /// 이메일 유효성 검사
  static bool isValidEmail(String email) {
    return ValidationUtilsEnhanced.isValidEmail(email);
  }

  /// 비밀번호 유효성 검사
  static bool isValidPassword(String password) {
    return ValidationUtilsEnhanced.isValidPassword(password);
  }

  /// 사용자명 유효성 검사
  static bool isValidUsername(String username) {
    return ValidationUtilsEnhanced.isValidUsername(username);
  }

  /// 비밀번호 확인
  static bool doPasswordsMatch(String password, String confirmPassword) {
    return ValidationUtilsEnhanced.doPasswordsMatch(password, confirmPassword);
  }

  /// 소셜 로그인 프로바이더 검사
  static bool isSupportedProvider(String provider) {
    return ValidationUtilsEnhanced.isSupportedProvider(provider);
  }

  /// 이메일 에러 메시지 가져오기
  static String? getEmailErrorMessage(String email) {
    return ValidationUtilsEnhanced.getFieldErrorMessage(
      email,
      ValidationField.email,
    );
  }

  /// 비밀번호 에러 메시지 가져오기
  static String? getPasswordErrorMessage(String password) {
    return ValidationUtilsEnhanced.getFieldErrorMessage(
      password,
      ValidationField.password,
    );
  }

  /// 사용자명 에러 메시지 가져오기
  static String? getUsernameErrorMessage(String username) {
    return ValidationUtilsEnhanced.getFieldErrorMessage(
      username,
      ValidationField.username,
    );
  }

  /// 비밀번호 확인 에러 메시지 가져오기
  static String? getConfirmPasswordErrorMessage(
    String password,
    String confirmPassword,
  ) {
    if (StringUtils.isEmpty(confirmPassword)) {
      return ValidationUtilsEnhanced.getErrorMessage(ValidationError.required);
    }
    if (!doPasswordsMatch(password, confirmPassword)) {
      return ValidationUtilsEnhanced.getErrorMessage(
        ValidationError.passwordsDoNotMatch,
      );
    }
    return null;
  }

  // private constructor (유틸리티 클래스)
  const AuthValidator._();
}
