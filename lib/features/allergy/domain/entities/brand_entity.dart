import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_entity.freezed.dart';

/// 펫푸드 브랜드 엔티티
@freezed
class BrandEntity with _$BrandEntity {
  const factory BrandEntity({
    /// 브랜드 ID
    required String id,

    /// 브랜드명 (영문)
    required String name,

    /// 브랜드명 (일본어)
    required String japaneseName,

    /// 카테고리 (dog, cat)
    required List<String> category,

    /// 로고 URL
    String? logoUrl,

    /// 공식 사이트 URL
    String? officialUrl,
  }) = _BrandEntity;
}
