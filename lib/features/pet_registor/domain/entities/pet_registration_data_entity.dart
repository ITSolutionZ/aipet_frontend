import 'pet_registration_step.dart';

/// 펫 등록 데이터 엔티티
class PetRegistrationDataEntity {
  final String? id;
  final String? name;
  final String? type;
  final String? breed;
  final DateTime? birthDate;
  final String? imagePath;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic>? additionalInfo;

  // 펫 등록 과정에서 사용되는 필드들
  final String? selectedPetType;
  final String? petName;
  final String? petGender;
  final DateTime? petBirthday;
  final String? petSize;
  final double? petWeight;
  final DateTime? petAnniversary;
  final String? selectedDogBreed;
  final String? selectedCatBreed;
  final String? customBreed;
  final String? petImagePath;
  final String? microchipNumber;
  final bool? isNeutered;
  final DateTime? petArrivalDate;

  const PetRegistrationDataEntity({
    this.id,
    this.name,
    this.type,
    this.breed,
    this.birthDate,
    this.imagePath,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.additionalInfo,
    this.selectedPetType,
    this.petName,
    this.petGender,
    this.petBirthday,
    this.petSize,
    this.petWeight,
    this.petAnniversary,
    this.selectedDogBreed,
    this.selectedCatBreed,
    this.customBreed,
    this.petImagePath,
    this.microchipNumber,
    this.isNeutered,
    this.petArrivalDate,
  });

  PetRegistrationDataEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    DateTime? birthDate,
    String? imagePath,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? additionalInfo,
    String? selectedPetType,
    String? petName,
    String? petGender,
    DateTime? petBirthday,
    String? petSize,
    double? petWeight,
    DateTime? petAnniversary,
    String? selectedDogBreed,
    String? selectedCatBreed,
    String? customBreed,
    String? petImagePath,
    String? microchipNumber,
    bool? isNeutered,
    DateTime? petArrivalDate,
  }) {
    return PetRegistrationDataEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      imagePath: imagePath ?? this.imagePath,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      selectedPetType: selectedPetType ?? this.selectedPetType,
      petName: petName ?? this.petName,
      petGender: petGender ?? this.petGender,
      petBirthday: petBirthday ?? this.petBirthday,
      petSize: petSize ?? this.petSize,
      petWeight: petWeight ?? this.petWeight,
      petAnniversary: petAnniversary ?? this.petAnniversary,
      selectedDogBreed: selectedDogBreed ?? this.selectedDogBreed,
      selectedCatBreed: selectedCatBreed ?? this.selectedCatBreed,
      customBreed: customBreed ?? this.customBreed,
      petImagePath: petImagePath ?? this.petImagePath,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      isNeutered: isNeutered ?? this.isNeutered,
      petArrivalDate: petArrivalDate ?? this.petArrivalDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetRegistrationDataEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// 현재 선택된 품종 반환
  String? get currentBreed {
    if (customBreed != null && customBreed!.isNotEmpty) {
      return customBreed;
    }
    if (selectedPetType == 'dog' && selectedDogBreed != null) {
      return selectedDogBreed;
    }
    if (selectedPetType == 'cat' && selectedCatBreed != null) {
      return selectedCatBreed;
    }
    return null;
  }

  /// 등록이 완료되었는지 확인
  bool get isRegistrationComplete {
    return selectedPetType != null &&
        petName != null &&
        petGender != null &&
        petBirthday != null &&
        petSize != null &&
        petWeight != null &&
        petImagePath != null;
  }

  /// 특정 단계 이후에 데이터가 있는지 확인
  bool hasDataBeyondStep(PetRegistrationStep step) {
    switch (step) {
      case PetRegistrationStep.typeSelection:
        return selectedPetType != null;
      case PetRegistrationStep.breedSelection:
        return selectedPetType != null && currentBreed != null;
      case PetRegistrationStep.nameInput:
        return selectedPetType != null &&
            currentBreed != null &&
            petName != null;
      case PetRegistrationStep.birthDateInput:
        return selectedPetType != null &&
            currentBreed != null &&
            petName != null &&
            petBirthday != null;
      case PetRegistrationStep.imageUpload:
        return selectedPetType != null &&
            currentBreed != null &&
            petName != null &&
            petBirthday != null &&
            petImagePath != null;
      case PetRegistrationStep.complete:
        return isRegistrationComplete;
    }
  }

  @override
  String toString() {
    return 'PetRegistrationDataEntity(id: $id, name: $name, type: $type)';
  }
}
