import 'package:go_router/go_router.dart';

import 'routes/routes.dart';

/// 중앙집중화된 앱 라우터 설정
///
/// 이 클래스는 앱의 모든 라우팅을 관리합니다.
/// 각 라우트 그룹은 별도의 파일로 분리되어 있습니다:
/// - splash_shell_routes.dart: 로고 시퀀스 → 온보딩 Shell 라우트 (최우선)
/// - auth_routes.dart: 인증 관련 라우트 (로그인, 회원가입)
/// - shell_routes.dart: 메인 앱 Shell 라우트 (하단 네비게이션)
/// - standalone_routes.dart: 독립적인 전체화면 라우트
///
/// 라우터는 모듈형 구조로 설계되어 있어 유지보수와 확장이 용이합니다.
class AppRouter {
  // 라우트 상수들은 RouteConstants에서 관리
  static const String logoRoute = RouteConstants.logoRoute;
  static const String splashRoute = RouteConstants.splashRoute;
  static const String onboardingRoute = RouteConstants.onboardingRoute;
  static const String homeRoute = RouteConstants.homeRoute;
  static const String loginRoute = RouteConstants.loginRoute;
  static const String signupRoute = RouteConstants.signupRoute;
  static const String welcomeRoute = RouteConstants.welcomeRoute;
  static const String schedulingRoute = RouteConstants.schedulingRoute;
  static const String aiRoute = RouteConstants.aiRoute;
  static const String walkRoute = RouteConstants.walkRoute;
  static const String calendarRoute = RouteConstants.calendarRoute;
  static const String settingsRoute = RouteConstants.settingsRoute;

  // 추가된 라우트 상수들
  static const String petProfileRoute = RouteConstants.petProfileRoute;
  static const String profileEditRoute = RouteConstants.profileEditRoute;
  static const String accountDeleteRoute = RouteConstants.accountDeleteRoute;
  static const String pushNotificationRoute =
      RouteConstants.pushNotificationRoute;
  static const String alarmTimeSettingsRoute =
      RouteConstants.alarmTimeSettingsRoute;
  static const String notificationDetailRoute =
      RouteConstants.notificationDetailRoute;
  static const String feedingScheduleRoute =
      RouteConstants.feedingScheduleRoute;
  static const String feedingRecordsRoute = RouteConstants.feedingRecordsRoute;
  static const String feedingAnalysisRoute =
      RouteConstants.feedingAnalysisRoute;
  static const String feedingScheduleEditRoute =
      RouteConstants.feedingScheduleEditRoute;
  static const String addFeedingRecordRoute =
      RouteConstants.addFeedingRecordRoute;
  static const String feedingMainRoute = RouteConstants.feedingMainRoute;
  static const String trainingMainRoute = RouteConstants.trainingMainRoute;
  static const String wateringMainRoute = RouteConstants.wateringMainRoute;
  static const String healthMainRoute = RouteConstants.healthMainRoute;
  static const String vaccinesRoute = RouteConstants.vaccinesRoute;
  static const String hospitalReservationRoute =
      RouteConstants.hospitalReservationRoute;
  static const String groomingReservationRoute =
      RouteConstants.groomingReservationRoute;
  static const String facilityDetailRoute = RouteConstants.facilityDetailRoute;
  static const String bookingRoute = RouteConstants.bookingRoute;
  static const String recipesRoute = RouteConstants.recipesRoute;
  static const String addRecipeRoute = RouteConstants.addRecipeRoute;

  /// GoRouter 인스턴스를 생성합니다.
  ///
  /// 라우터 우선순위:
  /// 1. SplashShellRoutes: 로고 시퀀스 → 온보딩 (최우선, 스킵 불가)
  /// 2. AuthRoutes: 인증 관련 라우트 (로그인, 회원가입)
  /// 3. ShellRoutes: 메인 앱 Shell 라우트 (하단 네비게이션)
  /// 4. StandaloneRoutes: 독립적인 전체화면 라우트
  ///
  /// [return] 구성된 GoRouter 인스턴스
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: logoRoute,
      debugLogDiagnostics: true,
      routes: [
        // 1. Splash Shell 라우트 (로고 시퀀스 → 온보딩) - 최우선
        SplashShellRoutes.splashShellRoute,

        // 2. 인증 관련 라우트 (로그인, 회원가입)
        ...AuthRoutes.routes,

        // 3. 메인 앱 Shell 라우트 (하단 네비게이션)
        ShellRoutes.shellRoute,

        // 4. 펫 관련 라우트 (펫 등록, 프로필, 건강)
        ...PetRoutes.routes,

        // 5. 독립적인 전체화면 라우트
        ...StandaloneRoutes.routes,
      ],
    );
  }
}
