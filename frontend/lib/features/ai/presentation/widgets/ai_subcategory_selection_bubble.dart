import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';

/// AI 메시지 버블 형태의 서브카테고리 선택 위젯
class AiSubCategorySelectionBubble extends StatelessWidget {
  final AiCategoryEntity selectedCategory;
  final AiSubCategoryEntity? selectedSubCategory;
  final Function(AiSubCategoryEntity) onSubCategorySelected;

  const AiSubCategorySelectionBubble({
    super.key,
    required this.selectedCategory,
    this.selectedSubCategory,
    required this.onSubCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/logos/aipet_white.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 메시지 버블
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppRadius.medium,
                ).copyWith(bottomLeft: Radius.zero),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AI 메시지 텍스트
                  Text(
                    '${selectedCategory.name}について、具体的にどのような内容でしょうか？',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    '詳細なカテゴリを選択してください：',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 서브카테고리 선택 위젯
                  if (selectedCategory.subCategories != null &&
                      selectedCategory.subCategories!.isNotEmpty)
                    _buildSubCategorySelection(),

                  const SizedBox(height: AppSpacing.sm),

                  // 타임스탬프
                  Text(
                    '今',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategorySelection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: selectedCategory.subCategories!.map((subCategory) {
        return _buildSubCategoryChip(subCategory);
      }).toList(),
    );
  }

  Widget _buildSubCategoryChip(AiSubCategoryEntity subCategory) {
    final isSelected = selectedSubCategory?.id == subCategory.id;

    return GestureDetector(
      onTap: () => onSubCategorySelected(subCategory),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedCategory.color : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? selectedCategory.color
                : selectedCategory.color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedCategory.color.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  subCategory.icon,
                  size: 18,
                  color: isSelected ? Colors.white : selectedCategory.color,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  subCategory.name,
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (subCategory.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subCategory.description,
                style: AppFonts.caption.copyWith(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColors.pointGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
