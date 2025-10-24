import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';

/// AI 메시지 버블 형태의 카테고리 선택 위젯
class AiCategorySelectionBubble extends StatelessWidget {
  final AiCategoryEntity? selectedCategory;
  final Function(AiCategoryEntity) onCategorySelected;
  final VoidCallback? onSkip; // ✅ 추가: Skip 콜백

  const AiCategorySelectionBubble({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.onSkip, // ✅ 추가
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

                  // ✅ 추가: Skip 버튼
                  if (onSkip != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: onSkip,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: AppColors.pointGray.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: AppColors.pointGray,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'スキップして自由に質問する',
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.pointGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

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
      children: AiCategoryEntity.defaults.map((category) {
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
