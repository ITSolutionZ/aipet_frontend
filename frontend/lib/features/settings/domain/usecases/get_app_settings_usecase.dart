import 'package:aipet_frontend/features/settings/domain/entities/settings_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class GetAppSettingsUseCase {
  final SettingsRepository _repository;

  const GetAppSettingsUseCase(this._repository);

  /// 앱 설정 가져오기
  Future<Result<AppSettingsEntity>> call() async {
    final result = await _repository.getAppSettings();
    if (result.isSuccess) {
      return Result.success('アプリ設定を取得しました', result.dataOrNull);
    } else {
      return Result.failure('アプリ設定の取得に失敗しました');
    }
  }
}
