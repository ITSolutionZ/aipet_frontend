import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// お気に入り画面
///
/// ユーザーがお気に入りに追加した項目を表示
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        title: const Text('お気に入り'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '施設'),
            Tab(text: '散歩コース'),
            Tab(text: '商品'),
            Tab(text: 'その他'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFacilityFavorites(),
          _buildWalkCourseFavorites(),
          _buildProductFavorites(),
          _buildOtherFavorites(),
        ],
      ),
    );
  }

  /// 施設のお気に入り
  Widget _buildFacilityFavorites() {
    // TODO: 実際のお気に入り施設データを表示
    return _buildEmptyState(
      icon: Icons.location_on,
      title: 'お気に入りの施設がありません',
      message: '動物病院やペットカフェなどをお気に入りに追加できます',
      actionLabel: '施設を探す',
      onAction: () {
        context.push('/facility-list');
      },
    );
  }

  /// 散歩コースのお気に入り
  Widget _buildWalkCourseFavorites() {
    // TODO: 実際のお気に入り散歩コースデータを表示
    return _buildEmptyState(
      icon: Icons.directions_walk,
      title: 'お気に入りの散歩コースがありません',
      message: 'よく行く散歩コースをお気に入りに追加できます',
      actionLabel: '散歩記録を見る',
      onAction: () {
        context.push('/walk/calendar');
      },
    );
  }

  /// 商品のお気に入り
  Widget _buildProductFavorites() {
    // TODO: 実際のお気に入り商品データを表示
    return _buildEmptyState(
      icon: Icons.shopping_bag,
      title: 'お気に入りの商品がありません',
      message: 'ペット用品や食品をお気に入りに追加できます',
      actionLabel: '商品を探す',
      onAction: () {
        context.push('/pet-search');
      },
    );
  }

  /// その他のお気に入り
  Widget _buildOtherFavorites() {
    return _buildEmptyState(
      icon: Icons.bookmark,
      title: 'その他のお気に入りがありません',
      message: 'さまざまな情報をお気に入りに追加できます',
    );
  }

  /// 空の状態表示
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
