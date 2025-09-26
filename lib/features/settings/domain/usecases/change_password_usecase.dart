import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

class ChangePasswordUseCase {
  final SettingsRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Result<void>> call(PasswordChangeRequest request) async {
    if (!request.isValid) {
      return const Failure('無効なパスワード変更リクエストです');
    }

    final result = await repository.changePassword(request);
    if (result.isSuccess) {
      return Success(null, result.errorOrNull);
    } else {
      return Failure(result.errorOrNull ?? 'Unknown error');
    }
  }
}
