import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

abstract class PetProfileRepository {
  /// 모든 펫 목록 가져오기
  Future<Result<List<PetProfileEntity>>> getAllPets();

  /// ID로 펫 가져오기
  Future<Result<PetProfileEntity?>> getPetById(String id);

  /// 펫 생성
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet);

  /// 펫 업데이트
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet);

  /// 펫 삭제
  Future<Result<void>> deletePet(String id);

  /// 펫 프로필 이미지 업로드
  Future<Result<String>> uploadPetImage(String petId, String imagePath);

  /// 펫 프로필 공유 설정
  Future<Result<void>> updateSharingSettings(String petId, bool isPublic);

  /// 가족 관리자 추가
  Future<Result<void>> addFamilyManager(String petId, String userId);

  /// 가족 관리자 제거
  Future<Result<void>> removeFamilyManager(String petId, String userId);
}
