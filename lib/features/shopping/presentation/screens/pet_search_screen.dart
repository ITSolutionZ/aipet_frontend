import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'name': 'ROYAL CANIN',
      'japaneseName': 'ロイヤルカナン',
      'logo': 'assets/images/brands/royal_canin.png',
      'isSelected': false,
    },
    {
      'name': 'HILLS',
      'japaneseName': 'ヒルズ',
      'logo': 'assets/images/brands/hills.png',
      'isSelected': false,
    },
    {
      'name': 'ORIJEN',
      'japaneseName': 'オリジン',
      'logo': 'assets/images/brands/orijen.png',
      'isSelected': false,
    },
    {
      'name': 'ACANA',
      'japaneseName': 'アカナ',
      'logo': 'assets/images/brands/acana.png',
      'isSelected': false,
    },
    {
      'name': 'ZIWI PEAK',
      'japaneseName': 'ジウィピーク',
      'logo': 'assets/images/brands/ziwi_peak.png',
      'isSelected': false,
    },
    {
      'name': 'CANIDAE',
      'japaneseName': 'カニデ',
      'logo': 'assets/images/brands/canidae.png',
      'isSelected': false,
    },
    {
      'name': 'WELLNESS',
      'japaneseName': 'ウェルネス',
      'logo': 'assets/images/brands/wellness.png',
      'isSelected': false,
    },
    {
      'name': 'BLUE BUFFALO',
      'japaneseName': 'ブルーバッファロー',
      'logo': 'assets/images/brands/blue_buffalo.png',
      'isSelected': false,
    },
    {
      'name': 'NATURAL BALANCE',
      'japaneseName': 'ナチュラルバランス',
      'logo': 'assets/images/brands/natural_balance.png',
      'isSelected': false,
    },
    {
      'name': 'NUTRO',
      'japaneseName': 'ナチュロ',
      'logo': 'assets/images/brands/nutro.png',
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
    // タブが変更された時はフィルターなしでタブの基本キーワードで検索
    final String baseKeyword = _getCurrentTabKeyword();

    final notifier = ref.read(rakutenProductsProvider.notifier);

    debugPrint('🔍 Tab changed to: $baseKeyword');
    notifier.searchPetProducts(keyword: baseKeyword);
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

    // 사용자 입력은 검색바가 없으므로 제거

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

    // フィルターをクリアした後、現在のタブの基本キーワードで再検索
    final String baseKeyword = _getCurrentTabKeyword();

    final notifier = ref.read(rakutenProductsProvider.notifier);

    debugPrint('🔍 Filters cleared, searching with: $baseKeyword');
    notifier.searchPetProducts(keyword: baseKeyword);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: ''),
      body: Column(
        children: [
          // 카테고리 탭
          _buildCategoryTabs(),

          // 메인 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 필터 섹션
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 건강 관련 필터
                        _buildFilterSection('うちの子の健康が気になりますか？', _healthFilters),
                        const SizedBox(height: AppSpacing.xl),

                        // 제조국별 필터
                        _buildFilterSection('フード製造国別で見る', _countryFilters),
                        const SizedBox(height: AppSpacing.xl),

                        // 원료 성분 필터
                        _buildFilterSection('原料成分でフードを見る', _ingredientFilters),
                        const SizedBox(height: AppSpacing.xl),

                        // 액션 버튼들
                        _buildActionButtons(),
                        const SizedBox(height: AppSpacing.xl),

                        // 인기 브랜드
                        _buildPopularBrandsSection(),
                      ],
                    ),
                  ),

                  // 상품 리스트
                  _buildProductList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 탭 구성
  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.pureWhite,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.pointBrown,
        labelColor: AppColors.pointBrown,
        unselectedLabelColor: AppColors.pointGray,
        indicatorWeight: 3,
        tabs: _categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  /// 액션 버튼들 구성
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ActionButton.primary(
            text: '適応',
            onPressed: _applyFilters,
            isEnabled: true,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ActionButton.secondary(
            foregroundColor: AppColors.pointPink,
            text: 'クリア',
            onPressed: _clearAllFilters,
            isEnabled: true,
          ),
        ),
      ],
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
  Future<void> _openProductPage(RakutenPetProduct product) async {
    try {
      debugPrint('🔗 Opening product page: ${product.itemName}');
      debugPrint('🔗 Product URL: ${product.itemUrl}');
      
      final Uri url = Uri.parse(product.itemUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // 外部ブラウザで開く
        );
        
        // 成功メッセージ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.itemName}の商品ページを開きました'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.pointBrown,
            ),
          );
        }
      } else {
        // URLを開けない場合のエラーハンドリング
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('商品ページを開けませんでした'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening product page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: filters.map((filter) {
            final isSelected = filter['isSelected'] == true;
            return GestureDetector(
              onTap: () {
                setState(() {
                  filter['isSelected'] = !filter['isSelected'];
                });
                // 필터를 적용
                _applyFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pointBrown
                      : AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.pointBrown
                        : AppColors.pointGray.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  filter['name'],
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pureWhite
                        : AppColors.pointGray,
                    fontWeight: FontWeight.w500,
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
        Text(
          '人気ブランド',
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularBrands.length,
            itemBuilder: (context, index) {
              final brand = _popularBrands[index];
              final isSelected = brand['isSelected'] == true;

              return Container(
                width: 110,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      brand['isSelected'] = !isSelected;
                    });
                    // 필터를 적용
                    _applyFilters();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.pointBrown.withValues(alpha: 0.1)
                          : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.pointBrown
                            : AppColors.pointGray.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pointBrown.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 브랜드 로고 이미지
                        Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            color: AppColors.pointOffWhite,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            child:
                                brand['logo'] != null &&
                                    brand['logo'].isNotEmpty
                                ? Image.asset(
                                    brand['logo'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.pets,
                                        color: isSelected
                                            ? AppColors.pointBrown
                                            : AppColors.pointGray,
                                        size: 30,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.pets,
                                    color: isSelected
                                        ? AppColors.pointBrown
                                        : AppColors.pointGray,
                                    size: 30,
                                  ),
                          ),
                        ),
                        // 브랜드 이름 (영문)
                        Text(
                          brand['name'],
                          style: AppFonts.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.pointBrown
                                : AppColors.pointGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // 브랜드 이름 (일본어)
                        Text(
                          brand['japaneseName'],
                          style: AppFonts.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.pointBrown
                                : AppColors.pointGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
