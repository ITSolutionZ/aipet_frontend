import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 학습할 트릭 카드
class LearnTrickCard extends StatelessWidget {
  final TrickEntity trick;
  final VoidCallback? onTap;

  const LearnTrickCard({super.key, required this.trick, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 트릭 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: trick.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        child: Image.asset(trick.imagePath!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.pets,
                        color: AppColors.pointBrown,
                        size: 30,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),

              // 트릭 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trick.name,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      trick.description,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _buildDifficultyChip(trick.difficulty),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${trick.estimatedTime}分',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 학습 시작 버튼
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.pointGreen,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(DifficultyLevel difficulty) {
    Color color;
    String text;

    switch (difficulty) {
      case DifficultyLevel.easy:
        color = AppColors.pointGreen;
        text = '簡単';
        break;
      case DifficultyLevel.medium:
        color = AppColors.pointBlue;
        text = '普通';
        break;
      case DifficultyLevel.hard:
        color = AppColors.pointBrown;
        text = '難しい';
        break;
      case DifficultyLevel.expert:
        color = AppColors.pointPink;
        text = '専門家';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        text,
        style: AppFonts.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
