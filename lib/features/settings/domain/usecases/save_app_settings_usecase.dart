import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class SaveAppSettingsUseCase {
  final SettingsRepository _repository;

  const SaveAppSettingsUseCase(this._repository);

  /// 앱 설정 저장
  Future<Result<AppSettingsEntity>> call(AppSettingsEntity settings) async {
    final result = await _repository.saveAppSettings(settings);
    if (result.isSuccess) {
      return Result.success('アプリ設定を保存しました', result.dataOrNull!);
    } else {
      return Result.failure('アプリ設定の保存に失敗しました');
    }
  }
}
