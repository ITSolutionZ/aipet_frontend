import '../repositories/onboarding_repository.dart';

/// 온보딩 완료 UseCase
class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  Future<void> call() async {
    // 비즈니스 로직: 온보딩 완료 처리
    await repository.completeOnboarding();

    // 온보딩 상태를 완료로 업데이트
    final currentState = await repository.loadOnboardingState();
    final completedState = currentState.copyWith(isCompleted: true);
    await repository.saveOnboardingState(completedState);
  }
}
