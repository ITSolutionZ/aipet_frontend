import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_profile_entity.freezed.dart';
part 'pet_profile_entity.g.dart';

/// 🐾 統合ペットプロフィールエンティティ
///
/// ## 設計原則
/// - Single Source of Truth: 全機能で共通使用
/// - Freezed + JSON Serialization: 完全対応
/// - Backward Compatibility: 既存コード互換性保証
/// - Rich Domain Logic: ビジネスロジック内包
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
    String? size, // Pet Profile 기능용 추가 필드
    String? microchipNumber, // Pet Profile 기능용 추가 필드
    DateTime? arrivalDate, // Pet Profile 기능용 추가 필드
    bool? neutered, // Pet Profile 기능용 추가 필드
    String? imagePath,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
    Map<String, dynamic>? additionalInfo,
  }) = _PetProfileEntity;

  /// JSON 직렬화를 위한 팩토리 생성자
  factory PetProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$PetProfileEntityFromJson(json);
}

/// PetProfileEntity 확장 메서드
extension PetProfileEntityX on PetProfileEntity {
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

  /// Pet Registration 호환용 - 기본 필드만 사용하는 경우
  PetProfileEntity copyWithBasicFields() {
    return PetProfileEntity(
      id: id,
      name: name,
      type: type,
      breed: breed,
      birthDate: birthDate,
      gender: gender,
      weight: weight,
      imagePath: imagePath,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      additionalInfo: additionalInfo,
    );
  }

  /// Pet Profile 호환용 - 확장 필드 포함
  PetProfileEntity copyWithExtendedFields({
    String? size,
    String? microchipNumber,
    DateTime? arrivalDate,
    bool? neutered,
  }) {
    return copyWith(
      size: size ?? this.size,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      neutered: neutered ?? this.neutered,
    );
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
