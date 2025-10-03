import 'package:aipet_frontend/features/allergy/allergy.dart';
import 'package:aipet_frontend/shared/mock_data/brand_mock_data.dart';
import 'package:aipet_frontend/shared/mock_data/product_mock_data.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.05),
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
    // 의심 원료를 포함하지 않는 상품 필터링
    final filteredProducts = ProductMockData.products
        .where((p) => p.category == category)
        .where((p) {
          // 실제로는 상품의 원료 정보와 비교해야 하지만,
          // 현재는 Mock 데이터이므로 모든 상품을 표시
          // TODO: API 연동 시 실제 원료 정보로 필터링
          return true;
        })
        .toList();

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
              return _buildProductCard(product);
            },
          ),
        ),
      ],
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // 제품 이미지 (플레이스홀더)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                Icons.pets,
                size: 40,
                color: AppColors.pointGray.withValues(alpha: 0.5),
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 가격
                  Text(
                    '¥${product.price}',
                    style: AppFonts.titleSmall.copyWith(
                      color: AppColors.pointBrown,
                      fontWeight: FontWeight.bold,
                    ),
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
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
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
    );
  }
}
