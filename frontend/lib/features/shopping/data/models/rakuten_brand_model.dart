/// ラクテン ブランドモデル
class RakutenBrand {
  final String brandId;
  final String brandName;
  final String brandNameJapanese;
  final String brandLogoUrl;
  final String brandDescription;
  final int productCount;
  final bool isSelected;

  const RakutenBrand({
    required this.brandId,
    required this.brandName,
    required this.brandNameJapanese,
    required this.brandLogoUrl,
    required this.brandDescription,
    required this.productCount,
    this.isSelected = false,
  });

  /// JSONからRakutenBrandを作成
  factory RakutenBrand.fromJson(Map<String, dynamic> json) {
    return RakutenBrand(
      brandId: json['brandId']?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? '',
      brandNameJapanese: json['brandNameJapanese']?.toString() ?? '',
      brandLogoUrl: json['brandLogoUrl']?.toString() ?? '',
      brandDescription: json['brandDescription']?.toString() ?? '',
      productCount: json['productCount'] ?? 0,
      isSelected: json['isSelected'] ?? false,
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'brandId': brandId,
      'brandName': brandName,
      'brandNameJapanese': brandNameJapanese,
      'brandLogoUrl': brandLogoUrl,
      'brandDescription': brandDescription,
      'productCount': productCount,
      'isSelected': isSelected,
    };
  }

  /// コピー（選択状態変更用）
  RakutenBrand copyWith({
    String? brandId,
    String? brandName,
    String? brandNameJapanese,
    String? brandLogoUrl,
    String? brandDescription,
    int? productCount,
    bool? isSelected,
  }) {
    return RakutenBrand(
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      brandNameJapanese: brandNameJapanese ?? this.brandNameJapanese,
      brandLogoUrl: brandLogoUrl ?? this.brandLogoUrl,
      brandDescription: brandDescription ?? this.brandDescription,
      productCount: productCount ?? this.productCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() {
    return 'RakutenBrand(brandId: $brandId, brandName: $brandName, brandNameJapanese: $brandNameJapanese, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RakutenBrand && other.brandId == brandId;
  }

  @override
  int get hashCode => brandId.hashCode;
}
