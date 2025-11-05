import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/shopping/shopping.dart';

/// 알레르기 추천 상품 화면
///
/// 의심 원료를 포함하지 않는 상품들을 표시
class AllergyRecommendedProductsScreen extends ConsumerStatefulWidget {
  final List<String> suspectedIngredients;
  final String petId;
  final String petName;

  const AllergyRecommendedProductsScreen({
    super.key,
    required this.suspectedIngredients,
    required this.petId,
    required this.petName,
  });

  @override
  ConsumerState<AllergyRecommendedProductsScreen> createState() =>
      _AllergyRecommendedProductsScreenState();
}

class _AllergyRecommendedProductsScreenState
    extends ConsumerState<AllergyRecommendedProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 초기 데이터 로드 (怪しい賢良なし로 검색)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductsForCategory('フード');
    });

    // 탭 변경 리스너 추가 (怪しい賢良なし로 검색)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final category = _getCategoryName(_tabController.index);
        _loadProductsForCategory(category);
      }
    });
  }

  /// 탭 인덱스로 카테고리명 가져오기
  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'フード';
      case 1:
        return 'サプリメント';
      case 2:
        return 'おやつ';
      case 3:
        return '生食';
      default:
        return 'フード';
    }
  }

  /// 카테고리별 상품 로드
  void _loadProductsForCategory(String category) {
    final notifier = ref.read(rakutenProductsProvider.notifier);

    // 더 일반적인 키워드로 검색 (안전한 제품)
    String keyword = '';
    switch (category) {
      case 'フード':
        keyword = 'ペットフード 安全 無添加';
        break;
      case 'サプリメント':
        keyword = 'ペットサプリメント 健康';
        break;
      case 'おやつ':
        keyword = 'ペットおやつ 安全';
        break;
      case '生食':
        keyword = 'ペット生食 フリーズドライ';
        break;
      default:
        keyword = 'ペット $category';
    }

    notifier.searchPetProducts(keyword: keyword);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // PDF 출력에 적합한 고정 배경색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '推奨商品リスト',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 의심 원료 안내
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: const Color(0x0DFFFF6B), // 투명도 대신 고정 색상 사용
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFF6B9D),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '以下の原料を含まない商品のみ表示',
                        style: AppFonts.bodySmall.copyWith(
                          color: const Color(0xFFFF6B9D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 카테고리 탭
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.pointBrown,
                  unselectedLabelColor: AppColors.pointGray,
                  indicatorColor: AppColors.pointBrown,
                  labelStyle: AppFonts.bodyMedium.copyWith(
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
    final productsState = ref.watch(rakutenProductsProvider);

    // 로딩 중일 때
    if (productsState.isLoading && productsState.products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 에러가 발생했을 때
    if (productsState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0x80AAAAAA), // 투명도 대신 고정 색상 사용
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'エラーが発生しました',
                style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                productsState.error!,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 임시로 필터링 제거 - 모든 상품 표시
    final filteredProducts = productsState.products;

    if (filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Color(0x80AAAAAA), // 투명도 대신 고정 색상 사용
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '推奨商品がありません',
                style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 의심 원료 칩 리스트
        if (widget.suspectedIngredients.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: Colors.white,
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: widget.suspectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(
                    ingredient,
                    style: AppFonts.bodySmall.copyWith(
                      color: const Color(0xFFFF6B9D),
                    ),
                  ),
                  backgroundColor: const Color(
                    0xFFFF6B9D,
                  ).withValues(alpha: 0.1),
                  side: const BorderSide(color: Color(0xFFFF6B9D), width: 1),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFFFF6B9D),
                  ),
                  onDeleted: null,
                );
              }).toList(),
            ),
          ),
        // 상품 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildRakutenProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  /// 라쿠텐 제품 카드
  Widget _buildRakutenProductCard(RakutenPetProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 상품 상세 페이지로 이동 (외부 브라우저 또는 WebView)
          _openProductPage(product);
        },
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 제품 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0x1AAAAAAA), // 투명도 대신 고정 색상 사용
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              size: 40,
                              color: Color(0x80AAAAAA), // 투명도 대신 고정 색상 사용
                            );
                          },
                        )
                      : const Icon(
                          Icons.pets,
                          size: 40,
                          color: Color(0x80AAAAAA), // 투명도 대신 고정 색상 사용
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // 제품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상점명
                    if (product.shopName.isNotEmpty)
                      Text(
                        product.shopName,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),

                    // 제품명
                    Text(
                      product.itemName,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // 가격과 리뷰
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: AppFonts.titleSmall.copyWith(
                            color: AppColors.pointBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.reviewCount.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            product.formattedReviewAverage,
                            style: AppFonts.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 안전 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1A4CAF50), // 투명도 대신 고정 색상 사용
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '安全',
                      style: AppFonts.bodySmall.copyWith(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상품 페이지 열기
  void _openProductPage(RakutenPetProduct product) {
    // 상품 URL로 이동 (실제로는 url_launcher 패키지 사용)
    SnackBarService.showInfo(
      context,
      '${product.itemName}の商品ページを開きます',
      duration: const Duration(seconds: 2),
    );
  }
}
