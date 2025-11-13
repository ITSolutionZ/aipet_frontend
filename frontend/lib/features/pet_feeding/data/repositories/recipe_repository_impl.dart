import 'package:aipet_frontend/features/pet_feeding/data/repositories/helpers/helpers.dart';
import 'package:aipet_frontend/features/pet_feeding/data/services/pet_feeding_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/repositories/recipe_repository.dart';

/// 레시피 리포지토리 구현 (리팩토링됨)
class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl();

  @override
  Future<List<RecipeEntity>> getAllRecipes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    return RecipeMapperHelper.jsonListToEntityList(recipesData);
  }

  @override
  Future<List<RecipeEntity>> getUserRecipes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    final recipes = RecipeMapperHelper.jsonListToEntityList(recipesData);

    return RecipeFilterHelper.filterByUserId(recipes, userId);
  }

  @override
  Future<RecipeEntity?> getRecipeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();

    try {
      final recipeData = recipesData.firstWhere((data) => data['id'] == id);
      return RecipeMapperHelper.jsonToEntity(recipeData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<RecipeEntity> createRecipe(RecipeEntity recipe) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 유효성 검사
    if (recipe.name.isEmpty || recipe.description.isEmpty) {
      throw Exception('レシピ名と説明は必須です。');
    }

    final newRecipe = recipe.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await PetFeedingLocalStorageService.addRecipe(newRecipe.toJson());

    return newRecipe;
  }

  @override
  Future<RecipeEntity> updateRecipe(RecipeEntity recipe) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 유효성 검사
    if (recipe.name.isEmpty || recipe.description.isEmpty) {
      throw Exception('レシピ名と説明は必須です。');
    }

    final updatedRecipe = recipe.copyWith(updatedAt: DateTime.now());

    await PetFeedingLocalStorageService.updateRecipe(
      recipe.id,
      updatedRecipe.toJson(),
    );

    return updatedRecipe;
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await PetFeedingLocalStorageService.deleteRecipe(id);
  }

  @override
  Future<List<RecipeEntity>> getRecipesByDifficulty(String difficulty) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    final recipes = RecipeMapperHelper.jsonListToEntityList(recipesData);

    return RecipeFilterHelper.filterByDifficulty(recipes, difficulty);
  }

  @override
  Future<List<RecipeEntity>> getFavoriteRecipes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    final recipes = RecipeMapperHelper.jsonListToEntityList(recipesData);

    return RecipeFilterHelper.filterFavorites(recipes, userId);
  }

  @override
  Future<List<RecipeEntity>> searchRecipes(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    final recipes = RecipeMapperHelper.jsonListToEntityList(recipesData);

    return RecipeSearchHelper.searchRecipes(recipes, query);
  }

  @override
  Future<List<RecipeEntity>> getTopRatedRecipes({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    final recipes = RecipeMapperHelper.jsonListToEntityList(recipesData);

    return RecipeSearchHelper.sortByRating(recipes, limit: limit);
  }

  @override
  Future<List<RecipeEntity>> getQuickRecipes() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipesData = await PetFeedingLocalStorageService.getRecipes();
    final recipes = RecipeMapperHelper.jsonListToEntityList(recipesData);

    return RecipeFilterHelper.filterQuickRecipes(recipes);
  }

  @override
  Future<void> toggleFavorite(String recipeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipe = await getRecipeById(recipeId);
    if (recipe != null) {
      final updatedRecipe = recipe.copyWith(
        isFavorite: !recipe.isFavorite,
        updatedAt: DateTime.now(),
      );

      await PetFeedingLocalStorageService.updateRecipe(
        recipeId,
        updatedRecipe.toJson(),
      );
    }
  }

  @override
  Future<void> updateRating(String recipeId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final recipe = await getRecipeById(recipeId);
    if (recipe != null) {
      final updatedRecipe = recipe.copyWith(
        rating: rating,
        updatedAt: DateTime.now(),
      );

      await PetFeedingLocalStorageService.updateRecipe(
        recipeId,
        updatedRecipe.toJson(),
      );
    }
  }
}
