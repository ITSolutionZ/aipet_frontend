import 'package:aipet_frontend/features/board/data/models/board_post_model.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 게시판 상세 화면
class BoardDetailScreen extends StatelessWidget {
  final String postId;
  final BoardPost? post;

  const BoardDetailScreen({super.key, required this.postId, this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        title: const Text('投稿詳細'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: post != null ? _buildPostDetail() : _buildNotFound(),
    );
  }

  Widget _buildPostDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 정보
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
                child: Text(
                  post!.authorName.isNotEmpty ? post!.authorName[0] : '?',
                  style: AppFonts.bodyMedium.copyWith(
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
                      post!.authorName,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      post!.relativeTime,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ),
              // 카테고리 배지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(post!.category),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  post!.category,
                  style: AppFonts.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 제목
          Text(
            post!.title,
            style: AppFonts.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 내용
          Text(
            post!.content,
            style: AppFonts.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),

          if (post!.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: post!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pointOffWhite,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointBrown,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // 통계 정보
          Row(
            children: [
              _buildStat(Icons.visibility_outlined, post!.viewCount),
              const SizedBox(width: AppSpacing.lg),
              _buildStat(Icons.favorite_outline, post!.likeCount),
              const SizedBox(width: AppSpacing.lg),
              _buildStat(Icons.comment_outlined, post!.commentCount),
            ],
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
            '投稿ID: $postId',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.pointGray),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
      ],
    );
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
