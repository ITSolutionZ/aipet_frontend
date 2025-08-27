import '../repositories/settings_repository.dart';

class ClearAppCacheUseCase {
  final SettingsRepository repository;

  ClearAppCacheUseCase(this.repository);

  Future<bool> call() async {
    return repository.clearAppCache();
  }
}
