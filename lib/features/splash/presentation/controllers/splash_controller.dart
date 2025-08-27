import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class SplashResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const SplashResult._(this.isSuccess, this.message, this.data);

  factory SplashResult.success(String message, [dynamic data]) =>
      SplashResult._(true, message, data);
  factory SplashResult.failure(String message) =>
      SplashResult._(false, message, null);
}

class SplashController extends BaseController {
  SplashController(super.ref);

  // Repository 및 UseCase 인스턴스
  late final SplashRepository _repository = SplashRepositoryImpl();
  late final GetSplashConfigUseCase _getSplashConfigUseCase =
      GetSplashConfigUseCase(_repository);

  /// 스플래시 설정 로드
  Future<SplashResult> loadSplashConfig() async {
    try {
      final splashConfig = await _getSplashConfigUseCase.call();
      return SplashResult.success('스플래시 설정이 로드되었습니다', splashConfig);
    } catch (error) {
      handleError(error);
      return SplashResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 스플래시 화면 표시 시간 관리
  Future<SplashResult> showSplashScreen() async {
    try {
      // 스플래시 화면 최소 표시 시간
      await Future.delayed(const Duration(milliseconds: 1500));
      return SplashResult.success('스플래시 화면 표시 완료');
    } catch (error) {
      handleError(error);
      return SplashResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 다음 화면 결정 (Bootstrap에서 초기화된 상태를 기반으로)
  String determineNextRoute({
    required bool isAuthenticated,
    required bool isOnboardingCompleted,
  }) {
    if (!isOnboardingCompleted) {
      return '/onboarding';
    } else if (!isAuthenticated) {
      return '/login';
    } else {
      return '/home';
    }
  }
}
