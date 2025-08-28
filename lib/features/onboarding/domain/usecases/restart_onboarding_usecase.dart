import '../domain.dart';

/// 온보딩 재시작 UseCase
class RestartOnboardingUseCase extends BaseUseCaseNoParams<void> {
  const RestartOnboardingUseCase(super.repository);

  @override
  Future<void> call() async {
    // 비즈니스 로직: 온보딩 재시작 처리
    await repository.restartOnboarding();
  }
}
