import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import 'trick_progress_card.dart';

/// 학습한 트릭 섹션
class YourTricksSection extends StatelessWidget {
  final List<TrickEntity> learnedTricks;
  final VoidCallback onManageTricks;

  const YourTricksSection({
    super.key,
    required this.learnedTricks,
    required this.onManageTricks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '学んだトリック',
              style: AppFonts.fredoka(
                fontSize: AppFonts.xl,
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.pointDark),
              onPressed: onManageTricks,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (learnedTricks.isEmpty)
          Center(
            child: Text(
              'まだ学んだトリックがありません。',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          ...learnedTricks.map(
            (trick) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TrickProgressCard(trick: trick),
            ),
          ),
      ],
    );
  }
}
