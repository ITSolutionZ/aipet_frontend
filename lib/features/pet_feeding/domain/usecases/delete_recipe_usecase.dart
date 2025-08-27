import '../repositories/recipe_repository.dart';

class DeleteRecipeUseCase {
  final RecipeRepository _repository;

  const DeleteRecipeUseCase(this._repository);

  /// 레시피 삭제
  Future<void> call(String id) async {
    await _repository.deleteRecipe(id);
  }
}
