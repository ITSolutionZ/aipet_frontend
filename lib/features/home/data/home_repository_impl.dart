import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/mock_data/mock_data_service.dart';
import '../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../domain/entities/home_dashboard_entity.dart';
import '../domain/repositories/home_repository.dart';
import 'models/weather_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeDashboardEntity> getDashboardData() async {
    // 실제 구현에서는 API 호출이나 로컬 데이터 소스에서 데이터를 가져옴
    final weather = await getCurrentWeather();
    final petProfiles = await getPetProfiles();

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return HomeDashboardEntity(
      currentTime: currentTime,
      weather: weather ?? _getMockWeatherData(),
      petProfiles: petProfiles,
      upcomingAppointments: await getUpcomingAppointments(),
      petHealthSummary: await getPetHealthSummary(),
      walkSummary: await getWalkSummary(),
    );
  }

  @override
  Future<WeatherData?> getCurrentWeather() async {
    try {
      // OpenWeatherMap API 연동 (무료 API)
      const apiKey = 'YOUR_API_KEY'; // 실제 사용시 환경변수에서 가져오기
      const city = 'Seoul';
      const countryCode = 'KR';

      const url =
          'https://api.openweathermap.org/data/2.5/weather?q=$city,$countryCode&appid=$apiKey&units=metric&lang=ja';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].toDouble();
        final iconCode = data['weather'][0]['icon'];
        final location = data['name'];

        return WeatherData(
          temperature: temp,
          location: location,
          weatherId: data['weather'][0]['id'],
          description: data['weather'][0]['description'],
          feelsLike: data['main']['feels_like'].toDouble(),
          humidity: data['main']['humidity'],
          windSpeed: data['wind']?['speed']?.toDouble() ?? 0.0,
          iconCode: iconCode,
          uvIndex: 0.0, // 기본값
          visibility: data['visibility'] ?? 10000,
          pressure: data['main']['pressure'].toDouble(),
        );
      } else {
        // API 호출 실패시 Mock 데이터 사용
        return _getMockWeatherData();
      }
    } catch (e) {
      // 에러 발생시 Mock 데이터 사용
      return _getMockWeatherData();
    }
  }

  /// Mock 날씨 데이터 (API 실패시 fallback)
  WeatherData _getMockWeatherData() {
    return const WeatherData(
      temperature: 23.0,
      location: '東京都品川区',
      weatherId: 800,
      description: '맑음',
      feelsLike: 25.0,
      humidity: 65,
      windSpeed: 2.5,
      iconCode: '01d',
      uvIndex: 5.0,
      visibility: 10000,
      pressure: 1013.25,
    );
  }

  @override
  Future<List<PetProfileEntity>> getPetProfiles() async {
    // Mock 데이터 사용 (실제 API 연동 전까지)
    await Future.delayed(const Duration(milliseconds: 250));
    return MockDataService.getMockPets();
  }

  @override
  Future<WalkSummary> getWalkSummary() async {
    // Mock 데이터 사용
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataService.getMockWalkSummary();
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    // Mock 데이터 사용
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataService.getMockHealthSummary();
  }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async {
    // Mock 데이터 사용
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataService.getMockAppointments();
  }
}
