import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 유튜브 비디오 타임라인 섹션 위젯
class YouTubeTimelineSection extends StatelessWidget {
  final List<YouTubeTimelineEntity> timelineSections;
  final Function(YouTubeTimelineEntity) onSectionTap;
  final Function(YouTubeTimelineEntity) onBookmarkTap;

  const YouTubeTimelineSection({
    super.key,
    required this.timelineSections,
    required this.onSectionTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (timelineSections.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '타임라인 섹션',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${timelineSections.length}개 섹션',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...timelineSections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: index < timelineSections.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _buildTimelineItem(section),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '타임라인 섹션이 없습니다',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '비디오 설명에서 시간 정보를 찾을 수 없습니다',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(YouTubeTimelineEntity section) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSectionTap(section),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // 썸네일
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    color: AppColors.pointBrown.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Image.network(
                      section.thumbnailUrlGenerated,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.pointBrown,
                          size: 24,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 섹션 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: AppFonts.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        section.timeRange,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (section.description != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          section.description!,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // 북마크 버튼
                IconButton(
                  onPressed: () => onBookmarkTap(section),
                  icon: const Icon(
                    Icons.bookmark_border,
                    color: AppColors.pointBrown,
                    size: 20,
                  ),
                  tooltip: '북마크 추가',
                ),

                // 재생 버튼
                IconButton(
                  onPressed: () => onSectionTap(section),
                  icon: const Icon(
                    Icons.play_arrow,
                    color: AppColors.pointBlue,
                    size: 24,
                  ),
                  tooltip: '섹션 재생',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
