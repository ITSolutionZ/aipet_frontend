import 'package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart';

/// 레시피 필터 헬퍼
class RecipeFilterHelper {
  /// 난이도별 필터링
  static List<RecipeEntity> filterByDifficulty(
    List<RecipeEntity> recipes,
    String difficulty,
  ) {
    return recipes.where((recipe) {
      return recipe.difficulty.toLowerCase() == difficulty.toLowerCase();
    }).toList();
  }

  /// 즐겨찾기 필터링
  static List<RecipeEntity> filterFavorites(
    List<RecipeEntity> recipes,
    String userId,
  ) {
    return recipes.where((recipe) => recipe.isFavorite).toList();
  }

  /// 사용자별 필터링
  static List<RecipeEntity> filterByUserId(
    List<RecipeEntity> recipes,
    String userId,
  ) {
    return recipes.where((recipe) => recipe.userId == userId).toList();
  }

  /// 조리 시간별 필터링
  static List<RecipeEntity> filterByCookingTime(
    List<RecipeEntity> recipes, {
    int? maxMinutes,
    int? minMinutes,
  }) {
    return recipes.where((recipe) {
      final time = int.tryParse(recipe.cookingTime.split(' ').first) ?? 0;

      if (maxMinutes != null && time > maxMinutes) return false;
      if (minMinutes != null && time < minMinutes) return false;

      return true;
    }).toList();
  }

  /// 평점별 필터링
  static List<RecipeEntity> filterByRating(
    List<RecipeEntity> recipes, {
    double minRating = 0.0,
  }) {
    return recipes.where((recipe) => recipe.rating >= minRating).toList();
  }

  /// 인분 수별 필터링
  static List<RecipeEntity> filterByServings(
    List<RecipeEntity> recipes, {
    int? minServings,
    int? maxServings,
  }) {
    return recipes.where((recipe) {
      if (minServings != null && recipe.servings < minServings) return false;
      if (maxServings != null && recipe.servings > maxServings) return false;
      return true;
    }).toList();
  }

  /// 빠른 조리 레시피 필터링 (30분 이하)
  static List<RecipeEntity> filterQuickRecipes(List<RecipeEntity> recipes) {
    return filterByCookingTime(recipes, maxMinutes: 30);
  }

  /// 복합 필터링
  static List<RecipeEntity> applyFilters(
    List<RecipeEntity> recipes, {
    String? difficulty,
    String? userId,
    bool? isFavorite,
    double? minRating,
    int? maxCookingTime,
  }) {
    var filteredRecipes = recipes;

    if (difficulty != null) {
      filteredRecipes = filterByDifficulty(filteredRecipes, difficulty);
    }

    if (userId != null) {
      filteredRecipes = filterByUserId(filteredRecipes, userId);
    }

    if (isFavorite == true) {
      filteredRecipes = filteredRecipes.where((r) => r.isFavorite).toList();
    }

    if (minRating != null) {
      filteredRecipes = filterByRating(filteredRecipes, minRating: minRating);
    }

    if (maxCookingTime != null) {
      filteredRecipes = filterByCookingTime(
        filteredRecipes,
        maxMinutes: maxCookingTime,
      );
    }

    return filteredRecipes;
  }
}
