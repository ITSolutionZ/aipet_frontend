import 'package:aipet_frontend/features/home/domain/entities/entities.dart';

/// 홈 리포지토리 인터페이스
abstract class HomeRepository {
  /// 대시보드 데이터 조회
  Future<HomeDashboardEntity> getDashboardData();

  /// 현재 날씨 정보 조회
  Future<WeatherEntity?> getCurrentWeather({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  });

  /// 펫 프로필 목록 조회
  Future<List<PetSummaryEntity>> getPetSummaries();

  /// 산책 요약 정보 조회
  Future<WalkSummary> getWalkSummary();

  /// 펫 건강 요약 정보 조회
  Future<HealthSummary> getPetHealthSummary();

  /// 예정된 예약 목록 조회
  Future<List<AppointmentSummary>> getUpcomingAppointments();
}
