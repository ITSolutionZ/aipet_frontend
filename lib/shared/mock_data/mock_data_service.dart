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
import 'features/home/home_mock_service.dart';
import 'features/notification/notification_mock_service.dart';
import 'features/pet/pet_mock_service.dart';
import 'features/scheduling/scheduling_mock_service.dart';

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
}