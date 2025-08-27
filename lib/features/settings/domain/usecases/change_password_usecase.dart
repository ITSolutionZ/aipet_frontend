import '../entities/user_profile_entity.dart';
import '../repositories/settings_repository.dart';

class ChangePasswordUseCase {
  final SettingsRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<bool> call(PasswordChangeRequest request) async {
    if (!request.isValid) {
      throw ArgumentError('Invalid password change request');
    }
    return repository.changePassword(request);
  }
}
