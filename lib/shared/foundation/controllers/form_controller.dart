import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/utils/validation_utils.dart';

/// 폼 관리를 위한 공통 컨트롤러
///
/// 모든 폼에서 공통으로 사용되는 패턴을 제공합니다.
/// 유효성 검사, 에러 처리, 상태 관리를 자동화합니다.
abstract class FormController<T> extends BaseController {
  FormController(super.ref);

  /// 폼 데이터
  T get formData;

  /// 폼 유효성 검사
  bool get isFormValid;

  /// 폼 제출 가능 여부
  bool get canSubmit;

  /// 폼 초기화
  void initializeForm();

  /// 폼 리셋
  void resetForm();

  /// 폼 제출
  Future<Result<void>> submitForm();

  /// 필드 유효성 검사
  ///
  /// [value] 검사할 값
  /// [field] 필드 타입
  /// [return] 유효성 검사 결과
  Result<void> validateField(String value, ValidationField field) {
    try {
      bool isValid;
      switch (field) {
        case ValidationField.email:
          isValid = ValidationUtils.isValidEmail(value);
          break;
        case ValidationField.password:
          isValid = ValidationUtils.isValidPassword(value);
          break;
        case ValidationField.username:
          isValid = ValidationUtils.isValidUsername(value);
          break;
        default:
          isValid = true;
      }

      if (isValid) {
        return Result.success('有効な値です');
      } else {
        final errorMessage = ValidationUtils.getFieldErrorMessage(value, field);
        return Result.failure(errorMessage ?? '無効な値です');
      }
    } catch (error) {
      return Result.failure('検証中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 이메일 유효성 검사
  Result<void> validateEmail(String email) {
    return validateField(email, ValidationField.email);
  }

  /// 비밀번호 유효성 검사
  Result<void> validatePassword(String password) {
    return validateField(password, ValidationField.password);
  }

  /// 사용자명 유효성 검사
  Result<void> validateUsername(String username) {
    return validateField(username, ValidationField.username);
  }

  /// 비밀번호 확인 검사
  Result<void> validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    try {
      final isValid = ValidationUtils.doPasswordsMatch(
        password,
        confirmPassword,
      );
      if (isValid) {
        return Result.success('パスワードが一致しています');
      } else {
        return const Failure('パスワードが一致しません');
      }
    } catch (error) {
      return Result.failure('パスワード確認中にエラーが発生しました: ${error.toString()}');
    }
  }

  /// 필수 필드 검사
  ///
  /// [value] 검사할 값
  /// [fieldName] 필드 이름
  /// [return] 유효성 검사 결과
  Result<void> validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return Result.failure('$fieldNameは必須項目です');
    }
    return Result.success('有効な値です');
  }

  /// 숫자 필드 검사
  ///
  /// [value] 검사할 값
  /// [fieldName] 필드 이름
  /// [min] 최소값
  /// [max] 최대값
  /// [return] 유효성 검사 결과
  Result<void> validateNumberField(
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
  ///
  /// [value] 검사할 값
  /// [fieldName] 필드 이름
  /// [return] 유효성 검사 결과
  Result<void> validateDateField(String? value, String fieldName) {
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

  /// 안전한 폼 제출
  ///
  /// [submitFunction] 제출 함수
  /// [return] 제출 결과
  Future<Result<void>> safeSubmit(
    Future<Result<void>> Function() submitFunction,
  ) async {
    try {
      // 폼 유효성 검사
      if (!isFormValid) {
        return const Failure('フォームに無効な値があります');
      }

      // 제출 실행
      final result = await submitFunction();
      if (result.isSuccess) {
        return Result.success('フォームが正常に送信されました');
      } else {
        return Result.failure('送信に失敗しました: ${result.message}');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(
        '送信中にエラーが発生しました: ${getUserFriendlyErrorMessage(error)}',
      );
    }
  }
}

/// 펫 관련 폼 컨트롤러
///
/// 펫 등록/수정 폼에서 공통으로 사용되는 패턴을 제공합니다.
abstract class PetFormController<T> extends FormController<T> {
  PetFormController(super.ref);

  /// 펫 이름 유효성 검사
  Result<void> validatePetName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return const Failure('ペットの名前は必須項目です');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Failure('ペットの名前は1文字以上である必要があります');
    }

    if (trimmedName.length > 50) {
      return const Failure('ペットの名前は50文字以下である必要があります');
    }

    return Result.success('有効な名前です');
  }

  /// 펫 체중 유효성 검사
  Result<void> validatePetWeight(double? weight) {
    if (weight == null) {
      return const Failure('ペットの体重は必須項目です');
    }

    if (weight <= 0.0) {
      return const Failure('ペットの体重は0より大きい必要があります');
    }

    if (weight > 100.0) {
      return const Failure('ペットの体重は100kg以下である必要があります');
    }

    return Result.success('有効な体重です');
  }

  /// 펫 생년월일 유효성 검사
  Result<void> validatePetBirthday(DateTime? birthday) {
    if (birthday == null) {
      return const Failure('ペットの生年月日は必須項目です');
    }

    final now = DateTime.now();
    if (birthday.isAfter(now)) {
      return const Failure('ペットの生年月日は未来の日付にできません');
    }

    // 30년 전보다 오래된 날짜는 유효하지 않음
    final thirtyYearsAgo = DateTime(now.year - 30, now.month, now.day);
    if (birthday.isBefore(thirtyYearsAgo)) {
      return const Failure('ペットの生年月日は30年前より新しい必要があります');
    }

    return Result.success('有効な生年月日です');
  }

  /// 마이크로칩 번호 유효성 검사
  Result<void> validateMicrochipNumber(String? number) {
    if (number == null || number.isEmpty) {
      return Result.success('マイクロチップ番号は任意項目です');
    }

    if (number.length != 15) {
      return const Failure('マイクロチップ番号は15桁である必要があります');
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(number)) {
      return const Failure('マイクロチップ番号は数字のみである必要があります');
    }

    return Result.success('有効なマイクロチップ番号です');
  }
}
