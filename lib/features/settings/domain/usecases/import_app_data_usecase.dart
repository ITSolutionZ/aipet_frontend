import '../repositories/settings_repository.dart';

class ImportAppDataUseCase {
  final SettingsRepository repository;

  ImportAppDataUseCase(this.repository);

  Future<bool> call(String filePath) async {
    return repository.importAppData(filePath);
  }
}
