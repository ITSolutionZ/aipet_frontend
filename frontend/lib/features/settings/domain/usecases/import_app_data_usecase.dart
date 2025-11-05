import '../../../../shared/shared.dart';

import '../../../../../features/settings/domain/repositories/settings_repository.dart';

class ImportAppDataUseCase {
  final SettingsRepository repository;

  ImportAppDataUseCase(this.repository);

  Future<Result<void>> call(String filePath) async {
    final result = await repository.importAppData(filePath);
    if (result.isSuccess) {
      return Result.success('アプリデータをインポートしました', null);
    } else {
      return Result.failure('アプリデータのインポートに失敗しました');
    }
  }
}
