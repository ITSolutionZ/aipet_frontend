import '../../domain/entities/temporary_pet_data_entity.dart';

class TemporaryPetData {
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

  const TemporaryPetData({
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

  factory TemporaryPetData.fromEntity(TemporaryPetDataEntity entity) {
    return TemporaryPetData(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      breed: entity.breed,
      birthDate: entity.birthDate,
      imagePath: entity.imagePath,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      additionalInfo: entity.additionalInfo,
      currentStep: entity.currentStep,
      stepData: entity.stepData,
    );
  }

  TemporaryPetDataEntity toEntity() {
    return TemporaryPetDataEntity(
      id: id,
      name: name,
      type: type,
      breed: breed,
      birthDate: birthDate,
      imagePath: imagePath,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      additionalInfo: additionalInfo,
      currentStep: currentStep,
      stepData: stepData,
    );
  }

  TemporaryPetData copyWith({
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
    return TemporaryPetData(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'birthDate': birthDate?.toIso8601String(),
      'imagePath': imagePath,
      'ownerId': ownerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'additionalInfo': additionalInfo,
      'currentStep': currentStep.name,
      'stepData': stepData,
    };
  }

  factory TemporaryPetData.fromJson(Map<String, dynamic> json) {
    return TemporaryPetData(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      breed: json['breed'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
      ownerId: json['ownerId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      currentStep: PetRegistrationStep.values.firstWhere(
        (e) => e.name == json['currentStep'],
        orElse: () => PetRegistrationStep.typeSelection,
      ),
      stepData: json['stepData'] as Map<String, dynamic>?,
    );
  }
}
