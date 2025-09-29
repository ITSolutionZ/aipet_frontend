import 'package:aipet_frontend/features/pet_feeding/domain/repositories/pet_feeding_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 레시피 수정 UseCase
class UpdateRecipeUseCase {
  final PetFeedingRepository repository;

  UpdateRecipeUseCase(this.repository);

  /// 레시피 정보 수정
  Future<Result<Map<String, dynamic>>> call(Map<String, dynamic> recipe) async {
    try {
      // 레시피 데이터 검증
      if (!_validateRecipe(recipe)) {
        return Result.failure('レシピデータが無効です');
      }

      // 실제 구현에서는 repository에 updateRecipe 메서드가 필요
      // 현재는 mock 데이터로 처리
      final updatedRecipe = Map<String, dynamic>.from(recipe);
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();
      updatedRecipe['version'] = (updatedRecipe['version'] ?? 0) + 1;

      return Result.success('レシピを更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピの更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 이름 수정
  Future<Result<Map<String, dynamic>>> updateRecipeName(
    String recipeId,
    String newName,
  ) async {
    try {
      if (newName.trim().isEmpty) {
        return Result.failure('レシピ名は空にできません');
      }

      // 기존 레시피 조회 (실제로는 repository에서 조회)
      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['name'] = newName.trim();
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピ名を更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピ名の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 재료 수정
  Future<Result<Map<String, dynamic>>> updateRecipeIngredients(
    String recipeId,
    List<String> ingredients,
  ) async {
    try {
      if (ingredients.isEmpty) {
        return Result.failure('材料は少なくとも1つ必要です');
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['ingredients'] = ingredients
          .map((ingredient) => ingredient.trim())
          .toList();
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピの材料を更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピの材料の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 방법 수정
  Future<Result<Map<String, dynamic>>> updateRecipeInstructions(
    String recipeId,
    List<String> instructions,
  ) async {
    try {
      if (instructions.isEmpty) {
        return Result.failure('作り方は少なくとも1つ必要です');
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['instructions'] = instructions
          .map((instruction) => instruction.trim())
          .toList();
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピの作り方を更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピの作り方の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 영양 정보 수정
  Future<Result<Map<String, dynamic>>> updateRecipeNutrition(
    String recipeId,
    Map<String, double> nutritionInfo,
  ) async {
    try {
      if (nutritionInfo.isEmpty) {
        return Result.failure('栄養情報は少なくとも1つ必要です');
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['nutrition'] = nutritionInfo;
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピの栄養情報を更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピの栄養情報の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 카테고리 수정
  Future<Result<Map<String, dynamic>>> updateRecipeCategory(
    String recipeId,
    String category,
  ) async {
    try {
      if (category.trim().isEmpty) {
        return Result.failure('カテゴリは空にできません');
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['category'] = category.trim();
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピのカテゴリを更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピのカテゴリの更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 난이도 수정
  Future<Result<Map<String, dynamic>>> updateRecipeDifficulty(
    String recipeId,
    String difficulty,
  ) async {
    try {
      final validDifficulties = ['easy', 'medium', 'hard'];
      if (!validDifficulties.contains(difficulty.toLowerCase())) {
        return Result.failure('無効な難易度です。easy, medium, hard のいずれかを選択してください');
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['difficulty'] = difficulty.toLowerCase();
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピの難易度を更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピの難易度の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 준비 시간 수정
  Future<Result<Map<String, dynamic>>> updateRecipePrepTime(
    String recipeId,
    int prepTimeMinutes,
  ) async {
    try {
      if (prepTimeMinutes <= 0) {
        return Result.failure('準備時間は0より大きい値である必要があります');
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      final updatedRecipe = Map<String, dynamic>.from(existingRecipe);
      updatedRecipe['prepTimeMinutes'] = prepTimeMinutes;
      updatedRecipe['updatedAt'] = DateTime.now().toIso8601String();

      return Result.success('レシピの準備時間を更新しました', updatedRecipe);
    } catch (error) {
      return Result.failure('レシピの準備時間の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 일괄 수정
  Future<Result<Map<String, dynamic>>> updateMultipleRecipes(
    List<Map<String, dynamic>> recipeUpdates,
  ) async {
    try {
      final results = <String, dynamic>{};

      for (final update in recipeUpdates) {
        final recipeId = update['id'] as String;
        final updateData = Map<String, dynamic>.from(update);
        updateData.remove('id');

        final result = await call(updateData);
        results[recipeId] = result.isSuccess ? 'success' : result.message;
      }

      return Result.success('複数のレシピを更新しました', results);
    } catch (error) {
      return Result.failure('複数のレシピの更新に失敗しました: ${error.toString()}');
    }
  }

  /// 레시피 데이터 검증
  bool _validateRecipe(Map<String, dynamic> recipe) {
    return recipe.containsKey('name') &&
        recipe.containsKey('ingredients') &&
        recipe.containsKey('instructions') &&
        recipe['name'].toString().trim().isNotEmpty &&
        (recipe['ingredients'] as List).isNotEmpty &&
        (recipe['instructions'] as List).isNotEmpty;
  }

  /// 레시피 ID로 조회 (Mock)
  Future<Map<String, dynamic>?> _getRecipeById(String recipeId) async {
    // 실제 구현에서는 repository에서 조회
    return {
      'id': recipeId,
      'name': 'Sample Recipe',
      'ingredients': ['ingredient1', 'ingredient2'],
      'instructions': ['step1', 'step2'],
      'category': 'main',
      'difficulty': 'medium',
      'prepTimeMinutes': 30,
      'nutrition': {'calories': 300.0, 'protein': 20.0},
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
