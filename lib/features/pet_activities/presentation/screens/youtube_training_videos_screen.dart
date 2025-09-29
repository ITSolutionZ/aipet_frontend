import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/controllers/youtube_videos_controller.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/add_youtube_video_button.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/add_youtube_video_dialog.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/video_bookmark_list.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_search_bar.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_tag_filter.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_video_list.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _loadVideos() {
    _controller.loadYouTubeVideos(widget.petId);
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
      _loadVideos();
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
        ).showSnackBar(const SnackBar(content: Text('YouTubeアプリケーションを開きません。')));
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
      appBar: const SoftGradientBackAppBar(title: 'トレーニングビデオ'),
      body: Column(
        children: [
          // 검색 바
          YouTubeSearchBar(
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          // 태그 필터
          _buildTagFilter(),

          // Add Video 버튼
          AddYouTubeVideoButton(onPressed: _addVideo),

          // 비디오 목록
          Expanded(
            child: videosState.when(
              data: (videos) => YouTubeVideoList(
                videos: videos,
                searchQuery: _searchQuery,
                selectedTags: _selectedTags,
                onVideoTap: _openVideo,
                onBookmarkTap: _showBookmarks,
                onDeleteTap: _deleteVideo,
                onAddVideo: _addVideo,
              ),
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
                    const const const SizedBox(height: AppSpacing.md),
                    Text(
                      'ビデオの読み込みに失敗しました',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                      ),
                    ),
                    const const const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _loadVideos,
                      child: const Text('再試行'),
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

  Widget _buildTagFilter() {
    // 모든 비디오에서 사용된 태그들 수집
    final videosState = ref.watch(youTubeVideosProvider(widget.petId));
    final allTags = <String>{};

    videosState.whenData((videos) {
      for (final video in videos) {
        allTags.addAll(video.tags);
      }
    });

    return YouTubeTagFilter(
      allTags: allTags,
      selectedTags: _selectedTags,
      onTagToggle: (tag) {
        setState(() {
          if (_selectedTags.contains(tag)) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
    );
  }

  Future<void> _deleteVideo(YouTubeVideoEntity video) async {
    await ConfirmationDialogComponent.showDelete(
      context: context,
      title: 'ビデオを削除しますか？',
      message: '「${video.title}」を削除しますか？',
      onConfirm: () async {
        await _controller.deleteVideo(video.id);
        _loadVideos();
      },
    );
  }
}
