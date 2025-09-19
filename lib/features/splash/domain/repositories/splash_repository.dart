import '../../../../shared/shared.dart';
import '../entities/splash_entity.dart';

abstract class SplashRepository {
  Future<Result<SplashEntity>> getSplashConfig();
  Future<Result<void>> initializeApp();
}
