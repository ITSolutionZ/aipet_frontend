import 'package:go_router/go_router.dart';

import '../../../features/onboarding/presentation/presentation.dart';
import '../../../features/splash/presentation/presentation.dart';
import 'route_constants.dart';

/// Splash Shell 라우터
///
/// 로고 시퀀스 (ITZ → AI Pet) → Onboarding까지를 처리하는 Shell 라우터입니다.
/// 사용자는 이 과정을 스킵할 수 없으며, 모든 단계를 거쳐야 합니다.
///
/// 라우트 순서:
/// 1. / (logo) → ITZ 로고 표시
/// 2. /splash → AI Pet 로고 표시
/// 3. /onboarding → 온보딩 화면
///
/// 이 Shell은 앱 시작 시 최우선으로 실행되며, 사용자 경험의 첫 단계를 담당합니다.
class SplashShellRoutes {
  /// Splash Shell 라우트를 반환합니다.
  ///
  /// 로고 시퀀스부터 온보딩까지의 모든 라우트를 포함하는 Shell 라우트입니다.
  static final ShellRoute splashShellRoute = ShellRoute(
    builder: (context, state, child) {
      // Shell은 단순히 자식 위젯을 표시
      return child;
    },
    routes: [
      // 1단계: 로고 페이지 (ITZ 로고)
      GoRoute(
        path: RouteConstants.logoRoute,
        name: 'logo',
        builder: (context, state) => const LogoPage(),
      ),

      // 2단계: 스플래시 페이지 (AI Pet 로고)
      GoRoute(
        path: RouteConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 3단계: 온보딩 페이지
      GoRoute(
        path: RouteConstants.onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
