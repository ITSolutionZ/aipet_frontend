import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/board/data/models/board_post_model.dart';

/// 掲示板詳細画面
class BoardDetailScreen extends StatefulWidget {
  final String postId;
  final BoardPost? post;

  const BoardDetailScreen({super.key, required this.postId, this.post});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  late bool _isLiked;
  late int _likeCount;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.post?.likeCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: '投稿詳細'),
      body: widget.post != null ? _buildPostDetail() : _buildNotFound(),
    );
  }

  Widget _buildPostDetail() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像ギャラリー
          if (widget.post!.imageUrls.isNotEmpty) ...[_buildImageGallery()],

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 著者情報
                _buildAuthorSection(),
                const SizedBox(height: AppSpacing.lg),

                // タイトル
                Text(
                  widget.post!.title,
                  style: AppFonts.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 統計情報バー
                _buildStatsBar(),
                const SizedBox(height: AppSpacing.lg),

                // 分割線
                Divider(color: AppColors.pointGray.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.lg),

                // コンテンツ
                Text(
                  widget.post!.content,
                  style: AppFonts.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.8,
                  ),
                ),

                // タグ
                if (widget.post!.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: widget.post!.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pointOffWhite,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          border: Border.all(
                            color: AppColors.pointBrown.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // 分割線
                Divider(color: AppColors.pointGray.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.lg),

                // アクションボタン
                _buildActionButtons(),

                const SizedBox(height: AppSpacing.xl),

                // コメントセクション
                _buildCommentsSection(),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: widget.post!.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Image ${index + 1}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
              // インジケーター
              Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${widget.post!.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
          child: Text(
            widget.post!.authorName.isNotEmpty
                ? widget.post!.authorName[0]
                : '?',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post!.authorName,
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.pointDark,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.post!.relativeTime,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.post!.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.post!.category,
                      style: AppFonts.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.visibility_outlined,
            '${widget.post!.viewCount}',
            'viewed',
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.pointGray.withValues(alpha: 0.2),
          ),
          _buildStatItem(Icons.favorite_outline, '$_likeCount', 'liked'),
          Container(
            width: 1,
            height: 30,
            color: AppColors.pointGray.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            Icons.comment_outlined,
            '${widget.post!.commentCount}',
            'comments',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.pointGray),
        const SizedBox(height: 4),
        Text(
          count,
          style: AppFonts.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 好きボタン
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleLike,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _isLiked
                      ? AppColors.pointBrown.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: _isLiked
                        ? AppColors.pointBrown
                        : AppColors.pointGray.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_outline,
                      color: _isLiked
                          ? AppColors.pointBrown
                          : AppColors.pointGray,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _isLiked ? 'いいね済み' : 'いいね',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isLiked
                            ? AppColors.pointBrown
                            : AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // シェアボタン
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _sharePost,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: AppColors.pointGray.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      color: AppColors.pointGray,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'シェア',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'コメント (${widget.post!.commentCount})',
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // サンプルコメント
        _buildCommentItem('鈴木太郎', '大変参考になりました！', '1時間前'),
        const SizedBox(height: AppSpacing.md),
        _buildCommentItem('山田花子', 'こちらも同じ悩みがありました。', '3時間前'),
        const SizedBox(height: AppSpacing.lg),

        // コメント追加フォーム
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: AppColors.pointGray.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'コメントを入力...',
                  hintStyle: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 3,
                style: AppFonts.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      UiService.showSuccess(context, 'コメント送信準備中です');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                    ),
                    child: const Text(
                      '送信',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(String author, String text, String time) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
                child: Text(
                  author.isNotEmpty ? author[0] : '?',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: AppFonts.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.pointGray),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '投稿が見つかりませんでした',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '投稿ID: ${widget.postId}',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });
    UiService.showSuccess(context, _isLiked ? 'いいねしました！' : 'いいねを取り消しました');
  }

  Future<void> _sharePost() async {
    try {
      await Share.share(
        '${widget.post!.title}\n\n${widget.post!.content}',
        subject: widget.post!.title,
      );
    } on Exception catch (e) {
      if (mounted) {
        UiService.showError(context, 'シェアに失敗しました');
      }
      debugPrint('シェアエラー: $e');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '質問':
        return const Color(0xFF2196F3);
      case '情報共有':
        return const Color(0xFF4CAF50);
      case 'レビュー':
        return const Color(0xFFFF9800);
      case '日常':
        return const Color(0xFFE91E63);
      case '健康・医療':
        return const Color(0xFFF44336);
      case 'しつけ・訓練':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.pointBrown;
    }
  }
}
