import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';

import '../../domain/entities/pet_summary_entity.dart';

/// Pet 관련 데이터 변환 매퍼
class PetMapper {
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
  static List<PetSummaryEntity> toSummaryEntityList(List<PetProfileEntity> profiles) {
    return profiles.map(toSummaryEntity).toList();
  }
}