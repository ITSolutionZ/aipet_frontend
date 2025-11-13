import 'package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/repositories/recipe_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class GetAllRecipesUseCase {
  final RecipeRepository _repository;

  const GetAllRecipesUseCase(this._repository);

  /// 모든 레시피 가져오기
  Future<Result<List<RecipeEntity>>> call() async {
    try {
      final result = await _repository.getAllRecipes();
      return Result.success('レシピ一覧を取得しました', result);
    } catch (error) {
      return Result.failure('レシピ一覧の取得に失敗しました: ${error.toString()}');
    }
  }
}
