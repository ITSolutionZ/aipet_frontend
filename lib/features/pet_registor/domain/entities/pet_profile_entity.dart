import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_profile_entity.freezed.dart';

/// ペットプロフィールエンティティ
@freezed
class PetProfileEntity with _$PetProfileEntity {
  const factory PetProfileEntity({
    required String id,
    required String name,
    required String type, // 'dog', 'cat', 'bird', 'hamster', 'rabbit', 'turtle'
    String? breed,
    required DateTime birthDate,
    required String gender,
    required double weight,
    String? imagePath,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
    Map<String, dynamic>? additionalInfo,
  }) = _PetProfileEntity;

  const PetProfileEntity._();

  /// 펫 나이 계산 (생년월일 기준)
  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// 펫 타입 일본어명
  String get typeName {
    switch (type.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'hamster':
        return 'ハムスター';
      case 'rabbit':
        return 'うさぎ';
      case 'turtle':
        return '亀';
      default:
        return 'ペット';
    }
  }

  /// 펫 타입 아이콘
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'hamster':
        return '🐹';
      case 'rabbit':
        return '🐰';
      case 'turtle':
        return '🐢';
      default:
        return '🐾';
    }
  }
}
