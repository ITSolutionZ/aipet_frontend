import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 트릭 상세 다이얼로그
class TrickDetailDialog extends StatelessWidget {
  final TrickEntity trick;

  const TrickDetailDialog({super.key, required this.trick});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trick.name,
                    style: AppFonts.titleLarge.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.pointDark),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 트릭 이미지
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                image: DecorationImage(
                  image: AssetImage(trick.imagePath),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // 난이도 태그
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getDifficultyColor(
                  trick.difficulty,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                trick.difficulty.toUpperCase() ?? 'UNKNOWN',
                style: AppFonts.bodySmall.copyWith(
                  color: _getDifficultyColor(trick.difficulty),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // 설명
            if (trick.description.isNotEmpty == true) ...[
              Text(
                '説明',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                trick.description,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pointDark),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                    ),
                    child: Text(
                      '閉じる',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/learn-trick/${trick.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                    ),
                    child: Text(
                      '学習を開始',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return AppColors.pointGreen;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.pointDark;
    }
  }
}
