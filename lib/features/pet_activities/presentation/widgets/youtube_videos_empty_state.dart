import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// YouTube 영상이 없을 때의 빈 상태 위젯
class YouTubeVideosEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onAddVideo;

  const YouTubeVideosEmptyState({
    super.key,
    required this.hasFilters,
    required this.onAddVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 64,
            color: AppColors.pointBrown,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasFilters
                ? '現在のフィルターでは動画が見つかりません'
                : 'まだトレーニング動画がありません',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: onAddVideo,
            icon: const Icon(Icons.add),
            label: const Text('最初の動画を追加'),
          ),
        ],
      ),
    );
  }
}