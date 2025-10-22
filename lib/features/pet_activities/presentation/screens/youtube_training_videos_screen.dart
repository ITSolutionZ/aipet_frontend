import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/data/services/youtube_timeline_service.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/controllers/youtube_videos_controller.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/add_bookmark_dialog.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/add_youtube_video_button.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/add_youtube_video_dialog.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/video_bookmark_list.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_search_bar.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_tag_filter.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_timeline_section.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_video_list.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  late YoutubePlayerController _youtubeController;
  String _searchQuery = '';
  final List<String> _selectedTags = [];
  List<YouTubeTimelineEntity> _timelineSections = [];
  final List<VideoBookmarkEntity> _bookmarks = [];
  YouTubeVideoEntity? _selectedVideo;
  String? _playingVideoId;

  @override
  void initState() {
    super.initState();
    _controller = YouTubeVideosController(ref, context);
    // 초기 YouTube 플레이어 컨트롤러 (더미 비디오 ID로 시작)
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'dQw4w9WgXcQ', // 초기 비디오 ID
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
    _loadVideos();
  }

  void _loadVideos() {
    _controller.loadYouTubeVideos(widget.petId);
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
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
    // 비디오 재생 상태 토글
    setState(() {
      if (_playingVideoId == video.id) {
        // 같은 비디오를 다시 클릭하면 재생 중지
        _playingVideoId = null;
        _selectedVideo = null;
        _timelineSections = [];
      } else {
        // 다른 비디오를 클릭하면 해당 비디오 재생
        _playingVideoId = video.id;
        _selectedVideo = video;
        _timelineSections = [];
      }
    });

    // YouTube 플레이어 업데이트
    if (_playingVideoId != null && _selectedVideo != null) {
      try {
        _youtubeController.load(_selectedVideo!.youtubeVideoId);
        if (startTime != null) {
          _youtubeController.seekTo(
            Duration(seconds: startTime),
            allowSeekAhead: true,
          );
        }
        // 자동 재생
        _youtubeController.play();
      } catch (e) {
        debugPrint('❌ YouTube 비디오 로드 실패: $e');
      }
    }

    // 타임라인 섹션 로드
    if (_playingVideoId != null) {
      _loadTimelineSections(video.youtubeVideoId);
    }
  }

  /// 플레이 토글
  void _togglePlay(YouTubeVideoEntity video) {
    setState(() {
      if (_playingVideoId == video.id) {
        _playingVideoId = null;
        _selectedVideo = null;
        _timelineSections = [];
        // 정지
        _youtubeController.pause();
      } else {
        _playingVideoId = video.id;
        _selectedVideo = video;
        _timelineSections = [];
      }
    });

    // YouTube 플레이어 업데이트
    if (_playingVideoId != null && _selectedVideo != null) {
      try {
        _youtubeController.load(_selectedVideo!.youtubeVideoId);
        _youtubeController.play();
      } catch (e) {
        debugPrint('❌ YouTube 비디오 로드 실패: $e');
      }
    }

    // 타임라인 섹션 로드
    if (_playingVideoId != null) {
      _loadTimelineSections(video.youtubeVideoId);
    }
  }

  /// YouTube 비디오의 실제 타임라인 섹션 로드 (백그라운드)
  ///
  /// YouTube API를 통해 비디오 설명란에 등록된 chapters를 추출합니다.
  /// chapters 형식: "0:00 제목", "2:30 - 제목" 등
  ///
  /// 주의: 타임아웃 5초, 초과 시 타임라인이 표시되지 않음
  void _loadTimelineSections(String videoId) {
    // 백그라운드에서 비동기로 로드 (UI 블로킹 없음)
    Future.microtask(() async {
      try {
        debugPrint('⏱️ YouTube Chapters 로드 중...');

        // YouTube API를 통해 실제 chapters 데이터 추출
        final timelineService = YouTubeTimelineService();
        final result = await timelineService.extractTimelineSections(
          videoId: videoId,
        );

        final chapters = result.isSuccess
            ? result.data!
            : <YouTubeTimelineEntity>[];

        if (mounted) {
          setState(() {
            _timelineSections = chapters;
          });

          if (chapters.isEmpty) {
            debugPrint('⚠️ Chapters를 찾을 수 없습니다. 타임라인이 표시되지 않습니다.');
          } else {
            debugPrint('✅ ${chapters.length}개의 Chapters 로드 완료');
          }
        }
      } catch (e) {
        debugPrint('❌ Chapters 로드 실패: $e');
      }
    });
  }

  /// 타임라인 섹션 탭
  void _onTimelineSectionTap(YouTubeTimelineEntity section) {
    if (_selectedVideo != null) {
      _openVideo(_selectedVideo!, startTime: section.startTimeSec);
    }
  }

  /// 북마크 추가
  void _onTimelineBookmarkTap(YouTubeTimelineEntity section) {
    if (_selectedVideo == null) return;

    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        videoId: _selectedVideo!.youtubeVideoId,
        currentPositionSec: section.startTimeSec,
        onBookmarkAdded: (bookmark) {
          setState(() {
            _bookmarks.add(bookmark);
          });
          UiService.showSuccess(context, '북마크가 추가되었습니다');
        },
      ),
    );
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
      body: videosState.when(
        data: (videos) => CustomScrollView(
          slivers: [
            // ヘッダー (検索・フィルター・ボタン)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 検索 바
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

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // YouTube 플레이어 (비디오 선택 시에만 표시)
            if (_selectedVideo != null) ...[
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: AppColors.pointBrown,
                        onReady: () {
                          debugPrint('✅ YouTube プレイヤー準備完了');
                        },
                        onEnded: (metadata) {
                          debugPrint('✅ ビデオ再生完了: ${metadata.videoId}');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            ],

            // 비디오 콘텐츠 영역
            SliverToBoxAdapter(child: _buildVideoContent(videos)),
          ],
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
              const SizedBox(height: AppSpacing.md),
              Text(
                'ビデオの読み込みに失敗しました',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(onPressed: _loadVideos, child: const Text('再試行')),
            ],
          ),
        ),
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

  /// 비디오 콘텐츠 빌드 (비디오 목록 + 타임라인)
  Widget _buildVideoContent(List<YouTubeVideoEntity> videos) {
    return Column(
      children: [
        // 선택된 비디오 정보 (플레이어 아래에 표시)
        if (_selectedVideo != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.pointBrown,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _selectedVideo!.title,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.pointBrown,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _addBookmark(),
                  icon: const Icon(
                    Icons.bookmark_add,
                    color: AppColors.pointBrown,
                    size: 20,
                  ),
                  tooltip: 'ブックマーク追加',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ビデオリストラベル
        if (videos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'トレーニング動画一覧',
                  style: AppFonts.titleSmall.copyWith(
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${videos.length}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),

        // 비디오 목록
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: YouTubeVideoList(
            videos: videos,
            searchQuery: _searchQuery,
            selectedTags: _selectedTags,
            onVideoTap: _openVideo,
            onBookmarkTap: _showBookmarks,
            onDeleteTap: _deleteVideo,
            onAddVideo: _addVideo,
            playingVideoId: _playingVideoId,
            onPlayToggle: _togglePlay,
          ),
        ),

        // タイムラインセクション (下部) - Chaptersが読み込まれたら表示
        if (_selectedVideo != null && _timelineSections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'チャプター',
                    style: AppFonts.titleSmall.copyWith(
                      color: AppColors.pointDark,
                    ),
                  ),
                ),
                YouTubeTimelineSection(
                  timelineSections: _timelineSections,
                  onSectionTap: _onTimelineSectionTap,
                  onBookmarkTap: _onTimelineBookmarkTap,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// 북마크 추가
  void _addBookmark() {
    if (_selectedVideo == null) return;

    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        videoId: _selectedVideo!.youtubeVideoId,
        currentPositionSec: 0, // 현재 재생 위치를 가져와야 함
        onBookmarkAdded: (bookmark) {
          setState(() {
            _bookmarks.add(bookmark);
          });
          UiService.showSuccess(context, '북마크가 추가되었습니다');
        },
      ),
    );
  }
}
