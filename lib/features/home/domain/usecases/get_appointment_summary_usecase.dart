import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';

/// 예약 요약 조회 유스케이스
class GetAppointmentSummaryUseCase {
  final HomeRepository _repository;

  GetAppointmentSummaryUseCase(this._repository);

  /// 예약 요약 목록 조회 실행
  Future<List<AppointmentSummary>> call() async {
    return _repository.getUpcomingAppointments();
  }
}
