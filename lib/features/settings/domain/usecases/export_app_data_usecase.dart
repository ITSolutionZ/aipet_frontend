import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class ExportAppDataUseCase {
  final SettingsRepository repository;

  ExportAppDataUseCase(this.repository);

  Future<DataExportResult> call() async {
    return repository.exportAppData();
  }
}
