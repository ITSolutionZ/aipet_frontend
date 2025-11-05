import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/shopping/shopping.dart';
import '../../utils/product_name_cleaner.dart';


/// 楽天商品カードウィジェット
///
/// アレルギー商品選択画面で使用される商品カード
class RakutenProductCard extends StatelessWidget {
  final RakutenPetProduct product;
  final bool isSelected;
  final bool hasAllergy;
  final VoidCallback onTap;

  const RakutenProductCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.hasAllergy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? (hasAllergy
            ? const Color(0xFFFF6B9D).withValues(alpha: 0.1) // アレルギー商品: ピンク
            : const Color(0xFF4CAF50).withValues(alpha: 0.1)) // 非アレルギー商品: 緑
        : Colors.white;

    final borderColor = isSelected
        ? (hasAllergy
            ? const Color(0xFFFF6B9D) // アレルギー商品: ピンク
            : const Color(0xFF4CAF50)) // 非アレルギー商品: 緑
        : null;

    final checkIconColor = hasAllergy
        ? const Color(0xFFFF6B9D) // アレルギー商品: ピンク
        : const Color(0xFF4CAF50); // 非アレルギー商品: 緑

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: isSelected ? Border.all(color: borderColor!, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 選択マーク (左側に表示)
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    Icons.check_circle,
                    color: checkIconColor,
                    size: 24,
                  ),
                ),

              // 商品画像
              _buildProductImage(),
              const SizedBox(width: AppSpacing.md),

              // 商品情報
              Expanded(child: _buildProductInfo()),
            ],
          ),
        ),
      ),
    );
  }

  /// 商品画像セクション
  Widget _buildProductImage() {
    if (product.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Image.network(
          product.imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  /// プレースホルダー画像
  Widget _buildPlaceholderImage() {
    return Container(
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
    );
  }

  /// 商品情報セクション
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // メーカー (ブランド)
        Text(
          ProductNameCleaner.extractMaker(product.itemName),
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // 商品名 (クリーンアップ版)
        Text(
          ProductNameCleaner.cleanProductName(product.itemName),
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
