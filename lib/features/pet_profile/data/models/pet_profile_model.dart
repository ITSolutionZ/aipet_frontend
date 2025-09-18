import '../../domain/entities/pet_profile_entity.dart';

/// Pet Profile Data Model
///
/// 데이터 레이어에서 사용되는 Pet Profile 모델
/// 외부 데이터 소스와의 직렬화/역직렬화를 담당
class PetProfileModel {
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
  final Map<String, dynamic>? sharingSettings;
  final Map<String, dynamic>? healthInfo;
  final List<String> familyManagerIds;
  final String visibilityLevel;
  final Map<String, dynamic>? customFields;

  PetProfileModel({
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
    this.sharingSettings,
    this.healthInfo,
    this.familyManagerIds = const [],
    this.visibilityLevel = 'private',
    this.customFields,
  });

  /// JSON에서 모델 생성 (외부 API, 데이터베이스용)
  factory PetProfileModel.fromJson(Map<String, dynamic> json) {
    return PetProfileModel(
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
      sharingSettings: json['sharingSettings'] as Map<String, dynamic>?,
      healthInfo: json['healthInfo'] as Map<String, dynamic>?,
      familyManagerIds: (json['familyManagerIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      visibilityLevel: json['visibilityLevel'] as String? ?? 'private',
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  /// 모델을 JSON으로 변환 (외부 API, 데이터베이스용)
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
      'sharingSettings': sharingSettings,
      'healthInfo': healthInfo,
      'familyManagerIds': familyManagerIds,
      'visibilityLevel': visibilityLevel,
      'customFields': customFields,
    };
  }

  /// Pet Registor Entity에서 모델 생성 (Mock 데이터 호환성용)
  factory PetProfileModel.fromLegacyEntity(dynamic legacyEntity) {
    // pet_registor의 PetProfileEntity나 Mock 데이터와 호환
    if (legacyEntity is Map<String, dynamic>) {
      return PetProfileModel.fromJson(legacyEntity);
    }

    // 기존 Entity 객체인 경우
    return PetProfileModel(
      id: legacyEntity.id,
      name: legacyEntity.name,
      type: legacyEntity.type,
      breed: legacyEntity.breed,
      birthDate: legacyEntity.birthDate,
      imagePath: legacyEntity.imagePath,
      ownerId: legacyEntity.ownerId,
      createdAt: legacyEntity.createdAt,
      updatedAt: legacyEntity.updatedAt,
      isActive: legacyEntity.isActive ?? true,
      sharingSettings: _extractSharingSettings(legacyEntity.additionalInfo),
      healthInfo: _extractHealthInfo(legacyEntity.additionalInfo),
      familyManagerIds: _extractFamilyManagerIds(legacyEntity.additionalInfo),
      visibilityLevel: _extractVisibilityLevel(legacyEntity.additionalInfo),
      customFields: legacyEntity.additionalInfo,
    );
  }

  /// 도메인 엔티티로 변환
  PetProfileEntity toDomainEntity() {
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
      sharingSettings: _parseSharingSettings(sharingSettings),
      healthInfo: _parseHealthInfo(healthInfo),
      familyManagerIds: familyManagerIds,
      visibilityLevel: _parseVisibilityLevel(visibilityLevel),
      customFields: customFields,
    );
  }

  /// 도메인 엔티티에서 모델 생성
  factory PetProfileModel.fromDomainEntity(PetProfileEntity entity) {
    return PetProfileModel(
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
      sharingSettings: _serializeSharingSettings(entity.sharingSettings),
      healthInfo: _serializeHealthInfo(entity.healthInfo),
      familyManagerIds: entity.familyManagerIds,
      visibilityLevel: entity.visibilityLevel.name,
      customFields: entity.customFields,
    );
  }

  // Helper methods for data conversion
  static Map<String, dynamic>? _extractSharingSettings(Map<String, dynamic>? additionalInfo) {
    if (additionalInfo == null) return null;
    final isPublic = additionalInfo['isPublic'] as bool? ?? false;
    return {
      'allowSharing': isPublic,
      'allowQrCode': false,
      'allowDirectLink': false,
    };
  }

  static Map<String, dynamic>? _extractHealthInfo(Map<String, dynamic>? additionalInfo) {
    if (additionalInfo == null) return null;
    final weight = additionalInfo['weight'] as double?;
    if (weight == null) return null;
    return {
      'weight': weight,
    };
  }

  static List<String> _extractFamilyManagerIds(Map<String, dynamic>? additionalInfo) {
    if (additionalInfo == null) return [];
    final managers = additionalInfo['familyManagers'] as List<dynamic>?;
    return managers?.map((e) => e.toString()).toList() ?? [];
  }

  static String _extractVisibilityLevel(Map<String, dynamic>? additionalInfo) {
    final isPublic = additionalInfo?['isPublic'] as bool? ?? false;
    return isPublic ? 'public' : 'private';
  }

  static ProfileSharingSettings _parseSharingSettings(Map<String, dynamic>? data) {
    if (data == null) return const ProfileSharingSettings();
    return ProfileSharingSettings(
      allowSharing: data['allowSharing'] as bool? ?? false,
      allowQrCode: data['allowQrCode'] as bool? ?? false,
      allowDirectLink: data['allowDirectLink'] as bool? ?? false,
    );
  }

  static HealthInfo? _parseHealthInfo(Map<String, dynamic>? data) {
    if (data == null) return null;
    return HealthInfo(
      weight: data['weight'] as double?,
      currentMedication: data['currentMedication'] as String?,
      vaccinations: [], // TODO: Parse vaccination records
    );
  }

  static ProfileVisibilityLevel _parseVisibilityLevel(String level) {
    switch (level.toLowerCase()) {
      case 'public':
        return ProfileVisibilityLevel.public;
      case 'family':
        return ProfileVisibilityLevel.family;
      default:
        return ProfileVisibilityLevel.private;
    }
  }

  static Map<String, dynamic>? _serializeSharingSettings(ProfileSharingSettings settings) {
    return {
      'allowSharing': settings.allowSharing,
      'allowQrCode': settings.allowQrCode,
      'allowDirectLink': settings.allowDirectLink,
      'linkExpiryDate': settings.linkExpiryDate?.toIso8601String(),
    };
  }

  static Map<String, dynamic>? _serializeHealthInfo(HealthInfo? healthInfo) {
    if (healthInfo == null) return null;
    return {
      'weight': healthInfo.weight,
      'currentMedication': healthInfo.currentMedication,
      'lastCheckupDate': healthInfo.lastCheckupDate?.toIso8601String(),
      'veterinarianNotes': healthInfo.veterinarianNotes,
    };
  }
}