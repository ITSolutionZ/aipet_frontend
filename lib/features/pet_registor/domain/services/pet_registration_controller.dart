import 'package:aipet_frontend/features/pet_registor/data/providers/pet_registration_provider.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_validation_utils.dart';

/// 펫 등록 컨트롤러
/// Domain Layer의 비즈니스 로직을 캡슐화
class PetRegistrationController {
  final Ref ref;

  PetRegistrationController(this.ref);

  /// 현재 등록 상태 가져오기 (외부에서 주입받아야 함)
  PetRegistrationDataEntity get currentState => ref.read(petRegistrationStateProvider);

  /// 다음 단계로 이동 가능한지 확인
  bool canProceedToNextStep(int currentStep) {
    return PetValidationUtils.canProceedToNextStep(currentState, currentStep);
  }

  /// 등록 완료 상태 확인
  bool get isRegistrationComplete {
    return PetValidationUtils.isRegistrationComplete(currentState);
  }

  /// 현재 단계 이후에 더 많은 데이터가 있는지 확인
  bool hasDataBeyondStep(int currentStep) {
    return PetValidationUtils.hasDataBeyondStep(currentState, currentStep);
  }

  /// 현재 선택된 품종 반환
  String? get currentBreed {
    return PetValidationUtils.getCurrentBreed(currentState);
  }

  /// 펫 타입 선택
  void selectPetType(String petType) {
    if (petType.isNotEmpty) {
      ref.read(petRegistrationStateProvider.notifier).selectPetType(petType);
    }
  }

  /// 강아지 품종 선택
  void selectDogBreed(String breed) {
    if (breed.isNotEmpty) {
      ref.read(petRegistrationStateProvider.notifier).selectDogBreed(breed);
    }
  }

  /// 고양이 품종 선택
  void selectCatBreed(String breed) {
    if (breed.isNotEmpty) {
      ref.read(petRegistrationStateProvider.notifier).selectCatBreed(breed);
    }
  }

  /// 커스텀 품종 입력 (검증 포함)
  void setCustomBreed(String customBreed) {
    if (customBreed.trim().isNotEmpty) {
      ref.read(petRegistrationStateProvider.notifier).setCustomBreed(customBreed.trim());
    }
  }

  /// 펫 이름 입력 (검증 포함)
  void setPetName(String name) {
    if (PetValidationUtils.isValidPetName(name)) {
      ref.read(petRegistrationStateProvider.notifier).setPetName(name.trim());
    } else {
      throw ArgumentError('Invalid pet name: $name');
    }
  }

  /// 펫 크기/체중 입력 (검증 포함)
  void setPetSizeWeight({String? size, double? weight}) {
    if (weight != null && !PetValidationUtils.isValidWeight(weight)) {
      throw ArgumentError('Invalid weight: $weight');
    }
    ref.read(petRegistrationStateProvider.notifier).setPetSizeWeight(size: size, weight: weight);
  }

  /// 펫 생일 설정
  void setPetBirthday(DateTime birthday) {
    if (birthday.isBefore(DateTime.now())) {
      ref.read(petRegistrationStateProvider.notifier).setPetBirthday(birthday);
    } else {
      throw ArgumentError('Birthday cannot be in the future');
    }
  }

  /// 펫 입양일 설정
  void setPetArrivalDate(DateTime arrivalDate) {
    if (arrivalDate.isBefore(DateTime.now()) || arrivalDate.isAtSameMomentAs(DateTime.now())) {
      ref.read(petRegistrationStateProvider.notifier).setPetArrivalDate(arrivalDate);
    } else {
      throw ArgumentError('Arrival date cannot be in the future');
    }
  }

  /// 펫 성별 및 중성화 상태 설정
  void setPetGenderInfo({String? gender, bool? isNeutered}) {
    if (gender != null && !['male', 'female'].contains(gender)) {
      throw ArgumentError('Invalid gender: $gender');
    }
    ref
        .read(petRegistrationStateProvider.notifier)
        .setPetGenderInfo(gender: gender, isNeutered: isNeutered);
  }

  /// 마이크로칩 번호 설정 (검증 포함)
  void setMicrochipNumber(String? number) {
    if (number != null && !PetValidationUtils.isValidMicrochipNumber(number)) {
      throw ArgumentError('Invalid microchip number: $number');
    }
    ref.read(petRegistrationStateProvider.notifier).setMicrochipNumber(number);
  }

  /// 등록 데이터 초기화
  void resetRegistration() {
    ref.read(petRegistrationStateProvider.notifier).reset();
  }

  /// 등록 프로세스 완료 검증
  void validateAndCompleteRegistration() {
    if (!isRegistrationComplete) {
      final missingFields = _getMissingRequiredFields();
      throw StateError('Registration incomplete. Missing: ${missingFields.join(', ')}');
    }
    // TODO: 실제 API 호출이나 다른 완료 처리 로직 추가
  }

  /// 누락된 필수 필드 반환 (디버깅용)
  List<String> _getMissingRequiredFields() {
    final List<String> missing = [];
    final state = currentState;

    if (state.selectedPetType == null) missing.add('Pet Type');
    if (state.petName == null || state.petName!.isEmpty) {
      missing.add('Pet Name');
    }
    if (state.petGender == null) missing.add('Gender');
    if (state.petBirthday == null) missing.add('Birthday');
    if (state.petSize == null) missing.add('Size');
    if (state.petWeight == null) missing.add('Weight');

    return missing;
  }
}

/// Provider for PetRegistrationController
final petRegistrationControllerProvider = Provider<PetRegistrationController>((ref) {
  return PetRegistrationController(ref);
});
