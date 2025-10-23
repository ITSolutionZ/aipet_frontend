import 'dart:convert';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import 'package:flutter/foundation.dart';

/// 레시피 저장소 헬퍼
import 'package:aipet_frontend/shared/services/cache_service.dart';
class RecipeStorageHelper {
  static const String _keyRecipes = 'pet_recipes';
  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  /// 레시피 가져오기
  static Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      await _init();
      final recipesJson = prefs.getStringList(_keyRecipes) ?? [];

      if (recipesJson.isEmpty) {
        return await _initializeDefaultRecipes();
      }

      return recipesJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      LoggerService.debug('레시피 로드 실패: $e');
      return [];
    }
  }

  /// 레시피 추가
  static Future<void> addRecipe(Map<String, dynamic> recipe) async {
    try {
      await _init();
      final recipes = prefs.getStringList(_keyRecipes) ?? [];

      if (recipe['id'] == null || (recipe['id'] as String).isEmpty) {
        recipe['id'] = 'recipe-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (recipe['createdAt'] == null) {
        recipe['createdAt'] = DateTime.now().toIso8601String();
      }

      recipes.add(jsonEncode(recipe));
      await prefs.setStringList(_keyRecipes, recipes);

      LoggerService.debug('레시피 추가 성공: ${recipe['id']}');
    } catch (e) {
      LoggerService.debug('레시피 추가 실패: $e');
      rethrow;
    }
  }

  /// 레시피 업데이트
  static Future<void> updateRecipe(
    String recipeId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _init();
      final recipes = prefs.getStringList(_keyRecipes) ?? [];

      final index = recipes.indexWhere((r) {
        final recipeData = jsonDecode(r) as Map<String, dynamic>;
        return recipeData['id'] == recipeId;
      });

      if (index != -1) {
        final existingRecipe =
            jsonDecode(recipes[index]) as Map<String, dynamic>;
        existingRecipe.addAll(updates);
        existingRecipe['updatedAt'] = DateTime.now().toIso8601String();

        recipes[index] = jsonEncode(existingRecipe);
        await prefs.setStringList(_keyRecipes, recipes);
        LoggerService.debug('레시피 업데이트 성공: $recipeId');
      }
    } catch (e) {
      LoggerService.debug('레시피 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 레시피 삭제
  static Future<void> deleteRecipe(String recipeId) async {
    try {
      await _init();
      final recipes = prefs.getStringList(_keyRecipes) ?? [];

      recipes.removeWhere((r) {
        final recipeData = jsonDecode(r) as Map<String, dynamic>;
        return recipeData['id'] == recipeId;
      });

      await prefs.setStringList(_keyRecipes, recipes);
      LoggerService.debug('레시피 삭제 성공: $recipeId');
    } catch (e) {
      LoggerService.debug('레시피 삭제 실패: $e');
      rethrow;
    }
  }

  /// 레시피 검색
  static Future<List<Map<String, dynamic>>> searchRecipes(String query) async {
    try {
      final allRecipes = await getRecipes();
      final lowerQuery = query.toLowerCase();

      return allRecipes.where((recipe) {
        final name = (recipe['name'] as String? ?? '').toLowerCase();
        final description = (recipe['description'] as String? ?? '')
            .toLowerCase();
        final ingredients = (recipe['ingredients'] as List<dynamic>? ?? [])
            .map((i) => (i as String).toLowerCase())
            .toList();

        return name.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            ingredients.any((i) => i.contains(lowerQuery));
      }).toList();
    } catch (e) {
      LoggerService.debug('레시피 검색 실패: $e');
      return [];
    }
  }

  /// 난이도별 레시피 가져오기
  static Future<List<Map<String, dynamic>>> getRecipesByDifficulty(
    String difficulty,
  ) async {
    try {
      final allRecipes = await getRecipes();

      return allRecipes.where((recipe) {
        final recipeDifficulty = (recipe['difficulty'] as String? ?? '')
            .toLowerCase();
        return recipeDifficulty == difficulty.toLowerCase();
      }).toList();
    } catch (e) {
      LoggerService.debug('난이도별 레시피 로드 실패: $e');
      return [];
    }
  }

  /// 즐겨찾기 레시피 가져오기
  static Future<List<Map<String, dynamic>>> getFavoriteRecipes(
    String userId,
  ) async {
    try {
      final allRecipes = await getRecipes();

      return allRecipes.where((recipe) {
        return recipe['isFavorite'] == true && recipe['userId'] == userId;
      }).toList();
    } catch (e) {
      LoggerService.debug('즐겨찾기 레시피 로드 실패: $e');
      return [];
    }
  }

  /// 최고 평점 레시피 가져오기
  static Future<List<Map<String, dynamic>>> getTopRatedRecipes({
    int limit = 5,
  }) async {
    try {
      final allRecipes = await getRecipes();

      allRecipes.sort((a, b) {
        final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
        final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      return allRecipes.take(limit).toList();
    } catch (e) {
      LoggerService.debug('최고 평점 레시피 로드 실패: $e');
      return [];
    }
  }

  /// 빠른 조리 레시피 가져오기 (30분 이하)
  static Future<List<Map<String, dynamic>>> getQuickRecipes() async {
    try {
      final allRecipes = await getRecipes();

      return allRecipes.where((recipe) {
        final cookingTime = recipe['cookingTime'] as String? ?? '';
        final time = int.tryParse(cookingTime.split(' ').first) ?? 0;
        return time <= 30;
      }).toList();
    } catch (e) {
      LoggerService.debug('빠른 조리 레시피 로드 실패: $e');
      return [];
    }
  }

  /// 초기 기본 레시피 생성
  static Future<List<Map<String, dynamic>>> _initializeDefaultRecipes() async {
    await _init();
    final defaultRecipes = [
      {
        'id': 'recipe-1',
        'name': '鶏肉と野菜のスープ',
        'image': 'assets/images/placeholder.png',
        'description': '新鮮な鶏肉と野菜を使った栄養豊富なスープ',
        'cookingTime': '45分',
        'difficulty': 'Medium',
        'ingredients': ['鶏肉 200g', 'にんじん 1本', 'かぼちゃ 100g', '水 500ml'],
        'instructions': [
          '鶏肉を小さく切る',
          '野菜を食べやすい大きさに切る',
          '全ての材料を鍋に入れて30分煮る',
          '冷ましてから与える',
        ],
        'servings': 2,
        'rating': 4.5,
        'isFavorite': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'recipe-2',
        'name': 'サーモンとご飯',
        'image': 'assets/images/placeholder.png',
        'description': 'オメガ3が豊富なサーモンと白米の簡単レシピ',
        'cookingTime': '30分',
        'difficulty': 'Easy',
        'ingredients': ['サーモン 150g', '白米 200g', 'ブロッコリー 50g'],
        'instructions': ['サーモンを焼く', 'ブロッコリーを茹でる', '白米と混ぜる', '冷ましてから与える'],
        'servings': 1,
        'rating': 4.8,
        'isFavorite': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    final recipesJson = defaultRecipes.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(_keyRecipes, recipesJson);

    return defaultRecipes;
  }
}
