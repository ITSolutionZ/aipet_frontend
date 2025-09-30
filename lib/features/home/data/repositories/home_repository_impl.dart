import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/home/data/mappers/pet_mapper.dart';
import 'package:aipet_frontend/features/home/data/mappers/weather_mapper.dart';
import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/data/services/weather_service.dart';
import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/home/home_mock_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final WeatherService _weatherService = WeatherService();

  @override
  Future<HomeDashboardEntity> getDashboardData() async {
    try {
      print('🏠 HomeRepositoryImpl: getDashboardData 시작');

      // 실제 구현에서는 API 호출이나 로컬 데이터 소스에서 데이터를 가져옴
      print('🌤️ 날씨 데이터 조회 시작...');
      final weather = await getCurrentWeather();
      print('🌤️ 날씨 데이터 조회 완료: ${weather != null ? '성공' : '실패'}');

      print('🐕 펫 프로필 조회 시작...');
      final petProfiles = await getPetSummaries();
      print('🐕 펫 프로필 조회 완료: ${petProfiles.length}개');

      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      print('📅 예약 정보 조회 시작...');
      final appointments = await getUpcomingAppointments();
      print('📅 예약 정보 조회 완료: ${appointments.length}개');

      print('🏥 건강 정보 조회 시작...');
      final healthSummary = await getPetHealthSummary();
      print('🏥 건강 정보 조회 완료');

      print('🚶 산책 정보 조회 시작...');
      final walkSummary = await getWalkSummary();
      print('🚶 산책 정보 조회 완료');

      final dashboard = HomeDashboardEntity(
        currentTime: currentTime,
        weather: weather ?? _getMockWeatherEntity(),
        petProfiles: petProfiles,
        upcomingAppointments: appointments,
        petHealthSummary: healthSummary,
        walkSummary: walkSummary,
      );

      print('✅ HomeRepositoryImpl: getDashboardData 완료');
      return dashboard;
    } catch (error, stackTrace) {
      print('💥 HomeRepositoryImpl: getDashboardData 실패 - $error');
      print('📍 StackTrace: $stackTrace');
      rethrow;
    }
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

    // 이번주 최장 기록 여부 계산 (예시: 30분 이상이면 최장 기록으로 처리)
    final todayDuration = walkSummaryData['todayDuration'] as Duration;
    final isWeeklyRecord = todayDuration.inMinutes >= 30;

    return WalkSummary(
      todayWalks: walkSummaryData['todayWalks'] as int,
      todayDistance: walkSummaryData['todayDistance'] as double,
      todayDuration: todayDuration,
      weeklyGoal: walkSummaryData['weeklyGoal'] as double,
      weeklyProgress: walkSummaryData['weeklyProgress'] as double,
      isWeeklyRecord: isWeeklyRecord,
    );
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    // Mock 데이터 사용
    await Future.delayed(_mockDelay);

    // HomeMockService.getMockHealthSummary()는 HealthSummary에 맞지 않는 구조를 반환하므로
    // 직접 HealthSummary용 데이터를 생성
    final alerts = [
      const HealthAlert(petName: 'マックス', message: '健康診断が必要です'),
      const HealthAlert(petName: 'ルナ', message: 'ワクチン接種が必要です'),
    ];

    return HealthSummary(totalPets: 3, healthyPets: 2, petsNeedingAttention: 1, alerts: alerts);
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
