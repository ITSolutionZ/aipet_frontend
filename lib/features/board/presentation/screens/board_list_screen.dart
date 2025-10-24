import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/board_post_model.dart';
import '../../data/services/mock_board_data.dart';

/// 掲示板リスト画面
class BoardListScreen extends ConsumerStatefulWidget {
  const BoardListScreen({super.key});

  @override
  ConsumerState<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends ConsumerState<BoardListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BoardPost> _posts = [];
  String _selectedCategory = '全て';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BoardCategory.values.length,
      vsync: this,
    );
    _posts = MockBoardData.getMockPosts();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = BoardCategory.values[_tabController.index].label;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BoardPost> get _filteredPosts {
    if (_selectedCategory == '全て') {
      return _posts;
    }
    return _posts.where((post) => post.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationScreen(
      child: Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
            kToolbarHeight + 48,
          ), // TabBar 높이 포함
          child: Column(
            children: [
              const SoftGradientAppBar(
                title: '', // 타이틀 삭제
              ),
              Flexible(
                child: Container(
                  color: AppColors.pointBrown,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabAlignment: TabAlignment.start,
                    tabs: BoardCategory.values
                        .map((category) => Tab(text: category.label))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: BoardCategory.values.map((category) {
            return _buildPostList();
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showNewPostDialog,
          backgroundColor: AppColors.pointBrown,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('投稿する', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildPostList() {
    final posts = _filteredPosts;

    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 80,
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '投稿がありません',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '最初の投稿をしてみませんか？',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(BoardPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: () => _navigateToPostDetail(post),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー (著者情報)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.pointBrown.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName[0] : '?',
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
                          post.authorName,
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.relativeTime,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // カテゴリバッジ
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(post.category),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        post.category,
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // タイトル
              Text(
                post.title,
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              // コンテンツプレビュー
              Text(
                post.content,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: post.tags.take(3).map((tag) {
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
              const SizedBox(height: AppSpacing.md),
              // フッター (統計情報)
              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      Icons.visibility_outlined,
                      post.viewCount,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildStat(Icons.favorite_outline, post.likeCount),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildStat(
                      Icons.comment_outlined,
                      post.commentCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.pointGray),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            count.toString(),
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            overflow: TextOverflow.ellipsis,
          ),
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

  Future<void> _refreshPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _posts = MockBoardData.getMockPosts();
    });
  }

  void _navigateToPostDetail(BoardPost post) {
    context.push('/board/${post.id}', extra: post);
  }

  void _showNewPostDialog() {
    SnackBarService.showInfo(
      context,
      '投稿機能は準備中です',
      duration: const Duration(seconds: 2),
    );
  }
}
