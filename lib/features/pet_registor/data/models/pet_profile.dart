import '../../domain/entities/pet_profile_entity.dart';

class PetProfile {
  final String id;
  final String name;
  final String type;
  final String? breed;
  final DateTime birthDate;
  final String? imagePath;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? additionalInfo;

  const PetProfile({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    required this.birthDate,
    this.imagePath,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.additionalInfo,
  });

  factory PetProfile.fromEntity(PetProfileEntity entity) {
    return PetProfile(
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
    );
  }

  PetProfileEntity toEntity() {
    return PetProfileEntity(
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
    );
  }

  PetProfile copyWith({
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
  }) {
    return PetProfile(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'birthDate': birthDate.toIso8601String(),
      'imagePath': imagePath,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'additionalInfo': additionalInfo,
    };
  }

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      imagePath: json['imagePath'] as String?,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }
}
