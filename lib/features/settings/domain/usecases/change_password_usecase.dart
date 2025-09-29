import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class ChangePasswordUseCase {
  final SettingsRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Result<void>> call(PasswordChangeRequest request) async {
    if (!request.isValid) {
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
