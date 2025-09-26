import 'package:aipet_frontend/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// UseCase 기본 클래스 with parameters
abstract class BaseUseCase<T, P> {
  final OnboardingRepository repository;

  const BaseUseCase(this.repository);

  Future<Result<T>> call(P params);
}

/// 파라미터가 없는 UseCase 기본 클래스
abstract class BaseUseCaseNoParams<T> {
  final OnboardingRepository repository;

  const BaseUseCaseNoParams(this.repository);

  Future<Result<T>> call();
}
