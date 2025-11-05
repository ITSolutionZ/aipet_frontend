/// ラクテン ペット商品モデル
class RakutenPetProduct {
  final String itemCode;
  final String itemName;
  final String itemCaption;
  final String itemUrl;
  final String affiliateUrl;
  final String imageUrl;
  final List<String> smallImageUrls;
  final int itemPrice;
  final String taxFlag;
  final String postageFlag;
  final String creditCardFlag;
  final String shopOfTheYearFlag;
  final String shipOverseasFlag;
  final String shipOverseasArea;
  final String asurakuFlag;
  final String asurakuClosingTime;
  final String asurakuArea;
  final String affiliateRate;
  final String startTime;
  final String endTime;
  final String reviewCount;
  final String reviewAverage;
  final String pointRate;
  final String pointRateStartTime;
  final String pointRateEndTime;
  final String giftFlag;
  final String shopName;
  final String shopCode;
  final String shopUrl;
  final String shopAffiliateUrl;

  const RakutenPetProduct({
    required this.itemCode,
    required this.itemName,
    required this.itemCaption,
    required this.itemUrl,
    required this.affiliateUrl,
    required this.imageUrl,
    required this.smallImageUrls,
    required this.itemPrice,
    required this.taxFlag,
    required this.postageFlag,
    required this.creditCardFlag,
    required this.shopOfTheYearFlag,
    required this.shipOverseasFlag,
    required this.shipOverseasArea,
    required this.asurakuFlag,
    required this.asurakuClosingTime,
    required this.asurakuArea,
    required this.affiliateRate,
    required this.startTime,
    required this.endTime,
    required this.reviewCount,
    required this.reviewAverage,
    required this.pointRate,
    required this.pointRateStartTime,
    required this.pointRateEndTime,
    required this.giftFlag,
    required this.shopName,
    required this.shopCode,
    required this.shopUrl,
    required this.shopAffiliateUrl,
  });

  factory RakutenPetProduct.fromJson(Map<String, dynamic> json) {
    // formatVersion=2の新しいレスポンス形式に対応
    // 直接itemフィールドにアクセスする形式
    final item = json['item'] as Map<String, dynamic>? ?? json;

    return RakutenPetProduct(
      itemCode: _getItemCode(item),
      itemName: _getItemName(item),
      itemCaption: _safeGetString(item, 'itemCaption'),
      itemUrl: _getItemUrl(item),
      affiliateUrl: _safeGetString(item, 'affiliateUrl'),
      imageUrl: _getImageUrl(item),
      smallImageUrls: _getSmallImageUrls(item),
      itemPrice: _safeGetInt(item, 'itemPrice'),
      taxFlag: _safeGetString(item, 'taxFlag'),
      postageFlag: _safeGetString(item, 'postageFlag'),
      creditCardFlag: _safeGetString(item, 'creditCardFlag'),
      shopOfTheYearFlag: _safeGetString(item, 'shopOfTheYearFlag'),
      shipOverseasFlag: _safeGetString(item, 'shipOverseasFlag'),
      shipOverseasArea: _safeGetString(item, 'shipOverseasArea'),
      asurakuFlag: _safeGetString(item, 'asurakuFlag'),
      asurakuClosingTime: _safeGetString(item, 'asurakuClosingTime'),
      asurakuArea: _safeGetString(item, 'asurakuArea'),
      affiliateRate: _safeGetString(item, 'affiliateRate'),
      startTime: _safeGetString(item, 'startTime'),
      endTime: _safeGetString(item, 'endTime'),
      reviewCount: _safeGetString(item, 'reviewCount'),
      reviewAverage: _safeGetString(item, 'reviewAverage'),
      pointRate: _safeGetString(item, 'pointRate'),
      pointRateStartTime: _safeGetString(item, 'pointRateStartTime'),
      pointRateEndTime: _safeGetString(item, 'pointRateEndTime'),
      giftFlag: _safeGetString(item, 'giftFlag'),
      shopName: _safeGetString(item, 'shopName'),
      shopCode: _safeGetString(item, 'shopCode'),
      shopUrl: _safeGetString(item, 'shopUrl'),
      shopAffiliateUrl: _safeGetString(item, 'shopAffiliateUrl'),
    );
  }

