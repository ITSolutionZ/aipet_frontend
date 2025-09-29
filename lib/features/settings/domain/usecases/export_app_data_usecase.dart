import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

class ExportAppDataUseCase {
  final SettingsRepository repository;

  ExportAppDataUseCase(this.repository);

  Future<Result<DataExportResult>> call() async {
    final result = await repository.exportAppData();
    if (result.isSuccess) {
      return Success(result.dataOrNull!, result.errorOrNull);
    } else {
      return Result.failure(result.errorOrNull ?? 'Unknown error');
    }
  }
}
