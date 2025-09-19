import 'string_utils.dart';

/// 향상된 검증 유틸리티 클래스 (기존 validation_utils.dart와 통합)
class ValidationUtilsEnhanced {
  ValidationUtilsEnhanced._();

  /// 이메일 형식 검증 (StringUtils 사용)
  static bool isValidEmail(String? email) {
    return StringUtils.isValidEmail(email);
  }

  /// 비밀번호 형식 검증
  static bool isValidPassword(String? password) {
    if (StringUtils.isEmpty(password)) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    // 최소 8자, 영문/숫자/특수문자 조합
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password!);
  }

  /// 사용자명 검증
  static bool isValidUsername(String? username) {
    if (StringUtils.isEmpty(username)) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    // 2-20자, 한글/영문/숫자만 허용
    final usernameRegex = RegExp(r'^[가-힣a-zA-Z0-9]{2,20}$');
    return usernameRegex.hasMatch(username!);
  }

  /// 이름 검증 (사용자명과 동일)
  static bool isValidName(String? name) {
    return isValidUsername(name);
  }

  /// 전화번호 형식 검증 (StringUtils 사용)
  static bool isValidPhoneNumber(String? phone) {
    return StringUtils.isValidPhoneNumber(phone);
  }

  /// URL 형식 검증 (StringUtils 사용)
  static bool isValidUrl(String? url) {
    return StringUtils.isValidUrl(url);
  }

  /// 필수 필드 검증
  static bool isRequired(String? value) {
    return StringUtils.isNotEmpty(value);
  }

  /// 최소 길이 검증 (StringUtils 사용)
  static bool hasMinLength(String? value, int minLength) {
    return StringUtils.hasMinLength(value, minLength);
  }

  /// 최대 길이 검증 (StringUtils 사용)
  static bool hasMaxLength(String? value, int maxLength) {
    return StringUtils.hasMaxLength(value, maxLength);
  }

  /// 길이 범위 검증 (StringUtils 사용)
  static bool isLengthInRange(String? value, int minLength, int maxLength) {
    return StringUtils.isLengthInRange(value, minLength, maxLength);
  }

  /// 숫자 검증 (StringUtils 사용)
  static bool isNumeric(String? value) {
    return StringUtils.isNumeric(value);
  }

  /// 양수 검증 (StringUtils 사용)
  static bool isPositiveNumber(String? value) {
    return StringUtils.isPositiveNumber(value);
  }

  /// 날짜 형식 검증 (YYYY-MM-DD)
  static bool isValidDate(String? date) {
    if (StringUtils.isEmpty(date)) return false;

    // 개발 중에는 모든 입력을 허용
    if (_isDevelopmentMode()) return true;

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date!)) return false;

    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 펫 이름 검증
  static bool isValidPetName(String? name) {
    if (StringUtils.isEmpty(name)) return false;

    final trimmedName = StringUtils.safeTrim(name);
    return trimmedName.isNotEmpty && trimmedName.length <= 50;
  }

  /// 체중 검증
  static bool isValidWeight(double? weight) {
    if (weight == null) return false;
    return weight > 0.0 && weight <= 100.0; // 0kg 초과 100kg 이하
  }

  /// 마이크로칩 번호 검증
  static bool isValidMicrochipNumber(String? number) {
    if (StringUtils.isEmpty(number)) return true; // 선택사항이므로 빈 값 허용
    return number!.length == 15 && RegExp(r'^[0-9]+$').hasMatch(number);
  }

  /// 비밀번호 확인 (두 비밀번호가 일치하는지)
  static bool doPasswordsMatch(String? password, String? confirmPassword) {
    if (StringUtils.isEmpty(password) || StringUtils.isEmpty(confirmPassword)) {
      return false;
    }
    return password == confirmPassword;
  }

  /// 소셜 로그인 프로바이더 검증
  static bool isSupportedProvider(String? provider) {
    if (StringUtils.isEmpty(provider)) return false;

    const supportedProviders = ['google', 'apple', 'facebook', 'twitter'];
    return supportedProviders.contains(provider!.toLowerCase());
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
      case ValidationError.invalidUsername:
        return 'ユーザー名は2-20文字のみ使用できます。';
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
      case ValidationError.invalidPetName:
        return 'ペットの名前は1-50文字で入力してください。';
      case ValidationError.invalidWeight:
        return '体重は0.1-100kgの範囲で入力してください。';
      case ValidationError.invalidMicrochip:
        return 'マイクロチップ番号は15桁の数字で入力してください。';
      case ValidationError.passwordsDoNotMatch:
        return 'パスワードが一致しません。';
      case ValidationError.unsupportedProvider:
        return 'サポートされていないプロバイダーです。';
    }
  }

  /// 특정 필드에 대한 에러 메시지 생성
  static String? getFieldErrorMessage(String? value, ValidationField field) {
    switch (field) {
      case ValidationField.email:
        if (StringUtils.isEmpty(value)) {
          return getErrorMessage(ValidationError.required);
        }
        if (!isValidEmail(value)) {
          return getErrorMessage(ValidationError.invalidEmail);
        }
        return null;

      case ValidationField.password:
        if (StringUtils.isEmpty(value)) {
          return getErrorMessage(ValidationError.required);
        }
        if (!isValidPassword(value)) {
          return getErrorMessage(ValidationError.invalidPassword);
        }
        return null;

      case ValidationField.username:
        if (StringUtils.isEmpty(value)) {
          return getErrorMessage(ValidationError.required);
        }
        if (!isValidUsername(value)) {
          return getErrorMessage(ValidationError.invalidUsername);
        }
        return null;

      case ValidationField.name:
        if (StringUtils.isEmpty(value)) {
          return getErrorMessage(ValidationError.required);
        }
        if (!isValidName(value)) {
          return getErrorMessage(ValidationError.invalidName);
        }
        return null;

      case ValidationField.phone:
        if (StringUtils.isEmpty(value)) {
          return getErrorMessage(ValidationError.required);
        }
        if (!isValidPhoneNumber(value)) {
          return getErrorMessage(ValidationError.invalidPhone);
        }
        return null;

      case ValidationField.petName:
        if (StringUtils.isEmpty(value)) {
          return getErrorMessage(ValidationError.required);
        }
        if (!isValidPetName(value)) {
          return getErrorMessage(ValidationError.invalidPetName);
        }
        return null;

      case ValidationField.microchip:
        if (StringUtils.isNotEmpty(value) && !isValidMicrochipNumber(value)) {
          return getErrorMessage(ValidationError.invalidMicrochip);
        }
        return null;
    }
  }
}

/// 검증 에러 타입 (기존과 통합)
enum ValidationError {
  required,
  invalidEmail,
  invalidPassword,
  invalidName,
  invalidUsername,
  invalidPhone,
  tooShort,
  tooLong,
  invalidNumber,
  invalidPositiveNumber,
  invalidDate,
  invalidUrl,
  invalidPetName,
  invalidWeight,
  invalidMicrochip,
  passwordsDoNotMatch,
  unsupportedProvider,
}

/// 검증 필드 타입
enum ValidationField {
  email,
  password,
  username,
  name,
  phone,
  petName,
  microchip,
}

/// 검증 결과 클래스 (기존과 통합)
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
        .map((error) => ValidationUtilsEnhanced.getErrorMessage(error))
        .toList();
  }

  /// 첫 번째 에러 메시지 반환
  String? get firstErrorMessage {
    if (errors.isEmpty) return null;
    return ValidationUtilsEnhanced.getErrorMessage(errors.first);
  }
}
