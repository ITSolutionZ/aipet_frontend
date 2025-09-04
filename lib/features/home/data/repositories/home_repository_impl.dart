import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/mock_data/mock_data_service.dart';

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
    final mockWeatherInfo = MockDataService.getMockWeatherInfo();
    return WeatherEntity(
      temperature: mockWeatherInfo.temperature,
      location: mockWeatherInfo.location,
      weatherId: 800, // 맑음
      description: mockWeatherInfo.condition,
      feelsLike: mockWeatherInfo.temperature + 2.0,
      humidity: 65,
      windSpeed: 2.5,
      iconCode: mockWeatherInfo.iconCode,
      uvIndex: 5.0,
      visibility: 10000,
      pressure: 1013.25,
    );
  }


  @override
  Future<List<PetSummaryEntity>> getPetSummaries() async {
    // Mock 데이터에서 PetProfileEntity 리스트를 가져온 후 PetSummaryEntity로 변환
    final petProfiles = MockDataService.getMockPets();
    return PetMapper.toSummaryEntityList(petProfiles);
  }

  // 기존 호환성을 위해 유지
  Future<List<PetProfileEntity>> getPetProfiles() async {
    // Mock 데이터 사용 (실제 API 연동 전까지)
    await Future.delayed(_mockDelay);
    return MockDataService.getMockPets();
  }

  @override
  Future<WalkSummary> getWalkSummary() async {
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);
    return MockDataService.getMockWalkSummary();
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);
    return MockDataService.getMockHealthSummary();
  }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async {
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);
    return MockDataService.getMockAppointments();
  }

  // 개발 모드용 지연 시간 상수
  static const Duration _mockDelay = Duration(milliseconds: 250);
}
