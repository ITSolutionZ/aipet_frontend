import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/brand_entity.dart';


part 'brand_model.freezed.dart';
part 'brand_model.g.dart';

/// 브랜드 모델 (API 통신용)
@freezed
abstract class BrandModel with _$BrandModel {
  const factory BrandModel({
    required String id,
    required String name,
    required String japaneseName,
    required List<String> category,
    String? logoUrl,
    String? officialUrl,
  }) = _BrandModel;

  const BrandModel._();

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);

  /// Entity로 변환
  BrandEntity toEntity() {
    return BrandEntity(
      id: id,
      name: name,
      japaneseName: japaneseName,
      category: category,
      logoUrl: logoUrl,
      officialUrl: officialUrl,
    );
  }

  /// Entity에서 변환
  factory BrandModel.fromEntity(BrandEntity entity) {
    return BrandModel(
      id: entity.id,
      name: entity.name,
      japaneseName: entity.japaneseName,
      category: entity.category,
      logoUrl: entity.logoUrl,
      officialUrl: entity.officialUrl,
    );
  }
}
