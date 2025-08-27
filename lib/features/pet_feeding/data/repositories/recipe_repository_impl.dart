import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  // 메모리 기반 저장소 (MockDataService의 데이터로 초기화)
  late final List<RecipeEntity> _recipes;

  RecipeRepositoryImpl() {
    // MockDataService에서 초기 데이터 로드
    _recipes = List.from(MockDataService.getMockRecipes()).map((recipe) {
      return RecipeEntity(
        id: recipe.id,
        name: recipe.name,
        image: recipe.image,
        description: recipe.description,
        cookingTime: recipe.cookingTime,
        difficulty: recipe.difficulty,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        servings: recipe.servings,
        rating: recipe.rating,
        isFavorite: recipe.isFavorite,
        userId: null, // 기본 목업 데이터는 사용자 ID 없음
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<List<RecipeEntity>> getAllRecipes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return List.from(_recipes);
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<RecipeEntity>> getUserRecipes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _recipes.where((recipe) => recipe.userId == userId).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<RecipeEntity?> getRecipeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      try {
        return _recipes.firstWhere((recipe) => recipe.id == id);
      } catch (e) {
        return null;
      }
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<RecipeEntity> createRecipe(RecipeEntity recipe) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      // 유효성 검사
      if (recipe.name.isEmpty || recipe.description.isEmpty) {
        throw Exception('레시피 이름과 설명은 필수입니다.');
      }

      final newRecipe = recipe.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _recipes.add(newRecipe);
      return newRecipe;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<RecipeEntity> updateRecipe(RecipeEntity recipe) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      // 유효성 검사
      if (recipe.name.isEmpty || recipe.description.isEmpty) {
        throw Exception('레시피 이름과 설명은 필수입니다.');
      }

      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        final updatedRecipe = recipe.copyWith(updatedAt: DateTime.now());
        _recipes[index] = updatedRecipe;
        return updatedRecipe;
      }
      throw Exception('레시피를 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      _recipes.removeWhere((recipe) => recipe.id == id);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<RecipeEntity>> getRecipesByDifficulty(String difficulty) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      return _recipes
          .where(
            (recipe) =>
                recipe.difficulty.toLowerCase() == difficulty.toLowerCase(),
          )
          .toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<RecipeEntity>> getFavoriteRecipes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      return _recipes.where((recipe) => recipe.isFavorite).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<RecipeEntity>> searchRecipes(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      if (query.isEmpty) return List.from(_recipes);

      return _recipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query.toLowerCase()) ||
            recipe.description.toLowerCase().contains(query.toLowerCase()) ||
            recipe.ingredients.any(
              (ingredient) =>
                  ingredient.toLowerCase().contains(query.toLowerCase()),
            );
      }).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<RecipeEntity>> getTopRatedRecipes({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      final recipes = List<RecipeEntity>.from(_recipes);
      recipes.sort((a, b) => b.rating.compareTo(a.rating));
      return recipes.take(limit).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<RecipeEntity>> getQuickRecipes() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      return _recipes.where((recipe) {
        final time = int.tryParse(recipe.cookingTime.split(' ').first) ?? 0;
        return time <= 30;
      }).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> toggleFavorite(String recipeId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (index != -1) {
        final recipe = _recipes[index];
        _recipes[index] = recipe.copyWith(
          isFavorite: !recipe.isFavorite,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> updateRating(String recipeId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      final index = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (index != -1) {
        final recipe = _recipes[index];
        _recipes[index] = recipe.copyWith(
          rating: rating,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }
}
