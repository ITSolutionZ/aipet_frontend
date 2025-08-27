import '../../../shared/mock_data/mock_data_service.dart';
import '../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../domain/entities/home_dashboard_entity.dart';
import '../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeDashboardEntity> getDashboardData() async {
    // 실제 구현에서는 API 호출이나 로컬 데이터 소스에서 데이터를 가져옴
    final weather = await getCurrentWeather();
    final appointments = await getUpcomingAppointments();
    final healthSummary = await getPetHealthSummary();
    final walkSummary = await getWalkSummary();
    final petProfiles = await getPetProfiles();

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return HomeDashboardEntity(
      currentTime: currentTime,
      weather: weather,
      upcomingAppointments: appointments,
      petHealthSummary: healthSummary,
      walkSummary: walkSummary,
      petProfiles: petProfiles,
    );
  }

  @override
  Future<WeatherInfo> getCurrentWeather() async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const WeatherInfo(
        temperature: 23.0,
        condition: '맑음',
        iconCode: 'sunny',
        location: '서울특별시',
      );
    }

    // TODO: 실제 날씨 API 연동
    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService.getMockAppointments();
    }

    // TODO: 실제 예약 데이터 API 연동
    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockDataService.getMockHealthSummary();
    }

    // TODO: 실제 건강 데이터 API 연동
    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<WalkSummary> getWalkSummary() async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 350));
      return MockDataService.getMockWalkSummary();
    }

    // TODO: 실제 산책 데이터 API 연동
    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<PetProfileEntity>> getPetProfiles() async {
    if (MockDataService.isEnabled) {
      await Future.delayed(const Duration(milliseconds: 250));
      return MockDataService.getMockPets();
    }

    // TODO: 실제 펫 프로필 API 연동
    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Stream<String> getCurrentTimeStream() async* {
    while (true) {
      final now = DateTime.now();
      final timeString =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      yield timeString;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
