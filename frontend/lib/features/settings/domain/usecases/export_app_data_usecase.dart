import '../../../../shared/shared.dart';

import '../../../../../features/settings/domain/entities/settings_entity.dart';
import '../../../../../features/settings/domain/repositories/settings_repository.dart';

class ExportAppDataUseCase {
  final SettingsRepository repository;

  ExportAppDataUseCase(this.repository);

  Future<Result<DataExportResult>> call() async {
    final result = await repository.exportAppData();
    if (result.isSuccess) {
      return Result.success('アプリデータをエクスポートしました', result.dataOrNull);
    } else {
      return Result.failure('アプリデータのエクスポートに失敗しました');
    }
  }
}
