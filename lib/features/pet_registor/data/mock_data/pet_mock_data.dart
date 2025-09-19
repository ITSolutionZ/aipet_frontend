/// 펫 Mock 데이터
///
/// 펫 등록 관련 Mock 데이터를 제공합니다.
class PetMockData {
  /// Mock 강아지 품종 데이터
  static List<Map<String, dynamic>> getDogBreeds() {
    return [
      {'id': 'shiba', 'name': '柴犬', 'size': 'medium'},
      {'id': 'golden_retriever', 'name': 'ゴールデンレトリバー', 'size': 'large'},
      {'id': 'chihuahua', 'name': 'チワワ', 'size': 'small'},
      {'id': 'poodle', 'name': 'プードル', 'size': 'medium'},
      {'id': 'custom', 'name': 'その他', 'size': 'unknown'},
    ];
  }

  /// Mock 고양이 품종 데이터
  static List<Map<String, dynamic>> getCatBreeds() {
    return [
      {'id': 'american_shorthair', 'name': 'アメリカンショートヘア', 'size': 'medium'},
      {'id': 'persian', 'name': 'ペルシャ', 'size': 'medium'},
      {'id': 'maine_coon', 'name': 'メインクーン', 'size': 'large'},
      {'id': 'british_shorthair', 'name': 'ブリティッシュショートヘア', 'size': 'medium'},
      {'id': 'custom', 'name': 'その他', 'size': 'unknown'},
    ];
  }

  /// Mock 펫 크기 데이터
  static List<Map<String, dynamic>> getPetSizes() {
    return [
      {'id': 'small', 'name': '小型', 'minWeight': 1.0, 'maxWeight': 10.0},
      {'id': 'medium', 'name': '中型', 'minWeight': 10.0, 'maxWeight': 25.0},
      {'id': 'large', 'name': '大型', 'minWeight': 25.0, 'maxWeight': 50.0},
    ];
  }

  /// Mock 성별 데이터
  static List<Map<String, dynamic>> getGenders() {
    return [
      {'id': 'male', 'name': 'オス'},
      {'id': 'female', 'name': 'メス'},
    ];
  }

  /// Mock 펫 데이터 반환
  static List<Map<String, dynamic>> getMockPets() {
    return [
      {
        'id': 'pet-1',
        'name': 'Maxi',
        'type': 'dog',
        'breed': '柴犬',
        'weight': 15.5,
        'gender': 'male',
        'birthDate': DateTime.now()
            .subtract(const Duration(days: 1095))
            .toIso8601String(),
        'imagePath': 'assets/images/dogs/shiba.png',
        'ownerId': 'user-1',
        'isActive': true,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'pet-2',
        'name': 'Luna',
        'type': 'cat',
        'breed': 'アメリカンショートヘア',
        'weight': 4.2,
        'gender': 'female',
        'birthDate': DateTime.now()
            .subtract(const Duration(days: 730))
            .toIso8601String(),
        'imagePath': 'assets/images/cats/american_shorthair.png',
        'ownerId': 'user-1',
        'isActive': true,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 200))
            .toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
  }
}
