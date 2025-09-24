import 'package:aipet_frontend/features/ai/data/services/ai_category_service.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// AI 메시지 버블 형태의 카테고리 선택 위젯
class AiCategorySelectionBubble extends StatelessWidget {
  final AiCategoryEntity? selectedCategory;
  final Function(AiCategoryEntity) onCategorySelected;

  const AiCategorySelectionBubble({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
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
              'assets/icons/logo_notinclude_text.png',
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
                    'ペットについて、どのような内容でお困りですか？',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    '該当するカテゴリを選択してください：',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 카테고리 선택 위젯
                  _buildCategorySelection(),

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

  Widget _buildCategorySelection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AiCategoryService.getDefaultCategories().map((category) {
        return _buildCategoryChip(category);
      }).toList(),
    );
  }

  Widget _buildCategoryChip(AiCategoryEntity category) {
    final isSelected = selectedCategory?.id == category.id;

    return GestureDetector(
      onTap: () => onCategorySelected(category),
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
                : AppColors.pointBrown.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
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
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.pointBrown,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              category.name,
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
