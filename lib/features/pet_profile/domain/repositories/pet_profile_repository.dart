import '../../../pet_registor/domain/entities/pet_profile_entity.dart';

abstract class PetProfileRepository {
  /// 펫 프로필 상세 정보 가져오기
  Future<PetProfileEntity> getPetProfile(String petId);

  /// 펫 프로필 업데이트
  Future<PetProfileEntity> updatePetProfile(PetProfileEntity pet);

  /// 펫 프로필 이미지 업로드
  Future<String> uploadPetImage(String petId, String imagePath);

  /// 펫 프로필 공유 설정
  Future<void> updateSharingSettings(String petId, bool isPublic);

  /// 가족 관리자 추가
  Future<void> addFamilyManager(String petId, String userId);

  /// 가족 관리자 제거
  Future<void> removeFamilyManager(String petId, String userId);
}
