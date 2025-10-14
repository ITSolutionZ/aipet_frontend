import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 레시피 검증 헬퍼
class RecipeValidationHelper {
  /// 레시피 데이터 전체 검증
  static bool validateRecipe(Map<String, dynamic> recipe) {
    return recipe.containsKey('name') &&
        recipe.containsKey('ingredients') &&
        recipe.containsKey('instructions') &&
        recipe['name'].toString().trim().isNotEmpty &&
        (recipe['ingredients'] as List).isNotEmpty &&
        (recipe['instructions'] as List).isNotEmpty;
  }

  /// 레시피 이름 검증
  static Result<String> validateRecipeName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return Result.failure('レシピ名は空にできません');
    }

    if (trimmedName.length < 2) {
      return Result.failure('レシピ名は2文字以上で入力してください');
    }

    if (trimmedName.length > 50) {
      return Result.failure('レシピ名は50文字以内で入力してください');
    }

    return Result.success('レシピ名が有効です', trimmedName);
  }

  /// 재료 리스트 검증
  static Result<List<String>> validateIngredients(List<String> ingredients) {
    if (ingredients.isEmpty) {
      return Result.failure('材料は少なくとも1つ必要です');
    }

    final trimmedIngredients = ingredients
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    if (trimmedIngredients.isEmpty) {
      return Result.failure('有効な材料は少なくとも1つ必要です');
    }

    return Result.success('材料が有効です', trimmedIngredients);
  }

  /// 조리 방법 검증
  static Result<List<String>> validateInstructions(List<String> instructions) {
    if (instructions.isEmpty) {
      return Result.failure('作り方は少なくとも1つ必要です');
    }

    final trimmedInstructions = instructions
        .map((instruction) => instruction.trim())
        .where((instruction) => instruction.isNotEmpty)
        .toList();

    if (trimmedInstructions.isEmpty) {
      return Result.failure('有効な作り方は少なくとも1つ必要です');
    }

    return Result.success('作り方が有効です', trimmedInstructions);
  }

  /// 난이도 검증
  static Result<String> validateDifficulty(String difficulty) {
    final validDifficulties = ['easy', 'medium', 'hard'];
    final lowerDifficulty = difficulty.toLowerCase();

    if (!validDifficulties.contains(lowerDifficulty)) {
      return Result.failure('無効な難易度です。easy, medium, hard のいずれかを選択してください');
    }

    return Result.success('難易度が有効です', lowerDifficulty);
  }

  /// 준비 시간 검증
  static Result<int> validatePrepTime(int prepTimeMinutes) {
    if (prepTimeMinutes <= 0) {
      return Result.failure('準備時間は0より大きい値である必要があります');
    }

    if (prepTimeMinutes > 480) {
      // 8시간 이상
      return Result.failure('準備時間は8時間以内で入力してください');
    }

    return Result.success('準備時間が有効です', prepTimeMinutes);
  }

  /// 영양 정보 검증
  static Result<Map<String, double>> validateNutrition(
    Map<String, double> nutritionInfo,
  ) {
    if (nutritionInfo.isEmpty) {
      return Result.failure('栄養情報は少なくとも1つ必要です');
    }

    // 음수 값 검증
    for (final entry in nutritionInfo.entries) {
      if (entry.value < 0) {
        return Result.failure('栄養情報の値は0以上である必要があります: ${entry.key}');
      }
    }

    return Result.success('栄養情報が有効です', nutritionInfo);
  }

  /// 카테고리 검증
  static Result<String> validateCategory(String category) {
    final trimmedCategory = category.trim();

    if (trimmedCategory.isEmpty) {
      return Result.failure('カテゴリは空にできません');
    }

    if (trimmedCategory.length > 20) {
      return Result.failure('カテゴリは20文字以内で入力してください');
    }

    return Result.success('カテゴリが有効です', trimmedCategory);
  }

  /// 인분 수 검증
  static Result<int> validateServings(int servings) {
    if (servings <= 0) {
      return Result.failure('人数分は1以上である必要があります');
    }

    if (servings > 20) {
      return Result.failure('人数分は20以下で入力してください');
    }

    return Result.success('人数分が有効です', servings);
  }

  /// 평점 검증
  static Result<double> validateRating(double rating) {
    if (rating < 0 || rating > 5) {
      return Result.failure('評価は0から5の間である必要があります');
    }

    return Result.success('評価が有効です', rating);
  }
}
