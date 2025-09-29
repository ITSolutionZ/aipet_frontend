import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class ChangePasswordUseCase {
  final SettingsRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Result<void>> call(Map<String, dynamic> request) async {
    // 비밀번호 변경 요청 유효성 검사
    if (request['isValid'] != true) {
      return Result.failure('無効なパスワード変更リクエストです');
    }

    final result = await repository.changePassword(request);
    if (result.isSuccess) {
      return Result.success('パスワードを変更しました', null);
    } else {
      return Result.failure('パスワードの変更に失敗しました');
    }
  }
}
