import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

/// 카테고리별 탭뷰 위젯
class CategoryTabViewWidget extends StatefulWidget {
  final Map<String, List<ProductEntity>> productsByCategory;
  final bool isAllergyTab;
  final Function(String) onRemoveProduct;

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.productsByCategory.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.productsByCategory.keys.toList();

    if (categories.isEmpty) {
      return const Center(child: Text('カテゴリがありません'));
    }

    return Column(
      children: [
        // 카테고리 탭바
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.pointGray.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.pointBrown,
            unselectedLabelColor: AppColors.pointGray,
            indicatorColor: AppColors.pointBrown,
            labelStyle: AppFonts.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: categories.map((category) {
              final count = widget.productsByCategory[category]?.length ?? 0;
              return Tab(child: Text('$category ($count)'));
            }).toList(),
          ),
        ),
        // 탭뷰
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              final products = widget.productsByCategory[category] ?? [];
              return _buildProductList(products);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 제품 리스트
  Widget _buildProductList(List<ProductEntity> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '商品がありません',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  /// 제품 카드
  Widget _buildProductCard(ProductEntity product) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // 제품 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isAllergyTab
                  ? const Color(0xFFFF6B9D).withValues(alpha: 0.1)
                  : const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(
              widget.isAllergyTab
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle,
              color: widget.isAllergyTab
                  ? const Color(0xFFFF6B9D)
                  : const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // 제품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '¥${product.price.toStringAsFixed(0)}',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
          // 삭제 버튼
          IconButton(
            onPressed: () => widget.onRemoveProduct(product.id),
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.pointGray,
            ),
          ),
        ],
      ),
    );
  }
}
