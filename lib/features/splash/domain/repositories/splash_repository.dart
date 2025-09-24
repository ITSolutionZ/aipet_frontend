import 'package:aipet_frontend/shared/entities/splash_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';

abstract class SplashRepository {
  Future<Result<SplashEntity>> getSplashConfig();
  Future<Result<void>> initializeApp();
}
