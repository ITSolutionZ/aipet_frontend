import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';

/// 건강 요약 조회 유스케이스
class GetHealthSummaryUseCase {
  final HomeRepository _repository;

  GetHealthSummaryUseCase(this._repository);

  /// 건강 요약 조회 실행
  Future<HealthSummary> call() async {
    return _repository.getPetHealthSummary();
  }
}
