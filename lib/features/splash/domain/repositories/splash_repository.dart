import '../entities/splash_entity.dart';

abstract class SplashRepository {
  Future<SplashEntity> getSplashConfig();
  Future<void> initializeApp();
}
