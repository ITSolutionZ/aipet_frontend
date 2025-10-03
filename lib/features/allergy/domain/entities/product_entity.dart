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

    /// 카테고리 (사료, 영양제, 간식, 생식)
    required String category,
  }) = _ProductEntity;
}
