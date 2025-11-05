import '../../../../shared/shared.dart';

import '../repositories/splash_repository.dart';
import '../splash_entity.dart';


/// 스플래시 설정 가져오기 UseCase
class GetSplashConfigUseCase {
  final SplashRepository repository;

  GetSplashConfigUseCase(this.repository);

  Future<Result<SplashEntity>> call() async {
    try {
      return await repository.getSplashConfig();
    } catch (error) {
      return Result.failure(
        'スプラッシュ設定の取得に失敗しました: ${error.toString()}',
        error is Exception ? error : Exception(error.toString()),
      );
    }
  }
}
