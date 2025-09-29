import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 온보딩 재시작 UseCase
class RestartOnboardingUseCase extends BaseUseCaseNoParams<void> {
  const RestartOnboardingUseCase(super.repository);

  @override
  Future<Result<void>> call() async {
    try {
      // 비즈니스 로직: 온보딩 재시작 처리
      return repository.restartOnboarding();
    } catch (e) {
      return Result.failure('온보딩 재시작 중 오류가 발생했습니다: $e');
    }
  }
}
