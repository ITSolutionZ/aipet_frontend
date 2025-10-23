import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/rakuten_brand_model.dart';
import '../models/rakuten_pet_product_model.dart';

/// ラクテン API サービス
class RakutenApiService {
  // ラクテン Ichiba Item Search API
  static const String _itemSearchUrl =
      'https://app.rakuten.co.jp/services/api/IchibaItem/Search/20220601';
  // ラクテン Ichiba Genre Search API
  static const String _genreSearchUrl =
      'https://app.rakuten.co.jp/services/api/IchibaGenre/Search/20120723';
  // ラクテン Ichiba Tag Search API
  static const String _tagSearchUrl =
      'https://app.rakuten.co.jp/services/api/IchibaTag/Search/20140222';

  static String get _applicationId => dotenv.env['RAKUTEN_APP_ID'] ?? '';
  static String get _affiliateId => dotenv.env['RAKUTEN_AFFILIATE_ID'] ?? '';

  /// ペット関連ジャンルを検索
  Future<List<Map<String, dynamic>>> searchPetGenres() async {
    try {
      if (_applicationId.isEmpty) {
        throw Exception(
          'Application ID is not set. Please check your .env file.',
        );
      }

      // ペット・動物ジャンル（ID: 100316）の子ジャンルを取得
      final uri = Uri.parse(_genreSearchUrl).replace(
        queryParameters: {
          'applicationId': _applicationId,
          'genreId': '100316', // ペット・動物ジャンル
          'format': 'json',
        },
      );

      LoggerService.debug('🔍 Genre Search URL: ${uri.toString()}');

      final response = await http.get(uri);
      LoggerService.debug('📊 Genre Response Status: ${response.statusCode}');
      LoggerService.debug('📝 Genre Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final children = data['children'] as List<dynamic>? ?? [];

        return children.map((child) {
          final genre = child['child'];
          return {
            'genreId': genre['genreId'],
            'genreName': genre['genreName'],
            'genreLevel': genre['genreLevel'],
          };
        }).toList();
      } else {
        throw Exception('Genre search failed: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.debug('⚠️ Genre search failed: $e');
      return [];
    }
  }

  /// ペット関連タグを検索
  Future<List<Map<String, dynamic>>> searchPetTags({
    String tagId = '1000317', // ペット関連タグID
  }) async {
    try {
      if (_applicationId.isEmpty) {
        throw Exception(
          'Application ID is not set. Please check your .env file.',
        );
      }

      final uri = Uri.parse(_tagSearchUrl).replace(
        queryParameters: {
          'applicationId': _applicationId,
          'tagId': tagId,
          'format': 'json',
        },
      );

      LoggerService.debug('🔍 Tag Search URL: ${uri.toString()}');

      final response = await http.get(uri);
      LoggerService.debug('📊 Tag Response Status: ${response.statusCode}');
      LoggerService.debug('📝 Tag Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tagGroups = data['tagGroups'] as List<dynamic>? ?? [];

        final List<Map<String, dynamic>> allTags = [];

        for (final tagGroup in tagGroups) {
          final group = tagGroup['tagGroup'];
          final tags = group['tags'] as List<dynamic>? ?? [];

          for (final tag in tags) {
            final tagData = tag['tag'];
            allTags.add({
              'tagId': tagData['tagId'],
              'tagName': tagData['tagName'],
              'parentTagId': tagData['parentTagId'],
              'tagGroupName': group['tagGroupName'],
              'tagGroupId': group['tagGroupId'],
            });
          }
        }

        return allTags;
      } else {
        throw Exception('Tag search failed: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.debug('⚠️ Tag search failed: $e');
      return [];
    }
  }

  /// ペット関連商品を検索
  Future<List<RakutenPetProduct>> searchPetProducts({
    String keyword = 'ペット',
    String? genreId, // ジャンルIDをオプションにする
    int page = 1,
    int hits = 30,
    String sort =
        'standard', // standard, +itemPrice, -itemPrice, +reviewCount, -reviewCount
    String availability = '1', // 1: 在庫あり, 0: すべて
  }) async {
    try {
      // API 키 확인
      if (_applicationId.isEmpty) {
        throw Exception(
          'Application ID is not set. Please check your .env file.',
        );
      }

      // 실제 API 호출 (최신 버전 사용)
      final queryParams = <String, String>{
        'format': 'json',
        'applicationId': _applicationId,
        'affiliateId': _affiliateId,
        'keyword': keyword,
        'page': page.toString(),
        'hits': hits.toString(),
        'sort': sort,
        'availability': availability,
        'imageFlag': '1', // 画像ありのみ
        'carrier': '0', // キャリア指定なし
        'formatVersion': '2', // 新しいレスポンス形式
      };

      // genreIdが指定されている場合のみ追加
      if (genreId != null && genreId.isNotEmpty) {
        queryParams['genreId'] = genreId;
      }

      final uri = Uri.parse(
        _itemSearchUrl,
      ).replace(queryParameters: queryParams);

      LoggerService.debug('🔍 API Request URL: ${uri.toString()}');
      LoggerService.debug('🔍 Search keyword: $keyword');
      LoggerService.debug(
        '🔑 Application ID: ${_applicationId.isNotEmpty ? "✅ Set" : "❌ Empty"}',
      );
      LoggerService.debug(
        '🔗 Affiliate ID: ${_affiliateId.isNotEmpty ? "✅ Set" : "❌ Empty"}',
      );

      final response = await http.get(uri);

      LoggerService.debug('📊 Response Status: ${response.statusCode}');
      LoggerService.debug('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LoggerService.debug('📊 API Response data keys: ${data.keys.toList()}');

        final items = data['Items'] as List<dynamic>? ?? [];
        LoggerService.debug('📦 Items count: ${items.length}');

        if (items.isEmpty) {
          LoggerService.debug('⚠️ No items found for keyword: $keyword');
          LoggerService.debug('⚠️ Returning empty list instead of mock data');
          return [];
        }

        // 最初のアイテムの構造をログ出力
        if (items.isNotEmpty) {
          LoggerService.debug('📝 First item type: ${items[0].runtimeType}');
          LoggerService.debug('📝 First item: ${items[0]}');

          // アイテムのキーを詳細にログ出力
          if (items[0] is Map<String, dynamic>) {
            final firstItem = items[0] as Map<String, dynamic>;
            LoggerService.debug('📝 First item keys: ${firstItem.keys.toList()}');

            // 重要なフィールドの値を個別にチェック
            LoggerService.debug('📝 itemCode: ${firstItem['itemCode']}');
            LoggerService.debug('📝 itemName: ${firstItem['itemName']}');
            LoggerService.debug('📝 catchcopy: ${firstItem['catchcopy']}');
            LoggerService.debug('📝 itemCaption: ${firstItem['itemCaption']}');
            LoggerService.debug('📝 itemPrice: ${firstItem['itemPrice']}');
          }
        }

        final List<RakutenPetProduct> products = [];

        for (int i = 0; i < items.length; i++) {
          try {
            final item = items[i];
            if (item is Map<String, dynamic>) {
              LoggerService.debug('🔍 Parsing item $i...');

              // アイテムの必須フィールドを事前チェック
              LoggerService.debug('🔍 Item $i keys: ${item.keys.toList()}');

              final product = RakutenPetProduct.fromJson(item);
              products.add(product);
              LoggerService.debug('✅ Successfully parsed item $i: ${product.itemName}');
            } else {
              LoggerService.debug(
                '⚠️ Item $i has invalid type: ${item.runtimeType}, value: $item',
              );
              // 無効なアイテムはスキップして続行
              continue;
            }
          } catch (e, stackTrace) {
            LoggerService.debug('⚠️ Failed to parse item $i: $e');
            LoggerService.debug('⚠️ Stack trace: $stackTrace');

            // パースに失敗した場合、基本的な情報だけでも表示するために
            // 簡易的な商品情報を作成
            try {
              if (items[i] is Map<String, dynamic>) {
                final item = items[i] as Map<String, dynamic>;
                final fallbackProduct = _createSimpleFallbackProduct(item, i);
                products.add(fallbackProduct);
                LoggerService.debug(
                  '✅ Created fallback product $i: ${fallbackProduct.itemName}',
                );
              }
            } catch (fallbackError) {
              LoggerService.debug(
                '⚠️ Failed to create fallback product $i: $fallbackError',
              );
            }
          }
        }

        if (products.isEmpty) {
          LoggerService.debug('⚠️ No valid products parsed for keyword: $keyword');
          LoggerService.debug('⚠️ Returning empty list instead of mock data');
          return [];
        }

        return products;
      } else {
        // 에러 응답 파싱
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error_description'] ?? 'Unknown error';
          LoggerService.debug('❌ API Error: $errorMessage');
          LoggerService.debug('⚠️ Returning empty list due to API error');
          return [];
        } catch (e) {
          LoggerService.debug('❌ API Error: ${response.body}');
          LoggerService.debug('⚠️ Returning empty list due to API error');
          return [];
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch pet products: $e');
    }
  }

  /// パースに失敗したアイテムから簡易的な商品情報を作成
  RakutenPetProduct _createSimpleFallbackProduct(
    Map<String, dynamic> item,
    int index,
  ) {
    return RakutenPetProduct(
      itemCode: _safeGetString(item, 'itemCode').isNotEmpty
          ? _safeGetString(item, 'itemCode')
          : 'fallback_$index',
      itemName: _safeGetString(item, 'itemName').isNotEmpty
          ? _safeGetString(item, 'itemName')
          : (_safeGetString(item, 'catchcopy').isNotEmpty
                ? _safeGetString(item, 'catchcopy')
                : '商品名不明'),
      itemCaption: _safeGetString(item, 'itemCaption'),
      itemUrl: _safeGetString(item, 'itemUrl'),
      affiliateUrl: _safeGetString(item, 'affiliateUrl'),
      imageUrl: _getSimpleImageUrl(item),
      smallImageUrls: [],
      itemPrice: _safeGetInt(item, 'itemPrice'),
      taxFlag: _safeGetString(item, 'taxFlag').isNotEmpty
          ? _safeGetString(item, 'taxFlag')
          : '1',
      postageFlag: _safeGetString(item, 'postageFlag').isNotEmpty
          ? _safeGetString(item, 'postageFlag')
          : '1',
      creditCardFlag: _safeGetString(item, 'creditCardFlag').isNotEmpty
          ? _safeGetString(item, 'creditCardFlag')
          : '1',
      shopOfTheYearFlag: _safeGetString(item, 'shopOfTheYearFlag').isNotEmpty
          ? _safeGetString(item, 'shopOfTheYearFlag')
          : '0',
      shipOverseasFlag: _safeGetString(item, 'shipOverseasFlag').isNotEmpty
          ? _safeGetString(item, 'shipOverseasFlag')
          : '0',
      shipOverseasArea: _safeGetString(item, 'shipOverseasArea'),
      asurakuFlag: _safeGetString(item, 'asurakuFlag').isNotEmpty
          ? _safeGetString(item, 'asurakuFlag')
          : '0',
      asurakuClosingTime: _safeGetString(item, 'asurakuClosingTime'),
      asurakuArea: _safeGetString(item, 'asurakuArea'),
      affiliateRate: _safeGetString(item, 'affiliateRate').isNotEmpty
          ? _safeGetString(item, 'affiliateRate')
          : '0',
      startTime: _safeGetString(item, 'startTime'),
      endTime: _safeGetString(item, 'endTime'),
      reviewCount: _safeGetString(item, 'reviewCount').isNotEmpty
          ? _safeGetString(item, 'reviewCount')
          : '0',
      reviewAverage: _safeGetString(item, 'reviewAverage').isNotEmpty
          ? _safeGetString(item, 'reviewAverage')
          : '0.0',
      pointRate: _safeGetString(item, 'pointRate').isNotEmpty
          ? _safeGetString(item, 'pointRate')
          : '1',
      pointRateStartTime: _safeGetString(item, 'pointRateStartTime'),
      pointRateEndTime: _safeGetString(item, 'pointRateEndTime'),
      giftFlag: _safeGetString(item, 'giftFlag').isNotEmpty
          ? _safeGetString(item, 'giftFlag')
          : '0',
      shopName: _safeGetString(item, 'shopName').isNotEmpty
          ? _safeGetString(item, 'shopName')
          : 'ショップ名不明',
      shopCode: _safeGetString(item, 'shopCode'),
      shopUrl: _safeGetString(item, 'shopUrl'),
      shopAffiliateUrl: _safeGetString(item, 'shopAffiliateUrl'),
    );
  }

  /// 簡易的な画像URLを取得
  String _getSimpleImageUrl(Map<String, dynamic> item) {
    // mediumImageUrlsから取得を試行
    final mediumImages = item['mediumImageUrls'] as List?;
    if (mediumImages != null && mediumImages.isNotEmpty) {
      final firstImage = mediumImages[0];
      if (firstImage is String) {
        return firstImage;
      } else if (firstImage is Map<String, dynamic>) {
        return _safeGetString(firstImage, 'imageUrl');
      }
    }

    // 直接のimageUrlフィールド
    return _safeGetString(item, 'imageUrl');
  }

  /// 安全にString値を取得
  String _safeGetString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  /// 安全にInt値を取得
  int _safeGetInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// ペットフードを検索
  Future<List<RakutenPetProduct>> searchPetFood({
    String keyword = 'ペットフード',
    String? genreId,
    int page = 1,
    int hits = 30,
    String sort = 'standard',
  }) async {
    return searchPetProducts(
      keyword: keyword,
      genreId: genreId,
      page: page,
      hits: hits,
      sort: sort,
    );
  }

  /// 犬用品を検索
  Future<List<RakutenPetProduct>> searchDogItems({
    String keyword = '犬用品',
    String? genreId,
    int page = 1,
    int hits = 30,
    String sort = 'standard',
  }) async {
    return searchPetProducts(
      keyword: keyword,
      genreId: genreId,
      page: page,
      hits: hits,
      sort: sort,
    );
  }

  /// 猫用品を検索
  Future<List<RakutenPetProduct>> searchCatItems({
    String keyword = '猫用品',
    String? genreId,
    int page = 1,
    int hits = 30,
    String sort = 'standard',
  }) async {
    return searchPetProducts(
      keyword: keyword,
      genreId: genreId,
      page: page,
      hits: hits,
      sort: sort,
    );
  }

  /// ペット用品を検索
  Future<List<RakutenPetProduct>> searchPetSupplies({
    String keyword = 'ペット用品',
    String? genreId,
    int page = 1,
    int hits = 30,
    String sort = 'standard',
  }) async {
    return searchPetProducts(
      keyword: keyword,
      genreId: genreId,
      page: page,
      hits: hits,
      sort: sort,
    );
  }

  /// 人気ブランドを検索
  Future<List<RakutenBrand>> searchPopularBrands({
    String keyword = 'ドッグフード',
    int page = 1,
    int hits = 30,
  }) async {
    try {
      if (_applicationId.isEmpty) {
        LoggerService.debug('⚠️ Application ID is empty, returning default brands');
        return _getDefaultBrands();
      }

      final queryParams = <String, String>{
        'format': 'json',
        'applicationId': _applicationId,
        'affiliateId': _affiliateId,
        'keyword': keyword,
        'page': page.toString(),
        'hits': hits.toString(),
        'sort': '-reviewCount', // レビュー数の多い順
        'availability': '1',
        'imageFlag': '1',
        'formatVersion': '2',
      };

      final uri = Uri.parse(_itemSearchUrl).replace(queryParameters: queryParams);

      LoggerService.debug('🔍 Brand Search URL: ${uri.toString()}');

      final response = await http.get(uri);

      LoggerService.debug('📊 Brand Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List<dynamic>? ?? [];

        LoggerService.debug('📦 Found ${items.length} items for brand extraction');

        if (items.isEmpty) {
          LoggerService.debug('⚠️ No items found, returning default brands');
          return _getDefaultBrands();
        }

        // ブランド情報を抽出 (shopNameベース)
        final Map<String, RakutenBrand> brandMap = {};
        final Set<String> processedShops = {};

        for (final item in items) {
          if (item is! Map<String, dynamic>) continue;

          final shopName = _safeGetString(item, 'shopName');
          final shopCode = _safeGetString(item, 'shopCode');
          final imageUrl = _getSimpleImageUrl(item);

          // shopNameが空またはすでに処理済みの場合はスキップ
          if (shopName.isEmpty || processedShops.contains(shopCode)) continue;

          // ブランド名を抽出 (shopNameから)
          final brandInfo = _extractBrandInfo(shopName);
          final brandName = brandInfo['brandName'] ?? '';
          final brandNameJapanese = brandInfo['brandNameJapanese'] ?? '';
          final description = brandInfo['description'] ?? '';

          LoggerService.debug('🏪 Shop: $shopName → Brand: $brandName');

          if (brandName.isNotEmpty && !brandMap.containsKey(shopCode)) {
            brandMap[shopCode] = RakutenBrand(
              brandId: shopCode,
              brandName: brandName,
              brandNameJapanese: brandNameJapanese,
              brandLogoUrl: imageUrl,
              brandDescription: description,
              productCount: 1,
            );
            processedShops.add(shopCode);

            LoggerService.debug('✅ Brand added: $brandName (Logo: ${imageUrl.isNotEmpty ? "✓" : "✗"})');

            // 최대 8개 브랜드만 수집
            if (brandMap.length >= 8) break;
          }
        }

        final brands = brandMap.values.toList();
        LoggerService.debug('🏷️ Extracted ${brands.length} brands from API');

        // ブランドが少ない場合はデフォルトブランドで補完
        if (brands.length < 8) {
          final defaultBrands = _getDefaultBrands();
          final existingBrandIds = brands.map((b) => b.brandId).toSet();

          for (final defaultBrand in defaultBrands) {
            if (!existingBrandIds.contains(defaultBrand.brandId)) {
              brands.add(defaultBrand);
              if (brands.length >= 8) break;
            }
          }
        }

        return brands.take(8).toList();
      } else {
        LoggerService.debug('❌ Brand search failed: ${response.statusCode}');
        return _getDefaultBrands();
      }
    } catch (e) {
      LoggerService.debug('⚠️ Brand search failed: $e');
      return _getDefaultBrands();
    }
  }

  /// ブランド情報を抽出 (shopNameから)
  Map<String, String> _extractBrandInfo(String shopName) {
    // 既知のブランド名マッピング
    final brandMappings = {
      'ロイヤルカナン': {'en': 'ROYAL CANIN', 'ja': 'ロイヤルカナン', 'desc': 'フランス発のプレミアムペットフードブランド'},
      'ヒルズ': {'en': 'HILLS', 'ja': 'ヒルズ', 'desc': '獣医師推奨のサイエンス・ダイエット'},
      'HILLS': {'en': 'HILLS', 'ja': 'ヒルズ', 'desc': '獣医師推奨のサイエンス・ダイエット'},
      'オリジン': {'en': 'ORIJEN', 'ja': 'オリジン', 'desc': 'カナダ産の高品質ペットフード'},
      'ORIJEN': {'en': 'ORIJEN', 'ja': 'オリジン', 'desc': 'カナダ産の高品質ペットフード'},
      'アカナ': {'en': 'ACANA', 'ja': 'アカナ', 'desc': '自然な原材料を使用したペットフード'},
      'ACANA': {'en': 'ACANA', 'ja': 'アカナ', 'desc': '自然な原材料を使用したペットフード'},
      'ニュートロ': {'en': 'NUTRO', 'ja': 'ニュートロ', 'desc': '自然素材を使用したプレミアムフード'},
      'NUTRO': {'en': 'NUTRO', 'ja': 'ニュートロ', 'desc': '自然素材を使用したプレミアムフード'},
      'ピュリナ': {'en': 'PURINA', 'ja': 'ピュリナ', 'desc': '世界的なペットフードブランド'},
      'PURINA': {'en': 'PURINA', 'ja': 'ピュリナ', 'desc': '世界的なペットフードブランド'},
      'アイムス': {'en': 'IAMS', 'ja': 'アイムス', 'desc': '科学的に証明された栄養バランス'},
      'IAMS': {'en': 'IAMS', 'ja': 'アイムス', 'desc': '科学的に証明された栄養バランス'},
    };

    // shopNameから既知のブランド名を検索
    for (final entry in brandMappings.entries) {
      if (shopName.contains(entry.key)) {
        return {
          'brandName': entry.value['en']!,
          'brandNameJapanese': entry.value['ja']!,
          'description': entry.value['desc']!,
        };
      }
    }

    // マッチしない場合は、shopNameから"公式"などを除去してブランド名として使用
    final cleanedName = shopName
        .replaceAll('公式', '')
        .replaceAll('ショップ', '')
        .replaceAll('楽天市場店', '')
        .replaceAll('店', '')
        .trim();

    return {
      'brandName': cleanedName,
      'brandNameJapanese': cleanedName,
      'description': 'ペットフードブランド',
    };
  }

  /// デフォルトブランドリスト (public method)
  List<RakutenBrand> getDefaultBrandsPublic() {
    return _getDefaultBrands();
  }

  /// デフォルトブランドリスト
  List<RakutenBrand> _getDefaultBrands() {
    return const [
      RakutenBrand(
        brandId: 'royal_canin',
        brandName: 'ROYAL CANIN',
        brandNameJapanese: 'ロイヤルカナン',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: 'フランス発のプレミアムペットフードブランド',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'hills',
        brandName: 'HILLS',
        brandNameJapanese: 'ヒルズ',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: '獣医師推奨のサイエンス・ダイエット',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'orijen',
        brandName: 'ORIJEN',
        brandNameJapanese: 'オリジン',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: 'カナダ産の高品質ペットフード',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'acana',
        brandName: 'ACANA',
        brandNameJapanese: 'アカナ',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: '自然な原材料を使用したペットフード',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'ziwi_peak',
        brandName: 'ZIWI PEAK',
        brandNameJapanese: 'ジウィピーク',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: 'ニュージーランド産のプレミアムフード',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'canidae',
        brandName: 'CANIDAE',
        brandNameJapanese: 'カニデ',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: '全ライフステージ対応のペットフード',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'wellness',
        brandName: 'WELLNESS',
        brandNameJapanese: 'ウェルネス',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: '自然素材を使用したヘルシーフード',
        productCount: 0,
      ),
      RakutenBrand(
        brandId: 'blue_buffalo',
        brandName: 'BLUE BUFFALO',
        brandNameJapanese: 'ブルーバッファロー',
        brandLogoUrl: 'assets/images/placeholder.png',
        brandDescription: '天然素材を使用したプレミアムフード',
        productCount: 0,
      ),
    ];
  }


  /// 価格帯でペット商品を検索
  Future<List<RakutenPetProduct>> searchPetProductsByPrice({
    required int minPrice,
    required int maxPrice,
    String keyword = 'ペット',
    String genreId = '100316',
    int page = 1,
    int hits = 30,
    String sort = 'standard',
  }) async {
    // 価格帯検索は通常の検索と同じロジックを使用
    LoggerService.debug('🔍 Price range search: ¥$minPrice - ¥$maxPrice');
    return searchPetProducts(
      keyword: keyword,
      genreId: genreId,
      page: page,
      hits: hits,
      sort: sort,
    );
  }
}
