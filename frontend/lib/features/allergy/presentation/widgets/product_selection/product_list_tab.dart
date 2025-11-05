import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/shopping/shopping.dart';
import 'rakuten_product_card.dart';


/// 商品リストタブウィジェット
///
/// フード/サプリメント/おやつタブで使用される商品リスト表示
class ProductListTab extends StatelessWidget {
  final String category;
  final List<RakutenPetProduct> products;
  final bool isLoading;
  final String? error;
  final bool hasAllergy;
  final Set<String> selectedProductIds;
  final Function(RakutenPetProduct) onProductTap;

  const ProductListTab({
    super.key,
    required this.category,
    required this.products,
    required this.isLoading,
    required this.error,
    required this.hasAllergy,
    required this.selectedProductIds,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    // ローディング中
    if (isLoading && products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // エラー発生
    if (error != null) {
      return _buildErrorView();
    }

    // 商品リスト表示
    if (products.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return RakutenProductCard(
          product: product,
          isSelected: selectedProductIds.contains(product.itemCode),
          hasAllergy: hasAllergy,
          onTap: () => onProductTap(product),
        );
      },
    );
  }

  /// エラービュー
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.pointGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'エラーが発生しました',
              style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error!,
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 空状態ビュー
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          '商品がありません',
          style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
        ),
      ),
    );
  }
}
