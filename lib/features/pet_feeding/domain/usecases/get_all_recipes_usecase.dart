import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetAllRecipesUseCase {
  final RecipeRepository _repository;

  const GetAllRecipesUseCase(this._repository);

  /// 모든 레시피 가져오기
  Future<List<RecipeEntity>> call() async {
    return _repository.getAllRecipes();
  }
}
