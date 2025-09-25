import 'package:aipet_frontend/features/home/domain/entities/entities.dart';

/// 홈 대시보드 데이터 Repository 인터페이스
abstract class HomeRepository {
  Future<HomeDashboardEntity> getDashboardData();
  Future<WeatherEntity?> getCurrentWeather({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  });
  Future<List<PetSummaryEntity>> getPetSummaries();
  Future<WalkSummary> getWalkSummary();
  Future<HealthSummary> getPetHealthSummary();
  Future<List<AppointmentSummary>> getUpcomingAppointments();
}
