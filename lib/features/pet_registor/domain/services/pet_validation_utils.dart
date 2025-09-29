import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';

/// 펫 등록 검증 유틸리티
class PetValidationUtils {
  /// 다음 단계로 진행 가능한지 확인
  static bool canProceedToNextStep(
    PetRegistrationDataEntity data,
    int currentStep,
  ) {
    switch (currentStep) {
      case 1: // 펫 타입 선택
        return data.type != null;
      case 2: // 품종 선택
        return data.breed != null && data.breed!.isNotEmpty;
      case 3: // 이름 입력
        return data.name != null && data.name!.isNotEmpty;
      case 4: // 크기/체중 입력
        final weight = data.additionalInfo?['weight'] as double?;
        return weight != null && weight > 0;
      case 5: // 기념일 입력
        return data.birthDate != null;
      default:
        return false;
    }
  }

  /// 등록 완료 상태 확인
  static bool isRegistrationComplete(PetRegistrationDataEntity data) {
    return data.type != null &&
        data.name != null &&
        data.name!.isNotEmpty &&
        data.birthDate != null &&
        data.additionalInfo?['weight'] != null;
  }

  /// 현재 단계 이후에 더 많은 데이터가 있는지 확인
  static bool hasDataBeyondStep(
    PetRegistrationDataEntity data,
    int currentStep,
  ) {
    switch (currentStep) {
      case 1: // 펫 타입 선택 후
        return data.breed != null ||
            data.name != null ||
            data.birthDate != null ||
            data.additionalInfo?['weight'] != null;
      case 2: // 품종 선택 후
        return data.name != null ||
            data.birthDate != null ||
            data.additionalInfo?['weight'] != null;
      case 3: // 이름 입력 후
        return data.birthDate != null || data.additionalInfo?['weight'] != null;
      case 4: // 크기/체중 입력 후
        return data.birthDate != null;
      default:
        return false;
    }
  }

  /// 현재 품종 가져오기
  static String? getCurrentBreed(PetRegistrationDataEntity data) {
    return data.breed;
  }

  /// 펫 이름 유효성 검사
  static bool isValidPetName(String name) {
    final trimmed = name.trim();
    return trimmed.length >= 2 && trimmed.length <= 20;
  }

  /// 체중 유효성 검사
  static bool isValidWeight(double weight) {
    return weight >= 0.5 && weight <= 50.0;
  }

  /// 마이크로칩 번호 유효성 검사
  static bool isValidMicrochipNumber(String? number) {
    if (number == null || number.isEmpty) return true; // 선택사항
    final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 15;
  }
}
