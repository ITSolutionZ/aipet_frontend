import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

/// 트릭 관련 액션 버튼들
class TrickActionButtons extends StatelessWidget {
  final VoidCallback? onOpenTrainingVideos;

  const TrickActionButtons({
    super.key,
    this.onOpenTrainingVideos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Learn new tricks 버튼
        _LearnNewTricksButton(),
        const SizedBox(height: AppSpacing.lg),
        // Training videos 버튼
        _TrainingVideosButton(onPressed: onOpenTrainingVideos),
        const SizedBox(height: AppSpacing.lg),
        // Pet profile 카드
        const _PetProfileCard(),
      ],
    );
  }
}

/// 새 트릭 학습 버튼
class _LearnNewTricksButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          context.push('/learn-trick');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.pointBlue, width: 2),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
        child: Text(
          '新しいトリックを学ぶ',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 트레이닝 비디오 버튼
class _TrainingVideosButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _TrainingVideosButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed ?? () => context.push('/training-videos'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.pointBlue, width: 2),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
        child: Text(
          'トレーニング動画',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 펫 프로필 카드
class _PetProfileCard extends StatelessWidget {
  const _PetProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/dogs/shiba.png'),
            backgroundColor: AppColors.pointBrown,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Maxi',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}