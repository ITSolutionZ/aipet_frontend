import '../../../../shared/shared.dart';
import '../repositories/settings_repository.dart';

class ClearAppCacheUseCase {
  final SettingsRepository repository;

  ClearAppCacheUseCase(this.repository);

  Future<Result<void>> call() async {
    final result = await repository.clearAppCache();
    if (result.isSuccess) {
      return Result.success(result.message);
    } else {
      return Result.failure(result.message);
    }
  }
}
