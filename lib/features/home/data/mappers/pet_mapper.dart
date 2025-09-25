import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';

/// Pet 관련 데이터 변환 매퍼
class PetMapper {
  /// Map 데이터를 PetProfileEntity로 변환
  static PetProfileEntity fromMap(Map<String, dynamic> map) {
    return PetProfileEntity(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['typeName']?.toString() ?? map['type']?.toString() ?? 'dog',
      breed: map['breed']?.toString(),
      birthDate: map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      gender: map['gender']?.toString() ?? 'unknown',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath']?.toString(),
      ownerId: map['ownerId']?.toString() ?? 'unknown',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      additionalInfo: map['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Map 리스트를 PetProfileEntity 리스트로 변환
  static List<PetProfileEntity> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map(fromMap).toList();
  }

  /// Map 리스트를 PetSummaryEntity 리스트로 직접 변환
  static List<PetSummaryEntity> toSummaryEntityListFromMaps(
    List<Map<String, dynamic>> maps,
  ) {
    return maps.map((map) => toSummaryEntity(fromMap(map))).toList();
  }

  /// PetProfileEntity를 PetSummaryEntity로 변환
  ///
  /// 다른 feature의 entity를 home feature의 domain entity로 변환하여
  /// domain layer의 독립성을 유지
  static PetSummaryEntity toSummaryEntity(PetProfileEntity profile) {
    return PetSummaryEntity(
      id: profile.id,
      name: profile.name,
      typeName: profile.typeName,
      breed: profile.breed,
      age: profile.age,
      birthDate: profile.birthDate,
      createdAt: profile.createdAt,
      profileImageUrl: null, // PetProfileEntity에서 이미지 URL을 추출하는 로직 필요시 추가
      additionalInfo: profile.additionalInfo,
    );
  }

  /// 여러 PetProfileEntity를 PetSummaryEntity 리스트로 변환
  static List<PetSummaryEntity> toSummaryEntityList(
    List<PetProfileEntity> profiles,
  ) {
    return profiles.map(toSummaryEntity).toList();
  }
}
