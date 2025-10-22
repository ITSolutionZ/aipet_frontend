import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/add_bookmark_dialog.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/youtube_timeline_section.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// 유튜브 비디오 플레이어 화면
class YouTubePlayerScreen extends ConsumerStatefulWidget {
  final YouTubeVideoEntity video;
  final int? startTimeSec;
  final List<YouTubeTimelineEntity> timelineSections;
  final List<VideoBookmarkEntity> bookmarks;

  const YouTubePlayerScreen({
    super.key,
    required this.video,
    this.startTimeSec,
    this.timelineSections = const [],
    this.bookmarks = const [],
  });

  @override
  ConsumerState<YouTubePlayerScreen> createState() =>
      _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends ConsumerState<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _showTimeline = false;
  List<VideoBookmarkEntity> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _bookmarks = List.from(widget.bookmarks);
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeVideoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: false,
        forceHD: true,
        enableCaption: true,
        showLiveFullscreenButton: true,
        startAt: widget.startTimeSec ?? 0,
      ),
    );

    _controller.addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && _controller.value.isReady) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  /// 북마크 추가
  void _addBookmark() {
    final currentPosition = _controller.value.position.inSeconds;

    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        videoId: widget.video.youtubeVideoId,
        currentPositionSec: currentPosition,
        onBookmarkAdded: (bookmark) {
          setState(() {
            _bookmarks.add(bookmark);
          });
          UiService.showSuccess(context, '북마크가 추가되었습니다');
        },
      ),
    );
  }

  /// 북마크로 이동
  void _jumpToBookmark(VideoBookmarkEntity bookmark) {
    _controller.seekTo(Duration(seconds: bookmark.positionSec));
  }

  /// 타임라인 섹션으로 이동
  void _jumpToTimelineSection(YouTubeTimelineEntity section) {
    _controller.seekTo(Duration(seconds: section.startTimeSec));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _addBookmark,
            icon: const Icon(Icons.bookmark_add, color: Colors.white),
            tooltip: '북마크 추가',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showTimeline = !_showTimeline;
              });
            },
            icon: Icon(
              _showTimeline ? Icons.timeline : Icons.timeline_outlined,
              color: Colors.white,
            ),
            tooltip: '타임라인 토글',
          ),
        ],
      ),
      body: Column(
        children: [
          // 유튜브 플레이어
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.pointBlue,
            progressColors: const ProgressBarColors(
              playedColor: AppColors.pointBlue,
              handleColor: AppColors.pointBlue,
            ),
            onReady: () {
              _isPlayerReady = true;
            },
            onEnded: (data) {
              // 비디오 종료 시 처리
            },
          ),

          // 타임라인 및 북마크 섹션
          if (_showTimeline) ...[
            Container(height: 1, color: Colors.grey[800]),
            Expanded(
              child: Container(
                color: Colors.grey[900],
                child: Column(
                  children: [
                    // 탭 바
                    Container(
                      color: Colors.grey[800],
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              '타임라인',
                              Icons.timeline,
                              true,
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              '북마크',
                              Icons.bookmark,
                              false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 콘텐츠
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _showTimeline = isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.pointBlue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.pointBlue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.timelineSections.isNotEmpty) {
      return YouTubeTimelineSection(
        timelineSections: widget.timelineSections,
        onSectionTap: _jumpToTimelineSection,
        onBookmarkTap: (section) {
          // 타임라인 섹션에서 북마크 추가
          _addBookmark();
        },
      );
    } else if (_bookmarks.isNotEmpty) {
      return _buildBookmarksList();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildBookmarksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _bookmarks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: ListTile(
            leading: const Icon(Icons.bookmark, color: AppColors.pointBrown),
            title: Text(
              bookmark.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              bookmark.formattedTime,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              onPressed: () => _jumpToBookmark(bookmark),
              icon: const Icon(Icons.play_arrow, color: AppColors.pointBlue),
            ),
            onTap: () => _jumpToBookmark(bookmark),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[600]),
          const SizedBox(height: AppSpacing.md),
          Text(
            '타임라인 섹션이나 북마크가 없습니다',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '비디오를 시청하면서 북마크를 추가해보세요',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: _addBookmark,
            icon: const Icon(Icons.bookmark_add),
            label: const Text('북마크 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
