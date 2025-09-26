import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 예약 요약 정보 조회 UseCase
class GetAppointmentSummaryUseCase {
  final HomeRepository repository;

  GetAppointmentSummaryUseCase(this.repository);

  /// 예약 요약 정보 조회
  Future<Result<List<AppointmentSummary>>> call() async {
    try {
      final data = await repository.getUpcomingAppointments();
      return ResultFactory.success(data, '予約情報を取得しました');
    } catch (error) {
      return ResultFactory.failure<List<AppointmentSummary>>(
        '予約情報の取得に失敗しました: ${error.toString()}',
      );
    }
  }
}
