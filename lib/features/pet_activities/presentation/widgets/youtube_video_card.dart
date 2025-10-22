import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube 비디오 카드
class YouTubeVideoCard extends StatefulWidget {
  final YouTubeVideoEntity video;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onDeleteTap;
  final bool isPlaying;
  final VoidCallback? onPlayToggle;

  const YouTubeVideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onBookmarkTap,
    this.onDeleteTap,
    this.isPlaying = false,
    this.onPlayToggle,
  });

  @override
  State<YouTubeVideoCard> createState() => _YouTubeVideoCardState();
}

class _YouTubeVideoCardState extends State<YouTubeVideoCard> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPlaying) {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(YouTubeVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _initializePlayer();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _disposePlayer();
    }
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: false,
        forceHD: true,
        enableCaption: true,
      ),
    );
    _controller!.addListener(_listener);
  }

  void _disposePlayer() {
    if (_controller != null) {
      _controller!.removeListener(_listener);
      _controller!.dispose();
      _controller = null;
    }
  }

  void _listener() {
    if (_isPlayerReady && mounted && _controller != null && _controller!.value.isReady) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 또는 플레이어
            widget.isPlaying ? _buildPlayer() : _buildThumbnail(),

            // 비디오 정보
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    widget.video.title,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // 설명
                  if (widget.video.description != null) ...[
                    Text(
                      widget.video.description!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  // 태그
                  if (widget.video.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: widget.video.tags
                          .take(3)
                          .map((tag) => _buildTagChip(tag))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // 하단 정보
                  Row(
                    children: [
                      // 재생 시간
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text(
                          widget.video.formattedDuration,
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // 액션 버튼들
                      if (widget.onBookmarkTap != null)
                        IconButton(
                          onPressed: widget.onBookmarkTap,
                          icon: const Icon(Icons.bookmark_border),
                          color: AppColors.pointBrown,
                          iconSize: 20,
                        ),
                      if (widget.onDeleteTap != null)
                        IconButton(
                          onPressed: widget.onDeleteTap,
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

  /// 플레이어 빌드
  Widget _buildPlayer() {
    // _controller는 isPlaying=true일 때 반드시 초기화되어 있음
    if (_controller == null) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.md),
          topRight: Radius.circular(AppSpacing.md),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.md),
          topRight: Radius.circular(AppSpacing.md),
        ),
        child: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.pointBlue,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.pointBlue,
            handleColor: AppColors.pointBlue,
          ),
          onReady: () {
            _isPlayerReady = true;
          },
        ),
      ),
    );
  }

  /// 썸네일 빌드
  Widget _buildThumbnail() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.md),
          topRight: Radius.circular(AppSpacing.md),
        ),
        image: DecorationImage(
          image: NetworkImage(widget.video.thumbnailUrl ?? ''),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // YouTube 배지
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
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

          // 플레이 버튼
          Center(
            child: GestureDetector(
              onTap: widget.onPlayToggle,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),

          // 재생 시간
          Positioned(
            bottom: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                widget.video.formattedDuration,
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

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.3)),
      ),
      child: Text(
        tag,
        style: AppFonts.bodySmall.copyWith(
          color: AppColors.pointBrown,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
