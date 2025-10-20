import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/rakuten_pet_product_model.dart';
import '../../data/providers/rakuten_products_provider.dart';

/// ペット商品検索画面
class PetSearchScreen extends ConsumerStatefulWidget {
  const PetSearchScreen({super.key});

  @override
  ConsumerState<PetSearchScreen> createState() => _PetSearchScreenState();
}

class _PetSearchScreenState extends ConsumerState<PetSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // アコーディオン状態管理
  final Set<String> _expandedProducts = <String>{};

  final List<String> _categories = [
    'ペットフード',
    'ペットサプリメント',
    'ペットおやつ',
    'ペット用品',
    'ペットトイ',
    'ペットケア用品',
    'ペット服',
    'ペットアクセサリー',
  ];

  final List<Map<String, dynamic>> _healthFilters = [
    {'name': '子犬おすすめフード', 'isSelected': false},
    {'name': '子猫おすすめフード', 'isSelected': false},
    {'name': '乳酸菌たっぷりフード', 'isSelected': false},
    {'name': 'ヘアボール防止フード', 'isSelected': false},
  ];

  final List<Map<String, dynamic>> _countryFilters = [
    {'name': 'ペット先進国', 'isSelected': false},
    {'name': 'カナダ産', 'isSelected': false},
    {'name': 'アメリカ産', 'isSelected': false},
    {'name': 'ドイツ産', 'isSelected': false},
    {'name': 'スペイン産', 'isSelected': false},
    {'name': 'フランス産', 'isSelected': false},
    {'name': 'イギリス産', 'isSelected': false},
    {'name': 'イタリア産', 'isSelected': false},
  ];

  final List<Map<String, dynamic>> _ingredientFilters = [
    {'name': '大豆不使用フード', 'isSelected': false},
    {'name': '単一タンパク質', 'isSelected': false},
    {'name': '低タンパク・低リン', 'isSelected': false},
    {'name': 'ナトリウム制限', 'isSelected': false},
    {'name': '便秘予防', 'isSelected': false},
  ];

  final List<Map<String, dynamic>> _popularBrands = [
    {
      'name': 'CARNA4',
      'japaneseName': 'カルナ4',
      'logo': 'assets/images/placeholder.png', // placeholder 이미지 사용
      'isSelected': false,
    },
    {
      'name': 'BEST BREED',
      'japaneseName': 'ベストブリード',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
    {
      'name': 'Gutsy',
      'japaneseName': 'ガッツィ',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
    {
      'name': 'BELCANDO',
      'japaneseName': 'ベルカンド',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
    {
      'name': 'PLATINUM',
      'japaneseName': 'プラチナム',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
    {
      'name': 'ROYAL CANIN',
      'japaneseName': 'ロイヤルカナン',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
    {
      'name': 'ORIJEN',
      'japaneseName': 'オリジン',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
    {
      'name': 'Hills',
      'japaneseName': 'ヒルズ',
      'logo': 'assets/images/placeholder.png',
      'isSelected': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);

    // タブ変更リスナーを追加
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });

    // 初期データを読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTabChanged(0);
    });
  }

  void _onTabChanged(int index) {
    // タブが変更された時はフィルターなしでタブの基本キーワード + ユーザー入力で検索
    final String baseKeyword = _getCurrentTabKeyword();
    final userInput = _searchController.text.trim();

    String keyword = baseKeyword;
    if (userInput.isNotEmpty) {
      keyword = '$baseKeyword $userInput';
    }

    final notifier = ref.read(rakutenProductsProvider.notifier);

    debugPrint('🔍 Tab changed to: $keyword');
    debugPrint('🔍 User input: ${userInput.isEmpty ? "なし" : userInput}');
    notifier.searchPetProducts(keyword: keyword);
  }

  /// 現在のタブの基本キーワードを取得
  String _getCurrentTabKeyword() {
    switch (_tabController.index) {
      case 0: // ペットフード
        return 'ドッグフード';
      case 1: // ペットサプリメント
        return 'ペット サプリメント';
      case 2: // ペットおやつ
        return 'ペット おやつ';
      case 3: // ペット用品
        return 'ペット用品';
      case 4: // ペットトイ
        return 'ペット トイ';
      case 5: // ペットケア用品
        return 'ペット ケア用品';
      case 6: // ペット服
        return 'ペット 服';
      case 7: // ペットアクセサリー
        return 'ペット アクセサリー';
      default:
        return 'ドッグフード';
    }
  }

  /// フィルターを適用して検索
  void _applyFilters() {
    final notifier = ref.read(rakutenProductsProvider.notifier);

    // 現在のタブの基本キーワードを取得
    final String baseKeyword = _getCurrentTabKeyword();

    // 選択されたフィルターを収集
    final List<String> selectedFilters = [];

    // 健康関連フィルター
    for (final filter in _healthFilters) {
      if (filter['isSelected'] == true) {
        selectedFilters.add(filter['name']);
      }
    }

    // 製造国フィルター
    for (final filter in _countryFilters) {
      if (filter['isSelected'] == true) {
        selectedFilters.add(filter['name']);
      }
    }

    // 原料成分フィルター
    for (final filter in _ingredientFilters) {
      if (filter['isSelected'] == true) {
        selectedFilters.add(filter['name']);
      }
    }

    // 人気ブランドフィルター
    for (final brand in _popularBrands) {
      if (brand['isSelected'] == true) {
        selectedFilters.add(brand['name']);
      }
    }

    // 検索キーワードを構築: タブ名 + ユーザー入力 + フィルター1 + フィルター2 + ...
    final List<String> allKeywords = [baseKeyword];

    // ユーザーが検索バーに入力した内容を追加
    final userInput = _searchController.text.trim();
    if (userInput.isNotEmpty) {
      allKeywords.add(userInput);
    }

    // フィルターキーワードを最適化
    for (final filter in selectedFilters) {
      switch (filter) {
        case 'スペイン産':
          allKeywords.add('スペイン');
          break;
        case 'フランス産':
          allKeywords.add('フランス');
          break;
        case 'アメリカ産':
          allKeywords.add('アメリカ');
          break;
        case 'ドイツ産':
          allKeywords.add('ドイツ');
          break;
        case 'カナダ産':
          allKeywords.add('カナダ');
          break;
        case 'イギリス産':
          allKeywords.add('イギリス');
          break;
        case 'イタリア産':
          allKeywords.add('イタリア');
          break;
        default:
          allKeywords.add(filter);
          break;
      }
    }

    final keyword = allKeywords.join(' ');

    debugPrint('🔍 Applying filters with keyword: $keyword');
    debugPrint('🔍 Base keyword from tab: $baseKeyword');
    debugPrint('🔍 User input: ${userInput.isEmpty ? "なし" : userInput}');
    debugPrint('🔍 Selected filters: $selectedFilters');
    debugPrint('🔍 Filter count: ${selectedFilters.length}');

    // 各 필터 타입별로 선택된 항목들을 로깅
    for (final filter in _healthFilters) {
      if (filter['isSelected'] == true) {
        debugPrint('🔍 Health filter selected: ${filter['name']}');
      }
    }
    for (final filter in _countryFilters) {
      if (filter['isSelected'] == true) {
        debugPrint('🔍 Country filter selected: ${filter['name']}');
      }
    }
    for (final filter in _ingredientFilters) {
      if (filter['isSelected'] == true) {
        debugPrint('🔍 Ingredient filter selected: ${filter['name']}');
      }
    }
    for (final brand in _popularBrands) {
      if (brand['isSelected'] == true) {
        debugPrint('🔍 Brand filter selected: ${brand['name']}');
      }
    }

    // 常に検索を実行（フィルターがなくてもタブの基本キーワードで検索）
    notifier.searchPetProducts(keyword: keyword);

    // スナックバーでフィルター適用を通知
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedFilters.isNotEmpty
              ? '${selectedFilters.length}個のフィルターを適用しました'
              : 'フィルターをクリアしました',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  /// すべてのフィルターをクリア
  void _clearAllFilters() {
    setState(() {
      // 健康関連フィルターをクリア
      for (final filter in _healthFilters) {
        filter['isSelected'] = false;
      }

      // 製造国フィルターをクリア
      for (final filter in _countryFilters) {
        filter['isSelected'] = false;
      }

      // 原料成分フィルターをクリア
      for (final filter in _ingredientFilters) {
        filter['isSelected'] = false;
      }

      // 人気ブランドフィルターをクリア
      for (final brand in _popularBrands) {
        brand['isSelected'] = false;
      }
    });

    // フィルターをクリアした後、現在のタブの基本キーワード + ユーザー入力で再検索
    final String baseKeyword = _getCurrentTabKeyword();
    final userInput = _searchController.text.trim();

    String keyword = baseKeyword;
    if (userInput.isNotEmpty) {
      keyword = '$baseKeyword $userInput';
    }

    final notifier = ref.read(rakutenProductsProvider.notifier);

    debugPrint('🔍 Filters cleared, searching with: $keyword');
    debugPrint('🔍 User input: ${userInput.isEmpty ? "なし" : userInput}');
    notifier.searchPetProducts(keyword: keyword);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべてのフィルターをクリアしました'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF1E3A8A),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '検索ワードを入力してください',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  // 検索アイコンタップで検索実行
                  _applyFilters();
                },
                child: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            onSubmitted: (value) {
              // Enterキーで検索実行
              _applyFilters();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリータブ
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.red,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.grey,
                tabs: _categories
                    .map((category) => Tab(text: category))
                    .toList(),
              ),
            ),

            // フィルターセクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 健康心配フィルター
                  _buildFilterSection('うちの子の健康が気になりますか？', _healthFilters),
                  const SizedBox(height: 24),

                  // 製造国別フィルター
                  _buildFilterSection('フード製造国別で見る', _countryFilters),
                  const SizedBox(height: 24),

                  // 原料成分フィルター
                  _buildFilterSection('原料成分でフードを見る', _ingredientFilters),
                  const SizedBox(height: 24),

                  // フィルターボタン
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _applyFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'フィルターを適用して検索',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _clearAllFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'フィルターをクリア',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 人気ブランド
                  _buildPopularBrandsSection(),
                ],
              ),
            ),

            // 商品リスト
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    final productsState = ref.watch(rakutenProductsProvider);

    if (productsState.isLoading && productsState.products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (productsState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: AppFonts.titleMedium.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productsState.error!,
                textAlign: TextAlign.center,
                style: AppFonts.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(rakutenProductsProvider.notifier).clearError();
                  _onTabChanged(_tabController.index);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    if (productsState.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '商品が見つかりませんでした',
                style: AppFonts.titleMedium.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '検索条件を変更して再度お試しください',
                style: AppFonts.bodyMedium.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _clearAllFilters();
                },
                child: const Text('フィルターをクリア'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '検索結果 (${productsState.products.length}件)',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productsState.products.length,
            itemBuilder: (context, index) {
              final product = productsState.products[index];
              return _buildProductListItem(product);
            },
          ),
          if (productsState.hasMore) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: productsState.isLoading
                    ? null
                    : () {
                        ref.read(rakutenProductsProvider.notifier).loadMore();
                      },
                child: productsState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('もっと見る'),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProductListItem(RakutenPetProduct product) {
    final isExpanded = _expandedProducts.contains(product.itemCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // メイン商品情報
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedProducts.remove(product.itemCode);
                } else {
                  _expandedProducts.add(product.itemCode);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 商品画像
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.pets,
                                  size: 30,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.pets,
                              size: 30,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 商品情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.itemName,
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.formattedPrice,
                          style: AppFonts.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointBrown,
                          ),
                        ),
                        if (product.reviewCount.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.formattedReviewAverage,
                                style: AppFonts.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.formattedReviewCount})',
                                style: AppFonts.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 展開アイコン
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // アコーディオン詳細情報
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // 商品説明
                  if (product.itemCaption.isNotEmpty) ...[
                    _buildDetailRow('商品説明', product.itemCaption),
                    const SizedBox(height: 8),
                  ],

                  // ショップ情報
                  if (product.shopName.isNotEmpty) ...[
                    _buildDetailRow('ショップ', product.shopName),
                    const SizedBox(height: 8),
                  ],

                  // 配送情報
                  _buildDetailRow(
                    '送料',
                    product.postageFlag == '1' ? '送料込み' : '送料別',
                  ),
                  const SizedBox(height: 8),

                  // 決済情報
                  _buildDetailRow(
                    '決済',
                    product.creditCardFlag == '1' ? 'クレジットカード対応' : 'その他決済',
                  ),
                  const SizedBox(height: 8),

                  // レビュー詳細
                  if (product.reviewCount.isNotEmpty) ...[
                    _buildDetailRow(
                      'レビュー',
                      '${product.formattedReviewCount}件 (平均${product.formattedReviewAverage})',
                    ),
                    const SizedBox(height: 8),
                  ],

                  // アクションボタン
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 商品ページへ移動
                            _openProductPage(product);
                          },
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('商品ページ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pointBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // お気に入り追加
                            _addToFavorites(product);
                          },
                          icon: const Icon(Icons.favorite_border, size: 16),
                          label: const Text('お気に入り'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.pointBrown,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 詳細情報行を構築
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  /// 商品ページを開く
  void _openProductPage(RakutenPetProduct product) {
    // 商品ページを開く処理（簡易実装）
    debugPrint('🔗 Opening product page: ${product.itemName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.itemName}の商品ページを開きます'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.pointBrown,
      ),
    );
  }

  /// お気に入りに追加
  void _addToFavorites(RakutenPetProduct product) {
    // お気に入り追加処理（簡易実装）
    debugPrint('⭐ Added to favorites: ${product.itemName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.itemName}をお気に入りに追加しました'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.pointBrown,
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Map<String, dynamic>> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((filter) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  filter['isSelected'] = !filter['isSelected'];
                });
                // フィルターを適用
                _applyFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: filter['isSelected']
                      ? Colors.blue[100]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: filter['isSelected']
                      ? Border.all(color: Colors.blue, width: 1)
                      : null,
                ),
                child: Text(
                  filter['name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: filter['isSelected']
                        ? Colors.blue[800]
                        : Colors.black87,
                    fontWeight: filter['isSelected']
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '人気ブランド',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _popularBrands.length,
          itemBuilder: (context, index) {
            final brand = _popularBrands[index];
            final isSelected = brand['isSelected'] == true;

            return GestureDetector(
              onTap: () {
                setState(() {
                  brand['isSelected'] = !isSelected;
                });
                // フィルターを適用
                _applyFilters();
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: brand['logo'] != null
                          ? Image.asset(
                              brand['logo'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.pets,
                                  size: 30,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.pets,
                              size: 30,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brand['japaneseName'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.blue[800] : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
