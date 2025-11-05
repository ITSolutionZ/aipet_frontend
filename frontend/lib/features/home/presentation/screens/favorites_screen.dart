import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/shopping/data/providers/favorite_products_provider.dart';

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
    final favoritesAsync = ref.watch(favoriteProductsProvider);

    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) {
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

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final product = favorites[index];
            return _buildProductCard(product);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppSpacing.md),
              Text(
                'エラーが発生しました',
                style: AppFonts.titleMedium.copyWith(color: Colors.red),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 商品カード
  Widget _buildProductCard(dynamic product) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: () => _openProductPage(product.itemUrl),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品画像
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  color: AppColors.pointOffWhite,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.pets, size: 30);
                          },
                        )
                      : const Icon(Icons.pets, size: 30),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 商品情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.itemName,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      product.shopName,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      product.formattedPrice,
                      style: AppFonts.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointBrown,
                      ),
                    ),
                    if (product.reviewCount != null &&
                        product.reviewCount!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            product.formattedReviewAverage,
                            style: AppFonts.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.formattedReviewCount})',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // 削除ボタン
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeFavorite(product.itemCode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 商品ページを開く
  Future<void> _openProductPage(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      LoggerService.debug('Failed to open product page: $e');
    }
  }

  /// お気に入りから削除
  Future<void> _removeFavorite(String itemCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('お気に入りから削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(favoriteProductsProvider.notifier)
          .removeFavorite(itemCode);

      if (mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showWarning(
          context,
          'お気に入りから削除しました',
          duration: const Duration(seconds: 2),
        );
      }
    }
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
