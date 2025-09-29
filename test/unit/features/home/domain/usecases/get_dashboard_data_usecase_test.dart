import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.dart';
import 'get_dashboard_data_usecase_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  group('GetDashboardDataUseCase', () {
    late GetDashboardDataUseCase useCase;
    late MockHomeRepository mockRepository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockRepository = MockHomeRepository();
      useCase = GetDashboardDataUseCase(mockRepository);
    });

    group('call method', () {
      test('should return dashboard data successfully', () async {
        // Arrange
        const expectedData = HomeDashboardEntity(
          currentTime: '2024-01-01 12:00:00',
          weather: WeatherEntity(
            temperature: 25.0,
            location: '東京都品川区',
            weatherId: 800,
            description: '晴れ',
            feelsLike: 27.0,
            humidity: 65,
            windSpeed: 2.5,
            iconCode: '01d',
            uvIndex: 5.0,
            visibility: 10000,
            pressure: 1013.25,
          ),
          petProfiles: [],
          upcomingAppointments: [],
          petHealthSummary: HealthSummary(
            totalPets: 0,
            healthyPets: 0,
            petsNeedingAttention: 0,
            alerts: [],
          ),
          walkSummary: WalkSummary(
            todayWalks: 0,
            todayDistance: 0.0,
            todayDuration: Duration.zero,
            weeklyGoal: 10.0,
            weeklyProgress: 0.0,
          ),
        );

        when(
          mockRepository.getDashboardData(),
        ).thenAnswer((_) async => expectedData);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, equals(expectedData));
        verify(mockRepository.getDashboardData()).called(1);
      });

      test('should handle repository errors', () async {
        // Arrange
        when(
          mockRepository.getDashboardData(),
        ).thenThrow(Exception('Repository error'));

        // Act & Assert
        expect(() => useCase.call(), throwsException);
        verify(mockRepository.getDashboardData()).called(1);
      });

      test('should handle null data from repository', () async {
        // Arrange
        when(
          mockRepository.getDashboardData(),
        ).thenAnswer((_) async => throw Exception('No data'));

        // Act & Assert
        expect(() => useCase.call(), throwsException);
        verify(mockRepository.getDashboardData()).called(1);
      });
    });

    group('edge cases', () {
      test('should handle empty dashboard data', () async {
        // Arrange
        const emptyData = HomeDashboardEntity(
          currentTime: '2024-01-01 12:00:00',
          weather: WeatherEntity(
            temperature: 25.0,
            location: '東京都品川区',
            weatherId: 800,
            description: '晴れ',
            feelsLike: 27.0,
            humidity: 65,
            windSpeed: 2.5,
            iconCode: '01d',
            uvIndex: 5.0,
            visibility: 10000,
            pressure: 1013.25,
          ),
          petProfiles: [],
          upcomingAppointments: [],
          petHealthSummary: HealthSummary(
            totalPets: 0,
            healthyPets: 0,
            petsNeedingAttention: 0,
            alerts: [],
          ),
          walkSummary: WalkSummary(
            todayWalks: 0,
            todayDistance: 0.0,
            todayDuration: Duration.zero,
            weeklyGoal: 10.0,
            weeklyProgress: 0.0,
          ),
        );

        when(
          mockRepository.getDashboardData(),
        ).thenAnswer((_) async => emptyData);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, equals(emptyData));
        expect(result.petProfiles, isEmpty);
        expect(result.upcomingAppointments, isEmpty);
        expect(result.walkSummary.todayWalks, equals(0));
        expect(result.petHealthSummary.totalPets, equals(0));
      });
    });
  });
}
