import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/favorite_product_model.dart';
import '../../data/models/rakuten_pet_product_model.dart';
import '../../data/providers/favorite_products_provider.dart';
import '../../data/providers/rakuten_brands_provider.dart';
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
  // 商品説明の展開状態管理 (商品コード -> 展開状態)
  final Map<String, bool> _expandedDescriptions = <String, bool>{};

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
    {'name': 'カナダ産', 'isSelected': false},
    {'name': 'アメリカ産', 'isSelected': false},
    {'name': 'ドイツ産', 'isSelected': false},
    {'name': 'スペイン産', 'isSelected': false},
    {'name': 'フランス産', 'isSelected': false},
    {'name': 'イギリス産', 'isSelected': false},
    {'name': 'イタリア産', 'isSelected': false},
    {'name': '日本産', 'isSelected': false},
    {'name': '韓国産', 'isSelected': false},
  ];

  final List<Map<String, dynamic>> _ingredientFilters = [
    {'name': '大豆不使用フード', 'isSelected': false},
    {'name': '単一タンパク質', 'isSelected': false},
    {'name': '低タンパク・低リン', 'isSelected': false},
    {'name': 'ナトリウム制限', 'isSelected': false},
    {'name': '便秘予防', 'isSelected': false},
  ];

  final List<Map<String, dynamic>> _petTypeFilters = [
    {'name': '犬', 'keyword': 'ドッグ', 'isSelected': false},
    {'name': '猫', 'keyword': 'キャット', 'isSelected': false},
    {'name': '小動物', 'keyword': '小動物', 'isSelected': false},
    {'name': '鳥', 'keyword': '鳥', 'isSelected': false},
  ];

  // ブランド情報はAPIから取得するため、ローカルリストを削除

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
      // ブランド情報は _onTabChanged 内で検索されるため、ここでは不要
    });
  }

  void _onTabChanged(int index) {
    // タブが変更された時はフィルターなしでタブの基本キーワードで検索
    final String baseKeyword = _getCurrentTabKeyword();

    final notifier = ref.read(rakutenProductsProvider.notifier);

    LoggerService.debug('🔍 Tab changed to: $baseKeyword');
    notifier.searchPetProducts(keyword: baseKeyword);

    // タブに対応するブランドを検索
    ref
        .read(rakutenBrandsProvider.notifier)
        .searchPopularBrands(keyword: baseKeyword);
  }

  /// 現在のタブの基本キーワードを取得
  String _getCurrentTabKeyword() {
    switch (_tabController.index) {
      case 0: // ペットフード
        return 'ペットフード';
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
        return 'ペットフード';
    }
  }

  /// フィルターを適用して検索 (AND条件)
  void _applyFilters() {
    // キーボードを閉じる
    FocusScope.of(context).unfocus();

    final notifier = ref.read(rakutenProductsProvider.notifier);

    // 1. 現在のタブの基本キーワードを取得 (必須)
    final String baseKeyword = _getCurrentTabKeyword();

    // 2. チップフィルターを収集 (健康/国/成分)
    final List<String> chipFilters = [];

    // 健康関連フィルター
    for (final filter in _healthFilters) {
      if (filter['isSelected'] == true) {
        chipFilters.add(filter['name']);
      }
    }

    // 製造国フィルター
    for (final filter in _countryFilters) {
      if (filter['isSelected'] == true) {
        chipFilters.add(filter['name']);
      }
    }

    // 原料成分フィルター
    for (final filter in _ingredientFilters) {
      if (filter['isSelected'] == true) {
        chipFilters.add(filter['name']);
      }
    }

    // 3. ブランドフィルターを収集
    final brandState = ref.read(rakutenBrandsProvider);
    final List<String> selectedBrands = [];

    for (final brand in brandState.brands) {
      if (brand.isSelected) {
        selectedBrands.add(brand.brandName);
      }
    }

    // 4. 検索キーワードを構築 (AND条件): タブ名 + ユーザー入力 + チップフィルター + ブランド
    final List<String> allKeywords = [];

    // 4-1. タブ名 (必須)
    allKeywords.add(baseKeyword);

    // 4-2. ユーザー入力の検索ワード (オプション)
    final String userInput = _searchController.text.trim();
    if (userInput.isNotEmpty) {
      allKeywords.add(userInput);
    }

    // 4-3. ペット種類フィルターを追加
    for (final filter in _petTypeFilters) {
      if (filter['isSelected'] == true) {
        allKeywords.add(filter['keyword']);
      }
    }

    // 4-4. チップフィルターを最適化して追加
    for (final filter in chipFilters) {
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
        case '日本産':
          allKeywords.add('日本');
          break;
        case '韓国産':
          allKeywords.add('韓国');
          break;
        default:
          allKeywords.add(filter);
          break;
      }
    }

    // 4-5. ブランド名を最適化して追加
    for (final brandName in selectedBrands) {
      switch (brandName) {
        case 'ROYAL CANIN':
          allKeywords.add('ロイヤルカナン');
          break;
        case 'HILLS':
          allKeywords.add('ヒルズ');
          break;
        case 'ORIJEN':
          allKeywords.add('オリジン');
          break;
        case 'ACANA':
          allKeywords.add('アカナ');
          break;
        case 'NUTRO':
          allKeywords.add('ニュートロ');
          break;
        case 'PURINA':
          allKeywords.add('ピュリナ');
          break;
        case 'IAMS':
          allKeywords.add('アイムス');
          break;
        default:
          allKeywords.add(brandName);
          break;
      }
    }

    // 5. AND条件でキーワードを結合 (スペース区切り)
    final keyword = allKeywords.join(' ');

    // 6. デバッグログ
    LoggerService.debug('═══════════════════════════════════════');
    LoggerService.debug('🔍 検索条件 (AND条件)');
    LoggerService.debug('═══════════════════════════════════════');
    LoggerService.debug('📌 タブ: $baseKeyword');
    if (userInput.isNotEmpty) {
      LoggerService.debug('✏️ ユーザー入力: $userInput');
    }
    final selectedPetTypes = _petTypeFilters
        .where((f) => f['isSelected'] == true)
        .map((f) => f['name'])
        .toList();
    if (selectedPetTypes.isNotEmpty) {
      LoggerService.debug(
        '🐾 ペット種類 (${selectedPetTypes.length}個): $selectedPetTypes',
      );
    }
    LoggerService.debug('🏷️ チップフィルター (${chipFilters.length}個): $chipFilters');
    LoggerService.debug('🎯 ブランド (${selectedBrands.length}個): $selectedBrands');
    LoggerService.debug('🔎 最終検索キーワード: "$keyword"');
    LoggerService.debug('═══════════════════════════════════════');

    // 7. 検索を実行
    notifier.searchPetProducts(keyword: keyword);

    // 8. スナックバーで通知
    final totalFilters =
        chipFilters.length +
        selectedBrands.length +
        selectedPetTypes.length +
        (userInput.isNotEmpty ? 1 : 0);
    if (totalFilters > 0) {
      // ✅ Shared SnackBarService 사용
      SnackBarService.showInfo(
        context,
        '$totalFilters個のフィルターを適用しました (AND条件)',
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// すべてのフィルターをクリア
  void _clearAllFilters() {
    setState(() {
      // 検索入力フィールドをクリア
      _searchController.clear();

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

      // ペット種類フィルターをクリア
      for (final filter in _petTypeFilters) {
        filter['isSelected'] = false;
      }

      // 人気ブランドフィルターをクリア (APIから取得したブランドを使用)
      ref.read(rakutenBrandsProvider.notifier).clearAllSelections();
    });

    // フィルターをクリアした後、現在のタブの基本キーワードで再検索
    final String baseKeyword = _getCurrentTabKeyword();

    final notifier = ref.read(rakutenProductsProvider.notifier);

    LoggerService.debug('🔍 Filters cleared, searching with: $baseKeyword');
    notifier.searchPetProducts(keyword: baseKeyword);

    // ✅ Shared SnackBarService 사용
    SnackBarService.showInfo(
      context,
      'すべてのフィルターをクリアしました',
      duration: const Duration(seconds: 2),
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
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: ''),
      body: Column(
        children: [
          // 카테고리 탭
          _buildCategoryTabs(),

          // ペット種類選択
          _buildPetTypeSelector(),

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

                        // 検索入力フィールド
                        _buildSearchInputField(),
                        const SizedBox(height: AppSpacing.md),

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

  /// ペット種類選択構成
  Widget _buildPetTypeSelector() {
    return Container(
      color: AppColors.pureWhite,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'ペット種類：',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _petTypeFilters.map((filter) {
                  final isSelected = filter['isSelected'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          filter['isSelected'] = !filter['isSelected'];
                        });
                        // 선택 즉시 필터 적용
                        _applyFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
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
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 検索入力フィールド構成
  Widget _buildSearchInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品名で検索',
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pointBrown.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '検索ワードを入力してください（例：チキン）',
                    hintStyle: const TextStyle(
                      color: AppColors.pointGray,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.pointBrown,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.pointGray,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // suffixIcon 업데이트를 위해
                  },
                  onSubmitted: (value) {
                    // Enterキーで検索実行
                    if (value.isNotEmpty) {
                      _applyFilters();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // 検索ボタン
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _applyFilters();
                } else {
                  SnackBarService.showWarning(
                    context,
                    '検索ワードを入力してください',
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              child: const Text(
                '検索',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
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
      // 検索条件 확인
      final hasSearchTerm = _searchController.text.isNotEmpty;
      final hasFilters =
          _healthFilters.any((f) => f['isSelected'] == true) ||
          _countryFilters.any((f) => f['isSelected'] == true) ||
          _ingredientFilters.any((f) => f['isSelected'] == true) ||
          _petTypeFilters.any((f) => f['isSelected'] == true);

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                '商品が見つかりませんでした',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (hasSearchTerm) ...[
                Text(
                  '検索ワード: "${_searchController.text}"',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                hasSearchTerm || hasFilters
                    ? '検索条件を減らすか変更してください'
                    : 'カテゴリを変更するか、後でもう一度お試しください',
                style: AppFonts.bodyMedium.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              if (hasSearchTerm || hasFilters) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('フィルターをクリア'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
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

                  // 原料成分情報 (別セクション)
                  _buildIngredientsSection(product),
                  const SizedBox(height: 12),

                  // 商品説明 (5行以上は折りたたみ)
                  if (product.itemCaption.isNotEmpty) ...[
                    _buildExpandableDescription(product),
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
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // 商品を選択して戻る
                                _selectProduct(product);
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('この商品を選択'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pointGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // 商品ページへ移動
                                _openProductPage(product);
                              },
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('商品ページ'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.pointBrown,
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
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 原料成分セクションを構築
  Widget _buildIngredientsSection(RakutenPetProduct product) {
    // itemCaptionから原料情報を抽出
    final ingredients = _extractIngredients(product.itemCaption);

    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pointGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.pointGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, size: 16, color: AppColors.pointGreen),
              const SizedBox(width: 4),
              Text(
                '原料成分情報',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ingredients,
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 商品説明から原料情報を抽出
  String _extractIngredients(String caption) {
    if (caption.isEmpty) return '';

    // HTML タグを除去
    final String cleanCaption = caption
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 原料関連キーワードで検索
    final keywords = ['原材料', '原料', '成分', '主原料', '主成分', '配合成分', '使用原料'];

    for (final keyword in keywords) {
      final index = cleanCaption.indexOf(keyword);
      if (index != -1) {
        // キーワードから次の区切りまでを抽出
        final afterKeyword = cleanCaption.substring(index);
        final endMarkers = ['。', '※', '■', '●', '【', '＜'];

        int endIndex = afterKeyword.length;
        for (final marker in endMarkers) {
          final markerIndex = afterKeyword.indexOf(marker, keyword.length);
          if (markerIndex != -1 && markerIndex < endIndex) {
            endIndex = markerIndex;
          }
        }

        String extracted = afterKeyword.substring(0, endIndex).trim();

        // 最大200文字に制限
        if (extracted.length > 200) {
          extracted = '${extracted.substring(0, 197)}...';
        }

        return extracted;
      }
    }

    return '';
  }

  /// 折りたたみ可能な商品説明を構築
  Widget _buildExpandableDescription(RakutenPetProduct product) {
    final isExpanded = _expandedDescriptions[product.itemCode] ?? false;

    // HTML タグを除去してクリーンなテキストを取得
    final cleanDescription = product.itemCaption
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // テキストの行数を推定 (文字数ベース: 1行約30文字と仮定)
    final estimatedLines = (cleanDescription.length / 30).ceil();
    final needsExpansion = estimatedLines > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                '商品説明',
                style: AppFonts.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleanDescription,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    maxLines: needsExpansion && !isExpanded ? 5 : null,
                    overflow: needsExpansion && !isExpanded
                        ? TextOverflow.ellipsis
                        : null,
                  ),
                  // 5行以上の場合は「もっと見る」ボタンを表示
                  if (needsExpansion) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedDescriptions[product.itemCode] = !isExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            isExpanded ? '折りたたむ' : 'もっと見る',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.pointBrown,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
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
      LoggerService.debug('🔗 Opening product page: ${product.itemName}');
      LoggerService.debug('🔗 itemUrl: ${product.itemUrl}');
      LoggerService.debug('🔗 affiliateUrl: ${product.affiliateUrl}');

      // URL 우선순위: affiliateUrl > itemUrl
      final String targetUrl = product.affiliateUrl.isNotEmpty
          ? product.affiliateUrl
          : product.itemUrl;

      LoggerService.debug('🎯 Selected URL: $targetUrl');

      // URL 검증
      if (targetUrl.isEmpty) {
        LoggerService.debug('❌ Both URLs are empty');
        if (mounted) {
          SnackBarService.showError(
            context,
            '商品URLが見つかりませんでした',
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      // URL 파싱 시도
      Uri? url;
      try {
        url = Uri.parse(targetUrl);
        LoggerService.debug('✅ URL parsed successfully: ${url.toString()}');
      } catch (parseError) {
        LoggerService.debug('❌ URL parse error: $parseError');
        if (mounted) {
          SnackBarService.showError(
            context,
            '無効な商品URLです',
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      // URL 실행 가능 여부 확인
      LoggerService.debug('🔍 Checking if URL can be launched...');
      final canLaunch = await canLaunchUrl(url);
      LoggerService.debug('🔍 Can launch URL: $canLaunch');

      // canLaunchUrl 체크 없이 바로 실행 (Android에서 false를 반환하는 버그 회피)
      LoggerService.debug('🚀 Launching URL...');

      try {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // 外部ブラウザで開く
        );

        LoggerService.debug('🚀 Launch result: $launched');

        if (!launched) {
          // 외부 브라우저로 실패하면 platformDefault 시도
          LoggerService.debug(
            '⚠️ External app launch failed, trying platformDefault...',
          );
          final retryLaunched = await launchUrl(
            url,
            mode: LaunchMode.platformDefault,
          );
          LoggerService.debug('🚀 Retry launch result: $retryLaunched');
        }
      } catch (launchError) {
        // Launch 실패 시 에러 처리
        LoggerService.debug('❌ Launch error: $launchError');
        if (mounted) {
          SnackBarService.showError(
            context,
            '商品ページを開けませんでした',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e, stackTrace) {
      LoggerService.debug('❌ Error opening product page: $e');
      LoggerService.debug('❌ Stack trace: $stackTrace');
      if (mounted) {
        SnackBarService.showError(
          context,
          'エラーが発生しました: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 商品を選択して戻る
  void _selectProduct(RakutenPetProduct product) {
    LoggerService.debug('✅ 상품 선택: ${product.itemName}');
    context.pop(product.itemName);
  }

  /// お気に入りに追加
  Future<void> _addToFavorites(RakutenPetProduct product) async {
    // RakutenPetProductをFavoriteProductに変換
    final favoriteProduct = FavoriteProduct(
      itemCode: product.itemCode,
      itemName: product.itemName,
      imageUrl: product.imageUrl,
      itemPrice: product.itemPrice,
      shopName: product.shopName,
      itemUrl: product.itemUrl,
      reviewAverage: product.reviewAverage,
      reviewCount: product.reviewCount,
      addedAt: DateTime.now(),
    );

    // お気に入りに追加
    final success = await ref
        .read(favoriteProductsProvider.notifier)
        .addFavorite(favoriteProduct);

    if (!mounted) return;

    if (success) {
      SnackBarService.showSuccess(
        context,
        '${product.itemName}をお気に入りに追加しました',
        duration: const Duration(seconds: 2),
      );
    } else {
      SnackBarService.showWarning(
        context,
        '既にお気に入りに追加されています',
        duration: const Duration(seconds: 2),
      );
    }
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
    final brandState = ref.watch(rakutenBrandsProvider);

    // 디버그 로그 추가
    LoggerService.debug(
      '🏷️ Brand State: isLoading=${brandState.isLoading}, error=${brandState.error}, brands=${brandState.brands.length}',
    );

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
          child: brandState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : brandState.error != null
              ? Center(
                  child: Text(
                    'ブランド情報の読み込みに失敗しました',
                    style: AppFonts.bodyMedium.copyWith(color: Colors.red),
                  ),
                )
              : brandState.brands.isEmpty
              ? Center(
                  child: Text(
                    'ブランド情報がありません',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: brandState.brands.length,
                  itemBuilder: (context, index) {
                    final brand = brandState.brands[index];
                    final isSelected = brand.isSelected;

                    return Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(rakutenBrandsProvider.notifier)
                              .toggleBrandSelection(brand.brandId);

                          // 상태 업데이트 후 필터 적용
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _applyFilters();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pointBrown.withValues(alpha: 0.1)
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.pointBrown
                                  : AppColors.pointGray.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pointBrown.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 브랜드 로고 아이콘
                              Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                  color: AppColors.pointOffWhite,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.pointBrown
                                        : AppColors.pointGray.withValues(
                                            alpha: 0.2,
                                          ),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                  child: brand.brandLogoUrl.isNotEmpty
                                      ? Image.network(
                                          brand.brandLogoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Center(
                                                  child: Text(
                                                    brand.brandName.isNotEmpty
                                                        ? brand.brandName[0]
                                                              .toUpperCase()
                                                        : '?',
                                                    style: AppFonts.titleLarge
                                                        .copyWith(
                                                          color: isSelected
                                                              ? AppColors
                                                                    .pointBrown
                                                              : AppColors
                                                                    .pointGray,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 28,
                                                        ),
                                                  ),
                                                );
                                              },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                color: AppColors.pointBrown,
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Text(
                                            brand.brandName.isNotEmpty
                                                ? brand.brandName[0]
                                                      .toUpperCase()
                                                : '?',
                                            style: AppFonts.titleLarge.copyWith(
                                              color: isSelected
                                                  ? AppColors.pointBrown
                                                  : AppColors.pointGray,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              // 브랜드 이름 (영문)
                              Text(
                                brand.brandName,
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
                                brand.brandNameJapanese,
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
