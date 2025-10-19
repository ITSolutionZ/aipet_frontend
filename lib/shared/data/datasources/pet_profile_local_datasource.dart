import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';

/// 펫 프로필 로컬 데이터 소스
/// 실제 펫 프로필 데이터를 제공
class PetProfileLocalDatasource {
  /// 실제 펫 프로필 데이터 목록
  /// 현재 펫이 등록되지 않은 상태로 빈 리스트 반환
  static List<PetProfileEntity> getPetProfiles() {
    // 펫이 등록되지 않은 상태 - 빈 리스트 반환
    return [];
  }

  /// ID로 특정 펫 프로필 가져오기
  static PetProfileEntity? getPetById(String id) {
    try {
      return getPetProfiles().firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 펫 타입별 필터링
  static List<PetProfileEntity> getPetsByType(String type) {
    return getPetProfiles().where((pet) => pet.type == type).toList();
  }

  /// 활성 펫만 가져오기
  static List<PetProfileEntity> getActivePets() {
    return getPetProfiles().where((pet) => pet.isActive).toList();
  }

  /// 펫 이름으로 검색
  static List<PetProfileEntity> searchPetsByName(String query) {
    final lowerQuery = query.toLowerCase();
    return getPetProfiles()
        .where((pet) => pet.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 펫 품종별 필터링
  static List<PetProfileEntity> getPetsByBreed(String breed) {
    return getPetProfiles()
        .where((pet) => pet.breed?.toLowerCase() == breed.toLowerCase())
        .toList();
  }

  /// 최근 등록된 펫들 (최신순)
  static List<PetProfileEntity> getRecentPets({int limit = 5}) {
    final pets = getPetProfiles();
    pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return pets.take(limit).toList();
  }

  /// 펫 통계 정보
  static Map<String, dynamic> getPetStatistics() {
    final pets = getPetProfiles();

    return {
      'totalPets': pets.length,
      'activePets': pets.where((pet) => pet.isActive).length,
      'petTypes': {
        'dog': pets.where((pet) => pet.type == 'dog').length,
        'cat': pets.where((pet) => pet.type == 'cat').length,
        'rabbit': pets.where((pet) => pet.type == 'rabbit').length,
        'other': pets
            .where((pet) => !['dog', 'cat', 'rabbit'].contains(pet.type))
            .length,
      },
      'averageAge':
          pets.map((pet) => pet.age).reduce((a, b) => a + b) / pets.length,
      'averageWeight':
          pets.map((pet) => pet.weight).reduce((a, b) => a + b) / pets.length,
    };
  }

  /// 펫 추가 (시뮬레이션)
  static void addPet(PetProfileEntity pet) {
    // 실제 구현에서는 로컬 저장소에 저장
    if (kDebugMode) {
      debugPrint('펫 추가: ${pet.name} (${pet.type})');
    }
  }

  /// 펫 업데이트 (시뮬레이션)
  static void updatePet(PetProfileEntity pet) {
    // 실제 구현에서는 로컬 저장소에 업데이트
    if (kDebugMode) {
      debugPrint('펫 업데이트: ${pet.name}');
    }
  }

  /// 펫 삭제 (시뮬레이션)
  static void deletePet(String petId) {
    // 실제 구현에서는 로컬 저장소에서 삭제
    if (kDebugMode) {
      debugPrint('펫 삭제: $petId');
    }
  }

  /// 펫 이미지 경로 가져오기
  static String? getPetImagePath(String petType, String? breed) {
    switch (petType.toLowerCase()) {
      case 'dog':
        switch (breed?.toLowerCase()) {
          case 'golden retriever':
          case 'ゴールデンレトリバー':
            return 'assets/images/dogs/golden.png';
          case 'shiba':
          case '柴犬':
            return 'assets/images/dogs/shiba.png';
          case 'poodle':
          case 'プードル':
            return 'assets/images/dogs/poodle.jpg';
          case 'pomeranian':
          case 'ポメラニアン':
            return 'assets/images/dogs/pomeranian.png';
          default:
            return 'assets/images/dogs/dogs.png';
        }
      case 'cat':
        return 'assets/images/cats/cat.png';
      case 'rabbit':
        return 'assets/images/etc/rabbit.png';
      case 'bird':
        return 'assets/images/etc/bird.png';
      case 'hamster':
        return 'assets/images/etc/hamster.png';
      default:
        return 'assets/images/pets/pets.png';
    }
  }

  /// 기본 펫 정보 생성 (새 펫 등록용)
  static PetProfileEntity createDefaultPet({
    required String name,
    required String type,
    String? breed,
    required String gender,
    required double weight,
    DateTime? birthDate,
  }) {
    final now = DateTime.now();
    return PetProfileEntity(
      id: 'pet_${now.millisecondsSinceEpoch}',
      name: name,
      type: type,
      breed: breed,
      birthDate: birthDate ?? now.subtract(const Duration(days: 365)),
      gender: gender,
      weight: weight,
      imagePath: getPetImagePath(type, breed),
      ownerId: 'user1',
      createdAt: now,
      updatedAt: now,
      isActive: true,
      additionalInfo: {},
    );
  }
}
