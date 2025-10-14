/// 레시피 업데이트 헬퍼
class RecipeUpdateHelper {
  /// 레시피 이름 업데이트
  static Map<String, dynamic> updateName(
    Map<String, dynamic> existingRecipe,
    String newName,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['name'] = newName.trim();
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 재료 업데이트
  static Map<String, dynamic> updateIngredients(
    Map<String, dynamic> existingRecipe,
    List<String> ingredients,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['ingredients'] = ingredients
        .map((ingredient) => ingredient.trim())
        .toList();
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 조리 방법 업데이트
  static Map<String, dynamic> updateInstructions(
    Map<String, dynamic> existingRecipe,
    List<String> instructions,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['instructions'] = instructions
        .map((instruction) => instruction.trim())
        .toList();
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 영양 정보 업데이트
  static Map<String, dynamic> updateNutrition(
    Map<String, dynamic> existingRecipe,
    Map<String, double> nutritionInfo,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['nutrition'] = nutritionInfo;
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 카테고리 업데이트
  static Map<String, dynamic> updateCategory(
    Map<String, dynamic> existingRecipe,
    String category,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['category'] = category.trim();
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 난이도 업데이트
  static Map<String, dynamic> updateDifficulty(
    Map<String, dynamic> existingRecipe,
    String difficulty,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['difficulty'] = difficulty.toLowerCase();
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 준비 시간 업데이트
  static Map<String, dynamic> updatePrepTime(
    Map<String, dynamic> existingRecipe,
    int prepTimeMinutes,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['prepTimeMinutes'] = prepTimeMinutes;
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 전체 업데이트
  static Map<String, dynamic> updateRecipe(
    Map<String, dynamic> recipe,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(recipe);
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    updatedRecipe['version'] = (updatedRecipe['version'] ?? 0) + 1;
    return updatedRecipe;
  }

  /// 레시피 인분 수 업데이트
  static Map<String, dynamic> updateServings(
    Map<String, dynamic> existingRecipe,
    int servings,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['servings'] = servings;
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 평점 업데이트
  static Map<String, dynamic> updateRating(
    Map<String, dynamic> existingRecipe,
    double rating,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['rating'] = rating;
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }

  /// 레시피 즐겨찾기 토글
  static Map<String, dynamic> toggleFavorite(
    Map<String, dynamic> existingRecipe,
  ) {
    final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
    updatedRecipe['isFavorite'] = !(existingRecipe['isFavorite'] as bool? ?? false);
    updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
    return updatedRecipe;
  }
}
