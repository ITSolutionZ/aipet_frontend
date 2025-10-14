import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 권장사항 섹션
class RecommendationsSection extends StatelessWidget {
  final List<String> recommendations;
  final Map<String, dynamic> analysisResult;
  final String petId;
  final String petName;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.analysisResult,
    required this.petId,
    required this.petName,
  });

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
                Icons.lightbulb_outline,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '推奨事項',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...recommendations.asMap().entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 상품보기 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                context.push(
                  '/home/allergy/recommended-products',
                  extra: {
                    'suspectedIngredients':
                        analysisResult['suspectedIngredients']
                            as List<String>? ??
                        [],
                    'petId': petId,
                    'petName': petName,
                  },
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
                ),
              ),
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF4CAF50),
              ),
              label: Text(
                '推奨商品を見る',
                style: AppFonts.bodyMedium.copyWith(
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
