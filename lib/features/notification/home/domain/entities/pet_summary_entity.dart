import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_summary_entity.freezed.dart';

/// 홈 대시보드에서 사용하는 펫 요약 정보
///
/// 다른 feature의 entity에 직접 의존하지 않도록 독립적으로 정의
@freezed
class PetSummaryEntity with _$PetSummaryEntity {
  const factory PetSummaryEntity({
    required String id,
    required String name,
    required String typeName,
    String? breed,
    required int age,
    required DateTime birthDate,
    required DateTime createdAt,
    String? profileImageUrl,
    Map<String, dynamic>? additionalInfo,
  }) = _PetSummaryEntity;

  const PetSummaryEntity._();

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
