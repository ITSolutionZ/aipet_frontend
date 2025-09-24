import 'package:aipet_frontend/shared/shared.dart';

/// 온보딩 데이터 로드 UseCase
class LoadOnboardingDataUseCase
    extends BaseUseCaseNoParams<List<OnboardingPage>> {
  const LoadOnboardingDataUseCase(super.repository);

  @override
  Future<List<OnboardingPage>> call() async {
    return repository.loadOnboardingData();
  }
}
