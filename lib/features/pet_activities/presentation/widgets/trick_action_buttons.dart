import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 트릭 액션 버튼들
class TrickActionButtons extends StatelessWidget {
  final VoidCallback onOpenTrainingVideos;

  const TrickActionButtons({super.key, required this.onOpenTrainingVideos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 유튜브 교육 영상 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onOpenTrainingVideos,
            icon: const Icon(Icons.video_library),
            label: const Text('トレーニングビデオ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 모든 트릭 보기 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.push(RouteConstants.allTricksDetailRoute);
            },
            icon: const Icon(Icons.list),
            label: const Text('すべてのトリック'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointBrown,
              side: const BorderSide(color: AppColors.pointBrown),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
