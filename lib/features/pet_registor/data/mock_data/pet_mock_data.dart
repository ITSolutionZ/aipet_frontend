import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_service.dart';

/// ⚠️ DEPRECATED: 중복 Mock 데이터 클래스
///
/// 이 클래스는 중앙화된 PetMockService로 대체되었습니다.
/// 새로운 코드에서는 PetMockService를 직접 사용하세요.
///
/// 마이그레이션 예시:
/// ```dart
/// // Before (DEPRECATED)
/// PetMockData.getDogBreeds()
///
/// // After (RECOMMENDED)
/// PetMockService.getMockDogBreeds()
/// ```
@Deprecated('Use PetMockService instead')
class PetMockData {
  /// Mock 강아지 품종 데이터
  @Deprecated('Use PetMockService.getMockDogBreeds() instead')
  static List<Map<String, dynamic>> getDogBreeds() {
    return PetMockService.getMockDogBreeds()
        .map((breed) => {'id': breed['id'], 'name': breed['koreanName'], 'size': breed['size']})
        .toList();
  }

  /// Mock 고양이 품종 데이터
  @Deprecated('Use PetMockService.getCatBreeds() instead')
  static List<Map<String, dynamic>> getCatBreeds() {
    return PetMockService.getCatBreeds()
        .map(
          (breed) => {
            'id': breed.toLowerCase().replaceAll(' ', '_'),
            'name': breed,
            'size': 'medium',
          },
        )
        .toList();
  }

  /// Mock 펫 크기 데이터
  @Deprecated('Use PetMockService.getPetStatusOptions() instead')
  static List<Map<String, dynamic>> getPetSizes() {
    return [
      {'id': 'small', 'name': '小型', 'minWeight': 1.0, 'maxWeight': 10.0},
      {'id': 'medium', 'name': '中型', 'minWeight': 10.0, 'maxWeight': 25.0},
      {'id': 'large', 'name': '大型', 'minWeight': 25.0, 'maxWeight': 50.0},
    ];
  }

  /// Mock 성별 데이터
  @Deprecated('Use PetMockService.getMockPetTypes() instead')
  static List<Map<String, dynamic>> getGenders() {
    return [
      {'id': 'male', 'name': 'オス'},
      {'id': 'female', 'name': 'メス'},
    ];
  }

  /// Mock 펫 데이터 반환
  @Deprecated('Use PetMockService.getMockPets() instead')
  static List<Map<String, dynamic>> getMockPets() {
    return PetMockService.getMockPets();
  }
}
