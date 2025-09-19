import '../../../../shared/shared.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class ChangePasswordUseCase {
  final SettingsRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Result<void>> call(PasswordChangeRequest request) async {
    if (!request.isValid) {
      return Result.failure('無効なパスワード変更リクエストです');
    }

    final result = await repository.changePassword(request);
    if (result.isSuccess) {
      return Result.success(result.message);
    } else {
      return Result.failure(result.message);
    }
  }
}
