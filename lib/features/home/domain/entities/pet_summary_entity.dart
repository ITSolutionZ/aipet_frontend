/// 홈 대시보드에서 사용하는 펫 요약 정보
/// 
/// 다른 feature의 entity에 직접 의존하지 않도록 독립적으로 정의
class PetSummaryEntity {
  final String id;
  final String name;
  final String typeName;
  final String? breed;
  final int age;
  final DateTime birthDate;
  final DateTime createdAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? additionalInfo;

  const PetSummaryEntity({
    required this.id,
    required this.name,
    required this.typeName,
    this.breed,
    required this.age,
    required this.birthDate,
    required this.createdAt,
    this.profileImageUrl,
    this.additionalInfo,
  });

  /// 펫 종류별 아이콘 코드 반환
  String get typeIcon {
    switch (typeName.toLowerCase()) {
      case 'dog':
      case '개':
        return '🐕';
      case 'cat':
      case '고양이':
        return '🐱';
      default:
        return '🐾';
    }
  }

  /// 나이대별 카테고리 반환
  String get ageCategory {
    if (age < 1) return 'puppy';
    if (age < 8) return 'adult';
    return 'senior';
  }
}