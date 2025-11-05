import '../../../../shared/shared.dart';

import '../../../../../features/pet_feeding/domain/entities/recipe_entity.dart';
import '../../../../../features/pet_feeding/domain/repositories/recipe_repository.dart';

class CreateRecipeUseCase {
  final RecipeRepository _repository;

  const CreateRecipeUseCase(this._repository);

  /// 레시피 생성
  Future<Result<RecipeEntity>> call(RecipeEntity recipe) async {
    try {
      final result = await _repository.createRecipe(recipe);
      return Result.success('レシピを作成しました', result);
    } catch (error) {
      return Result.failure('レシピの作成に失敗しました: ${error.toString()}');
    }
  }
}
