import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/utils/validation_utils.dart';

/// 통합 유효성 검사 서비스
///
/// 모든 feature에서 공통으로 사용되는 유효성 검사 로직을 제공합니다.
class ValidationService {
  /// 이메일 유효성 검사
  static Result<void> validateEmail(String email) {
    try {
      final isValid = ValidationUtils.isValidEmail(email);
      if (isValid) {
        return Result.success('有効なメールアドレスです');
      } else {
        final errorMessage = ValidationUtils.getFieldErrorMessage(email, ValidationField.email);
        return Result.failure(errorMessage ?? '無効なメールアドレスです');
      }
    } catch (error) {
      return Result.failure('メールアドレス検証中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 비밀번호 유효성 검사
  static Result<void> validatePassword(String password) {
    try {
      final isValid = ValidationUtils.isValidPassword(password);
      if (isValid) {
        return Result.success('有効なパスワードです');
      } else {
        final errorMessage = ValidationUtils.getFieldErrorMessage(
          password,
          ValidationField.password,
        );
        return Result.failure(errorMessage ?? '無効なパスワードです');
      }
    } catch (error) {
      return Result.failure('パスワード検証中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 사용자명 유효성 검사
  static Result<void> validateUsername(String username) {
    try {
      final isValid = ValidationUtils.isValidUsername(username);
      if (isValid) {
        return Result.success('有効なユーザー名です');
      } else {
        final errorMessage = ValidationUtils.getFieldErrorMessage(
          username,
          ValidationField.username,
        );
        return Result.failure(errorMessage ?? '無効なユーザー名です');
      }
    } catch (error) {
      return Result.failure('ユーザー名検証中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 비밀번호 확인 검사
  static Result<void> validateConfirmPassword(String password, String confirmPassword) {
    try {
      final isValid = ValidationUtils.doPasswordsMatch(password, confirmPassword);
      if (isValid) {
        return Result.success('パスワードが一致しています');
      } else {
        return Result.failure('パスワードが一致しません');
      }
    } catch (error) {
      return Result.failure('パスワード確認中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 펫 이름 유효성 검사
  static Result<void> validatePetName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return Result.failure('ペットの名前は必須項目です');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.failure('ペットの名前は1文字以上である必要があります');
    }

    if (trimmedName.length > 50) {
      return Result.failure('ペットの名前は50文字以下である必要があります');
    }

    // 특수문자 검사 (기본적인 검사)
    if (RegExp(r'[<>{}[\]\\|`~!@#$%^&*()+=]').hasMatch(trimmedName)) {
      return Result.failure('ペットの名前に使用できない文字が含まれています');
    }

    return Result.success('有効な名前です');
  }

  /// 펫 체중 유효성 검사
  static Result<void> validatePetWeight(double? weight) {
    if (weight == null) {
      return Result.failure('ペットの体重は必須項目です');
    }

    if (weight <= 0.0) {
      return Result.failure('ペットの体重は0より大きい必要があります');
    }

    if (weight > 100.0) {
      return Result.failure('ペットの体重は100kg以下である必要があります');
    }

    return Result.success('有効な体重です');
  }

  /// 펫 생년월일 유효성 검사
  static Result<void> validatePetBirthday(DateTime? birthday) {
    if (birthday == null) {
      return Result.failure('ペットの生年月日は必須項目です');
    }

    final now = DateTime.now();
    if (birthday.isAfter(now)) {
      return Result.failure('ペットの生年月日は未来の日付にできません');
    }

    // 30년 전보다 오래된 날짜는 유효하지 않음
    final thirtyYearsAgo = DateTime(now.year - 30, now.month, now.day);
    if (birthday.isBefore(thirtyYearsAgo)) {
      return Result.failure('ペットの生年月日は30年前より新しい必要があります');
    }

    return Result.success('有効な生年月日です');
  }

  /// 마이크로칩 번호 유효성 검사
  static Result<void> validateMicrochipNumber(String? number) {
    if (number == null || number.isEmpty) {
      return Result.success('マイクロチップ番号は任意項目です');
    }

    if (number.length != 15) {
      return Result.failure('マイクロチップ番号は15桁である必要があります');
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(number)) {
      return Result.failure('マイクロチップ番号は数字のみである必要があります');
    }

    return Result.success('有効なマイクロチップ番号です');
  }

  /// 필수 필드 검사
  static Result<void> validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Result.failure('$fieldNameは必須項目です');
    }
    return Result.success('有効な値です');
  }

  /// 숫자 필드 검사
  static Result<void> validateNumberField(
    String? value,
    String fieldName, {
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return Result.failure('$fieldNameは必須項目です');
    }

    final number = double.tryParse(value);
    if (number == null) {
      return Result.failure('$fieldNameは有効な数値である必要があります');
    }

    if (min != null && number < min) {
      return Result.failure('$fieldNameは$min以上である必要があります');
    }

    if (max != null && number > max) {
      return Result.failure('$fieldNameは$max以下である必要があります');
    }

    return Result.success('有効な値です');
  }

  /// 날짜 필드 검사
  static Result<void> validateDateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Result.failure('$fieldNameは必須項目です');
    }

    final date = DateTime.tryParse(value);
    if (date == null) {
      return Result.failure('$fieldNameは有効な日付である必要があります');
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return Result.failure('$fieldNameは未来の日付にできません');
    }

    return Result.success('有効な値です');
  }

  /// 전화번호 유효성 검사
  static Result<void> validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return Result.success('電話番号は任意項目です');
    }

    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length < 10) {
      return Result.failure('電話番号は10桁以上である必要があります');
    }

    if (cleaned.length > 15) {
      return Result.failure('電話番号は15桁以下である必要があります');
    }

    return Result.success('有効な電話番号です');
  }

  /// URL 유효성 검사
  static Result<void> validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return Result.success('URLは任意項目です');
    }

    try {
      final uri = Uri.parse(url);
      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return Result.success('有効なURLです');
      } else {
        return Result.failure('有効なURL形式ではありません');
      }
    } catch (e) {
      return Result.failure('無効なURL形式です');
    }
  }

  /// 복합 유효성 검사
  ///
  /// [validations] 검사할 유효성 검사 목록
  /// [return] 모든 검사가 통과하면 성공, 하나라도 실패하면 실패
  static Result<void> validateMultiple(List<Result<void>> validations) {
    for (final validation in validations) {
      if (!validation.isSuccess) {
        return validation;
      }
    }
    return Result.success('すべての検証が完了しました');
  }
}
