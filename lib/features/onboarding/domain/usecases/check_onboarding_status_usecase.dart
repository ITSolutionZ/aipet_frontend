import '../onboarding_state.dart';
import '../repositories/onboarding_repository.dart';

/// 온보딩 상태 확인 UseCase
class CheckOnboardingStatusUseCase {
  final OnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  Future<OnboardingState> call() async {
    // 비즈니스 로직: 온보딩 완료 여부 확인
    final isCompleted = await repository.isOnboardingCompleted();

    if (isCompleted) {
      // 완료된 경우 완료 상태 반환
      return const OnboardingState(isCompleted: true);
    } else {
      // 미완료인 경우 현재 진행 상태 로드
      return repository.loadOnboardingState();
    }
  }
}
