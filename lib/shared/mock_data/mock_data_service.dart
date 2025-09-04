/// DEPRECATED: 이 파일은 더 이상 사용되지 않습니다.
///
/// 각 기능별 Mock 서비스를 사용해주세요:
/// - [PetMockService] (features/pet/pet_mock_service.dart)
/// - [HomeMockService] (features/home/home_mock_service.dart)
/// - [NotificationMockService] (features/notification/notification_mock_service.dart)
/// - [SchedulingMockService] (features/scheduling/scheduling_mock_service.dart)
/// - [AuthMockService] (features/auth/auth_mock_service.dart)
/// - [AiMockService] (features/ai/ai_mock_service.dart)
library;

// 레거시 import들은 새로운 feature-specific mock 서비스로 대체됩니다
import 'features/ai/ai_mock_service.dart';
import 'features/auth/auth_mock_service.dart';
import 'features/facility/facility_mock_service.dart';
import 'features/home/home_mock_service.dart';
import 'features/notification/notification_mock_service.dart';
import 'features/pet/pet_mock_service.dart';
import 'features/pet_activities/pet_activities_mock_service.dart';
import 'features/pet_feeding/pet_feeding_mock_service.dart';
import 'features/pet_health/pet_health_mock_service.dart';
import 'features/scheduling/scheduling_mock_service.dart';
import 'features/walk/walk_mock_service.dart';

/// @deprecated 이 클래스는 더 이상 사용되지 않습니다. 각 feature별 Mock 서비스를 사용해주세요.
///
/// 마이그레이션 가이드:
/// ```dart
/// // Before
/// MockDataService.getMockPets();
///
/// // After
/// PetMockService.getMockPets();
/// ```
@Deprecated('Use feature-specific mock services instead')
abstract class MockDataService {
  /// Mock 데이터 사용 플래그
  static const bool isEnabled = true;

  // ==================== Pet Data ====================

  /// @deprecated Use [PetMockService.getMockPets] instead
  @Deprecated('Use PetMockService.getMockPets instead')
  static List<Map<String, dynamic>> getMockPets() =>
      PetMockService.getMockPets();

  /// @deprecated Use [PetMockService.getPetById] instead
  @Deprecated('Use PetMockService.getPetById instead')
  static Map<String, dynamic>? getMockPetById(String id) =>
      PetMockService.getPetById(id);

  // ==================== Home Data ====================

  /// @deprecated Use [HomeMockService.getMockWeatherInfo] instead
  @Deprecated('Use HomeMockService.getMockWeatherInfo instead')
  static Map<String, dynamic> getMockWeatherInfo() =>
      HomeMockService.getMockWeatherInfo();

  /// @deprecated Use [HomeMockService.getMockPetActivities] instead
  @Deprecated('Use HomeMockService.getMockPetActivities instead')
  static List<Map<String, dynamic>> getMockPetActivities({String? petId}) =>
      HomeMockService.getMockPetActivities(petId: petId);

  /// @deprecated Use [HomeMockService.getMockNextWalkTime] instead
  @Deprecated('Use HomeMockService.getMockNextWalkTime instead')
  static String getMockNextWalkTime({String? petId}) =>
      HomeMockService.getMockNextWalkTime(petId: petId);

  /// @deprecated Use [HomeMockService.getMockNextMealInfo] instead
  @Deprecated('Use HomeMockService.getMockNextMealInfo instead')
  static Map<String, dynamic> getMockNextMealInfo({String? petId}) =>
      HomeMockService.getMockNextMealInfo(petId: petId);

  /// @deprecated Use [HomeMockService.getMockExpectedCalories] instead
  @Deprecated('Use HomeMockService.getMockExpectedCalories instead')
  static int getMockExpectedCalories({String? petId}) =>
      HomeMockService.getMockExpectedCalories(petId: petId);

  /// @deprecated Use [HomeMockService.getMockNextAppointmentType] instead
  @Deprecated('Use HomeMockService.getMockNextAppointmentType instead')
  static String getMockNextAppointmentType({String? petId}) =>
      HomeMockService.getMockNextAppointmentType(petId: petId);

  /// @deprecated Use [HomeMockService.getMockWalkSummary] instead
  @Deprecated('Use HomeMockService.getMockWalkSummary instead')
  static Map<String, dynamic> getMockWalkSummary({String? petId}) =>
      HomeMockService.getMockWalkSummary(petId: petId);

