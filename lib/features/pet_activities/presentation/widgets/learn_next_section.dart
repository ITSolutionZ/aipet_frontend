import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'learn_next_trick_card.dart';

/// 다음 학습 트릭 섹션
class LearnNextSection extends StatelessWidget {
  final List<TrickEntity> availableTricks;

  const LearnNextSection({super.key, required this.availableTricks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '次に学ぶトリック',
              style: AppFonts.fredoka(
                fontSize: AppFonts.xl,
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/all-tricks'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'すべて見る',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const const const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.pointBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
        const const const SizedBox(height: AppSpacing.md),
        if (availableTricks.isEmpty)
          Center(
            child: Text(
              '学習完了しました',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          ...availableTricks
              .take(3)
              .map(
                (trick) => Padding(
                  padding: const const const EdgeInsets.only(bottom: AppSpacing.md),
                  child: LearnNextTrickCard(trick: trick),
                ),
              ),
      ],
    );
  }
}
