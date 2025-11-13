import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../../domain/domain.dart';

/// 알레르기 제품 카드
class AllergyProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onRemove;

  const AllergyProductCard({
    super.key,
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildProductImage(),

          // 상품 정보
          Expanded(child: _buildProductInfo()),

          // 삭제 버튼
          _buildRemoveButton(),
        ],
      ),
    );
  }

  /// 상품 이미지
  Widget _buildProductImage() {
    return Container(
      width: AllergyConstants.productImageSize,
      height: AllergyConstants.productImageSize,
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
    );
  }

  /// 상품 정보
  Widget _buildProductInfo() {
    return Column(
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
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointDark),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 삭제 버튼
  Widget _buildRemoveButton() {
    return IconButton(
      icon: const Icon(Icons.close, color: AppColors.pointGray, size: 20),
      onPressed: onRemove,
    );
  }
}
