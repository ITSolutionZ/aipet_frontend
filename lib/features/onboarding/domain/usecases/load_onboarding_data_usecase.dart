import '../onboarding_data.dart';
import '../repositories/onboarding_repository.dart';

/// 온보딩 데이터 로드 UseCase
class LoadOnboardingDataUseCase {
  final OnboardingRepository repository;

  LoadOnboardingDataUseCase(this.repository);

  Future<List<OnboardingPage>> call() async {
    return repository.loadOnboardingData();
  }
}
