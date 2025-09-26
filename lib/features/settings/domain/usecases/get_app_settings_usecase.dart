import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

class GetAppSettingsUseCase {
  final SettingsRepository _repository;

  const GetAppSettingsUseCase(this._repository);

  /// 앱 설정 가져오기
  Future<Result<AppSettingsEntity>> call() async {
    final result = await _repository.getAppSettings();
    if (result.isSuccess) {
      return Success(result.dataOrNull!, result.errorOrNull);
    } else {
      return Failure(result.errorOrNull ?? 'Unknown error');
    }
  }
}
