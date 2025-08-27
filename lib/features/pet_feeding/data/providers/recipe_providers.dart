import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/create_recipe_usecase.dart';
import '../../domain/usecases/delete_recipe_usecase.dart';
import '../../domain/usecases/get_all_recipes_usecase.dart';
import '../repositories/recipe_repository_impl.dart';

part 'recipe_providers.g.dart';

// Repository 프로바이더
@riverpod
RecipeRepositoryImpl recipeRepository(Ref ref) {
  return RecipeRepositoryImpl();
}

// UseCase 프로바이더들
@riverpod
GetAllRecipesUseCase getAllRecipesUseCase(Ref ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return GetAllRecipesUseCase(repository);
}

@riverpod
CreateRecipeUseCase createRecipeUseCase(Ref ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return CreateRecipeUseCase(repository);
}

@riverpod
DeleteRecipeUseCase deleteRecipeUseCase(Ref ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return DeleteRecipeUseCase(repository);
}

// 레시피 목록 프로바이더
@riverpod
class RecipesNotifier extends _$RecipesNotifier {
  @override
  Future<List<RecipeEntity>> build() async {
    final useCase = ref.watch(getAllRecipesUseCaseProvider);
    return useCase();
  }

  /// 레시피 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getAllRecipesUseCaseProvider);
      return useCase();
    });
  }

  /// 레시피 생성
  Future<void> createRecipe(RecipeEntity recipe) async {
    final useCase = ref.read(createRecipeUseCaseProvider);
    await useCase(recipe);
    await refresh();
  }

  /// 레시피 삭제
  Future<void> deleteRecipe(String id) async {
    final useCase = ref.read(deleteRecipeUseCaseProvider);
    await useCase(id);
    await refresh();
  }
}

// 개별 레시피 프로바이더
@riverpod
Future<RecipeEntity?> recipeById(Ref ref, String id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeById(id);
}

// 사용자별 레시피 프로바이더
@riverpod
Future<List<RecipeEntity>> userRecipes(Ref ref, String userId) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getUserRecipes(userId);
}

// 검색된 레시피 프로바이더
@riverpod
Future<List<RecipeEntity>> searchRecipes(Ref ref, String query) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.searchRecipes(query);
}

// 난이도별 레시피 프로바이더
@riverpod
Future<List<RecipeEntity>> recipesByDifficulty(
  Ref ref,
  String difficulty,
) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipesByDifficulty(difficulty);
}

// 즐겨찾기 레시피 프로바이더
@riverpod
Future<List<RecipeEntity>> favoriteRecipes(Ref ref, String userId) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getFavoriteRecipes(userId);
}

// 최고 평점 레시피 프로바이더
@riverpod
Future<List<RecipeEntity>> topRatedRecipes(Ref ref, {int limit = 5}) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getTopRatedRecipes(limit: limit);
}

// 빠른 조리 레시피 프로바이더
@riverpod
Future<List<RecipeEntity>> quickRecipes(Ref ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getQuickRecipes();
}
