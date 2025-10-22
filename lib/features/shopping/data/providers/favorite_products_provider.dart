import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/favorite_product_model.dart';
import '../services/favorite_service.dart';

part 'favorite_products_provider.g.dart';

/// お気に入り商品状態
@riverpod
class FavoriteProductsNotifier extends _$FavoriteProductsNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  @override
  Future<List<FavoriteProduct>> build() async {
    return await _favoriteService.getFavoriteProducts();
  }

  /// お気に入りに追加
  Future<bool> addFavorite(FavoriteProduct product) async {
    final success = await _favoriteService.addFavoriteProduct(product);

    if (success) {
      // 状態を更新
      ref.invalidateSelf();
    }

    return success;
  }

  /// お気に入りから削除
  Future<bool> removeFavorite(String itemCode) async {
    final success = await _favoriteService.removeFavoriteProduct(itemCode);

    if (success) {
      // 状態を更新
      ref.invalidateSelf();
    }

    return success;
  }

  /// 商品がお気に入りかチェック
  Future<bool> isFavorite(String itemCode) async {
    return await _favoriteService.isFavorite(itemCode);
  }

  /// すべてクリア
  Future<bool> clearAll() async {
    final success = await _favoriteService.clearAllFavorites();

    if (success) {
      // 状態を更新
      ref.invalidateSelf();
    }

    return success;
  }

  /// 再読み込み
  Future<void> reload() async {
    ref.invalidateSelf();
  }
}
