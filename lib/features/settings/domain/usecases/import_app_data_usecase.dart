import '../../../../shared/shared.dart';
import '../repositories/settings_repository.dart';

class ImportAppDataUseCase {
  final SettingsRepository repository;

  ImportAppDataUseCase(this.repository);

  Future<Result<void>> call(String filePath) async {
    final result = await repository.importAppData(filePath);
    if (result.isSuccess) {
      return Result.success(result.message);
    } else {
      return Result.failure(result.message);
    }
  }
}
