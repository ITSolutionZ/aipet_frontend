import '../repositories/settings_repository.dart';

class DeleteAccountUseCase {
  final SettingsRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<bool> call() async {
    return repository.deleteAccount();
  }
}
