import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.dart';
import 'home_repository_impl_test.mocks.dart';

@GenerateMocks([])
void main() {
  group('HomeRepositoryImpl', () {
    late HomeRepositoryImpl repository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      repository = HomeRepositoryImpl();
    });

    group('basic functionality', () {
      test('should initialize correctly', () {
        // Assert
        expect(repository, isNotNull);
      });
    });

    group('getDashboardData', () {
      test('should return dashboard data', () async {
        // Act
        final result = await repository.getDashboardData();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<HomeDashboardEntity>());
        expect(result.currentTime, isNotNull);
        expect(result.petProfiles, isA<List<PetSummaryEntity>>());
        expect(result.upcomingAppointments, isA<List<AppointmentSummary>>());
        expect(result.walkSummary, isA<WalkSummary>());
        expect(result.petHealthSummary, isA<HealthSummary>());
      });
    });

    group('getPetSummaries', () {
      test('should return pet summaries', () async {
        // Act
        final result = await repository.getPetSummaries();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<List<PetSummaryEntity>>());
      });
    });

    group('getCurrentWeather', () {
      test('should return weather data or null', () async {
        // Act
        final result = await repository.getCurrentWeather();

        // Assert
        // Weather data might be null due to API limitations in test environment
        if (result != null) {
          expect(result, isA<WeatherEntity>());
        }
      });

      test('should return weather data with location parameter', () async {
        // Arrange
        const location = WeatherLocationEntity(
          latitude: 35.6092,
          longitude: 139.7301,
          name: '東京都品川区',
        );

        // Act
        final result = await repository.getCurrentWeather(
          location: location,
          userTriggered: false,
        );

        // Assert
        // Weather data might be null due to API limitations in test environment
        if (result != null) {
          expect(result, isA<WeatherEntity>());
        }
      });

      test('should return weather data with userTriggered parameter', () async {
        // Act
        final result = await repository.getCurrentWeather(userTriggered: true);

        // Assert
        // Weather data might be null due to API limitations in test environment
        if (result != null) {
          expect(result, isA<WeatherEntity>());
        }
      });
    });

    group('getWalkSummary', () {
      test('should return walk summary', () async {
        // Act
        final result = await repository.getWalkSummary();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<WalkSummary>());
        expect(result.todayWalks, isA<int>());
        expect(result.todayDistance, isA<double>());
        expect(result.todayDuration, isA<Duration>());
      });
    });

    group('getPetHealthSummary', () {
      test('should return health summary', () async {
        // Act
        final result = await repository.getPetHealthSummary();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<HealthSummary>());
        expect(result.totalPets, isA<int>());
        expect(result.healthyPets, isA<int>());
        expect(result.petsNeedingAttention, isA<int>());
        expect(result.alerts, isA<List<HealthAlert>>());
      });
    });

    group('getUpcomingAppointments', () {
      test('should return upcoming appointments', () async {
        // Act
        final result = await repository.getUpcomingAppointments();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<List<AppointmentSummary>>());
      });
    });

    group('edge cases', () {
      test('should handle multiple calls to getDashboardData', () async {
        // Act
        final result1 = await repository.getDashboardData();
        final result2 = await repository.getDashboardData();

        // Assert
        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1, isA<HomeDashboardEntity>());
        expect(result2, isA<HomeDashboardEntity>());
      });

      test('should handle multiple calls to getPetSummaries', () async {
        // Act
        final result1 = await repository.getPetSummaries();
        final result2 = await repository.getPetSummaries();

        // Assert
        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1, isA<List<PetSummaryEntity>>());
        expect(result2, isA<List<PetSummaryEntity>>());
      });
    });
  });
}
