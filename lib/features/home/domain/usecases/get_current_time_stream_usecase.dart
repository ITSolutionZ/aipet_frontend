import '../repositories/home_repository.dart';

class GetCurrentTimeStreamUseCase {
  final HomeRepository repository;

  GetCurrentTimeStreamUseCase(this.repository);

  Stream<String> call() {
    return repository.getCurrentTimeStream();
  }
}
