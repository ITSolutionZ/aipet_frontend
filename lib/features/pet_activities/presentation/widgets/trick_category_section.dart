import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import 'trick_card.dart';

/// 트릭 카테고리 섹션
class TrickCategorySection extends StatelessWidget {
  final String category;
  final List<TrickEntity> tricks;
  final String selectedCategory;
  final Function(TrickEntity) onShowTrickDetail;
  final Function(TrickEntity) onStartLearning;

  const TrickCategorySection({
    super.key,
    required this.category,
    required this.tricks,
    required this.selectedCategory,
    required this.onShowTrickDetail,
    required this.onStartLearning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        if (selectedCategory == 'all') ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _getCategoryLabel(category),
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${tricks.length} tricks',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],

        // 트릭 카드들
        ...tricks.map(
          (trick) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TrickCard(
              trick: trick,
              onTap: () => onShowTrickDetail(trick),
              onStartLearning: () => onStartLearning(trick),
            ),
          ),
        ),

        if (selectedCategory == 'all' && tricks.isNotEmpty)
          const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'easy':
        return '簡単なトリック';
      case 'medium':
        return '普通のトリック';
      case 'hard':
        return '難しいトリック';
      default:
        return 'その他のトリック';
    }
  }
}
