import '../entities/recipe_entity.dart';

abstract class RecipeRepository {
  /// 모든 레시피 가져오기
  Future<List<RecipeEntity>> getAllRecipes();

  /// 사용자별 레시피 가져오기
  Future<List<RecipeEntity>> getUserRecipes(String userId);

  /// ID로 레시피 가져오기
  Future<RecipeEntity?> getRecipeById(String id);

  /// 레시피 생성
  Future<RecipeEntity> createRecipe(RecipeEntity recipe);

  /// 레시피 업데이트
  Future<RecipeEntity> updateRecipe(RecipeEntity recipe);

  /// 레시피 삭제
  Future<void> deleteRecipe(String id);

  /// 난이도별 레시피 필터링
  Future<List<RecipeEntity>> getRecipesByDifficulty(String difficulty);

  /// 즐겨찾기 레시피 가져오기
  Future<List<RecipeEntity>> getFavoriteRecipes(String userId);

  /// 검색어로 레시피 필터링
  Future<List<RecipeEntity>> searchRecipes(String query);

  /// 최고 평점 레시피 가져오기
  Future<List<RecipeEntity>> getTopRatedRecipes({int limit = 5});

  /// 빠른 조리 레시피 가져오기 (30분 이하)
  Future<List<RecipeEntity>> getQuickRecipes();

  /// 레시피 즐겨찾기 토글
  Future<void> toggleFavorite(String recipeId, String userId);

  /// 레시피 평점 업데이트
  Future<void> updateRating(String recipeId, double rating);
}
