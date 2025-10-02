import 'package:aipet_frontend/features/onboarding/domain/onboarding_state.dart';
import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 온보딩 상태 확인 UseCase
class CheckOnboardingStatusUseCase extends BaseUseCaseNoParams<OnboardingState> {
  const CheckOnboardingStatusUseCase(super.repository);

  @override
  Future<Result<OnboardingState>> call() async {
    try {
      // 비즈니스 로직: 온보딩 완료 여부 확인
      final completedResult = await repository.isOnboardingCompleted();
      if (!completedResult.isSuccess) {
        return Result.failure('온보딩 완료 상태 확인에 실패했습니다');
      }

      final isCompleted = completedResult.dataOrNull ?? false;
      if (isCompleted) {
        // 완료된 경우 완료 상태 반환
        return Result.success(const OnboardingState(isCompleted: true).toString());
      } else {
        // 미완료인 경우 현재 진행 상태 로드
        return repository.loadOnboardingState();
      }
    } catch (e) {
      return Result.failure('온보딩 상태 확인 중 오류가 발생했습니다: $e');
    }
  }
}