  /// @deprecated Use [HomeMockService.getMockWeightRecords] instead
  @Deprecated('Use HomeMockService.getMockWeightRecords instead')
  static List<Map<String, dynamic>> getMockWeightRecords({
    String? petId,
    int days = 30,
  }) =>
      HomeMockService.getMockWeightRecords(petId: petId, days: days);

  /// @deprecated Use [HomeMockService.getMockTodayMeals] instead
  @Deprecated('Use HomeMockService.getMockTodayMeals instead')
  static List<Map<String, dynamic>> getMockTodayMeals({String? petId}) =>
      HomeMockService.getMockTodayMeals(petId: petId);

  // ==================== Appointments Data ====================

  /// @deprecated Use [PetMockService.getMockAppointments] instead
  @Deprecated('Use PetMockService.getMockAppointments instead')
  static List<Map<String, dynamic>> getMockAppointments() =>
      PetMockService.getMockAppointments();

  /// @deprecated Use [PetMockService.getMockTodayAppointmentsByPet] instead
  @Deprecated('Use PetMockService.getMockTodayAppointmentsByPet instead')
  static List<Map<String, dynamic>> getMockTodayAppointmentsByPet({
    String? petId,
  }) =>
      PetMockService.getMockTodayAppointmentsByPet(petId: petId);

  // ==================== Scheduling Data ====================

  /// @deprecated Use [SchedulingMockService.getMockFeedingSchedules] instead
  @Deprecated('Use SchedulingMockService.getMockFeedingSchedules instead')
  static List<Map<String, dynamic>> getMockFeedingSchedules() =>
      SchedulingMockService.getMockFeedingSchedules();

  /// @deprecated Use [SchedulingMockService.getMockTodayMealsForSchedule] instead
  @Deprecated('Use SchedulingMockService.getMockTodayMealsForSchedule instead')
  static List<Map<String, dynamic>> getMockTodayMealsForSchedule() =>
      SchedulingMockService.getMockTodayMealsForSchedule();

  /// @deprecated Use [SchedulingMockService.getMockWateringData] instead
  @Deprecated('Use SchedulingMockService.getMockWateringData instead')
  static Map<String, dynamic> getMockWateringData() =>
      SchedulingMockService.getMockWateringData();

  /// @deprecated Use [SchedulingMockService.getMockTrainingData] instead
  @Deprecated('Use SchedulingMockService.getMockTrainingData instead')
  static Map<String, dynamic> getMockTrainingData() =>
      SchedulingMockService.getMockTrainingData();

  /// @deprecated Use [SchedulingMockService.getMockHealthData] instead
  @Deprecated('Use SchedulingMockService.getMockHealthData instead')
  static Map<String, dynamic> getMockHealthData() =>
      SchedulingMockService.getMockHealthData();

  /// @deprecated Use [SchedulingMockService.getMockFeedingStatisticsForRecords] instead
  @Deprecated(
    'Use SchedulingMockService.getMockFeedingStatisticsForRecords instead',
  )
  static Map<String, dynamic> getMockFeedingStatisticsForRecords() =>
      SchedulingMockService.getMockFeedingStatisticsForRecords();
  
  // ==================== Pet Status Data ====================
  
  /// @deprecated Use [PetMockService.getPetStatusOptions] instead
  @Deprecated('Use PetMockService.getPetStatusOptions instead')
  static List<Map<String, dynamic>> getPetStatusOptions() =>
      PetMockService.getPetStatusOptions();

  /// @deprecated Use [HomeMockService.getMockHealthSummary] instead
  @Deprecated('Use HomeMockService.getMockHealthSummary instead')
  static Map<String, dynamic> getMockHealthSummary({String? petId}) =>
      HomeMockService.getMockHealthSummary(petId: petId);

  // ==================== Pet Registration Data ====================

  /// @deprecated Use [PetMockService.getMockPetTypes] instead
  @Deprecated('Use PetMockService.getMockPetTypes instead')
  static List<Map<String, dynamic>> getMockPetTypes() =>
      PetMockService.getMockPetTypes();

  /// @deprecated Use [PetMockService.getMockDogBreeds] instead
  @Deprecated('Use PetMockService.getMockDogBreeds instead')
  static List<Map<String, dynamic>> getMockDogBreeds() =>
      PetMockService.getMockDogBreeds();

  /// @deprecated Use [PetMockService.getPetCurrentStatus] instead
  @Deprecated('Use PetMockService.getPetCurrentStatus instead')
  static Map<String, dynamic> getPetCurrentStatus(String petId) =>
      PetMockService.getPetCurrentStatus(petId);

