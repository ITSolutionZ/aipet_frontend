/// 펫 Mock 서비스
///
/// 펫 관련 Mock 데이터를 제공합니다.
class PetMockService {
  /// ID로 펫 정보 반환
  static Map<String, dynamic> getMockPetById(String petId) {
    return {
      'id': petId,
      'name': 'Maxi',
      'type': 'dog',
      'breed': '柴犬',
      'age': 3,
      'weight': 15.5,
      'gender': 'male',
      'birthDate': DateTime.now().subtract(const Duration(days: 1095)),
      'profileImage': 'assets/images/dogs/shiba.png',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    };
  }

  /// 모든 펫 목록 반환
  static List<Map<String, dynamic>> getAllMockPets() {
    return [
      getMockPetById('pet-1'),
      {
        'id': 'pet-2',
        'name': 'Luna',
        'type': 'cat',
        'breed': 'アメリカンショートヘア',
        'age': 2,
        'weight': 4.2,
        'gender': 'female',
        'birthDate': DateTime.now().subtract(const Duration(days: 730)),
        'profileImage': 'assets/images/cats/american_shorthair.png',
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 200)),
        'updatedAt': DateTime.now(),
      },
    ];
  }
}
