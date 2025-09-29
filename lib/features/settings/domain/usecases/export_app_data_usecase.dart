import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class ExportAppDataUseCase {
  final SettingsRepository repository;

  ExportAppDataUseCase(this.repository);

  Future<Result<DataExportResult>> call() async {
    final result = await repository.exportAppData();
    if (result.isSuccess) {
      return Result.success('アプリデータをエクスポートしました', result.dataOrNull!);
    } else {
      return Result.failure('アプリデータのエクスポートに失敗しました');
    }
  }
}
