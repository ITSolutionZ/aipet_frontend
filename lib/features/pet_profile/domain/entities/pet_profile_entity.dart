import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_profile_entity.freezed.dart';
part 'pet_profile_entity.g.dart';

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
    String? size,
    String? microchipNumber,
    DateTime? arrivalDate,
    bool? neutered,
    String? imagePath,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
    Map<String, dynamic>? additionalInfo,
  }) = _PetProfileEntity;

  const PetProfileEntity._();

  /// JSON 직렬화를 위한 팩토리 생성자
  factory PetProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$PetProfileEntityFromJson(json);

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

  /// 권장 산책 시간 (분 단위)
  int get recommendedWalkTime {
    // 개 타입일 경우
    if (type.toLowerCase() == 'dog') {
      // 크기와 몸무게에 따라 산책 시간 결정
      if (size != null) {
        switch (size!.toLowerCase()) {
          case 'small': // 소형견 (< 10kg)
            return 30;
          case 'medium': // 중형견 (10-25kg)
            return 45;
          case 'large': // 대형견 (> 25kg)
            return 60;
        }
      }

      // size가 없으면 몸무게로 판단
      if (weight < 10) {
        return 30; // 소형견
      } else if (weight < 25) {
        return 45; // 중형견
      } else {
        return 60; // 대형견
      }
    }

    // 고양이
    if (type.toLowerCase() == 'cat') {
      return 20;
    }

    // 기타 동물
    return 15;
  }
}
