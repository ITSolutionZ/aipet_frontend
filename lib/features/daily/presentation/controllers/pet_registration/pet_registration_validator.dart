import 'package:flutter/foundation.dart';

/// 펫 등록 폼 검증 서비스
///
/// 모든 검증 로직을 담당하는 클래스
class PetRegistrationValidator {
  /// 펫 이름 검증
  String? validatePetName(String? value) {
    debugPrint('🔍 Validating pet name: "$value"');
    if (value == null || value.trim().isEmpty) {
      debugPrint('❌ Pet name validation failed: empty');
      return 'ペットの名前を入力してください';
    }
    if (value.length < 2 || value.length > 10) {
      debugPrint('❌ Pet name validation failed: length ${value.length}');
      return '2〜10文字で入力してください';
    }
    debugPrint('✅ Pet name validation passed');
    return null;
  }

  /// 생년월일 검証
  String? validateBirthDate(String? value) {
    debugPrint('🔍 Validating birth date: "$value"');
    if (value == null || value.trim().isEmpty) {
      debugPrint('❌ Birth date validation failed: empty');
      return '生年月日を入力してください';
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      debugPrint('❌ Birth date validation failed: invalid format');
      return 'YYYY-MM-DD形式で入力してください';
    }
    debugPrint('✅ Birth date validation passed');
    return null;
  }

  /// 입양일 검증 (선택사항)
  String? validateAdoptionDate(String? value) {
    // 집에 온 날은 선택사항이므로 빈 값이어도 됩니다
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'YYYY-MM-DD形式で入力してください';
    }
    return null;
  }

  /// 체중 검증
  String? validateWeight(String? value) {
    debugPrint('🔍 Validating weight: "$value"');
    if (value == null || value.trim().isEmpty) {
      debugPrint('❌ Weight validation failed: empty');
      return '体重を入力してください';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0 || weight > 100) {
      debugPrint('❌ Weight validation failed: invalid value $weight');
      return '有効な体重を入力してください';
    }
    debugPrint('✅ Weight validation passed');
    return null;
  }

  /// 외견 검증 (선택사항)
  String? validateAppearance(String? value) {
    // 외견은 선택사항이므로 빈 값이어도 됩니다
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.length > 500) {
      return '500文字以内で入力してください';
    }
    return null;
  }

  /// 품종 검증
  String? validateBreed(String breed) {
    debugPrint('🔍 Validating breed: "$breed" (empty: ${breed.isEmpty})');
    if (breed.isEmpty) {
      debugPrint('❌ Breed validation failed: breed is empty');
      return '品種を選択してください';
    }
    debugPrint('✅ Breed validation passed');
    return null;
  }

  /// 성별 검증
  String? validateGender(String gender) {
    debugPrint('🔍 Validating gender: "$gender" (empty: ${gender.isEmpty})');
    if (gender.isEmpty) {
      debugPrint('❌ Gender validation failed: gender is empty');
      return '性別を選択してください';
    }
    debugPrint('✅ Gender validation passed');
    return null;
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
