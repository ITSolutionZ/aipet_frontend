import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product_entity.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// 제품 모델 (API 통신용)
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required int price,
    required String brandId,
    required String category,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Entity로 변환
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      brandId: brandId,
      category: category,
    );
  }

  /// Entity에서 변환
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      brandId: entity.brandId,
      category: entity.category,
    );
  }
}
