/// Pet Profile Domain Entity
///
/// Pet Profile 기능에 특화된 도메인 엔티티
/// Pet Registor와는 독립적으로 Pet Profile 관리에 필요한 정보만 포함
class PetProfileEntity {
  final String id;
  final String name;
  final String type; // 'dog', 'cat', 'bird', 'hamster', 'rabbit'
  final String? breed;
  final DateTime birthDate;
  final String? imagePath;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  // Pet Profile 기능에 특화된 정보
  final ProfileSharingSettings sharingSettings;
  final HealthInfo? healthInfo;
  final List<String> familyManagerIds;
  final ProfileVisibilityLevel visibilityLevel;
  final Map<String, dynamic>? customFields;

  const PetProfileEntity({
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
    this.sharingSettings = const ProfileSharingSettings(),
    this.healthInfo,
    this.familyManagerIds = const [],
    this.visibilityLevel = ProfileVisibilityLevel.private,
    this.customFields,
  });

  PetProfileEntity copyWith({
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
    ProfileSharingSettings? sharingSettings,
    HealthInfo? healthInfo,
    List<String>? familyManagerIds,
    ProfileVisibilityLevel? visibilityLevel,
    Map<String, dynamic>? customFields,
  }) {
    return PetProfileEntity(
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
      sharingSettings: sharingSettings ?? this.sharingSettings,
      healthInfo: healthInfo ?? this.healthInfo,
      familyManagerIds: familyManagerIds ?? this.familyManagerIds,
      visibilityLevel: visibilityLevel ?? this.visibilityLevel,
      customFields: customFields ?? this.customFields,
    );
  }

  /// 펫 나이 계산
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 펫 타입 일본어명
  String get typeName {
    switch (type.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'hamster':
        return 'ハムスター';
      case 'rabbit':
        return 'うさぎ';
      default:
        return 'ペット';
    }
  }

  /// 펫 타입 아이콘
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'hamster':
        return '🐹';
      case 'rabbit':
        return '🐰';
      default:
        return '🐾';
    }
  }

  /// 프로필이 공유 가능한지 확인
  bool get isShareable {
    return sharingSettings.allowSharing &&
        visibilityLevel != ProfileVisibilityLevel.private;
  }

  /// 패밀리 매니저 권한 확인
  bool canBeEditedBy(String userId) {
    return ownerId == userId || familyManagerIds.contains(userId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetProfileEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PetProfileEntity(id: $id, name: $name, type: $type, breed: $breed, isShareable: $isShareable)';
  }
}

/// 프로필 공유 설정
class ProfileSharingSettings {
  final bool allowSharing;
  final bool allowQrCode;
  final bool allowDirectLink;
  final DateTime? linkExpiryDate;

  const ProfileSharingSettings({
    this.allowSharing = false,
    this.allowQrCode = false,
    this.allowDirectLink = false,
    this.linkExpiryDate,
  });

  ProfileSharingSettings copyWith({
    bool? allowSharing,
    bool? allowQrCode,
    bool? allowDirectLink,
    DateTime? linkExpiryDate,
  }) {
    return ProfileSharingSettings(
      allowSharing: allowSharing ?? this.allowSharing,
      allowQrCode: allowQrCode ?? this.allowQrCode,
      allowDirectLink: allowDirectLink ?? this.allowDirectLink,
      linkExpiryDate: linkExpiryDate ?? this.linkExpiryDate,
    );
  }
}

/// 건강 정보
class HealthInfo {
  final double? weight;
  final String? currentMedication;
  final List<VaccinationRecord> vaccinations;
  final DateTime? lastCheckupDate;
  final String? veterinarianNotes;

  const HealthInfo({
    this.weight,
    this.currentMedication,
    this.vaccinations = const [],
    this.lastCheckupDate,
    this.veterinarianNotes,
  });

  HealthInfo copyWith({
    double? weight,
    String? currentMedication,
    List<VaccinationRecord>? vaccinations,
    DateTime? lastCheckupDate,
    String? veterinarianNotes,
  }) {
    return HealthInfo(
      weight: weight ?? this.weight,
      currentMedication: currentMedication ?? this.currentMedication,
      vaccinations: vaccinations ?? this.vaccinations,
      lastCheckupDate: lastCheckupDate ?? this.lastCheckupDate,
      veterinarianNotes: veterinarianNotes ?? this.veterinarianNotes,
    );
  }
}

/// 예방접종 기록
class VaccinationRecord {
  final String vaccineName;
  final DateTime administeredDate;
  final DateTime? nextDueDate;
  final String? veterinarianName;
  final String? notes;

  const VaccinationRecord({
    required this.vaccineName,
    required this.administeredDate,
    this.nextDueDate,
    this.veterinarianName,
    this.notes,
  });
}

/// 프로필 공개 수준
enum ProfileVisibilityLevel {
  private, // 비공개
  family, // 가족만
  public, // 공개
}
