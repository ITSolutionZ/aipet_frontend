import 'package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/repositories/recipe_repository.dart';

class CreateRecipeUseCase {
  final RecipeRepository _repository;

  const CreateRecipeUseCase(this._repository);

  /// 레시피 생성
  Future<RecipeEntity> call(RecipeEntity recipe) async {
    return _repository.createRecipe(recipe);
  }
}
