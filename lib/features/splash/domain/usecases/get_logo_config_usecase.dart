import '../entities/logo_entity.dart';
import '../repositories/logo_repository.dart';

class GetLogoConfigUseCase {
  final LogoRepository repository;

  GetLogoConfigUseCase(this.repository);

  Future<LogoEntity> call() async {
    return repository.getLogoConfig();
  }
}
