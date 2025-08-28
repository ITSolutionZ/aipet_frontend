import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class OnboardingResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const OnboardingResult._(this.isSuccess, this.message, this.data);

  factory OnboardingResult.success(String message, [dynamic data]) =>
      OnboardingResult._(true, message, data);
  factory OnboardingResult.failure(String message) =>
      OnboardingResult._(false, message, null);
}

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
    ref.read(onboardingStateNotifierProvider.notifier).nextPage();
  }

  void previousPage() {
    ref.read(onboardingStateNotifierProvider.notifier).previousPage();
  }

  void goToPage(int page) {
    ref.read(onboardingStateNotifierProvider.notifier).goToPage(page);
  }

  void completeOnboarding() {
    ref.read(onboardingStateNotifierProvider.notifier).completeOnboarding();
  }

  /// 온보딩 데이터 로드
  Future<OnboardingResult> loadOnboardingData() async {
    try {
      final pages = await _loadDataUseCase();
      return OnboardingResult.success('온보딩 데이터가 로드되었습니다', pages);
    } catch (error) {
      handleError(error);
      return OnboardingResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 온보딩 완료 처리
  Future<OnboardingResult> finishOnboarding() async {
    try {
      await _completeUseCase();
      completeOnboarding();
      return OnboardingResult.success('온보딩이 완료되었습니다');
    } catch (error) {
      handleError(error);
      return OnboardingResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 온보딩 상태 확인
  Future<OnboardingResult> checkOnboardingStatus() async {
    try {
      final status = await _checkStatusUseCase();
      return OnboardingResult.success('온보딩 상태를 확인했습니다', status);
    } catch (error) {
      handleError(error);
      return OnboardingResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 온보딩 재시작
  Future<OnboardingResult> restartOnboarding() async {
    try {
      await _restartUseCase();
      goToPage(0);
      return OnboardingResult.success('온보딩이 재시작되었습니다');
    } catch (error) {
      handleError(error);
      return OnboardingResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