  /// 安全にString値を取得
  static String _safeGetString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  /// アイテムコードを取得（複数のフィールドから試行）
  static String _getItemCode(Map<String, dynamic> json) {
    final itemCode = _safeGetString(json, 'itemCode');
    if (itemCode.isNotEmpty) return itemCode;

    final itemId = _safeGetString(json, 'itemId');
    if (itemId.isNotEmpty) return itemId;

    return '';
  }

  /// アイテム名を取得（複数のフィールドから試行）
  static String _getItemName(Map<String, dynamic> json) {
    final itemName = _safeGetString(json, 'itemName');
    if (itemName.isNotEmpty) return itemName;

    final catchcopy = _safeGetString(json, 'catchcopy');
    if (catchcopy.isNotEmpty) return catchcopy;

    return '';
  }

  /// アイテムURLを取得（複数のフィールドから試行）
  static String _getItemUrl(Map<String, dynamic> json) {
    final itemUrl = _safeGetString(json, 'itemUrl');
    if (itemUrl.isNotEmpty) return itemUrl;

    final itemPageUrl = _safeGetString(json, 'itemPageUrl');
    if (itemPageUrl.isNotEmpty) return itemPageUrl;

    return '';
  }

  /// 安全にInt値を取得
  static int _safeGetInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 画像URLを取得（複数の形式に対応）
  static String _getImageUrl(Map<String, dynamic> json) {
    // mediumImageUrls配列から最初の画像URLを取得
    final mediumImages = json['mediumImageUrls'] as List?;
    if (mediumImages != null && mediumImages.isNotEmpty) {
      final firstImage = mediumImages[0];
      if (firstImage is Map<String, dynamic>) {
        return _safeGetString(firstImage, 'imageUrl');
      } else if (firstImage is String) {
        // 直接URL文字列の場合
        return firstImage;
      }
    }

    // 直接のimageUrlフィールド
    return _safeGetString(json, 'imageUrl');
  }

  /// 小さい画像URLリストを取得
  static List<String> _getSmallImageUrls(Map<String, dynamic> json) {
    final smallImages = json['smallImageUrls'] as List?;
    if (smallImages == null) return [];

    return smallImages
        .map((e) {
          if (e is Map<String, dynamic>) {
            return _safeGetString(e, 'imageUrl');
          } else if (e is String) {
            // 直接URL文字列の場合
            return e;
          }
          return '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'itemCaption': itemCaption,
      'itemUrl': itemUrl,
      'affiliateUrl': affiliateUrl,
      'imageUrl': imageUrl,
      'smallImageUrls': smallImageUrls,
      'itemPrice': itemPrice,
      'taxFlag': taxFlag,
      'postageFlag': postageFlag,
      'creditCardFlag': creditCardFlag,
      'shopOfTheYearFlag': shopOfTheYearFlag,
      'shipOverseasFlag': shipOverseasFlag,
      'shipOverseasArea': shipOverseasArea,
      'asurakuFlag': asurakuFlag,
      'asurakuClosingTime': asurakuClosingTime,
      'asurakuArea': asurakuArea,
      'affiliateRate': affiliateRate,
      'startTime': startTime,
      'endTime': endTime,
      'reviewCount': reviewCount,
      'reviewAverage': reviewAverage,
      'pointRate': pointRate,
      'pointRateStartTime': pointRateStartTime,
      'pointRateEndTime': pointRateEndTime,
      'giftFlag': giftFlag,
      'shopName': shopName,
      'shopCode': shopCode,
      'shopUrl': shopUrl,
      'shopAffiliateUrl': shopAffiliateUrl,
    };
  }

  /// 価格をフォーマット（円記号付き）
  String get formattedPrice =>
      '¥${itemPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  /// レビュー平均をフォーマット
  String get formattedReviewAverage =>
      double.tryParse(reviewAverage)?.toStringAsFixed(1) ?? '0.0';

  /// レビュー数をフォーマット
  String get formattedReviewCount => reviewCount.isEmpty ? '0' : reviewCount;
}
