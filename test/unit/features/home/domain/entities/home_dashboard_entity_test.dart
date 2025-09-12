import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/home/domain/entities/home_dashboard_entity.dart';
import '../../../../../lib/features/home/domain/entities/pet_summary_entity.dart';
import '../../../../../lib/features/home/domain/entities/weather_entity.dart';

void main() {
  group('AppointmentSummary', () {
    late AppointmentSummary testAppointment;

    setUp(() {
      testAppointment = AppointmentSummary(
        id: 'appointment-1',
        title: '健康診断',
        scheduledTime: DateTime(2024, 1, 15, 14, 30),
        type: 'health_check',
        petName: 'テストペット',
      );
    });

    group('constructor', () {
      test('should create appointment with all parameters', () {
        // Act
        final appointment = AppointmentSummary(
          id: 'test-appointment',
          title: 'テスト予約',
          scheduledTime: DateTime(2024, 1, 1, 10, 0),
          type: 'test_type',
          petName: 'テストペット',
        );

        // Assert
        expect(appointment.id, equals('test-appointment'));
        expect(appointment.title, equals('テスト予約'));
        expect(appointment.scheduledTime, equals(DateTime(2024, 1, 1, 10, 0)));
        expect(appointment.type, equals('test_type'));
        expect(appointment.petName, equals('テストペット'));
      });
    });

    group('edge cases', () {
      test('should handle empty title and type', () {
        // Act
        final appointment = AppointmentSummary(
          id: 'empty-appointment',
          title: '',
          scheduledTime: DateTime(2024, 1, 1),
          type: '',
          petName: 'テストペット',
        );

        // Assert
        expect(appointment.title, equals(''));
        expect(appointment.type, equals(''));
      });

      test('should handle special characters in title', () {
        // Act
        final appointment = AppointmentSummary(
          id: 'special-appointment',
          title: 'スペシャル予約: !@#\$%^&*()🎉',
          scheduledTime: DateTime(2024, 1, 1),
          type: 'special_type',
          petName: 'テストペット',
        );

        // Assert
        expect(appointment.title, equals('スペシャル予約: !@#\$%^&*()🎉'));
      });
    });
  });

  group('HealthAlert', () {
    test('should create health alert with all parameters', () {
      // Act
      const alert = HealthAlert(petName: 'テストペット', message: 'ワクチン接種が必要です');

      // Assert
      expect(alert.petName, equals('テストペット'));
      expect(alert.message, equals('ワクチン接種が必要です'));
    });

    test('should handle empty message', () {
      // Act
      const alert = HealthAlert(petName: 'テストペット', message: '');

      // Assert
      expect(alert.message, equals(''));
    });
  });

  group('HealthSummary', () {
    late HealthSummary testHealthSummary;
    late List<HealthAlert> testAlerts;

    setUp(() {
      testAlerts = [
        const HealthAlert(petName: 'ペット1', message: '健康診断が必要です'),
        const HealthAlert(petName: 'ペット2', message: 'ワクチン接種が必要です'),
      ];

      testHealthSummary = HealthSummary(
        totalPets: 5,
        healthyPets: 3,
        petsNeedingAttention: 2,
        alerts: testAlerts,
      );
    });

    group('constructor', () {
      test('should create health summary with all parameters', () {
        // Act
        final healthSummary = HealthSummary(
          totalPets: 10,
          healthyPets: 8,
          petsNeedingAttention: 2,
          alerts: [],
        );

        // Assert
        expect(healthSummary.totalPets, equals(10));
        expect(healthSummary.healthyPets, equals(8));
        expect(healthSummary.petsNeedingAttention, equals(2));
        expect(healthSummary.alerts, isEmpty);
      });
    });

    group('edge cases', () {
      test('should handle zero pets', () {
        // Act
        final healthSummary = HealthSummary(
          totalPets: 0,
          healthyPets: 0,
          petsNeedingAttention: 0,
          alerts: [],
        );

        // Assert
        expect(healthSummary.totalPets, equals(0));
        expect(healthSummary.healthyPets, equals(0));
        expect(healthSummary.petsNeedingAttention, equals(0));
      });

      test('should handle many alerts', () {
        // Arrange
        final manyAlerts = List.generate(
          100,
          (index) => HealthAlert(petName: 'ペット$index', message: 'アラート$index'),
        );

        // Act
        final healthSummary = HealthSummary(
          totalPets: 100,
          healthyPets: 50,
          petsNeedingAttention: 50,
          alerts: manyAlerts,
        );

        // Assert
        expect(healthSummary.alerts, hasLength(100));
        expect(healthSummary.alerts.first.petName, equals('ペット0'));
        expect(healthSummary.alerts.last.petName, equals('ペット99'));
      });
    });
  });

  group('WalkSummary', () {
    late WalkSummary testWalkSummary;

    setUp(() {
      testWalkSummary = WalkSummary(
        todayWalks: 3,
        todayDistance: 2.5,
        todayDuration: const Duration(hours: 1, minutes: 30),
        weeklyGoal: 20.0,
        weeklyProgress: 15.0,
      );
    });

    group('constructor', () {
      test('should create walk summary with all parameters', () {
        // Act
        final walkSummary = WalkSummary(
          todayWalks: 5,
          todayDistance: 3.0,
          todayDuration: const Duration(hours: 2),
          weeklyGoal: 25.0,
          weeklyProgress: 20.0,
        );

        // Assert
        expect(walkSummary.todayWalks, equals(5));
        expect(walkSummary.todayDistance, equals(3.0));
        expect(walkSummary.todayDuration, equals(const Duration(hours: 2)));
        expect(walkSummary.weeklyGoal, equals(25.0));
        expect(walkSummary.weeklyProgress, equals(20.0));
      });
    });

    group('edge cases', () {
      test('should handle zero walks', () {
        // Act
        final walkSummary = WalkSummary(
          todayWalks: 0,
          todayDistance: 0.0,
          todayDuration: Duration.zero,
          weeklyGoal: 10.0,
          weeklyProgress: 0.0,
        );

        // Assert
        expect(walkSummary.todayWalks, equals(0));
        expect(walkSummary.todayDistance, equals(0.0));
        expect(walkSummary.todayDuration, equals(Duration.zero));
      });

      test('should handle very long duration', () {
        // Act
        final walkSummary = WalkSummary(
          todayWalks: 1,
          todayDistance: 10.0,
          todayDuration: const Duration(hours: 8),
          weeklyGoal: 50.0,
          weeklyProgress: 10.0,
        );

        // Assert
        expect(walkSummary.todayDuration, equals(const Duration(hours: 8)));
        expect(walkSummary.todayDistance, equals(10.0));
      });

      test('should handle negative values', () {
        // Act
        final walkSummary = WalkSummary(
          todayWalks: -1,
          todayDistance: -1.0,
          todayDuration: const Duration(hours: -1),
          weeklyGoal: -10.0,
          weeklyProgress: -5.0,
        );

        // Assert
        expect(walkSummary.todayWalks, equals(-1));
        expect(walkSummary.todayDistance, equals(-1.0));
        expect(walkSummary.weeklyGoal, equals(-10.0));
        expect(walkSummary.weeklyProgress, equals(-5.0));
      });
    });
  });

  group('HomeDashboardEntity', () {
    late HomeDashboardEntity testDashboard;
    late WeatherEntity testWeather;
    late List<PetSummaryEntity> testPets;
    late List<AppointmentSummary> testAppointments;
    late HealthSummary testHealthSummary;
    late WalkSummary testWalkSummary;

    setUp(() {
      testWeather = WeatherEntity(
        temperature: 25.0,
        location: '東京',
        weatherId: 800,
        description: '晴れ',
        feelsLike: 27.0,
        humidity: 60,
        windSpeed: 5.0,
        iconCode: '01d',
        uvIndex: 6.0,
        visibility: 10000,
        pressure: 1013.25,
      );

      testPets = [
        PetSummaryEntity(
          id: 'pet-1',
          name: 'テストペット1',
          typeName: 'dog',
          breed: '柴犬',
          age: 3,
          birthDate: DateTime(2021, 1, 1),
          createdAt: DateTime(2021, 1, 1),
          profileImageUrl: '/path/to/image1.jpg',
        ),
        PetSummaryEntity(
          id: 'pet-2',
          name: 'テストペット2',
          typeName: 'cat',
          breed: 'アメリカンショートヘア',
          age: 2,
          birthDate: DateTime(2022, 1, 1),
          createdAt: DateTime(2022, 1, 1),
          profileImageUrl: '/path/to/image2.jpg',
        ),
      ];

      testAppointments = [
        AppointmentSummary(
          id: 'appointment-1',
          title: '健康診断',
          scheduledTime: DateTime(2024, 1, 15, 14, 30),
          type: 'health_check',
          petName: 'テストペット1',
        ),
      ];

      testHealthSummary = HealthSummary(
        totalPets: 2,
        healthyPets: 1,
        petsNeedingAttention: 1,
        alerts: [const HealthAlert(petName: 'テストペット1', message: 'ワクチン接種が必要です')],
      );

      testWalkSummary = WalkSummary(
        todayWalks: 2,
        todayDistance: 1.5,
        todayDuration: const Duration(minutes: 45),
        weeklyGoal: 10.0,
        weeklyProgress: 6.0,
      );

      testDashboard = HomeDashboardEntity(
        currentTime: '2024-01-01T10:00:00Z',
        weather: testWeather,
        petProfiles: testPets,
        upcomingAppointments: testAppointments,
        petHealthSummary: testHealthSummary,
        walkSummary: testWalkSummary,
      );
    });

    group('constructor', () {
      test('should create dashboard with all parameters', () {
        // Act
        final dashboard = HomeDashboardEntity(
          currentTime: '2024-01-01T12:00:00Z',
          weather: testWeather,
          petProfiles: testPets,
          upcomingAppointments: testAppointments,
          petHealthSummary: testHealthSummary,
          walkSummary: testWalkSummary,
        );

        // Assert
        expect(dashboard.currentTime, equals('2024-01-01T12:00:00Z'));
        expect(dashboard.weather, equals(testWeather));
        expect(dashboard.petProfiles, equals(testPets));
        expect(dashboard.upcomingAppointments, equals(testAppointments));
        expect(dashboard.petHealthSummary, equals(testHealthSummary));
        expect(dashboard.walkSummary, equals(testWalkSummary));
      });
    });

    group('edge cases', () {
      test('should handle empty lists', () {
        // Act
        final dashboard = HomeDashboardEntity(
          currentTime: '2024-01-01T10:00:00Z',
          weather: testWeather,
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
            weeklyGoal: 0.0,
            weeklyProgress: 0.0,
          ),
        );

        // Assert
        expect(dashboard.petProfiles, isEmpty);
        expect(dashboard.upcomingAppointments, isEmpty);
        expect(dashboard.petHealthSummary.alerts, isEmpty);
      });

      test('should handle many pets and appointments', () {
        // Arrange
        final manyPets = List.generate(
          50,
          (index) => PetSummaryEntity(
            id: 'pet-$index',
            name: 'ペット$index',
            typeName: 'dog',
            age: index,
            birthDate: DateTime(2024 - index, 1, 1),
            createdAt: DateTime(2024 - index, 1, 1),
          ),
        );

        final manyAppointments = List.generate(
          20,
          (index) => AppointmentSummary(
            id: 'appointment-$index',
            title: '予約$index',
            scheduledTime: DateTime(2024, 1, 1 + index),
            type: 'type$index',
            petName: 'ペット$index',
          ),
        );

        // Act
        final dashboard = HomeDashboardEntity(
          currentTime: '2024-01-01T10:00:00Z',
          weather: testWeather,
          petProfiles: manyPets,
          upcomingAppointments: manyAppointments,
          petHealthSummary: testHealthSummary,
          walkSummary: testWalkSummary,
        );

        // Assert
        expect(dashboard.petProfiles, hasLength(50));
        expect(dashboard.upcomingAppointments, hasLength(20));
        expect(dashboard.petProfiles.first.name, equals('ペット0'));
        expect(dashboard.petProfiles.last.name, equals('ペット49'));
        expect(dashboard.upcomingAppointments.first.title, equals('予約0'));
        expect(dashboard.upcomingAppointments.last.title, equals('予約19'));
      });

      test('should handle special characters in currentTime', () {
        // Act
        final dashboard = HomeDashboardEntity(
          currentTime: '2024-01-01T10:00:00+09:00',
          weather: testWeather,
          petProfiles: testPets,
          upcomingAppointments: testAppointments,
          petHealthSummary: testHealthSummary,
          walkSummary: testWalkSummary,
        );

        // Assert
        expect(dashboard.currentTime, equals('2024-01-01T10:00:00+09:00'));
      });
    });
  });
}
