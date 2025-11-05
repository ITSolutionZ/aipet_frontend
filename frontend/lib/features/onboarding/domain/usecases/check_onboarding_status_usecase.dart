import '../../../../shared/shared.dart';

import '../onboarding_state.dart';
import '../repositories/onboarding_repository.dart';


/// 온보딩 상태 확인 UseCase
class CheckOnboardingStatusUseCase
    extends RepositoryUseCaseNoParams<OnboardingState, OnboardingRepository> {
  CheckOnboardingStatusUseCase(super.repository);

  @override
  String get operationName => '온보딩 상태 확인';

  @override
  Future<Result<OnboardingState>> execute() async {
    // 비즈니스 로직: 온보딩 완료 여부 확인
    final completedResult = await repository.isOnboardingCompleted();
    if (!completedResult.isSuccess) {
      return Result.failure('온보딩 완료 상태 확인에 실패했습니다');
    }

    final isCompleted = completedResult.dataOrNull ?? false;
    if (isCompleted) {
      // 완료된 경우 완료 상태 반환
      return Result.success(
        const OnboardingState(isCompleted: true).toString(),
      );
    } else {
      // 미완료인 경우 현재 진행 상태 로드
      return repository.loadOnboardingState();
    }
  }
}
