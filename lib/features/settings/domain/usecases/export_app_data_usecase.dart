import '../../../../shared/shared.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class ExportAppDataUseCase {
  final SettingsRepository repository;

  ExportAppDataUseCase(this.repository);

  Future<Result<DataExportResult>> call() async {
    final result = await repository.exportAppData();
    if (result.isSuccess) {
      return Result.success(result.message, result.data);
    } else {
      return Result.failure(result.message);
    }
  }
}
