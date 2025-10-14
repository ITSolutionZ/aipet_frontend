import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 의심 원료 섹션
class SuspectedIngredientsSection extends StatelessWidget {
  final List<String> ingredients;

  const SuspectedIngredientsSection({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF6B9D),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '疑わしい原料',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...ingredients.map(
            (ingredient) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFFF6B9D), size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w600,
                      ),
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
}
