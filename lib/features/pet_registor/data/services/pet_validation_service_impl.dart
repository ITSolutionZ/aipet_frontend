import '../../../../shared/shared.dart';
import '../../domain/entities/pet_registration_data_entity.dart';
import '../../domain/services/pet_validation_service.dart';

/// 펫 등록 검증 서비스 구현체
///
/// shared의 ValidationService를 사용하여 중복 코드를 제거합니다.
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
    // shared의 ValidationService 사용
    final result = ValidationService.validatePetName(name);
    return result.isSuccess;
  }

  @override
  bool isValidWeight(double? weight) {
    // shared의 ValidationService 사용
    final result = ValidationService.validatePetWeight(weight);
    return result.isSuccess;
  }

  @override
  bool isValidMicrochipNumber(String? number) {
    // shared의 ValidationService 사용
    final result = ValidationService.validateMicrochipNumber(number);
    return result.isSuccess;
  }

  /// 펫 이름 유효성 검사 (Result 패턴)
  Result<void> validatePetNameResult(String? name) {
    return ValidationService.validatePetName(name);
  }

  /// 펫 체중 유효성 검사 (Result 패턴)
  Result<void> validateWeightResult(double? weight) {
    return ValidationService.validatePetWeight(weight);
  }

  /// 마이크로칩 번호 유효성 검사 (Result 패턴)
  Result<void> validateMicrochipNumberResult(String? number) {
    return ValidationService.validateMicrochipNumber(number);
  }

  /// 펫 생년월일 유효성 검사 (Result 패턴)
  Result<void> validateBirthdayResult(DateTime? birthday) {
    return ValidationService.validatePetBirthday(birthday);
  }
}
