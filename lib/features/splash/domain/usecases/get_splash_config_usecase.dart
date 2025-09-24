import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/shared/entities/splash_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';

class GetSplashConfigUseCase {
  final SplashRepository repository;

  GetSplashConfigUseCase(this.repository);

  Future<Result<SplashEntity>> call() async {
    try {
      final result = await repository.getSplashConfig();
      return result;
    } catch (error) {
      return Result.failure('スプラッシュ設定の取得に失敗しました: ${error.toString()}');
    }
  }
}
