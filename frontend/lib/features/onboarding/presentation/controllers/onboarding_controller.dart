import '../../../../shared/shared.dart';

import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';


/// 🎯 Professional UseCase-Driven Onboarding Controller
///
/// All actions go through UseCases following Clean Architecture principles
class OnboardingController extends BaseController {
  OnboardingController(super.ref);

  // ✅ All UseCases properly injected
  late final CompleteOnboardingUseCase _completeUseCase =
      CompleteOnboardingUseCase(ref.read(onboardingRepositoryProvider));
  late final CheckOnboardingStatusUseCase _checkStatusUseCase =
      CheckOnboardingStatusUseCase(ref.read(onboardingRepositoryProvider));
  late final LoadOnboardingDataUseCase _loadDataUseCase =
      LoadOnboardingDataUseCase(ref.read(onboardingRepositoryProvider));
  late final RestartOnboardingUseCase _restartUseCase =
      RestartOnboardingUseCase(ref.read(onboardingRepositoryProvider));
  late final NextPageUseCase _nextPageUseCase = NextPageUseCase(
    ref.read(onboardingRepositoryProvider),
  );
  late final PreviousPageUseCase _previousPageUseCase = PreviousPageUseCase(
    ref.read(onboardingRepositoryProvider),
  );
  late final GoToPageUseCase _goToPageUseCase = GoToPageUseCase(
    ref.read(onboardingRepositoryProvider),
  );
  late final NavigateAfterOnboardingUseCase _navigationUseCase =
      NavigateAfterOnboardingUseCase(ref.read(onboardingRepositoryProvider));

  /// ✅ Navigate to next page through UseCase
  Future<Result<void>> nextPage() async {
    final result = await _nextPageUseCase();
    if (result.isSuccess) {
      // Update UI state after successful navigation
      ref.read(onboardingProvider.notifier).nextPage();
    }
    return result;
  }

  /// ✅ Navigate to previous page through UseCase
  Future<Result<void>> previousPage() async {
    final result = await _previousPageUseCase();
    if (result.isSuccess) {
      // Update UI state after successful navigation
      ref.read(onboardingProvider.notifier).previousPage();
    }
    return result;
  }

  /// ✅ Navigate to specific page through UseCase
  Future<Result<void>> goToPage(int page) async {
    final result = await _goToPageUseCase(page);
    if (result.isSuccess) {
      // Update UI state after successful navigation
      ref.read(onboardingProvider.notifier).goToPage(page);
    }
    return result;
  }

  /// ✅ Load onboarding data through UseCase
  Future<Result<List<OnboardingPage>>> loadOnboardingData() async {
    final result = await _loadDataUseCase();
    return result;
  }

  /// ✅ Complete onboarding through UseCase and update state
  Future<Result<void>> finishOnboarding() async {
    final result = await _completeUseCase();
    if (result.isSuccess) {
      // Update UI state after successful completion
      ref.read(onboardingProvider.notifier).completeOnboarding();
    }
    return result;
  }

  /// ✅ Check onboarding status through UseCase
  Future<Result<OnboardingState>> checkOnboardingStatus() async {
    final result = await _checkStatusUseCase();
    return result;
  }

  /// ✅ Restart onboarding through UseCase and reset state
  Future<Result<void>> restartOnboarding() async {
    final result = await _restartUseCase();
    if (result.isSuccess) {
      // Reset UI state after successful restart
      await goToPage(0);
    }
    return result;
  }

  /// ✅ Initialize onboarding state
  Future<Result<void>> initializeOnboarding() async {
    try {
      // Start onboarding tracking
      ref.read(onboardingProvider.notifier).startOnboarding();
      return Result.success(null.toString(), '온보딩이 시작되었습니다');
    } catch (error) {
      return Result.failure('온보딩 초기화 중 오류가 발생했습니다: $error');
    }
  }

  /// ✅ Get navigation route after onboarding completion
  Future<Result<String>> getNavigationRoute() async {
    final result = await _navigationUseCase();
    return result;
  }

  /// ✅ Complete onboarding and get navigation route
  Future<Result<String>> completeAndNavigate() async {
    final completeResult = await finishOnboarding();
    if (!completeResult.isSuccess) {
      return Result.failure('온보딩 완료에 실패했습니다');
    }

    final navigationResult = await getNavigationRoute();
    return navigationResult;
  }
}
