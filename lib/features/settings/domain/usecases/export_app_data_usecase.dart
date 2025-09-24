import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

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
