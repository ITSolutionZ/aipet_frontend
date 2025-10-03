import 'package:aipet_frontend/features/allergy/data/providers/allergy_providers.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/shared/mock_data/brand_mock_data.dart';
import 'package:aipet_frontend/shared/mock_data/product_mock_data.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알레르기 제품 선택 화면
///
/// 사료/영양제/간식 중 선택하여 알레르기 관련 제품을 등록하는 화면
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
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
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
                    Tab(text: '사료'),
                    Tab(text: '영양제'),
                    Tab(text: '간식'),
                    Tab(text: '생식'),
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
              // 똥따말사료 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 똥따말사료 기능
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: Text(
                    '똥따말사료',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList('사료'),
          _buildProductList('영양제'),
          _buildProductList('간식'),
          _buildProductList('생식'),
        ],
      ),
    );
  }

  Widget _buildProductList(String category) {
    // 검색 결과가 있으면 검색 결과만 표시
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    // 검색어가 없으면 기본 화면 표시
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
            '추천 필터',
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
              _buildFilterChip('퍼피 / 키튼'),
              _buildFilterChip('어덜트'),
              _buildFilterChip('시니어'),
              _buildFilterChip('건식'),
              _buildFilterChip('습식'),
              _buildFilterChip('발습식'),
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
                    '필터 더보기',
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
            '인기 브랜드',
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
                    '브랜드 더보기',
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
  Widget _buildBrandItem(String name, String logo) {
    return GestureDetector(
      onTap: () {
        // TODO: 브랜드 선택
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.pointGray.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  name,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark,
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
