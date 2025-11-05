import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
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
        border: Border.all(
          color: const Color(0x0D000000), // 투명도 대신 고정 색상 사용
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // 투명도 대신 고정 색상 사용
            blurRadius: 4,
            offset: Offset(0, 2),
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
                color: const Color(0x0DFFFF6B), // 투명도 대신 고정 색상 사용
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: const Color(0x33FF6B9D), // 투명도 대신 고정 색상 사용
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
