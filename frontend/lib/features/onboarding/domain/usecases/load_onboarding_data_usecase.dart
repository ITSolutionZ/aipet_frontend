import '../../../../shared/shared.dart';

import '../entities/entities.dart';
import '../repositories/onboarding_repository.dart';


/// 온보딩 데이터 로드 UseCase
class LoadOnboardingDataUseCase
    extends
        RepositoryUseCaseNoParams<List<OnboardingPage>, OnboardingRepository> {
  LoadOnboardingDataUseCase(super.repository);

  @override
  String get operationName => '온보딩 데이터 로드';

  @override
  Future<Result<List<OnboardingPage>>> execute() async {
    return repository.loadOnboardingData();
  }
}
