import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_video_card.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_videos_empty_state.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// YouTube 영상 목록 위젯
class YouTubeVideoList extends StatelessWidget {
  final List<YouTubeVideoEntity> videos;
  final String searchQuery;
  final List<String> selectedTags;
  final Function(YouTubeVideoEntity) onVideoTap;
  final Function(YouTubeVideoEntity) onBookmarkTap;
  final Function(YouTubeVideoEntity) onDeleteTap;
  final VoidCallback onAddVideo;

  const YouTubeVideoList({
    super.key,
    required this.videos,
    required this.searchQuery,
    required this.selectedTags,
    required this.onVideoTap,
    required this.onBookmarkTap,
    required this.onDeleteTap,
    required this.onAddVideo,
  });

  @override
  Widget build(BuildContext context) {
    final filteredVideos = _filterVideos();

    if (filteredVideos.isEmpty) {
      return YouTubeVideosEmptyState(onAddVideo: onAddVideo);
    }

    return ListView.builder(
      padding: const const const EdgeInsets.all(AppSpacing.md),
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return RepaintBoundary(
          key: ValueKey('youtube_video_${video.id}_$index'),
          child: Padding(
            padding: const const const EdgeInsets.only(bottom: AppSpacing.md),
            child: YouTubeVideoCard(
              key: ValueKey('youtube_card_${video.id}'),
              video: video,
              onTap: () => onVideoTap(video),
              onBookmarkTap: () => onBookmarkTap(video),
              onDeleteTap: () => onDeleteTap(video),
            ),
          ),
        );
      },
    );
  }

  List<YouTubeVideoEntity> _filterVideos() {
    var filteredVideos = videos;

    // 검색어 필터
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredVideos = filteredVideos.where((video) {
        return video.title.toLowerCase().contains(query) ||
            video.description?.toLowerCase().contains(query) == true ||
            video.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // 태그 필터
    if (selectedTags.isNotEmpty) {
      filteredVideos = filteredVideos.where((video) {
        return video.tags.any((tag) => selectedTags.contains(tag));
      }).toList();
    }

    return filteredVideos;
  }
}
