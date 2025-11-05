import '../../../../shared/shared.dart';

import '../../../../../features/pet_feeding/domain/repositories/pet_feeding_repository.dart';
import '../../../../../features/pet_feeding/domain/usecases/helpers/helpers.dart';

/// 레시피 수정 UseCase
class UpdateRecipeUseCase {
  final PetFeedingRepository repository;

  UpdateRecipeUseCase(this.repository);

  /// 레시피 정보 수정
  Future<Result<Map<String, dynamic>>> call(Map<String, dynamic> recipe) async {
    try {
      // 레시피 데이터 검증 (헬퍼 위임)
      if (!RecipeValidationHelper.validateRecipe(recipe)) {
        return Result.failure('レシピデータが無効です');
      }

      // 레시피 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateRecipe(recipe);

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
      // 이름 검증 (헬퍼 위임)
      final nameValidation = RecipeValidationHelper.validateRecipeName(newName);
      if (!nameValidation.isSuccess) {
        return Result.failure(nameValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 이름 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateName(
        existingRecipe,
        newName,
      );

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
      // 재료 검증 (헬퍼 위임)
      final ingredientsValidation = RecipeValidationHelper.validateIngredients(
        ingredients,
      );
      if (!ingredientsValidation.isSuccess) {
        return Result.failure(ingredientsValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 재료 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateIngredients(
        existingRecipe,
        ingredientsValidation.dataOrNull!,
      );

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
      // 조리 방법 검증 (헬퍼 위임)
      final instructionsValidation =
          RecipeValidationHelper.validateInstructions(instructions);
      if (!instructionsValidation.isSuccess) {
        return Result.failure(instructionsValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 조리 방법 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateInstructions(
        existingRecipe,
        instructionsValidation.dataOrNull!,
      );

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
      // 영양 정보 검증 (헬퍼 위임)
      final nutritionValidation = RecipeValidationHelper.validateNutrition(
        nutritionInfo,
      );
      if (!nutritionValidation.isSuccess) {
        return Result.failure(nutritionValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 영양 정보 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateNutrition(
        existingRecipe,
        nutritionValidation.dataOrNull!,
      );

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
      // 카테고리 검증 (헬퍼 위임)
      final categoryValidation = RecipeValidationHelper.validateCategory(
        category,
      );
      if (!categoryValidation.isSuccess) {
        return Result.failure(categoryValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 카테고리 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateCategory(
        existingRecipe,
        categoryValidation.dataOrNull!,
      );

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
      // 난이도 검증 (헬퍼 위임)
      final difficultyValidation = RecipeValidationHelper.validateDifficulty(
        difficulty,
      );
      if (!difficultyValidation.isSuccess) {
        return Result.failure(difficultyValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 난이도 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updateDifficulty(
        existingRecipe,
        difficultyValidation.dataOrNull!,
      );

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
      // 준비 시간 검증 (헬퍼 위임)
      final prepTimeValidation = RecipeValidationHelper.validatePrepTime(
        prepTimeMinutes,
      );
      if (!prepTimeValidation.isSuccess) {
        return Result.failure(prepTimeValidation.message);
      }

      final existingRecipe = await _getRecipeById(recipeId);
      if (existingRecipe == null) {
        return Result.failure('レシピが見つかりません');
      }

      // 준비 시간 업데이트 (헬퍼 위임)
      final updatedRecipe = RecipeUpdateHelper.updatePrepTime(
        existingRecipe,
        prepTimeValidation.dataOrNull!,
      );

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
