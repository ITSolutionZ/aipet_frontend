import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';
part 'user_profile_entity.g.dart';

/// 사용자 프로필 엔티티
@freezed
abstract class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String userName,
    required String email,
    String? nameKatakana,
    String? contact,
    String? profileImage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfileEntity;

  const UserProfileEntity._();

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$UserProfileEntityFromJson(json);
}
