import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/pet_registration_data_entity.dart';
import '../../domain/services/pet_validation_utils.dart';

part 'pet_registration_provider.g.dart';

/// 펫 등록 상태 데이터 클래스
@Riverpod(keepAlive: true)
class PetRegistrationState extends _$PetRegistrationState {
  @override
  PetRegistrationData build() {
    return const PetRegistrationData();
  }

  /// 펫 타입 선택
  void selectPetType(String petType) {
    state = state.copyWith(selectedPetType: petType);
  }

  /// 강아지 품종 선택
  void selectDogBreed(String breed) {
    state = state.copyWith(selectedDogBreed: breed);
  }

  /// 고양이 품종 선택
  void selectCatBreed(String breed) {
    state = state.copyWith(selectedCatBreed: breed);
  }

  /// 커스텀 품종 입력
  void setCustomBreed(String customBreed) {
    state = state.copyWith(customBreed: customBreed);
  }

  /// 펫 이름 입력
  void setPetName(String name) {
    state = state.copyWith(petName: name);
  }

  /// 펫 크기/체중 입력
  void setPetSizeWeight({String? size, double? weight}) {
    state = state.copyWith(petSize: size, petWeight: weight);
  }

  /// 펫 기념일 입력
  void setPetAnniversary(DateTime anniversary) {
    state = state.copyWith(petAnniversary: anniversary);
  }

  /// 펫 생일 및 입양일 입력
  void setPetDates({DateTime? birthday, DateTime? arrivalDate}) {
    state = state.copyWith(
      petBirthday: birthday ?? state.petBirthday,
      petArrivalDate: arrivalDate ?? state.petArrivalDate,
    );
  }

  /// 펫 생일만 설정
  void setPetBirthday(DateTime birthday) {
    state = state.copyWith(petBirthday: birthday);
  }

  /// 펫 입양일만 설정
  void setPetArrivalDate(DateTime arrivalDate) {
    state = state.copyWith(petArrivalDate: arrivalDate);
  }

  /// 펫 성별 및 중성화 상태 설정
  void setPetGenderInfo({String? gender, bool? isNeutered}) {
    state = state.copyWith(petGender: gender, isNeutered: isNeutered);
  }

  /// 펫 이미지 설정
  void setPetImagePath(String? imagePath) {
    state = state.copyWith(petImagePath: imagePath);
  }

  /// 커스텀 기본 이미지 경로 설정
  // void setCustomDefaultImagePath(String? imagePath) {
  //   state = state.copyWith(customDefaultImagePath: imagePath);
  // }

  /// 마이크로칩 번호 설정
  void setMicrochipNumber(String? number) {
    state = state.copyWith(microchipNumber: number);
  }

  /// 상태 초기화
  void reset() {
    state = const PetRegistrationData();
  }
}

/// 펫 등록 데이터 모델
class PetRegistrationData extends PetRegistrationDataEntity {
  const PetRegistrationData({
    super.selectedPetType,
    super.selectedDogBreed,
    super.selectedCatBreed,
    super.customBreed,
    super.petName,
    super.petSize,
    super.petWeight,
    super.petAnniversary,
    super.petBirthday,
    super.petArrivalDate,
    super.petGender,
    super.isNeutered,
    super.petImagePath,
    super.microchipNumber,
    super.customDefaultImagePath,
  });

  @override
  PetRegistrationData copyWith({
    String? selectedPetType,
    String? selectedDogBreed,
    String? selectedCatBreed,
    String? customBreed,
    String? petName,
    String? petSize,
    double? petWeight,
    DateTime? petAnniversary,
    DateTime? petBirthday,
    DateTime? petArrivalDate,
    String? petGender,
    bool? isNeutered,
    String? petImagePath,
    String? microchipNumber,
    String? customDefaultImagePath,
  }) {
    return PetRegistrationData(
      selectedPetType: selectedPetType ?? this.selectedPetType,
      selectedDogBreed: selectedDogBreed ?? this.selectedDogBreed,
      selectedCatBreed: selectedCatBreed ?? this.selectedCatBreed,
      customBreed: customBreed ?? this.customBreed,
      petName: petName ?? this.petName,
      petSize: petSize ?? this.petSize,
      petWeight: petWeight ?? this.petWeight,
      petGender: petGender ?? this.petGender,
      petAnniversary: petAnniversary ?? this.petAnniversary,
      petBirthday: petBirthday ?? this.petBirthday,
      petArrivalDate: petArrivalDate ?? this.petArrivalDate,
      isNeutered: isNeutered ?? this.isNeutered,
      petImagePath: petImagePath ?? this.petImagePath,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      customDefaultImagePath:
          customDefaultImagePath ?? this.customDefaultImagePath,
    );
  }

  /// 다음 단계로 이동할 수 있는지 확인
  bool canProceedToNextStep(int currentStep) {
    return PetValidationUtils.canProceedToNextStep(this, currentStep);
  }

  /// 등록이 완료 상태인지 확인 (모든 필수 정보가 입력되었는지)
  bool get isRegistrationComplete {
    return PetValidationUtils.isRegistrationComplete(this);
  }

  /// 현재 단계 이후에 더 많은 데이터가 있는지 확인
  bool hasDataBeyondStep(int currentStep) {
    return PetValidationUtils.hasDataBeyondStep(this, currentStep);
  }
}
