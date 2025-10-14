import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';

/// 제품 엔티티
@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    /// 제품 ID
    required String id,

    /// 제품명
    required String name,

    /// 가격 (엔화)
    required int price,

    /// 브랜드 ID
    required String brandId,

    /// カテゴリ（フード、サプリメント、おやつ、生食）
    required String category,

    /// 성분 목록 (optional)
    String? ingredients,

    /// 브랜드 객체 (optional)
    @Default(null) dynamic brand,

    /// 평점 (optional)
    double? rating,

    /// 상품 이미지 URL (optional)
    String? imageUrl,
  }) = _ProductEntity;
}
