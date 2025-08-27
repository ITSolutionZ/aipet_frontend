import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/repositories/pet_profile_repository.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  // 메모리 기반 저장소 (MockDataService의 데이터로 초기화)
  late final List<PetProfileEntity> _profiles;

  PetProfileRepositoryImpl() {
    // MockDataService에서 초기 데이터 로드
    _profiles = List.from(MockDataService.getMockPetProfiles());
  }

  @override
  Future<PetProfileEntity> getPetProfile(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      try {
        return _profiles.firstWhere((profile) => profile.id == petId);
      } catch (e) {
        throw Exception('펫 프로필을 찾을 수 없습니다');
      }
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<PetProfileEntity> updatePetProfile(PetProfileEntity pet) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      final index = _profiles.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        _profiles[index] = pet;
        return pet;
      }
      throw Exception('펫 프로필을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<String> uploadPetImage(String petId, String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (MockDataService.isEnabled) {
      return 'https://example.com/images/$petId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> updateSharingSettings(String petId, bool isPublic) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      final index = _profiles.indexWhere((p) => p.id == petId);
      if (index != -1) {
        final profile = _profiles[index];
        final updatedInfo = Map<String, dynamic>.from(
          profile.additionalInfo ?? {},
        );
        updatedInfo['isPublic'] = isPublic;

        _profiles[index] = profile.copyWith(
          additionalInfo: updatedInfo,
          updatedAt: DateTime.now(),
        );
        return;
      }
      throw Exception('펫 프로필을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> addFamilyManager(String petId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      final index = _profiles.indexWhere((p) => p.id == petId);
      if (index != -1) {
        final profile = _profiles[index];
        final updatedInfo = Map<String, dynamic>.from(
          profile.additionalInfo ?? {},
        );
        final managers = List<String>.from(updatedInfo['familyManagers'] ?? []);

        if (!managers.contains(userId)) {
          managers.add(userId);
          updatedInfo['familyManagers'] = managers;

          _profiles[index] = profile.copyWith(
            additionalInfo: updatedInfo,
            updatedAt: DateTime.now(),
          );
        }
        return;
      }
      throw Exception('펫 프로필을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> removeFamilyManager(String petId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      final index = _profiles.indexWhere((p) => p.id == petId);
      if (index != -1) {
        final profile = _profiles[index];
        final updatedInfo = Map<String, dynamic>.from(
          profile.additionalInfo ?? {},
        );
        final managers = List<String>.from(updatedInfo['familyManagers'] ?? []);

        managers.remove(userId);
        updatedInfo['familyManagers'] = managers;

        _profiles[index] = profile.copyWith(
          additionalInfo: updatedInfo,
          updatedAt: DateTime.now(),
        );
        return;
      }
      throw Exception('펫 프로필을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }
}
