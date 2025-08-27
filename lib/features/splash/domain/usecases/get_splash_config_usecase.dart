import '../entities/splash_entity.dart';
import '../repositories/splash_repository.dart';

class GetSplashConfigUseCase {
  final SplashRepository repository;

  GetSplashConfigUseCase(this.repository);

  Future<SplashEntity> call() async {
    return repository.getSplashConfig();
  }
}
