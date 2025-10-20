import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/onboarding_repository.dart';

/// 온보딩 완료 UseCase
class CompleteOnboardingUseCase
    extends RepositoryUseCaseNoParams<void, OnboardingRepository> {
  CompleteOnboardingUseCase(super.repository);

  @override
  String get operationName => '온보딩 완료';

  @override
  Future<Result<void>> execute() async {
    // 비즈니스 로직: 온보딩 완료 처리
    final completeResult = await repository.completeOnboarding();
    if (!completeResult.isSuccess) {
      return completeResult;
    }

    // 온보딩 상태를 완료로 업데이트
    final stateResult = await repository.loadOnboardingState();
    if (!stateResult.isSuccess) {
      return Result.failure('온보딩 상태 로드에 실패했습니다');
    }

    final currentState = stateResult.dataOrNull!;
    final completedState = currentState.copyWith(isCompleted: true);
    final saveResult = await repository.saveOnboardingState(completedState);

    return saveResult;
  }
}
