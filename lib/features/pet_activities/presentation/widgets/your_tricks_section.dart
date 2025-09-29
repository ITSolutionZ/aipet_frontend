import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import 'trick_progress_card.dart';

/// 사용자의 트릭 섹션
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
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'あなたのトリック',
              style: AppFonts.fredoka(
                fontSize: AppFonts.xl,
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: onManageTricks,
              icon: const Icon(Icons.more_vert),
              color: AppColors.pointBrown,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 트릭 목록
        if (learnedTricks.isEmpty)
          _buildEmptyState()
        else
          ...learnedTricks
              .take(3)
              .map(
                (trick) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: TrickProgressCard(trick: trick),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: AppColors.pointBrown.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'まだ学習したトリックがありません',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '新しいトリックを学んでみましょう！',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