  /// @deprecated Use [PetMockService.updatePetStatus] instead
  @Deprecated('Use PetMockService.updatePetStatus instead')
  static void updatePetStatus(String petId, List<String> categories, Map<String, String> statusMap) =>
      PetMockService.updatePetStatus(petId, categories, statusMap);

  /// @deprecated Use [PetMockService.getPetGenderByName] instead
  @Deprecated('Use PetMockService.getPetGenderByName instead')
  static String getPetGenderByName(String petName) =>
      PetMockService.getPetGenderByName(petName);

  /// @deprecated Use [PetMockService.getMockExampleLinks] instead
  @Deprecated('Use PetMockService.getMockExampleLinks instead')
  static List<String> getMockExampleLinks() =>
      PetMockService.getMockExampleLinks();

  /// @deprecated Use [PetMockService.getMockLinkRegistrationResult] instead
  @Deprecated('Use PetMockService.getMockLinkRegistrationResult instead')
  static Map<String, dynamic> getMockLinkRegistrationResult(String link) =>
      PetMockService.getMockLinkRegistrationResult(link);

  /// @deprecated Use [PetMockService.isValidLink] instead
  @Deprecated('Use PetMockService.isValidLink instead')
  static bool isValidLink(String link) => PetMockService.isValidLink(link);

  /// @deprecated Use [PetMockService.findPetById] instead
  @Deprecated('Use PetMockService.findPetById instead')
  static Map<String, dynamic>? findPetById(String petId) =>
      PetMockService.findPetById(petId);

  /// @deprecated Use [PetMockService.getMockPetProfiles] instead
  @Deprecated('Use PetMockService.getMockPetProfiles instead')
  static List<Map<String, dynamic>> getMockPetProfiles() =>
      PetMockService.getMockPetProfiles();

  // ==================== Scheduling & Feeding Data ====================

  /// @deprecated Use [PetFeedingMockService.getMockFeedingRecords] instead
  @Deprecated('Use PetFeedingMockService.getMockFeedingRecords instead')
  static List<Map<String, dynamic>> getMockFeedingRecords({String? petId}) =>
      PetFeedingMockService.getMockFeedingRecords(petId: petId);

  /// @deprecated Use [SchedulingMockService.getMockFeedingRecordsForRecords] instead
  @Deprecated('Use SchedulingMockService.getMockFeedingRecordsForRecords instead')
  static List<Map<String, dynamic>> getMockFeedingRecordsForRecords() =>
      SchedulingMockService.getMockFeedingRecordsForRecords();

  /// @deprecated Use [SchedulingMockService.addMockFeedingRecord] instead
  @Deprecated('Use SchedulingMockService.addMockFeedingRecord instead')
  static void addMockFeedingRecord(Map<String, dynamic> record) =>
      SchedulingMockService.addMockFeedingRecord(record);

  /// @deprecated Use [SchedulingMockService.getMockPetSizesAndFeedingAmounts] instead
  @Deprecated('Use SchedulingMockService.getMockPetSizesAndFeedingAmounts instead')
  static Map<String, Map<String, dynamic>> getMockPetSizesAndFeedingAmounts() =>
      SchedulingMockService.getMockPetSizesAndFeedingAmounts();

  /// @deprecated Use [SchedulingMockService.getPetSizeFeedingGuide] instead
  @Deprecated('Use SchedulingMockService.getPetSizeFeedingGuide instead')
  static Map<String, dynamic> getPetSizeFeedingGuide(String petId) =>
      SchedulingMockService.getPetSizeFeedingGuide();

  /// @deprecated Use [SchedulingMockService.getMockFeedingAnalysisData] instead
  @Deprecated('Use SchedulingMockService.getMockFeedingAnalysisData instead')
  static Map<String, dynamic> getMockFeedingAnalysisData({String? petId}) =>
      SchedulingMockService.getMockFeedingAnalysisData();

  /// @deprecated Use [SchedulingMockService.getMockFeedingStatistics] instead
  @Deprecated('Use SchedulingMockService.getMockFeedingStatistics instead')
  static Map<String, dynamic> getMockFeedingStatistics({String? petId}) =>
      SchedulingMockService.getMockFeedingStatistics();

  /// @deprecated Use [SchedulingMockService.getMockFeedingSchedulesForSchedule] instead
  @Deprecated('Use SchedulingMockService.getMockFeedingSchedulesForSchedule instead')
  static List<Map<String, dynamic>> getMockFeedingSchedulesForSchedule() =>
      SchedulingMockService.getMockFeedingSchedulesForSchedule();

