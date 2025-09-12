import '../../domain/entities/pet_registration_data_entity.dart';
import '../../domain/services/pet_validation_service.dart';

/// 펫 등록 검증 서비스 구현체
/// Data Layer에서 Domain Layer의 인터페이스를 구현
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
        data.petName != null && data.petName!.isNotEmpty &&
        data.petGender != null &&
        data.petBirthday != null &&
        data.petSize != null &&
        data.petWeight != null;
  }

  @override
  bool hasDataBeyondStep(PetRegistrationDataEntity data, int currentStep) {
    switch (currentStep) {
      case 1: // 펫 타입 선택 후
        return data.petName != null || data.petBirthday != null || data.petSize != null;
      case 2: // 품종 선택 후  
        return data.petName != null || data.petBirthday != null || data.petSize != null;
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
      return data.selectedDogBreed == 'custom' ? data.customBreed : data.selectedDogBreed;
    } else if (data.selectedPetType == 'cat') {
      return data.selectedCatBreed == 'custom' ? data.customBreed : data.selectedCatBreed;
    }
    return null;
  }

  @override
  bool isValidPetName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 50) return false;
    return true;
  }

  @override
  bool isValidWeight(double? weight) {
    if (weight == null) return false;
    return weight > 0.0 && weight <= 100.0; // 0kg 초과 100kg 이하
  }

  @override
  bool isValidMicrochipNumber(String? number) {
    if (number == null || number.isEmpty) return true; // 선택사항이므로 빈 값 허용
    return number.length == 15 && RegExp(r'^[0-9]+$').hasMatch(number);
  }

}