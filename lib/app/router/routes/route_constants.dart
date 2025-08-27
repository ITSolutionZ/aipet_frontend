/// 앱의 모든 라우트 상수를 정의하는 파일
///
/// 네이밍 컨벤션:
/// - 메인 라우트: kebab-case (예: /home, /pet-profile)
/// - 하위 라우트: kebab-case (예: /home/pet-empty, /settings/profile-edit)
/// - 쿼리 파라미터: camelCase (예: /pet-profile?petId=123)
class RouteConstants {
  // ===== SPLASH & ONBOARDING =====
  static const String logoRoute = '/';
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';

  // ===== AUTHENTICATION =====
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String welcomeRoute = '/welcome';

  // ===== MAIN APP TABS =====
  static const String homeRoute = '/home';
  static const String schedulingRoute = '/scheduling';
  static const String aiRoute = '/ai';
  static const String walkRoute = '/walk';
  static const String calendarRoute = '/calendar';
  static const String settingsRoute = '/settings';

  // ===== HOME TAB SUB-ROUTES =====
  static const String petEmptyRoute = '/home/pet-empty';
  static const String petProfileRoute = '/home/pet-profile';
  static const String sharingProfilesRoute = '/home/sharing-profiles';
  static const String vaccinesRoute = '/home/vaccines';
  static const String tricksRoute = '/home/tricks';
  static const String allTricksRoute = '/all-tricks';
  static const String trainingVideosRoute = '/training-videos';

  // ===== SCHEDULING TAB SUB-ROUTES =====
  static const String feedingScheduleRoute = '/scheduling/feeding-schedule';
  static const String feedingRecordsRoute = '/scheduling/feeding-records';
  static const String feedingAnalysisRoute = '/scheduling/feeding-analysis';
  static const String feedingScheduleEditRoute =
      '/scheduling/feeding-schedule/edit';
  static const String addFeedingRecordRoute = '/scheduling/add-feeding-record';
  static const String trainingMainRoute = '/scheduling/training';
  static const String wateringMainRoute = '/scheduling/watering';
  static const String healthMainRoute = '/scheduling/health';

  // ===== CALENDAR TAB SUB-ROUTES =====
  static const String groomingReservationRoute =
      '/calendar/grooming-reservation';
  static const String hospitalReservationRoute =
      '/calendar/hospital-reservation';
  static const String facilityDetailRoute = '/calendar/facility-detail';
  static const String bookingRoute = '/calendar/booking';

  // ===== SETTINGS TAB SUB-ROUTES =====
  static const String profileEditRoute = '/settings/profile-edit';
  static const String accountDeleteRoute = '/settings/account-delete';
  static const String pushNotificationRoute = '/settings/push-notification';
  static const String alarmTimeSettingsRoute = '/settings/alarm-time-settings';

  // ===== PET FEEDING =====
  static const String feedingMainRoute = '/feeding-main';
  static const String recipesRoute = '/recipes';
  static const String addRecipeRoute = '/add-recipe';

  // ===== PET REGISTRATION FLOW =====
  static const String petTypeSelectionRoute = '/pet-type-selection';
  static const String dogBreedSelectionRoute = '/dog-breed-selection';
  static const String petNameInputRoute = '/pet-name-input';
  static const String petSizeWeightRoute = '/pet-size-weight';
  static const String petAnniversaryRoute = '/pet-anniversary';
  static const String petAnniversarySummaryRoute = '/pet-anniversary-summary';
  static const String petRegistrationCompleteRoute =
      '/pet-registration-complete';

  // ===== STANDALONE ROUTES =====
  static const String addFamilyManagerRoute = '/add-family-manager';
  static const String weightTrackingRoute = '/weight-tracking';
  static const String healthRecordsRoute = '/health-records';
  static const String vaccinationRecordsRoute = '/vaccination-records';
  static const String notificationListRoute = '/notifications';
  static const String notificationDetailRoute = '/notification-detail';
  static const String eventDetailRoute = '/event-detail';
}
