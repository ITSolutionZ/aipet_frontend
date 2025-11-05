import 'package:freezed_annotation/freezed_annotation.dart';

part 'allergy_post_entity.freezed.dart';

/// 알레르기 커뮤니티 게시글 엔티티
@freezed
abstract class AllergyPostEntity with _$AllergyPostEntity {
  const factory AllergyPostEntity({
    /// 게시글 ID
    required String id,

    /// 작성자 ID
    required String authorId,

    /// 작성자 닉네임
    required String authorNickname,

    /// 알레르기 타입 (피부병, 눈물, 기염증, 가려움증, 털빠짐, 재채기 등)
    required AllergyType allergyType,

    /// 알레르기 발생 여부 (true: 발생, false: 미발생)
    required bool hasAllergy,

    /// 게시글 제목
    required String title,

    /// 게시글 내용
    required String content,

    /// 이미지 URL 리스트
    required List<String> imageUrls,

    /// 조회수
    required int viewCount,

    /// 댓글 수
    required int commentCount,

    /// 작성일
    required DateTime createdAt,

    /// 수정일
    DateTime? updatedAt,
  }) = _AllergyPostEntity;

  const AllergyPostEntity._();
}

/// 알레르기 타입
enum AllergyType {
  /// 피부병
  skinDisease('皮膚病'),

  /// 눈물
  tears('涙'),

  /// 귀 염증
  earInflammation('耳炎症'),

  /// 가려움증
  itching('かゆみ'),

  /// 털빠짐
  hairLoss('抜け毛'),

  /// 재채기
  sneezing('くしゃみ'),

  /// 기타
  other('その他');

  const AllergyType(this.displayName);

  /// 일본어 표시명
  final String displayName;
}
