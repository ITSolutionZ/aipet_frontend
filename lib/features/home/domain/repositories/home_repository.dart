import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 🏠 홈 리포지토리 인터페이스
///
/// 홈 화면 데이터 관리를 위한 리포지토리 인터페이스
abstract class HomeRepository {
  /// 대시보드 데이터 가져오기
  Future<Result<HomeDashboardEntity>> getDashboardData(String userId);

  /// 날씨 데이터 가져오기
  Future<Result<WeatherEntity?>> getWeatherData(String location);

  /// 펫 요약 목록 가져오기
  Future<Result<List<PetSummaryEntity>>> getPetSummaries(String userId);

  /// 오늘의 예약 목록 가져오기
  Future<Result<List<TodayAppointmentEntity>>> getTodayAppointments(String userId);

  /// 오늘의 총 산책 시간 가져오기
  Future<Result<int>> getTotalWalkMinutes(String userId);
}