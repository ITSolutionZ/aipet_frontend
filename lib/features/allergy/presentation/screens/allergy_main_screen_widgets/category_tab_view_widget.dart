import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';

/// 카테고리별 탭뷰를 위한 위젯
class CategoryTabViewWidget extends StatefulWidget {
  final Map<String, List<ProductEntity>> productsByCategory;
  final bool isAllergyTab;
  final ValueChanged<String> onRemoveProduct;

  const CategoryTabViewWidget({
    super.key,
    required this.productsByCategory,
    required this.isAllergyTab,
    required this.onRemoveProduct,
  });

  @override
  State<CategoryTabViewWidget> createState() => _CategoryTabViewWidgetState();
}

class _CategoryTabViewWidgetState extends State<CategoryTabViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카테고리 탭바
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(
                  'フード',
                  widget.productsByCategory['フード']?.length ?? 0,
                  0,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildCategoryChip(
                  'サプリ',
                  widget.productsByCategory['サプリメント']?.length ?? 0,
                  1,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildCategoryChip(
                  'おやつ',
                  widget.productsByCategory['おやつ']?.length ?? 0,
                  2,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildCategoryChip(
                  '生食',
                  widget.productsByCategory['生食']?.length ?? 0,
                  3,
                ),
              ],
            ),
          ),
        ),
        // 제품 리스트
        Expanded(
          child: TabBarView(
            controller: _categoryTabController,
            children: [
              _buildProductList(widget.productsByCategory['フード'] ?? [], 'フード'),
              _buildProductList(
                widget.productsByCategory['サプリメント'] ?? [],
                'サプリメント',
              ),
              _buildProductList(widget.productsByCategory['おやつ'] ?? [], 'おやつ'),
              _buildProductList(widget.productsByCategory['生食'] ?? [], '生食'),
            ],
          ),
        ),
      ],
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip(String label, int count, int index) {
    final isSelected = _categoryTabController.index == index;
    return GestureDetector(
      onTap: () {
        _categoryTabController.animateTo(index);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pointBrown : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointGray.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pointBrown.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.pointGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.pointBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  count.toString(),
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.pointBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductEntity> products, String category) {
    debugPrint('🔍 CategoryTabViewWidget._buildProductList:');
    debugPrint('  - Category: $category');
    debugPrint('  - Products count: ${products.length}');
    debugPrint('  - Products: ${products.map((p) => p.name).toList()}');

    if (products.isEmpty) {
      debugPrint('  - Showing empty state for category: $category');
      return Center(
        child: Text(
          '$categoryの商品がありません',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // 상품 이미지
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.small),
                color: AppColors.pointOffWhite,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.pointOffWhite,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.pointGray,
                        size: 24,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.pointOffWhite,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.pointBrown,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 브랜드명 (brandId 표시)
                Text(
                  product.brandId,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 제품명
                Text(
                  product.name,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.pointGray, size: 20),
            onPressed: () => widget.onRemoveProduct(product.id),
          ),
        ],
      ),
    );
  }
}
