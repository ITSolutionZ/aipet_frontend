import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../widgets/trick_category_card.dart';

/// 모든 트릭 카테고리 섹션
class AllTricksCategoriesSection extends StatelessWidget {
  final Function(String) onCategoryTap;

  const AllTricksCategoriesSection({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'すべてのトリック',
          style: AppFonts.fredoka(
            fontSize: AppFonts.xl,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TrickCategoryCard(
          title: '基本トリック',
          description: 'お手、お座り、伏せなど',
          icon: Icons.star,
          color: AppColors.pointGreen,
          onTap: () => onCategoryTap('基本トリック'),
        ),
        const SizedBox(height: AppSpacing.md),
        TrickCategoryCard(
          title: '高度なトリック',
          description: '回転、ジャンプ、ダンスなど',
          icon: Icons.star_half,
          color: AppColors.pointBlue,
          onTap: () => onCategoryTap('高度なトリック'),
        ),
        const SizedBox(height: AppSpacing.md),
        TrickCategoryCard(
          title: '芸術的トリック',
          description: '絵を描く、楽器を演奏するなど',
          icon: Icons.auto_awesome,
          color: AppColors.pointBrown,
          onTap: () => onCategoryTap('芸術的トリック'),
        ),
        const SizedBox(height: AppSpacing.md),
        TrickCategoryCard(
          title: 'スポーツトリック',
          description: 'アジリティ、フリスビーなど',
          icon: Icons.sports_soccer,
          color: AppColors.pointPink,
          onTap: () => onCategoryTap('スポーツトリック'),
        ),
      ],
    );
  }
}