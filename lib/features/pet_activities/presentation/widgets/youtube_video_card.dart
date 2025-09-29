import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// YouTube 비디오 카드
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            _buildThumbnail(),

            // 비디오 정보
            Padding(
              padding: const const const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    video.title,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const const const SizedBox(height: AppSpacing.xs),

                  // 설명
                  if (video.description != null) ...[
                    Text(
                      video.description!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const const const SizedBox(height: AppSpacing.xs),
                  ],

                  // 태그
                  if (video.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: video.tags
                          .take(3)
                          .map((tag) => _buildTagChip(tag))
                          .toList(),
                    ),
                    const const const SizedBox(height: AppSpacing.sm),
                  ],

                  // 하단 정보
                  Row(
                    children: [
                      // 재생 시간
                      Container(
                        padding: const const const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // 액션 버튼들
                      if (onBookmarkTap != null)
                        IconButton(
                          onPressed: onBookmarkTap,
                          icon: const Icon(Icons.bookmark_border),
                          color: AppColors.pointBrown,
                          iconSize: 20,
                        ),
                      if (onDeleteTap != null)
                        IconButton(
                          onPressed: onDeleteTap,
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.error,
                          iconSize: 20,
                        ),
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
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.md),
          topRight: Radius.circular(AppSpacing.md),
        ),
      ),
      child: Stack(
        children: [
          // 썸네일 이미지
          if (video.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.md),
                topRight: Radius.circular(AppSpacing.md),
              ),
              child: Image.network(
                video.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
            )
          else
            _buildPlaceholder(),

          // 재생 버튼
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          // YouTube 로고
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const const const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                'YouTube',
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.md),
          topRight: Radius.circular(AppSpacing.md),
        ),
      ),
      child: const Icon(
        Icons.video_library,
        color: AppColors.pointBrown,
        size: 48,
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const const const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        tag,
        style: AppFonts.bodySmall.copyWith(
          color: AppColors.pointBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
