import '../../../../shared/shared.dart';

import '../../../../../features/settings/domain/entities/settings_entity.dart';
import '../../../../../features/settings/domain/repositories/settings_repository.dart';

class SaveAppSettingsUseCase {
  final SettingsRepository _repository;

  const SaveAppSettingsUseCase(this._repository);

  /// 앱 설정 저장
  Future<Result<AppSettingsEntity>> call(AppSettingsEntity settings) async {
    final result = await _repository.saveAppSettings(settings);
    if (result.isSuccess) {
      return Result.success('アプリ設定を保存しました', result.dataOrNull);
    } else {
      return Result.failure('アプリ設定の保存に失敗しました');
    }
  }
}
