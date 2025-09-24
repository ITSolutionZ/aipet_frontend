import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/mappers/pet_mapper.dart';
import 'package:aipet_frontend/shared/mappers/weather_mapper.dart';
import 'package:aipet_frontend/shared/services/weather_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/home/home_mock_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final WeatherService _weatherService = WeatherService();

  @override
  Future<HomeDashboardEntity> getDashboardData() async {
    // 실제 구현에서는 API 호출이나 로컬 데이터 소스에서 데이터를 가져옴
    final weather = await getCurrentWeather();
    final petProfiles = await getPetSummaries();

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return HomeDashboardEntity(
      currentTime: currentTime,
      weather: weather ?? _getMockWeatherEntity(),
      petProfiles: petProfiles,
      upcomingAppointments: await getUpcomingAppointments(),
      petHealthSummary: await getPetHealthSummary(),
      walkSummary: await getWalkSummary(),
    );
  }

  @override
  Future<WeatherEntity?> getCurrentWeather({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    try {
      // WeatherService를 사용하여 날씨 데이터 조회
      WeatherLocation? weatherLocation;
      if (location != null) {
        weatherLocation = WeatherMapper.toDataLocation(location);
      }

      final weatherData = await _weatherService.getCurrentWeather(
        location: weatherLocation,
        userTriggered: userTriggered,
      );

      if (weatherData != null) {
        return WeatherMapper.toEntity(weatherData);
      }

      return null;
    } catch (e) {
      // 에러 발생시 null 반환
      return null;
    }
  }

  /// Mock 날씨 엔티티 (API 실패시 fallback)
  WeatherEntity _getMockWeatherEntity() {
    final mockWeatherInfo = HomeMockService.getMockWeatherInfo();
    return WeatherEntity(
      temperature: mockWeatherInfo['temperature'] as double,
      location: mockWeatherInfo['location'] as String,
      weatherId: 800, // 맑음
      description: mockWeatherInfo['condition'] as String,
      feelsLike: (mockWeatherInfo['temperature'] as double) + 2.0,
      humidity: 65,
      windSpeed: 2.5,
      iconCode: mockWeatherInfo['iconCode'] as String,
      uvIndex: 5.0,
      visibility: 10000,
      pressure: 1013.25,
    );
  }

  @override
  Future<List<PetSummaryEntity>> getPetSummaries() async {
    // 통합된 PetMockService에서 PetProfileEntity 리스트를 직접 가져옴
    await Future.delayed(_mockDelay);
    final petProfiles = PetMockService.getMockPetProfiles();
    return PetMapper.toSummaryEntityListFromMaps(petProfiles);
  }

  // 기존 호환성을 위해 유지
  Future<List<PetProfileEntity>> getPetProfiles() async {
    // 통합된 PetMockService 사용 (실제 API 연동 전까지)
    await Future.delayed(_mockDelay);
    final petMockData = PetMockService.getMockPetProfiles();
    return PetMapper.fromMapList(petMockData);
  }

  @override
  Future<WalkSummary> getWalkSummary() async {
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);
    final walkSummaryData = HomeMockService.getMockWalkSummary();
    return WalkSummary(
      todayWalks: walkSummaryData['todayWalks'] as int,
      todayDistance: walkSummaryData['todayDistance'] as double,
      todayDuration: Duration(minutes: walkSummaryData['todayDuration'] as int),
      weeklyGoal: walkSummaryData['weeklyGoal'] as double,
      weeklyProgress: walkSummaryData['weeklyProgress'] as double,
    );
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);
    final healthSummaryData = HomeMockService.getMockHealthSummary();
    final alertsData = (healthSummaryData['alerts'] as List)
        .cast<Map<String, dynamic>>();
    final alerts = alertsData
        .map(
          (alert) => HealthAlert(
            petName: alert['petName'] as String,
            message: alert['message'] as String,
          ),
        )
        .toList();

    return HealthSummary(
      totalPets: healthSummaryData['totalPets'] as int,
      healthyPets: healthSummaryData['healthyPets'] as int,
      petsNeedingAttention: healthSummaryData['petsNeedingAttention'] as int,
      alerts: alerts,
    );
  }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async {
    // Mock 데이터 사용 - HomeMockService로 변경
    await Future.delayed(_mockDelay);

    // 임시로 Mock 데이터 생성
    return [
      AppointmentSummary(
        id: 'app-1',
        title: '健康診断',
        scheduledTime: DateTime.now().add(const Duration(days: 3)),
        type: 'health_check',
        petName: 'マックス',
      ),
      AppointmentSummary(
        id: 'app-2',
        title: '予防接種',
        scheduledTime: DateTime.now().add(const Duration(days: 7)),
        type: 'vaccination',
        petName: 'ルナ',
      ),
    ];
  }

  // 개발 모드용 지연 시간 상수
  static Duration get _mockDelay => AppConfig.current.environment == 'test'
      ? const Duration(milliseconds: 1)
      : const Duration(milliseconds: 250);
}
