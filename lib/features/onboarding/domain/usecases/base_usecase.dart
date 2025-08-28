import '../domain.dart';

/// UseCase 기본 클래스
abstract class BaseUseCase<T> {
  final OnboardingRepository repository;

  const BaseUseCase(this.repository);

  Future<T> call();
}

/// 파라미터가 없는 UseCase 기본 클래스
abstract class BaseUseCaseNoParams<T> {
  final OnboardingRepository repository;

  const BaseUseCaseNoParams(this.repository);

  Future<T> call();
}
