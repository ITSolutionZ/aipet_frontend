import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 온보딩 완료 UseCase
class CompleteOnboardingUseCase extends BaseUseCaseNoParams<void> {
  const CompleteOnboardingUseCase(super.repository);

  @override
  Future<Result<void>> call() async {
    try {
      // 비즈니스 로직: 온보딩 완료 처리
      final completeResult = await repository.completeOnboarding();
      if (!completeResult.isSuccess) {
        return completeResult;
      }

      // 온보딩 상태를 완료로 업데이트
      final stateResult = await repository.loadOnboardingState();
      if (!stateResult.isSuccess) {
        return ResultFactory.failure('온보딩 상태 로드에 실패했습니다');
      }

      final currentState = stateResult.dataOrNull!;
      final completedState = currentState.copyWith(isCompleted: true);
      final saveResult = await repository.saveOnboardingState(completedState);

      return saveResult;
    } catch (e) {
      return ResultFactory.failure('온보딩 완료 처리 중 오류가 발생했습니다: $e');
    }
  }
}
