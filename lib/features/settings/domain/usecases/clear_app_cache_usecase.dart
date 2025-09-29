import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

class ClearAppCacheUseCase {
  final SettingsRepository repository;

  ClearAppCacheUseCase(this.repository);

  Future<Result<void>> call() async {
    final result = await repository.clearAppCache();
    if (result.isSuccess) {
      return Success(null, result.errorOrNull);
    } else {
      return Result.failure(result.errorOrNull ?? 'Unknown error');
    }
  }
}
