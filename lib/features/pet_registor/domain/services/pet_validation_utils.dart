import '../../../../../shared/shared.dart';
import '../entities/pet_registration_data_entity.dart';
import 'pet_validation_service.dart';

/// 펫 검증 유틸리티 클래스
/// 기존 코드와의 호환성을 위한 정적 메서드 제공
class PetValidationUtils {
  static final PetValidationService _service = PetValidationServiceImpl();

  /// 다음 단계로 이동할 수 있는지 확인
  static bool canProceedToNextStep(
    PetRegistrationDataEntity data,
    int currentStep,
  ) => _service.canProceedToNextStep(data, currentStep);

  /// 등록이 완료 상태인지 확인 (모든 필수 정보가 입력되었는지)
  static bool isRegistrationComplete(PetRegistrationDataEntity data) =>
      _service.isRegistrationComplete(data);

  /// 현재 단계 이후에 더 많은 데이터가 있는지 확인
  static bool hasDataBeyondStep(
    PetRegistrationDataEntity data,
    int currentStep,
  ) => _service.hasDataBeyondStep(data, currentStep);

  /// 현재 선택된 품종 반환 (일반 품종 또는 커스텀 품종)
  static String? getCurrentBreed(PetRegistrationDataEntity data) =>
      _service.getCurrentBreed(data);

  /// 펫 이름 유효성 검증 (shared 유틸리티 사용)
  static bool isValidPetName(String? name) =>
      ValidationUtils.isValidPetName(name);

  /// 체중 유효성 검증 (shared 유틸리티 사용)
  static bool isValidWeight(double? weight) =>
      ValidationUtils.isValidWeight(weight);

  /// 마이크로칩 번호 유효성 검증 (shared 유틸리티 사용)
  static bool isValidMicrochipNumber(String? number) =>
      ValidationUtils.isValidMicrochipNumber(number);
}

/// PetValidationService의 기본 구현체
class PetValidationServiceImpl implements PetValidationService {
  @override
  bool canProceedToNextStep(PetRegistrationDataEntity data, int currentStep) {
    switch (currentStep) {
      case 1: // 펫 타입 선택
        return data.selectedPetType != null;
      case 2: // 품종 선택 (강아지/고양이만)
        if (data.selectedPetType == 'dog') {
          return data.selectedDogBreed != null &&
              (data.selectedDogBreed != 'custom' ||
                  data.customBreed != null && data.customBreed!.isNotEmpty);
        } else if (data.selectedPetType == 'cat') {
          return data.selectedCatBreed != null &&
              (data.selectedCatBreed != 'custom' ||
                  data.customBreed != null && data.customBreed!.isNotEmpty);
        }
        return true; // 강아지/고양이가 아닌 경우 품종 선택 단계 건너뛰기
      case 3: // 이름 입력
        return data.petName != null && data.petName!.isNotEmpty;
      case 4: // 크기/체중 입력
        return data.petSize != null && data.petWeight != null;
      case 5: // 기념일 입력
        return data.petBirthday != null;
      default:
        return false;
    }
  }

  @override
  bool isRegistrationComplete(PetRegistrationDataEntity data) {
    return data.selectedPetType != null &&
        data.petName != null &&
        data.petName!.isNotEmpty &&
        data.petGender != null &&
        data.petBirthday != null &&
        data.petSize != null &&
        data.petWeight != null;
  }

  @override
  bool hasDataBeyondStep(PetRegistrationDataEntity data, int currentStep) {
    switch (currentStep) {
      case 1: // 펫 타입 선택 후
        return data.petName != null ||
            data.petBirthday != null ||
            data.petSize != null;
      case 2: // 품종 선택 후
        return data.petName != null ||
            data.petBirthday != null ||
            data.petSize != null;
      case 3: // 이름 입력 후
        return data.petBirthday != null || data.petSize != null;
      case 4: // 크기/체중 입력 후
        return data.petBirthday != null;
      case 5: // 기념일 입력 후
        return false; // 마지막 단계
      default:
        return false;
    }
  }

  @override
  String? getCurrentBreed(PetRegistrationDataEntity data) {
    if (data.selectedPetType == 'dog') {
      return data.selectedDogBreed == 'custom'
          ? data.customBreed
          : data.selectedDogBreed;
    } else if (data.selectedPetType == 'cat') {
      return data.selectedCatBreed == 'custom'
          ? data.customBreed
          : data.selectedCatBreed;
    }
    return null;
  }

  @override
  bool isValidPetName(String? name) {
    return ValidationUtils.isValidPetName(name);
  }

  @override
  bool isValidWeight(double? weight) {
    return ValidationUtils.isValidWeight(weight);
  }

  @override
  bool isValidMicrochipNumber(String? number) {
    return ValidationUtils.isValidMicrochipNumber(number);
  }
}
