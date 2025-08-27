
/// 임시 펫 데이터 엔티티 (등록 과정에서 사용)
class TemporaryPetDataEntity {
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
  final PetRegistrationStep currentStep;
  final Map<String, dynamic>? stepData;

  const TemporaryPetDataEntity({
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
    this.currentStep = PetRegistrationStep.typeSelection,
    this.stepData,
  });

  TemporaryPetDataEntity copyWith({
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
    PetRegistrationStep? currentStep,
    Map<String, dynamic>? stepData,
  }) {
    return TemporaryPetDataEntity(
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
      currentStep: currentStep ?? this.currentStep,
      stepData: stepData ?? this.stepData,
    );
  }

  /// 다음 단계로 진행
  TemporaryPetDataEntity nextStep() {
    final nextStep = _getNextStep(currentStep);
    return copyWith(currentStep: nextStep);
  }

  /// 이전 단계로 돌아가기
  TemporaryPetDataEntity previousStep() {
    final previousStep = _getPreviousStep(currentStep);
    return copyWith(currentStep: previousStep);
  }

  /// 현재 단계가 마지막인지 확인
  bool get isLastStep => currentStep == PetRegistrationStep.complete;

  /// 현재 단계가 첫 번째인지 확인
  bool get isFirstStep => currentStep == PetRegistrationStep.typeSelection;

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    const steps = PetRegistrationStep.values;
    final currentIndex = steps.indexOf(currentStep);
    return (currentIndex + 1) / steps.length;
  }

  /// 단계별 제목
  String get stepTitle {
    switch (currentStep) {
      case PetRegistrationStep.typeSelection:
        return '펫 종류 선택';
      case PetRegistrationStep.breedSelection:
        return '품종 선택';
      case PetRegistrationStep.nameInput:
        return '이름 입력';
      case PetRegistrationStep.birthDateInput:
        return '생년월일 입력';
      case PetRegistrationStep.imageUpload:
        return '사진 업로드';
      case PetRegistrationStep.complete:
        return '등록 완료';
    }
  }

  /// 단계별 설명
  String get stepDescription {
    switch (currentStep) {
      case PetRegistrationStep.typeSelection:
        return '펫의 종류를 선택해주세요';
      case PetRegistrationStep.breedSelection:
        return '펫의 품종을 선택해주세요';
      case PetRegistrationStep.nameInput:
        return '펫의 이름을 입력해주세요';
      case PetRegistrationStep.birthDateInput:
        return '펫의 생년월일을 입력해주세요';
      case PetRegistrationStep.imageUpload:
        return '펫의 사진을 업로드해주세요';
      case PetRegistrationStep.complete:
        return '펫 등록이 완료되었습니다!';
    }
  }

  PetRegistrationStep _getNextStep(PetRegistrationStep current) {
    switch (current) {
      case PetRegistrationStep.typeSelection:
        return PetRegistrationStep.breedSelection;
      case PetRegistrationStep.breedSelection:
        return PetRegistrationStep.nameInput;
      case PetRegistrationStep.nameInput:
        return PetRegistrationStep.birthDateInput;
      case PetRegistrationStep.birthDateInput:
        return PetRegistrationStep.imageUpload;
      case PetRegistrationStep.imageUpload:
        return PetRegistrationStep.complete;
      case PetRegistrationStep.complete:
        return PetRegistrationStep.complete;
    }
  }

  PetRegistrationStep _getPreviousStep(PetRegistrationStep current) {
    switch (current) {
      case PetRegistrationStep.typeSelection:
        return PetRegistrationStep.typeSelection;
      case PetRegistrationStep.breedSelection:
        return PetRegistrationStep.typeSelection;
      case PetRegistrationStep.nameInput:
        return PetRegistrationStep.breedSelection;
      case PetRegistrationStep.birthDateInput:
        return PetRegistrationStep.nameInput;
      case PetRegistrationStep.imageUpload:
        return PetRegistrationStep.birthDateInput;
      case PetRegistrationStep.complete:
        return PetRegistrationStep.imageUpload;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemporaryPetDataEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          currentStep == other.currentStep;

  @override
  int get hashCode => id.hashCode ^ currentStep.hashCode;

  @override
  String toString() {
    return 'TemporaryPetDataEntity(id: $id, name: $name, type: $type, currentStep: $currentStep)';
  }
}

/// 펫 등록 단계
enum PetRegistrationStep {
  typeSelection,
  breedSelection,
  nameInput,
  birthDateInput,
  imageUpload,
  complete,
}
