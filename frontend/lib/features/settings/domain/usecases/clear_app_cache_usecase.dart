import '../../../../shared/shared.dart';

import '../../../../../features/settings/domain/repositories/settings_repository.dart';

class ClearAppCacheUseCase {
  final SettingsRepository repository;

  ClearAppCacheUseCase(this.repository);

  Future<Result<void>> call() async {
    final result = await repository.clearAppCache();
    if (result.isSuccess) {
      return Result.success('アプリキャッシュをクリアしました', null);
    } else {
      return Result.failure('アプリキャッシュのクリアに失敗しました');
    }
  }
}
