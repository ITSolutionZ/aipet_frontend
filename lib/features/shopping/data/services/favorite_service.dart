import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_product_model.dart';

/// お気に入り管理サービス
class FavoriteService {
  static const String _key = 'favorite_products';

  /// お気に入り商品を全て取得
  Future<List<FavoriteProduct>> getFavoriteProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final products = jsonList
          .map((json) => FavoriteProduct.fromJson(json as Map<String, dynamic>))
          .toList();

      // 追加日時の新しい順にソート
      products.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      LoggerService.debug('✅ Loaded ${products.length} favorite products');
      return products;
    } catch (e) {
      LoggerService.debug('⚠️ Failed to load favorite products: $e');
      return [];
    }
  }

  /// お気に入り商品を追加
  Future<bool> addFavoriteProduct(FavoriteProduct product) async {
    try {
      final products = await getFavoriteProducts();

      // 既に存在するかチェック
      if (products.any((p) => p.itemCode == product.itemCode)) {
        LoggerService.debug('⚠️ Product already in favorites: ${product.itemName}');
        return false;
      }

      // 追加
      products.insert(0, product);

      // 保存
      await _saveProducts(products);

      LoggerService.debug('✅ Added to favorites: ${product.itemName}');
      return true;
    } catch (e) {
      LoggerService.debug('❌ Failed to add favorite product: $e');
      return false;
    }
  }

  /// お気に入り商品を削除
  Future<bool> removeFavoriteProduct(String itemCode) async {
    try {
      final products = await getFavoriteProducts();

      // 削除
      final initialLength = products.length;
      products.removeWhere((p) => p.itemCode == itemCode);

      if (products.length == initialLength) {
        LoggerService.debug('⚠️ Product not found in favorites: $itemCode');
        return false;
      }

      // 保存
      await _saveProducts(products);

      LoggerService.debug('✅ Removed from favorites: $itemCode');
      return true;
    } catch (e) {
      LoggerService.debug('❌ Failed to remove favorite product: $e');
      return false;
    }
  }

  /// 商品がお気に入りに含まれているかチェック
  Future<bool> isFavorite(String itemCode) async {
    try {
      final products = await getFavoriteProducts();
      return products.any((p) => p.itemCode == itemCode);
    } catch (e) {
      LoggerService.debug('⚠️ Failed to check favorite status: $e');
      return false;
    }
  }

  /// お気に入りをすべてクリア
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      LoggerService.debug('✅ Cleared all favorites');
      return true;
    } catch (e) {
      LoggerService.debug('❌ Failed to clear favorites: $e');
      return false;
    }
  }

  /// 商品リストを保存
  Future<void> _saveProducts(List<FavoriteProduct> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_key, jsonString);
    LoggerService.debug('💾 Saved ${products.length} favorite products');
  }
}
