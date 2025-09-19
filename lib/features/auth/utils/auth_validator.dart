import '../../../shared/shared.dart';

/// 인증 관련 유효성 검사 유틸리티 클래스
///
/// shared의 ValidationService를 사용하여 중복 코드를 제거합니다.
class AuthValidator {
  /// 이메일 유효성 검사 (Result 패턴 사용)
  static Result<void> validateEmail(String email) {
    return ValidationService.validateEmail(email);
  }

  /// 비밀번호 유효성 검사 (Result 패턴 사용)
  static Result<void> validatePassword(String password) {
    return ValidationService.validatePassword(password);
  }

  /// 사용자명 유효성 검사 (Result 패턴 사용)
  static Result<void> validateUsername(String username) {
    return ValidationService.validateUsername(username);
  }

  /// 비밀번호 확인 검사 (Result 패턴 사용)
  static Result<void> validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    return ValidationService.validateConfirmPassword(password, confirmPassword);
  }

  /// 소셜 로그인 프로바이더 검사
  static bool isSupportedProvider(String provider) {
    return ValidationUtils.isSupportedProvider(provider);
  }

  /// 이메일 유효성 검사 (boolean 반환, 기존 호환성 유지)
  static bool isValidEmail(String email) {
    return ValidationUtils.isValidEmail(email);
  }

  /// 비밀번호 유효성 검사 (boolean 반환, 기존 호환성 유지)
  static bool isValidPassword(String password) {
    return ValidationUtils.isValidPassword(password);
  }

  /// 사용자명 유효성 검사 (boolean 반환, 기존 호환성 유지)
  static bool isValidUsername(String username) {
    return ValidationUtils.isValidUsername(username);
  }

  /// 비밀번호 확인 (boolean 반환, 기존 호환성 유지)
  static bool doPasswordsMatch(String password, String confirmPassword) {
    return ValidationUtils.doPasswordsMatch(password, confirmPassword);
  }

  /// 이메일 에러 메시지 가져오기 (기존 호환성 유지)
  static String? getEmailErrorMessage(String email) {
    return ValidationUtils.getFieldErrorMessage(email, ValidationField.email);
  }

  /// 비밀번호 에러 메시지 가져오기 (기존 호환성 유지)
  static String? getPasswordErrorMessage(String password) {
    return ValidationUtils.getFieldErrorMessage(
      password,
      ValidationField.password,
    );
  }

  /// 사용자명 에러 메시지 가져오기 (기존 호환성 유지)
  static String? getUsernameErrorMessage(String username) {
    return ValidationUtils.getFieldErrorMessage(
      username,
      ValidationField.username,
    );
  }

  /// 비밀번호 확인 에러 메시지 가져오기 (기존 호환성 유지)
  static String? getConfirmPasswordErrorMessage(
    String password,
    String confirmPassword,
  ) {
    if (StringUtils.isEmpty(confirmPassword)) {
      return ValidationUtils.getErrorMessage(ValidationError.required);
    }
    if (!doPasswordsMatch(password, confirmPassword)) {
      return ValidationUtils.getErrorMessage(
        ValidationError.passwordsDoNotMatch,
      );
    }
    return null;
  }

  // private constructor (유틸리티 클래스)
  const AuthValidator._();
}
