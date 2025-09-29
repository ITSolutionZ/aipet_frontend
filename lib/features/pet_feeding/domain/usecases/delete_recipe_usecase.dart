import 'package:aipet_frontend/features/pet_feeding/domain/repositories/recipe_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class DeleteRecipeUseCase {
  final RecipeRepository _repository;

  const DeleteRecipeUseCase(this._repository);

  /// 레시피 삭제
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteRecipe(id);
      return Result.success('レシピを削除しました', null);
    } catch (error) {
      return Result.failure('レシピの削除に失敗しました: ${error.toString()}');
    }
  }
}
