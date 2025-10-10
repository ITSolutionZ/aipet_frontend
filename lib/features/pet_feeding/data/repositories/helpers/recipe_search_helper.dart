import 'package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart';

/// 레시피 검색 헬퍼
class RecipeSearchHelper {
  /// 레시피 검색
  static List<RecipeEntity> searchRecipes(
    List<RecipeEntity> recipes,
    String query,
  ) {
    if (query.isEmpty) return recipes;

    final lowerQuery = query.toLowerCase();

    return recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerQuery) ||
          recipe.description.toLowerCase().contains(lowerQuery) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

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
  static List<RecipeEntity> filterFavorites(List<RecipeEntity> recipes) {
    return recipes.where((recipe) => recipe.isFavorite).toList();
  }

  /// 빠른 조리 레시피 필터링 (30분 이하)
  static List<RecipeEntity> filterQuickRecipes(List<RecipeEntity> recipes) {
    return recipes.where((recipe) {
      final time = int.tryParse(recipe.cookingTime.split(' ').first) ?? 0;
      return time <= 30;
    }).toList();
  }

  /// 최고 평점 레시피 정렬
  static List<RecipeEntity> sortByRating(
    List<RecipeEntity> recipes, {
    int limit = 5,
  }) {
    final sortedRecipes = List<RecipeEntity>.from(recipes);
    sortedRecipes.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedRecipes.take(limit).toList();
  }

  /// 최신순 정렬
  static List<RecipeEntity> sortByCreatedDate(
    List<RecipeEntity> recipes, {
    bool ascending = false,
  }) {
    final sortedRecipes = List<RecipeEntity>.from(recipes);
    sortedRecipes.sort((a, b) {
      return ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
    return sortedRecipes;
  }

  /// 조리 시간순 정렬
  static List<RecipeEntity> sortByCookingTime(
    List<RecipeEntity> recipes, {
    bool ascending = true,
  }) {
    final sortedRecipes = List<RecipeEntity>.from(recipes);
    sortedRecipes.sort((a, b) {
      final timeA = int.tryParse(a.cookingTime.split(' ').first) ?? 0;
      final timeB = int.tryParse(b.cookingTime.split(' ').first) ?? 0;
      return ascending ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
    });
    return sortedRecipes;
  }
}
