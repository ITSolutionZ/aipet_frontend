import 'package:aipet_frontend/shared/shared.dart';

/// 펫 등록 폼 검증 서비스
///
/// **역할**: Pet registration form validation
/// - ValidationMixin을 사용하여 공통 검증 로직 재사용
/// - Pet registration 특화 검증 로직 포함
///
/// **특징**:
/// - shared/ValidationMixin 사용으로 DRY 원칙 준수
/// - 필수 필드, 길이, 범위, 형식 검증
class PetRegistrationValidator with ValidationMixin {
  /// 펫 이름 검증 (shared ValidationMixin 사용)
  @override
  String? validatePetName(String? value) {
    LoggerService.debug('🔍 Validating pet name: "$value"');
    final result = validateMultiple(value, [
      (v) => validateRequired(v, fieldName: 'ペットの名前'),
      (v) =>
          validateLength(v, minLength: 2, maxLength: 10, fieldName: 'ペットの名前'),
    ]);
    LoggerService.debug(
      result == null
          ? '✅ Pet name validation passed'
          : '❌ Pet name validation failed',
    );
    return result;
  }

  /// 생년월일 검증 (shared ValidationMixin 사용)
  String? validateBirthDate(String? value) {
    LoggerService.debug('🔍 Validating birth date: "$value"');
    final result = validateMultiple(value, [
      (v) => validateRequired(v, fieldName: '生年月日'),
      (v) => validateRegex(
        v,
        RegExp(r'^\d{4}-\d{2}-\d{2}$'),
        fieldName: '生年月日',
        errorMessage: 'YYYY-MM-DD形式で入力してください',
      ),
    ]);
    LoggerService.debug(
      result == null
          ? '✅ Birth date validation passed'
          : '❌ Birth date validation failed',
    );
    return result;
  }

  /// 입양일 검증 (선택사항, shared ValidationMixin 사용)
  String? validateAdoptionDate(String? value) {
    // 집에 온 날은 선택사항이므로 빈 값이어도 됩니다
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validateRegex(
      value,
      RegExp(r'^\d{4}-\d{2}-\d{2}$'),
      fieldName: '家にきた日',
      errorMessage: 'YYYY-MM-DD形式で入力してください',
    );
  }

  /// 체중 검증 (shared ValidationMixin 사용)
  String? validateWeight(String? value) {
    LoggerService.debug('🔍 Validating weight: "$value"');

    // 빈 값 체크
    if (value == null || value.trim().isEmpty) {
      return '体重を入力してください';
    }

    // 숫자와 소수점(.)만 허용하는지 확인
    final numericPattern = RegExp(r'^\d*\.?\d*$');
    if (!numericPattern.hasMatch(value.trim())) {
      return '体重は数字と小数点(.)のみ入力できます';
    }

    // 숫자 범위 검증
    final result = validateMultiple(value, [
      (v) => validateRequired(v, fieldName: '体重'),
      (v) => validateNumberRange(v, min: 0.1, max: 100, fieldName: '体重'),
    ]);
    LoggerService.debug(
      result == null
          ? '✅ Weight validation passed'
          : '❌ Weight validation failed',
    );
    return result;
  }

  /// 외견 검증 (선택사항, shared ValidationMixin 사용)
  String? validateAppearance(String? value) {
    // 외견은 선택사항이므로 빈 값이어도 됩니다
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validateLength(value, maxLength: 500, fieldName: '外見');
  }

  /// 품종 검증 (shared ValidationMixin 사용)
  String? validateBreed(String breed) {
    LoggerService.debug(
      '🔍 Validating breed: "$breed" (empty: ${breed.isEmpty})',
    );
    final result = validateRequired(breed, fieldName: '品種');
    LoggerService.debug(
      result == null
          ? '✅ Breed validation passed'
          : '❌ Breed validation failed',
    );
    return result;
  }

  /// 성별 검증 (shared ValidationMixin 사용)
  String? validateGender(String gender) {
    LoggerService.debug(
      '🔍 Validating gender: "$gender" (empty: ${gender.isEmpty})',
    );
    final result = validateRequired(gender, fieldName: '性別');
    LoggerService.debug(
      result == null
          ? '✅ Gender validation passed'
          : '❌ Gender validation failed',
    );
    return result;
  }

  /// 폼 전체 유효성 검사
  bool isFormValid({
    required String petName,
    required DateTime? birthDate,
    required double? weight,
    required String breed,
    required String gender,
  }) {
    return petName.isNotEmpty &&
        birthDate != null &&
        weight != null &&
        breed.isNotEmpty &&
        gender.isNotEmpty;
  }
}
