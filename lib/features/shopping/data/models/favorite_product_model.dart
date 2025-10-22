/// お気に入り商品モデル
class FavoriteProduct {
  final String itemCode;
  final String itemName;
  final String imageUrl;
  final int itemPrice;
  final String shopName;
  final String itemUrl;
  final String? reviewAverage;
  final String? reviewCount;
  final DateTime addedAt;

  const FavoriteProduct({
    required this.itemCode,
    required this.itemName,
    required this.imageUrl,
    required this.itemPrice,
    required this.shopName,
    required this.itemUrl,
    this.reviewAverage,
    this.reviewCount,
    required this.addedAt,
  });

  /// JSONからFavoriteProductを作成
  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      itemCode: json['itemCode']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      itemPrice: json['itemPrice'] ?? 0,
      shopName: json['shopName']?.toString() ?? '',
      itemUrl: json['itemUrl']?.toString() ?? '',
      reviewAverage: json['reviewAverage']?.toString(),
      reviewCount: json['reviewCount']?.toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'imageUrl': imageUrl,
      'itemPrice': itemPrice,
      'shopName': shopName,
      'itemUrl': itemUrl,
      'reviewAverage': reviewAverage,
      'reviewCount': reviewCount,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// 価格をフォーマット
  String get formattedPrice {
    return '¥${itemPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// レビュー平均をフォーマット
  String get formattedReviewAverage {
    if (reviewAverage == null || reviewAverage!.isEmpty) return '0.0';
    final double? rating = double.tryParse(reviewAverage!);
    if (rating == null) return '0.0';
    return rating.toStringAsFixed(1);
  }

  /// レビュー数をフォーマット
  String get formattedReviewCount {
    if (reviewCount == null || reviewCount!.isEmpty) return '0';
    final int? count = int.tryParse(reviewCount!);
    if (count == null) return '0';
    return count.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteProduct && other.itemCode == itemCode;
  }

  @override
  int get hashCode => itemCode.hashCode;
}
