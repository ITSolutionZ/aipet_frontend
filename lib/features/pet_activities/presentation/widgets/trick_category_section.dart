import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

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
    if (tricks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            _getCategoryDisplayName(category),
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 트릭 목록
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tricks.length,
          itemBuilder: (context, index) {
            final trick = tricks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: _buildTrickCard(trick),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildTrickCard(TrickEntity trick) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: () => onShowTrickDetail(trick),
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

              // 시작 버튼
              IconButton(
                onPressed: () => onStartLearning(trick),
                icon: const Icon(Icons.play_arrow, color: AppColors.pointGreen),
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

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'easy':
        return '簡単なトリック';
      case 'medium':
        return '普通のトリック';
      case 'hard':
        return '難しいトリック';
      case 'expert':
        return '専門家レベルのトリック';
      default:
        return category;
    }
  }
}
