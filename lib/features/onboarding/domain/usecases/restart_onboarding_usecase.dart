import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/onboarding_repository.dart';

/// 온보딩 재시작 UseCase
class RestartOnboardingUseCase
    extends RepositoryUseCaseNoParams<void, OnboardingRepository> {
  RestartOnboardingUseCase(super.repository);

  @override
  String get operationName => '온보딩 재시작';

  @override
  Future<Result<void>> execute() async {
    return repository.restartOnboarding();
  }
}
