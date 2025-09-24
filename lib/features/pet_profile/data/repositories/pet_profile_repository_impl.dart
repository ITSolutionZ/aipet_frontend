// Pet Profile Repository Implementation
import 'package:aipet_frontend/features/onboarding/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/models/pet_profile_model.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_data.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  // 메모리 기반 저장소 (통합된 PetMockData 사용)
  late final List<PetProfileModel> _profileModels;

  PetProfileRepositoryImpl() {
    // 통합된 PetMockData에서 초기 데이터를 Model로 변환하여 로드
    final mockData = PetMockData.getMockPets();
    _profileModels = mockData
        .map((entity) => PetProfileModel.fromLegacyEntity(entity))
        .toList();
  }

  // 테스트용 메서드
  void addTestProfile(PetProfileEntity profile) {
    _profileModels.add(PetProfileModel.fromDomainEntity(profile));
  }

  @override
  Future<PetProfileEntity> getPetProfile(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final profileModel = _profileModels.firstWhere(
        (model) => model.id == petId,
      );
      return profileModel.toDomainEntity();
    } catch (e) {
      throw Exception('펫 프로필을 찾을 수 없습니다');
    }
  }

  @override
  Future<PetProfileEntity> updatePetProfile(PetProfileEntity pet) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _profileModels.indexWhere((model) => model.id == pet.id);
    if (index != -1) {
      _profileModels[index] = PetProfileModel.fromDomainEntity(
        pet.copyWith(updatedAt: DateTime.now()),
      );
      return _profileModels[index].toDomainEntity();
    }
    throw Exception('펫 프로필을 찾을 수 없습니다');
  }

  @override
  Future<String> uploadPetImage(String petId, String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock image upload
    return 'https://example.com/images/$petId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  @override
  Future<void> updateSharingSettings(String petId, bool isPublic) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _profileModels.indexWhere((model) => model.id == petId);
    if (index != -1) {
      final currentModel = _profileModels[index];
      final currentEntity = currentModel.toDomainEntity();

      final updatedSharingSettings = currentEntity.sharingSettings.copyWith(
        allowSharing: isPublic,
      );

      final updatedVisibilityLevel = isPublic
          ? ProfileVisibilityLevel.public
          : ProfileVisibilityLevel.private;

      final updatedEntity = currentEntity.copyWith(
        sharingSettings: updatedSharingSettings,
        visibilityLevel: updatedVisibilityLevel,
        updatedAt: DateTime.now(),
      );

      _profileModels[index] = PetProfileModel.fromDomainEntity(updatedEntity);
      return;
    }
    throw Exception('펫 프로필을 찾을 수 없습니다');
  }

  @override
  Future<void> addFamilyManager(String petId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _profileModels.indexWhere((model) => model.id == petId);
    if (index != -1) {
      final currentModel = _profileModels[index];
      final currentEntity = currentModel.toDomainEntity();

      final updatedManagers = List<String>.from(currentEntity.familyManagerIds);
      if (!updatedManagers.contains(userId)) {
        updatedManagers.add(userId);

        final updatedEntity = currentEntity.copyWith(
          familyManagerIds: updatedManagers,
          updatedAt: DateTime.now(),
        );

        _profileModels[index] = PetProfileModel.fromDomainEntity(updatedEntity);
      }
      return;
    }
    throw Exception('펫 프로필을 찾을 수 없습니다');
  }

  @override
  Future<void> removeFamilyManager(String petId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _profileModels.indexWhere((model) => model.id == petId);
    if (index != -1) {
      final currentModel = _profileModels[index];
      final currentEntity = currentModel.toDomainEntity();

      final updatedManagers = List<String>.from(currentEntity.familyManagerIds);
      updatedManagers.remove(userId);

      final updatedEntity = currentEntity.copyWith(
        familyManagerIds: updatedManagers,
        updatedAt: DateTime.now(),
      );

      _profileModels[index] = PetProfileModel.fromDomainEntity(updatedEntity);
      return;
    }
    throw Exception('펫 프로필을 찾을 수 없습니다');
  }
}
