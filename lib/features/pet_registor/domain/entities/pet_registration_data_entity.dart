/// 펫 등록 데이터 엔티티
/// Data Layer에서 Domain Layer로 이동하여 의존성 방향 수정
class PetRegistrationDataEntity {
  final String? selectedPetType;
  final String? selectedDogBreed;
  final String? selectedCatBreed;
  final String? customBreed;
  final String? petName;
  final String? petSize;
  final double? petWeight;
  final DateTime? petAnniversary;
  final DateTime? petBirthday;
  final DateTime? petArrivalDate;
  final String? petGender;
  final bool? isNeutered;
  final String? petImagePath;
  final String? customDefaultImagePath;
  final String? microchipNumber;

  const PetRegistrationDataEntity({
    this.selectedPetType,
    this.selectedDogBreed,
    this.selectedCatBreed,
    this.customBreed,
    this.petName,
    this.petSize,
    this.petWeight,
    this.petAnniversary,
    this.petBirthday,
    this.petArrivalDate,
    this.petGender,
    this.isNeutered,
    this.petImagePath,
    this.customDefaultImagePath,
    this.microchipNumber,
  });

  PetRegistrationDataEntity copyWith({
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
    String? customDefaultImagePath,
    String? microchipNumber,
  }) {
    return PetRegistrationDataEntity(
      selectedPetType: selectedPetType ?? this.selectedPetType,
      selectedDogBreed: selectedDogBreed ?? this.selectedDogBreed,
      selectedCatBreed: selectedCatBreed ?? this.selectedCatBreed,
      customBreed: customBreed ?? this.customBreed,
      petName: petName ?? this.petName,
      petSize: petSize ?? this.petSize,
      petWeight: petWeight ?? this.petWeight,
      petAnniversary: petAnniversary ?? this.petAnniversary,
      petBirthday: petBirthday ?? this.petBirthday,
      petArrivalDate: petArrivalDate ?? this.petArrivalDate,
      petGender: petGender ?? this.petGender,
      isNeutered: isNeutered ?? this.isNeutered,
      petImagePath: petImagePath ?? this.petImagePath,
      customDefaultImagePath: customDefaultImagePath ?? this.customDefaultImagePath,
      microchipNumber: microchipNumber ?? this.microchipNumber,
    );
  }

  /// 현재 선택된 품종 반환 (일반 품종 또는 커스텀 품종)
  String? get currentBreed {
    if (selectedPetType == 'dog') {
      return selectedDogBreed == 'custom' ? customBreed : selectedDogBreed;
    } else if (selectedPetType == 'cat') {
      return selectedCatBreed == 'custom' ? customBreed : selectedCatBreed;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetRegistrationDataEntity &&
          runtimeType == other.runtimeType &&
          selectedPetType == other.selectedPetType &&
          petName == other.petName &&
          petBirthday == other.petBirthday;

  @override
  int get hashCode => selectedPetType.hashCode ^ petName.hashCode ^ petBirthday.hashCode;

  @override
  String toString() {
    return 'PetRegistrationDataEntity(petType: $selectedPetType, name: $petName, breed: $currentBreed)';
  }
}