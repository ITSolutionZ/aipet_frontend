/// 입력 검증을 위한 공통 유틸리티 클래스
class ValidationUtils {
  ValidationUtils._();

  /// 이메일 형식 검증
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 비밀번호 형식 검증
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    // 최소 8자, 영문/숫자/특수문자 조합
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  /// 이름 형식 검증
  static bool isValidName(String name) {
    if (name.isEmpty) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    // 2-20자, 한글/영문/숫자만 허용
    final nameRegex = RegExp(r'^[가-힣a-zA-Z0-9]{2,20}$');
    return nameRegex.hasMatch(name);
  }

  /// 전화번호 형식 검증
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    // 한국 전화번호 형식 (010-1234-5678, 01012345678)
    final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
    return phoneRegex.hasMatch(phone);
  }

  /// 필수 필드 검증
  static bool isRequired(String value) {
    return value.trim().isNotEmpty;
  }

  /// 최소 길이 검증
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// 최대 길이 검증
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  /// 숫자만 검증
  static bool isNumeric(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// 양수 검증
  static bool isPositive(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }

  /// 날짜 형식 검증 (YYYY-MM-DD)
  static bool isValidDate(String date) {
    if (date.isEmpty) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) return false;

    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// URL 형식 검증
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 개발 모드 확인
  static bool _isDevelopmentMode() {
    // 현재는 개발 환경으로만 진행
    return true;
  }

  /// 에러 메시지 생성
  static String getErrorMessage(ValidationError error) {
    switch (error) {
      case ValidationError.required:
        return '必須な項目です。';
      case ValidationError.invalidEmail:
        return '形式のメールアドレスではありません。';
      case ValidationError.invalidPassword:
        return 'パスワードは8文字以上で、英数字、記号を組み合わせる必要があります。';
      case ValidationError.invalidName:
        return '名前は2-20文字のみ使用できます。';
      case ValidationError.invalidPhone:
        return '電話番号の形式が正しくありません。';
      case ValidationError.tooShort:
        return '短すぎる';
      case ValidationError.tooLong:
        return 'を超える';
      case ValidationError.invalidNumber:
        return '数値のみ入力できます。';
      case ValidationError.invalidPositiveNumber:
        return '正の数を入力してください。';
      case ValidationError.invalidDate:
        return '正しい日付形式ではありません。';
      case ValidationError.invalidUrl:
        return '形式のURLではありません。';
    }
  }
}

/// 검증 에러 타입
enum ValidationError {
  required,
  invalidEmail,
  invalidPassword,
  invalidName,
  invalidPhone,
  tooShort,
  tooLong,
  invalidNumber,
  invalidPositiveNumber,
  invalidDate,
  invalidUrl,
}

/// 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;

  const ValidationResult({required this.isValid, this.errors = const []});

  /// 성공 결과 생성
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  /// 실패 결과 생성
  factory ValidationResult.failure(List<ValidationError> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  /// 에러 메시지 목록 반환
  List<String> get errorMessages {
    return errors
        .map((error) => ValidationUtils.getErrorMessage(error))
        .toList();
  }

  /// 첫 번째 에러 메시지 반환
  String? get firstErrorMessage {
    if (errors.isEmpty) return null;
    return ValidationUtils.getErrorMessage(errors.first);
  }
}
