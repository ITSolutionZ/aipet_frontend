import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/mock_data/features/home/home_mock_service.dart';
import 'package:aipet_frontend/shared/mock_data/features/pet/pet_mock_service.dart';

import '../mappers/pet_mapper.dart';
import '../mappers/weather_mapper.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

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
    // Mock 데이터에서 PetProfileEntity 리스트를 가져온 후 PetSummaryEntity로 변환
    final petProfilesData = PetMockService.getMockPets();
    final petProfiles = petProfilesData
        .map((petData) => _convertMockDataToPetProfileEntity(petData))
        .toList();
    return PetMapper.toSummaryEntityList(petProfiles);
  }

  // 기존 호환성을 위해 유지
  Future<List<PetProfileEntity>> getPetProfiles() async {
    // Mock 데이터 사용 (실제 API 연동 전까지)
    await Future.delayed(_mockDelay);
    final petProfilesData = PetMockService.getMockPets();
    return petProfilesData
        .map((petData) => _convertMockDataToPetProfileEntity(petData))
        .toList();
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
    final alertsData =
        healthSummaryData['alerts'] as List<Map<String, dynamic>>;
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
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);
    final appointmentsData = PetMockService.getMockAppointments();
    return appointmentsData
        .map(
          (data) => AppointmentSummary(
            id: data['id'] as String,
            title: data['title'] as String,
            scheduledTime: data['scheduledTime'] as DateTime,
            type: data['type'] as String,
            petName: data['petName'] as String,
          ),
        )
        .toList();
  }

  // 개발 모드용 지연 시간 상수
  static const Duration _mockDelay = Duration(milliseconds: 250);

  /// PetMockService의 Map 데이터를 PetProfileEntity로 변환
  PetProfileEntity _convertMockDataToPetProfileEntity(
    Map<String, dynamic> petData,
  ) {
    return PetProfileEntity(
      id: petData['id'] as String,
      name: petData['name'] as String,
      type: petData['typeName'] as String, // typeName을 type으로 매핑
      breed: petData['breed'] as String?,
      birthDate: DateTime.parse(petData['birthDate'] as String),
      age: petData['age'] as int? ?? 0,
      gender: petData['gender'] as String? ?? 'unknown',
      weight: (petData['weight'] as num?)?.toDouble() ?? 0.0,
      imagePath: null, // Mock 데이터에 이미지 경로가 없으므로 null
      ownerId: 'user1', // Mock 데이터에 ownerId가 없으므로 기본값 사용
      createdAt: DateTime.parse(petData['createdAt'] as String),
      updatedAt: DateTime.now(), // Mock 데이터에 updatedAt이 없으므로 현재 시간 사용
      isActive: true, // 기본값으로 활성 상태
      additionalInfo: petData['additionalInfo'] as Map<String, dynamic>?,
    );
  }
}