  /// @deprecated Use [SchedulingMockService.updateFeedingSchedule] instead
  @Deprecated('Use SchedulingMockService.updateFeedingSchedule instead')
  static void updateFeedingSchedule(String mealType, String time, String amount) =>
      SchedulingMockService.updateFeedingSchedule(mealType, time, amount);

  /// @deprecated Use [SchedulingMockService.getDefaultFeedingScheduleParams] instead
  @Deprecated('Use SchedulingMockService.getDefaultFeedingScheduleParams instead')
  static Map<String, dynamic> getDefaultFeedingScheduleParams() =>
      SchedulingMockService.getDefaultFeedingScheduleParams();

  // ==================== Notification Data ====================

  /// @deprecated Use [NotificationMockService.getMockNotifications] instead
  @Deprecated('Use NotificationMockService.getMockNotifications instead')
  static List<dynamic> getMockNotifications() =>
      NotificationMockService.getMockNotifications();

  /// @deprecated Use [NotificationMockService.getMockNotificationSettings] instead
  @Deprecated('Use NotificationMockService.getMockNotificationSettings instead')
  static dynamic getMockNotificationSettings() =>
      NotificationMockService.getMockNotificationSettings();

  /// @deprecated Use [NotificationMockService.getMockNotificationStats] instead
  @Deprecated('Use NotificationMockService.getMockNotificationStats instead')
  static List<Map<String, dynamic>> getMockNotificationStats({
    int days = 7,
    String? petId,
  }) =>
      NotificationMockService.getMockNotificationStats(days: days, petId: petId);

  /// @deprecated Use [NotificationMockService.getMockUserEngagement] instead
  @Deprecated('Use NotificationMockService.getMockUserEngagement instead')
  static List<Map<String, dynamic>> getMockUserEngagement({
    int days = 30,
    String? petId,
  }) =>
      NotificationMockService.getMockUserEngagement(days: days, petId: petId);

  // ==================== Pet Health Data ====================

  /// @deprecated Use [PetHealthMockService.getMockVaccineRecords] instead
  @Deprecated('Use PetHealthMockService.getMockVaccineRecords instead')
  static List<Map<String, dynamic>> getMockVaccineRecords() =>
      PetHealthMockService.getMockVaccineRecords();

  /// @deprecated Use [PetHealthMockService.getMockWeightChartData] instead
  @Deprecated('Use PetHealthMockService.getMockWeightChartData instead')
  static Map<String, dynamic> getMockWeightChartData({String? petId}) =>
      PetHealthMockService.getMockWeightChartData(petId: petId);

  // ==================== Pet Activities Data ====================

  /// @deprecated Use [PetActivitiesMockService.getMockTricks] instead
  @Deprecated('Use PetActivitiesMockService.getMockTricks instead')
  static List<Map<String, dynamic>> getMockTricks() =>
      PetActivitiesMockService.getMockTricks();

  /// @deprecated Use [PetActivitiesMockService.getMockVideoBookmarks] instead
  @Deprecated('Use PetActivitiesMockService.getMockVideoBookmarks instead')
  static List<Map<String, dynamic>> getMockVideoBookmarks() =>
      PetActivitiesMockService.getMockVideoBookmarks();

  /// @deprecated Use [PetActivitiesMockService.getMockVideoProgress] instead
  @Deprecated('Use PetActivitiesMockService.getMockVideoProgress instead')
  static Map<String, Map<String, dynamic>> getMockVideoProgress() =>
      PetActivitiesMockService.getMockVideoProgress();

  /// @deprecated Use [PetActivitiesMockService.getMockYouTubeVideoInfo] instead
  @Deprecated('Use PetActivitiesMockService.getMockYouTubeVideoInfo instead')
  static Map<String, dynamic> getMockYouTubeVideoInfo(String videoId) =>
      PetActivitiesMockService.getMockYouTubeVideoInfo(videoId);

  /// @deprecated Use [PetActivitiesMockService.getDefaultVideoTitle] instead
  @Deprecated('Use PetActivitiesMockService.getDefaultVideoTitle instead')
  static String getDefaultVideoTitle(String videoId) =>
      PetActivitiesMockService.getDefaultVideoTitle(videoId);

  // ==================== Pet Feeding Data ====================

