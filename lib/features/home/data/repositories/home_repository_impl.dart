import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 🏠 홈 리포지토리 구현체
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Result<HomeDashboardEntity>> getDashboardData(String userId) async {
    try {
      // TODO: 실제 API 연동 또는 로컬 데이터베이스 조회로 교체
      await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

      final dashboard = HomeDashboardEntity(
        userId: userId,
        weather: WeatherEntity(
          temperature: 23.5,
          condition: 'partly_cloudy',
          icon: '⛅',
          location: '東京',
          timestamp: DateTime.now(),
        ),
        pets: [
          const PetSummaryEntity(
            id: '1',
            name: 'ポチ',
            type: 'dog',
            age: 3,
            needsAttention: false,
          ),
        ],
        todayAppointments: [],
        totalWalkMinutes: 45,
        lastUpdated: DateTime.now(),
      );

      return ResultFactory.success(dashboard, '대시보드 데이터를 성공적으로 불러왔습니다');
    } catch (e) {
      return ResultFactory.failure('대시보드 데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<WeatherEntity?>> getWeatherData(String location) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock 날씨 데이터
      final weather = WeatherEntity(
        temperature: 23.5,
        condition: 'partly_cloudy',
        icon: '⛅',
        location: location,
        timestamp: DateTime.now(),
      );

      return ResultFactory.success(weather, '날씨 정보를 성공적으로 불러왔습니다');
    } catch (e) {
      return ResultFactory.failure('날씨 정보를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<List<PetSummaryEntity>>> getPetSummaries(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock 펫 데이터
      const pets = [
        PetSummaryEntity(
          id: '1',
          name: 'ポチ',
          type: 'dog',
          age: 3,
          needsAttention: false,
        ),
      ];

      return ResultFactory.success(pets, '반려동물 정보를 성공적으로 불러왔습니다');
    } catch (e) {
      return ResultFactory.failure('반려동물 정보를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<List<TodayAppointmentEntity>>> getTodayAppointments(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock 예약 데이터 (빈 목록)
      const appointments = <TodayAppointmentEntity>[];

      return ResultFactory.success(appointments, '오늘의 예약을 성공적으로 불러왔습니다');
    } catch (e) {
      return ResultFactory.failure('오늘의 예약을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<int>> getTotalWalkMinutes(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock 산책 시간 데이터
      const totalMinutes = 45;

      return ResultFactory.success(totalMinutes, '산책 시간을 성공적으로 불러왔습니다');
    } catch (e) {
      return ResultFactory.failure('산책 시간을 불러오는 중 오류가 발생했습니다: $e');
    }
  }
}