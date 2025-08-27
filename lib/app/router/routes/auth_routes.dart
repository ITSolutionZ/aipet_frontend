import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/presentation.dart';
import 'route_constants.dart';

/// 인증 관련 라우트 설정
///
/// 로그인, 회원가입, 환영 화면 등 순수한 인증 관련 라우트만 포함합니다.
/// 이 라우트들은 Shell 밖에서 독립적으로 실행되며, 인증 플로우를 담당합니다.
class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteConstants.loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteConstants.signupRoute,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: RouteConstants.welcomeRoute,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
  ];
}