  /// @deprecated Use [PetFeedingMockService.getMockRecipes] instead
  @Deprecated('Use PetFeedingMockService.getMockRecipes instead')
  static List<Map<String, dynamic>> getMockRecipes() =>
      PetFeedingMockService.getMockRecipes();

  // ==================== Walk Data ====================

  /// @deprecated Use [WalkMockService.getMockWalkRecords] instead
  @Deprecated('Use WalkMockService.getMockWalkRecords instead')
  static List<Map<String, dynamic>> getMockWalkRecords() =>
      WalkMockService.getMockWalkRecords();

  // ==================== Facility Data ====================

  /// @deprecated Use [FacilityMockService.getMockFacilities] instead
  @Deprecated('Use FacilityMockService.getMockFacilities instead')
  static List<Map<String, dynamic>> getMockFacilities() =>
      FacilityMockService.getMockFacilities();

  /// @deprecated Use [FacilityMockService.getMockFacilityById] instead
  @Deprecated('Use FacilityMockService.getMockFacilityById instead')
  static Map<String, dynamic>? getMockFacilityById(String facilityId) =>
      FacilityMockService.getMockFacilityById(facilityId);

  /// @deprecated Use [FacilityMockService.getMockFacilityDetailById] instead
  @Deprecated('Use FacilityMockService.getMockFacilityDetailById instead')
  static Map<String, dynamic>? getMockFacilityDetailById(String facilityId) =>
      FacilityMockService.getMockFacilityDetailById(facilityId);

  /// @deprecated Use [FacilityMockService.getMockGroomingFacilities] instead
  @Deprecated('Use FacilityMockService.getMockGroomingFacilities instead')
  static List<Map<String, dynamic>> getMockGroomingFacilities() =>
      FacilityMockService.getMockGroomingFacilities();

  /// @deprecated Use [FacilityMockService.getMockHospitalFacilities] instead
  @Deprecated('Use FacilityMockService.getMockHospitalFacilities instead')
  static List<Map<String, dynamic>> getMockHospitalFacilities() =>
      FacilityMockService.getMockHospitalFacilities();

  // ==================== AI Data ====================

  /// @deprecated Use [AiMockService.getMockAiChatHistory] instead
  @Deprecated('Use AiMockService.getMockAiChatHistory instead')
  static List<dynamic> getChatHistory() => AiMockService.getMockAiChatHistory();

  /// @deprecated Use [AiMockService.getMockAiSuggestedQuestions] instead
  @Deprecated('Use AiMockService.getMockAiSuggestedQuestions instead')
  static List<Map<String, dynamic>> get suggestedQuestions =>
      AiMockService.getMockAiSuggestedQuestions();

  /// @deprecated Use [BaseMockService.simulateApiDelay] from core/base_mock_service.dart instead
  @Deprecated('Use BaseMockService.simulateApiDelay instead')
  static Future<void> simulateApiDelay({int seconds = 1}) async =>
      Future.delayed(Duration(seconds: seconds));

  /// @deprecated Use [AiMockService.getMockAiChatSessions] instead
  @Deprecated('Use AiMockService.getMockAiChatSessions instead')
  static List<dynamic> getChatSessions() => AiMockService.getMockAiChatSessions();

  /// @deprecated Use [AiMockService.mockAiResponse] instead
  @Deprecated('Use AiMockService.mockAiResponse instead')
  static Future<dynamic> generateAiResponseMockData(String userMessage) =>
      AiMockService.mockAiResponse(userMessage: userMessage, petId: '1');

  /// @deprecated Create session data manually instead
  @Deprecated('Create session data manually instead')
  static Map<String, dynamic> createChatSessionMockData(String title, {String? petId}) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'petId': petId,
      'createdAt': DateTime.now(),
    };
  }

  /// @deprecated Use [AiMockService.getMockAiSuggestedQuestions] instead
  @Deprecated('Use AiMockService.getMockAiSuggestedQuestions instead')
  static List<Map<String, dynamic>> getSuggestedQuestions() =>
      AiMockService.getMockAiSuggestedQuestions();

  /// @deprecated Use [AiMockService.getMockFavoriteMessages] instead
  @Deprecated('Use AiMockService.getMockFavoriteMessages instead')
  static List<dynamic> getFavoriteQAsMockData() =>
      AiMockService.getMockFavoriteMessages();

  /// @deprecated Use [AiMockService.getMockAiChatHistory] instead
  @Deprecated('Use AiMockService.getMockAiChatHistory instead')
  static List<dynamic> getChatHistoryMockData() =>
      AiMockService.getMockAiChatHistory();
}