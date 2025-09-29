import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class DeleteAccountUseCase {
  final SettingsRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Result<void>> call() async {
    final result = await repository.deleteAccount();
    if (result.isSuccess) {
      return Result.success('アカウントを削除しました', null);
    } else {
      return Result.failure('アカウントの削除に失敗しました');
    }
  }
}
