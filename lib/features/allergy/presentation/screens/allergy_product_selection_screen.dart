import 'package:aipet_frontend/features/allergy/data/providers/allergy_providers.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/shared/mock_data/brand_mock_data.dart';
import 'package:aipet_frontend/shared/mock_data/product_mock_data.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알레르기 제품 선택 화면
///
/// フード/サプリメント/おやつ/生食から選択してアレルギー関連製品を登録する画面
class AllergyProductSelectionScreen extends ConsumerStatefulWidget {
  /// 알레르기 발생 여부 (true: 발생, false: 미발생)
  final bool hasAllergy;

  /// 선택된 펫 ID
  final String petId;

  const AllergyProductSelectionScreen({
    super.key,
    required this.hasAllergy,
    required this.petId,
  });

  @override
  ConsumerState<AllergyProductSelectionScreen> createState() =>
      _AllergyProductSelectionScreenState();
}

class _AllergyProductSelectionScreenState
    extends ConsumerState<AllergyProductSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  /// 선택된 필터들
  final Set<String> _selectedFilters = {};

  /// 검색어
  String _searchQuery = '';

  /// 검색 결과
  List<ProductEntity> _searchResults = [];

  /// 선택된 브랜드 ID
  String? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 탭바
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.pointBrown,
                  unselectedLabelColor: AppColors.pointGray,
                  indicatorColor: AppColors.pointBrown,
                  labelStyle: AppFonts.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'フード'),
                    Tab(text: 'サプリメント'),
                    Tab(text: 'おやつ'),
                    Tab(text: '生食'),
                  ],
                ),
              ),
              // 검색바
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '제품명을 입력하세요',
                    hintStyle: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.pointGray,
                    ),
                    filled: true,
                    fillColor: AppColors.pointOffWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      borderSide: BorderSide(
                        color: AppColors.pointGray.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      borderSide: BorderSide(
                        color: AppColors.pointGray.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      borderSide: const BorderSide(
                        color: AppColors.pointBrown,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      if (value.isNotEmpty) {
                        _searchResults = ProductMockData.searchProducts(value);
                      } else {
                        _searchResults = [];
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList('フード'),
          _buildProductList('サプリメント'),
          _buildProductList('おやつ'),
          _buildProductList('生食'),
        ],
      ),
    );
  }

  Widget _buildProductList(String category) {
    // 검색 결과가 있으면 검색 결과만 표시
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    // 선택된 브랜드가 있으면 해당 브랜드의 상품만 표시
    if (_selectedBrandId != null) {
      return _buildBrandProducts(category, _selectedBrandId!);
    }

    // 검색어와 선택된 브랜드가 없으면 기본 화면 표시
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),

          // 추천 필터
          _buildRecommendedFilters(),

          const SizedBox(height: AppSpacing.lg),

          // 인기 브랜드
          _buildPopularBrands(),
        ],
      ),
    );
  }

  /// 선택된 브랜드의 상품 표시
  Widget _buildBrandProducts(String category, String brandId) {
    // 해당 카테고리와 브랜드의 상품 필터링
    final filteredProducts = ProductMockData.products
        .where((p) => p.category == category && p.brandId == brandId)
        .toList();

    // 브랜드 정보 가져오기
    final brand = BrandMockData.brands.firstWhere(
      (b) => b.id == brandId,
      orElse: () => BrandMockData.brands.first,
    );

    if (filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.pointGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${brand.japaneseName}の$categoryがありません',
                style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedBrandId = null;
                  });
                },
                child: const Text('フィルターを解除'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 선택된 브랜드 헤더
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.pointBrown.withValues(alpha: 0.05),
          child: Row(
            children: [
              const Icon(
                Icons.filter_alt,
                size: 20,
                color: AppColors.pointBrown,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${brand.japaneseName}の商品',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointBrown,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedBrandId = null;
                  });
                },
                child: Text(
                  'フィルター解除',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 상품 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  /// 검색 결과 표시
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.pointGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '検索結果がありません',
                style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '「$_searchQuery」に一致する商品が見つかりませんでした',
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  /// 제품 카드
  Widget _buildProductCard(ProductEntity product) {
    // 브랜드 정보 가져오기
    final brand = BrandMockData.brands.firstWhere(
      (b) => b.id == product.brandId,
      orElse: () => BrandMockData.brands.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 제품 상세 또는 선택
            _selectProduct(product);
          },
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // 제품 이미지 영역 (플레이스홀더)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.pointOffWhite,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.pointGray,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // 제품 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 브랜드명
                      Text(
                        brand.japaneseName,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 제품명
                      Text(
                        product.name,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // 가격
                      Text(
                        '¥${_formatPrice(product.price)}',
                        style: AppFonts.bodyLarge.copyWith(
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // 선택 버튼
                const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.pointBrown,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 가격 포맷팅 (천 단위 콤마)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 제품 선택
  void _selectProduct(ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品を選択'),
        content: Text('${product.name}\nを選択しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // Provider에 제품 추가 (hasAllergy 정보 포함)
              ref
                  .read(selectedAllergyProductsProvider.notifier)
                  .addProduct(widget.petId, product, widget.hasAllergy);

              Navigator.pop(context);

              // 성공 메시지
              final message = widget.hasAllergy
                  ? 'アレルギー商品に追加しました'
                  : 'アレルギーなし商品に追加しました';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.pointBrown,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('選択'),
          ),
        ],
      ),
    );
  }

  /// 추천 필터 섹션
  Widget _buildRecommendedFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'おすすめフィルター',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 필터 그리드
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.5,
            children: [
              _buildFilterChip('パピー / キトン'),
              _buildFilterChip('アダルト'),
              _buildFilterChip('シニア'),
              _buildFilterChip('ドライ'),
              _buildFilterChip('ウェット'),
              _buildFilterChip('セミモイスト'),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Center(
            child: TextButton(
              onPressed: () {
                // TODO: 필터 더보기
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'もっと見る',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right,
                    color: AppColors.pointGray,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilters.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFilters.remove(label);
          } else {
            _selectedFilters.add(label);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointGray.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              color: isSelected ? AppColors.pointBrown : AppColors.pointDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// 인기 브랜드 섹션
  Widget _buildPopularBrands() {
    // Mock 데이터에서 인기 브랜드 가져오기
    final brands = BrandMockData.getPopularBrands(limit: 6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '人気ブランド',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 브랜드 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1,
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return _buildBrandItem(
                brand.id,
                brand.japaneseName,
                brand.logoUrl ?? 'assets/images/placeholder.png',
              );
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          Center(
            child: TextButton(
              onPressed: () {
                // TODO: 브랜드 더보기
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'もっと見る',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right,
                    color: AppColors.pointGray,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// 브랜드 아이템
  Widget _buildBrandItem(String brandId, String name, String logo) {
    final isSelected = _selectedBrandId == brandId;

    return GestureDetector(
      onTap: () {
        setState(() {
          // 같은 브랜드를 다시 클릭하면 필터 해제
          if (_selectedBrandId == brandId) {
            _selectedBrandId = null;
          } else {
            _selectedBrandId = brandId;
          }
        });
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pointBrown.withValues(alpha: 0.1)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.pointBrown
                      : AppColors.pointGray.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  name,
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pointBrown
                        : AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointDark),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
