import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// YouTube 비디오가 없을 때 표시되는 빈 상태 위젯
class YouTubeVideosEmptyState extends StatelessWidget {
  final String? message;
  final VoidCallback? onAddVideo;

  const YouTubeVideosEmptyState({super.key, this.message, this.onAddVideo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const const const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 빈 상태 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.video_library,
                size: 60,
                color: AppColors.pointBlue,
              ),
            ),
            const const const SizedBox(height: AppSpacing.xl),

            // 메시지
            Text(
              message ?? 'トレーニングビデオがありません',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const const const SizedBox(height: AppSpacing.md),

            Text(
              'YouTubeビデオを追加して\nペットのトレーニングを始めましょう',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const const const SizedBox(height: AppSpacing.xl),

            // 비디오 추가 버튼
            if (onAddVideo != null)
              ElevatedButton.icon(
                onPressed: onAddVideo,
                icon: const Icon(Icons.add),
                label: const Text('ビデオを追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBlue,
                  foregroundColor: Colors.white,
                  padding: const const const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
