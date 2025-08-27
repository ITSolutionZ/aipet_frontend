import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/youtube_video_entity.dart';

/// YouTube 비디오 카드 위젯
class YouTubeVideoCard extends StatelessWidget {
  final YouTubeVideoEntity video;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onDeleteTap;

  const YouTubeVideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onBookmarkTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 영역
            _buildThumbnail(),

            // 비디오 정보 영역
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 액션 버튼
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          style: AppFonts.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildActionButtons(),
                    ],
                  ),

                  if (video.description?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      video.description!,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  // 지속 시간과 태그
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.pointDark.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        video.formattedDuration,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      if (video.tags.isNotEmpty) _buildTags(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.medium),
            topRight: Radius.circular(AppRadius.medium),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: video.thumbnailUrl != null
                ? Image.network(
                    video.thumbnailUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.pointOffWhite,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.pointBrown,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorThumbnail(),
                  )
                : _buildErrorThumbnail(),
          ),
        ),

        // 재생 버튼
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorThumbnail() {
    return Container(
      color: AppColors.pointOffWhite,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 48, color: AppColors.pointBrown),
            SizedBox(height: AppSpacing.xs),
            Text(
              'YouTube Video',
              style: TextStyle(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onBookmarkTap != null)
          IconButton(
            onPressed: onBookmarkTap,
            icon: const Icon(
              Icons.bookmark,
              size: 20,
              color: AppColors.pointBlue,
            ),
            tooltip: 'Bookmarks',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        if (onDeleteTap != null)
          IconButton(
            onPressed: onDeleteTap,
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            tooltip: 'Delete',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  Widget _buildTags() {
    final displayTags = video.tags.take(3).toList();

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        ...displayTags.map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Text(
              tag,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBrown,
                fontSize: 10,
              ),
            ),
          ),
        ),
        if (video.tags.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.pointDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Text(
              '+${video.tags.length - 3}',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
