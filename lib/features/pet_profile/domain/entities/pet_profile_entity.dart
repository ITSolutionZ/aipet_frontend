import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_profile_entity.freezed.dart';
part 'pet_profile_entity.g.dart';

/// ペットプロフィールエンティティ
@freezed
abstract class PetProfileEntity with _$PetProfileEntity {
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
}
