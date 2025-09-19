import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class OnboardingController extends BaseController {
  OnboardingController(super.ref);

  // UseCases
  late final CompleteOnboardingUseCase _completeUseCase =
      CompleteOnboardingUseCase(ref.read(onboardingRepositoryProvider));
  late final CheckOnboardingStatusUseCase _checkStatusUseCase =
      CheckOnboardingStatusUseCase(ref.read(onboardingRepositoryProvider));
  late final LoadOnboardingDataUseCase _loadDataUseCase =
      LoadOnboardingDataUseCase(ref.read(onboardingRepositoryProvider));
  late final RestartOnboardingUseCase _restartUseCase =
      RestartOnboardingUseCase(ref.read(onboardingRepositoryProvider));

  void nextPage() {
    ref.read(onboardingNotifierProvider.notifier).nextPage();
  }

  void previousPage() {
    ref.read(onboardingNotifierProvider.notifier).previousPage();
  }

  void goToPage(int page) {
    ref.read(onboardingNotifierProvider.notifier).goToPage(page);
  }

  void completeOnboarding() {
    ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
  }

  /// 온보딩 데이터 로드
  Future<Result<List<OnboardingPage>>> loadOnboardingData() async {
    try {
      final pages = await _loadDataUseCase();
      return Result.success('온보딩 데이터가 로드되었습니다', pages);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 온보딩 완료 처리
  Future<Result<void>> finishOnboarding() async {
    try {
      await _completeUseCase();
      completeOnboarding();
      return Result.success('온보딩이 완료되었습니다');
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 온보딩 상태 확인
  Future<Result<OnboardingState>> checkOnboardingStatus() async {
    try {
      final status = await _checkStatusUseCase();
      return Result.success('온보딩 상태를 확인했습니다', status);
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 온보딩 재시작
  Future<Result<void>> restartOnboarding() async {
    try {
      await _restartUseCase();
      goToPage(0);
      return Result.success('온보딩이 재시작되었습니다');
    } catch (error) {
      handleError(error);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
