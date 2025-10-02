import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 트릭 카드 위젯
///
/// 개별 트릭의 정보를 보여주는 카드 위젯입니다.
class TrickCard extends StatelessWidget {
  final TrickEntity trick;
  final VoidCallback? onTap;
  final VoidCallback? onStartLearning;

  const TrickCard({super.key, required this.trick, this.onTap, this.onStartLearning});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      children: [
        // 트릭 이미지
        _buildTrickImage(),
        const SizedBox(width: AppSpacing.md),

        // 트릭 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 트릭 이름
              Text(
                trick.name,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.xs),

              // 설명 (있는 경우)
              if (trick.description.isNotEmpty == true) ...[
                Text(
                  trick.description,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // 난이도와 진행도
              Row(
                children: [
                  // 난이도 태그
                  _buildDifficultyChip(),
                  const Spacer(),
                  // 진행도 (학습 중인 경우)
                  if (trick.practiceCount > 0) _buildProgressIndicator(),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // 액션 버튼
        _buildActionButton(),
      ],
    );
  }

  Widget _buildTrickImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.small),
        color: AppColors.pointOffWhite,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: trick.imagePath != null
            ? Image.asset(
                trick.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.pointBrown.withValues(alpha: 0.1),
      child: const Center(child: Icon(Icons.pets, color: AppColors.pointBrown, size: 24)),
    );
  }

  Widget _buildDifficultyChip() {
    final difficulty = trick.difficulty.name;
    final color = _getDifficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: AppFonts.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${trick.progress}%',
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 40,
          height: 4,
          child: LinearProgressIndicator(
            value: trick.progress,
            backgroundColor: AppColors.pointDark.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pointBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final isLearned = trick.progress >= 100;
    final isLearning = trick.progress < 100;

    if (isLearned) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(color: AppColors.pointGreen, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }

    return IconButton(
      onPressed: onStartLearning,
      icon: Icon(
        isLearning ? Icons.play_circle_fill : Icons.play_circle_outline,
        color: AppColors.pointBlue,
        size: 28,
      ),
      tooltip: isLearning ? '学習を継続' : '学習を開始',
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
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
