import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/allergy_post_entity.dart';

part 'allergy_post_model.freezed.dart';
part 'allergy_post_model.g.dart';

/// 알레르ギー投稿モデル (API通信用)
@freezed
class AllergyPostModel with _$AllergyPostModel {
  const factory AllergyPostModel({
    required String id,
    required String authorId,
    required String authorNickname,
    required String allergyType,
    required bool hasAllergy,
    required String title,
    required String content,
    required List<String> imageUrls,
    required int viewCount,
    required int commentCount,
    required String createdAt,
    String? updatedAt,
  }) = _AllergyPostModel;

  factory AllergyPostModel.fromJson(Map<String, dynamic> json) =>
      _$AllergyPostModelFromJson(json);

  /// Entity로 변환
  AllergyPostEntity toEntity() {
    return AllergyPostEntity(
      id: id,
      authorId: authorId,
      authorNickname: authorNickname,
      allergyType: _stringToAllergyType(allergyType),
      hasAllergy: hasAllergy,
      title: title,
      content: content,
      imageUrls: imageUrls,
      viewCount: viewCount,
      commentCount: commentCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Entity에서 변환
  factory AllergyPostModel.fromEntity(AllergyPostEntity entity) {
    return AllergyPostModel(
      id: entity.id,
      authorId: entity.authorId,
      authorNickname: entity.authorNickname,
      allergyType: entity.allergyType.name,
      hasAllergy: entity.hasAllergy,
      title: entity.title,
      content: entity.content,
      imageUrls: entity.imageUrls,
      viewCount: entity.viewCount,
      commentCount: entity.commentCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// 문자열을 AllergyType으로 변환
  AllergyType _stringToAllergyType(String type) {
    return AllergyType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => AllergyType.other,
    );
  }
}
