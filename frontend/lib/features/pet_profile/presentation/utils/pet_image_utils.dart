/// 펫 이미지 관련 유틸리티 함수들
class PetImageUtils {
  PetImageUtils._();

  /// 펫 타입에 따른 기본 이미지 경로를 반환
  ///
  /// [petType] 펫 타입 ('dog', 'cat', 'bird', 'hamster', 'rabbit', 'turtle' 등)
  /// Returns 해당 펫 타입의 기본 이미지 경로
  static String getDefaultImagePath(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return 'assets/images/dogs/dogs.png';
      case 'cat':
        return 'assets/images/cats/cats.png';
      case 'bird':
        return 'assets/images/etc/bird.png';
      case 'hamster':
        return 'assets/images/etc/hamster.png';
      case 'rabbit':
        return 'assets/images/etc/rabbit.png';
      case 'turtle':
        return 'assets/images/etc/turtle.png';
      default:
        return 'assets/images/pets/default.png';
    }
  }

  /// 펫 이미지 경로를 반환 (imagePath가 null이면 기본 이미지 사용)
  ///
  /// [imagePath] 펫의 이미지 경로 (null 가능)
  /// [petType] 펫 타입
  /// Returns 실제 사용할 이미지 경로
  static String getImagePath(String? imagePath, String petType) {
    return imagePath ?? getDefaultImagePath(petType);
  }
}
