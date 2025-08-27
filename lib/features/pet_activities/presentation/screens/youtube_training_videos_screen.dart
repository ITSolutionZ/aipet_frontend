import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/entities.dart';
import '../controllers/youtube_videos_controller.dart';
import '../widgets/add_youtube_video_dialog.dart';
import '../widgets/video_bookmark_list.dart';
import '../widgets/youtube_video_card.dart';

/// YouTube 교육 영상 관리 화면
class YouTubeTrainingVideosScreen extends ConsumerStatefulWidget {
  final String petId;

  const YouTubeTrainingVideosScreen({super.key, required this.petId});

  @override
  ConsumerState<YouTubeTrainingVideosScreen> createState() =>
      _YouTubeTrainingVideosScreenState();
}

class _YouTubeTrainingVideosScreenState
    extends ConsumerState<YouTubeTrainingVideosScreen> {
  late YouTubeVideosController _controller;
  String _searchQuery = '';
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _controller = YouTubeVideosController(ref, context);
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    await _controller.loadYouTubeVideos(widget.petId);
  }

  Future<void> _addVideo() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddYouTubeVideoDialog(petId: widget.petId),
    );

    if (result != null) {
      await _controller.registerVideo(
        youtubeUrl: result['url'],
        title: result['title'],
        description: result['description'],
        tags: List<String>.from(result['tags']),
        petId: widget.petId,
      );
      await _loadVideos();
    }
  }

  Future<void> _openVideo(YouTubeVideoEntity video, {int? startTime}) async {
    final url = startTime != null
        ? video.getYouTubeUrlWithTime(startTime)
        : video.youtubeUrl;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('YouTube 앱을 열 수 없습니다.')));
      }
    }
  }

  void _showBookmarks(YouTubeVideoEntity video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoBookmarkList(
        videoId: video.id,
        youtubeVideoId: video.youtubeVideoId,
        onBookmarkTap: (bookmark) {
          Navigator.pop(context);
          _openVideo(video, startTime: bookmark.positionSec);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(youTubeVideosProvider(widget.petId));

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Training Videos',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.pointDark),
            onPressed: _addVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          _buildSearchBar(),

          // 태그 필터
          _buildTagFilter(),

          // 비디오 목록
          Expanded(
            child: videosState.when(
              data: (videos) => _buildVideoList(videos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.pointBrown,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Error loading videos',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _loadVideos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search training videos...',
          prefixIcon: Icon(Icons.search, color: AppColors.pointDark),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildTagFilter() {
    // 모든 비디오에서 사용된 태그들 수집
    final videosState = ref.watch(youTubeVideosProvider(widget.petId));
    final allTags = <String>{};

    videosState.whenData((videos) {
      for (final video in videos) {
        allTags.addAll(video.tags);
      }
    });

    if (allTags.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allTags.length,
        itemBuilder: (context, index) {
          final tag = allTags.elementAt(index);
          final isSelected = _selectedTags.contains(tag);

          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
              checkmarkColor: AppColors.pointBrown,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoList(List<YouTubeVideoEntity> videos) {
    // 필터링된 비디오 목록
    var filteredVideos = videos;

    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredVideos = filteredVideos.where((video) {
        return video.title.toLowerCase().contains(query) ||
            video.description?.toLowerCase().contains(query) == true ||
            video.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // 태그 필터
    if (_selectedTags.isNotEmpty) {
      filteredVideos = filteredVideos.where((video) {
        return video.tags.any((tag) => _selectedTags.contains(tag));
      }).toList();
    }

    if (filteredVideos.isEmpty) {
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
              _searchQuery.isNotEmpty || _selectedTags.isNotEmpty
                  ? 'No videos found for the current filters'
                  : 'No training videos yet',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _addVideo,
              icon: const Icon(Icons.add),
              label: const Text('Add First Video'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: YouTubeVideoCard(
            video: video,
            onTap: () => _openVideo(video),
            onBookmarkTap: () => _showBookmarks(video),
            onDeleteTap: () => _deleteVideo(video),
          ),
        );
      },
    );
  }

  Future<void> _deleteVideo(YouTubeVideoEntity video) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Are you sure you want to delete "${video.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteVideo(video.id);
      await _loadVideos();
    }
  }
}
