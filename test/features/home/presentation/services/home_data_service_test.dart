import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/features/home/presentation/services/home_data_service.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_data_service_test.mocks.dart';

@GenerateMocks([
  GetDashboardDataUseCase,
  GetPetSummaryUseCase,
  GetWeatherDataUseCase,
  GetWalkSummaryUseCase,
  GetHealthSummaryUseCase,
  GetAppointmentSummaryUseCase,
])
void main() {
  group('HomeDataService', () {
    late HomeDataService service;
    late MockGetDashboardDataUseCase mockDashboardUseCase;
    late MockGetPetSummaryUseCase mockPetUseCase;
    late MockGetWeatherDataUseCase mockWeatherUseCase;
    late MockGetWalkSummaryUseCase mockWalkUseCase;
    late MockGetHealthSummaryUseCase mockHealthUseCase;
    late MockGetAppointmentSummaryUseCase mockAppointmentUseCase;

    setUp(() {
      mockDashboardUseCase = MockGetDashboardDataUseCase();
      mockPetUseCase = MockGetPetSummaryUseCase();
      mockWeatherUseCase = MockGetWeatherDataUseCase();
      mockWalkUseCase = MockGetWalkSummaryUseCase();
      mockHealthUseCase = MockGetHealthSummaryUseCase();
      mockAppointmentUseCase = MockGetAppointmentSummaryUseCase();

      service = HomeDataService(
        getDashboardDataUseCase: mockDashboardUseCase,
        getPetSummaryUseCase: mockPetUseCase,
        getWeatherDataUseCase: mockWeatherUseCase,
        getWalkSummaryUseCase: mockWalkUseCase,
        getHealthSummaryUseCase: mockHealthUseCase,
        getAppointmentSummaryUseCase: mockAppointmentUseCase,
      );
    });

    group('initializeHome', () {
      test(
        'should return success when home is initialized successfully',
        () async {
          // Arrange
          final expectedDashboard = HomeDashboardEntity(
            id: 'dashboard_1',
            petSummaries: [],
            weather: null,
            walkSummary: const WalkSummary(
              id: 'walk_1',
              todayWalks: 0,
              weeklyProgress: 0,
              weeklyGoal: 5,
              lastWalkTime: null,
            ),
            petHealthSummary: const HealthSummary(
              id: 'health_1',
              totalPets: 0,
              healthyPets: 0,
              petsNeedingAttention: 0,
              alerts: [],
            ),
            upcomingAppointments: [],
            createdAt: DateTime.now(),
          );

          when(mockDashboardUseCase.call()).thenAnswer(
            (_) async =>
                ResultFactory.success(expectedDashboard, 'ダッシュボードを初期化しました'),
          );

          // Act
          final result = await service.initializeHome();

          // Assert
          expect(result.isSuccess, true);
          expect(result.dataOrNull, expectedDashboard);
          verify(mockDashboardUseCase.call()).called(1);
        },
      );

      test(
        'should return failure when dashboard initialization fails',
        () async {
          // Arrange
          when(mockDashboardUseCase.call()).thenAnswer(
            (_) async => ResultFactory.failure<HomeDashboardEntity>(
              'ダッシュボードの初期化に失敗しました',
            ),
          );

          // Act
          final result = await service.initializeHome();

          // Assert
          expect(result.isFailure, true);
          expect(result.errorOrNull, 'ダッシュボードの初期化に失敗しました');
        },
      );
    });

    group('hasPets', () {
      test('should return true when pets exist', () async {
        // Arrange
        final petSummaries = [
          PetSummaryEntity(
            id: 'pet_1',
            name: 'ポチ',
            type: 'dog',
            age: 3,
            breed: '柴犬',
            imageUrl: null,
            lastActivity: DateTime.now(),
          ),
        ];

        when(mockPetUseCase.call()).thenAnswer(
          (_) async => ResultFactory.success(petSummaries, 'ペット情報を取得しました'),
        );

        // Act
        final result = await service.hasPets();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, true);
      });

      test('should return false when no pets exist', () async {
        // Arrange
        when(mockPetUseCase.call()).thenAnswer(
          (_) async =>
              ResultFactory.success(<PetSummaryEntity>[], 'ペット情報を取得しました'),
        );

        // Act
        final result = await service.hasPets();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, false);
      });

      test('should return failure when pet data retrieval fails', () async {
        // Arrange
        when(mockPetUseCase.call()).thenAnswer(
          (_) async =>
              ResultFactory.failure<List<PetSummaryEntity>>('ペット情報の取得に失敗しました'),
        );

        // Act
        final result = await service.hasPets();

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, 'ペット情報の取得に失敗しました');
      });
    });

    group('loadWeatherInfo', () {
      test('should return success when weather info is loaded', () async {
        // Arrange
        final expectedWeather = WeatherEntity(
          id: 'weather_1',
          temperature: 25.0,
          humidity: 60.0,
          windSpeed: 5.0,
          description: '晴れ',
          iconCode: '01d',
          location: '東京',
          timestamp: DateTime.now(),
        );

        when(mockWeatherUseCase.call(userTriggered: false)).thenAnswer(
          (_) async => ResultFactory.success(expectedWeather, '天気情報を取得しました'),
        );

        // Act
        final result = await service.loadWeatherInfo(userTriggered: false);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, expectedWeather);
        verify(mockWeatherUseCase.call(userTriggered: false)).called(1);
      });

      test('should return failure when weather info loading fails', () async {
        // Arrange
        when(mockWeatherUseCase.call(userTriggered: false)).thenAnswer(
          (_) async => ResultFactory.failure<WeatherEntity?>('天気情報の取得に失敗しました'),
        );

        // Act
        final result = await service.loadWeatherInfo(userTriggered: false);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, '天気情報の取得に失敗しました');
      });
    });

    group('loadAllData', () {
      test(
        'should return success when all data is loaded successfully',
        () async {
          // Arrange
          final dashboardResult = ResultFactory.success(
            HomeDashboardEntity(
              id: 'dashboard_1',
              petSummaries: [],
              weather: null,
              walkSummary: const WalkSummary(
                id: 'walk_1',
                todayWalks: 0,
                weeklyProgress: 0,
                weeklyGoal: 5,
                lastWalkTime: null,
              ),
              petHealthSummary: const HealthSummary(
                id: 'health_1',
                totalPets: 0,
                healthyPets: 0,
                petsNeedingAttention: 0,
                alerts: [],
              ),
              upcomingAppointments: [],
              createdAt: DateTime.now(),
            ),
            'ダッシュボードを取得しました',
          );

          final petResult = ResultFactory.success(
            <PetSummaryEntity>[],
            'ペット情報を取得しました',
          );
          final weatherResult = ResultFactory.success<WeatherEntity?>(
            null,
            '天気情報を取得しました',
          );
          final walkResult = ResultFactory.success(
            const WalkSummary(
              id: 'walk_1',
              todayWalks: 0,
              weeklyProgress: 0,
              weeklyGoal: 5,
              lastWalkTime: null,
            ),
            '散歩情報を取得しました',
          );
          final healthResult = ResultFactory.success(
            const HealthSummary(
              id: 'health_1',
              totalPets: 0,
              healthyPets: 0,
              petsNeedingAttention: 0,
              alerts: [],
            ),
            '健康情報を取得しました',
          );
          final appointmentResult = ResultFactory.success(
            <AppointmentSummary>[],
            '予約情報を取得しました',
          );

          when(
            mockDashboardUseCase.call(),
          ).thenAnswer((_) async => dashboardResult);
          when(mockPetUseCase.call()).thenAnswer((_) async => petResult);
          when(
            mockWeatherUseCase.call(userTriggered: false),
          ).thenAnswer((_) async => weatherResult);
          when(mockWalkUseCase.call()).thenAnswer((_) async => walkResult);
          when(mockHealthUseCase.call()).thenAnswer((_) async => healthResult);
          when(
            mockAppointmentUseCase.call(),
          ).thenAnswer((_) async => appointmentResult);

          // Act
          final result = await service.loadAllData(userTriggered: false);

          // Assert
          expect(result.isSuccess, true);
          expect(result.dataOrNull, isA<Map<String, dynamic>>());
          expect(result.dataOrNull?.keys, contains('dashboard'));
          expect(result.dataOrNull?.keys, contains('pets'));
          expect(result.dataOrNull?.keys, contains('weather'));
          expect(result.dataOrNull?.keys, contains('walk'));
          expect(result.dataOrNull?.keys, contains('health'));
          expect(result.dataOrNull?.keys, contains('appointments'));
          expect(result.dataOrNull?.keys, contains('loadedAt'));
        },
      );

      test('should return failure when any data loading fails', () async {
        // Arrange
        when(mockDashboardUseCase.call()).thenAnswer(
          (_) async =>
              ResultFactory.failure<HomeDashboardEntity>('ダッシュボードの取得に失敗しました'),
        );

        // Act
        final result = await service.loadAllData(userTriggered: false);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, '일부 데이터 로드에 실패했습니다');
      });
    });
  });
}
