import '../entities/logo_entity.dart';

abstract class LogoRepository {
  Future<LogoEntity> getLogoConfig();
  Future<void> initializeApp();
}
