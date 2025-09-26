import 'package:aipet_frontend/features/onboarding/domain/entities/entities.dart';
import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 온보딩 데이터 로드 UseCase
class LoadOnboardingDataUseCase
    extends BaseUseCaseNoParams<List<OnboardingPage>> {
  const LoadOnboardingDataUseCase(super.repository);

  @override
  Future<Result<List<OnboardingPage>>> call() async {
    try {
      return repository.loadOnboardingData();
    } catch (e) {
      return ResultFactory.failure('온보딩 데이터 로드 중 오류가 발생했습니다: $e');
    }
  }
}
