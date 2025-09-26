import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';

/// 산책 요약 조회 유스케이스
class GetWalkSummaryUseCase {
  final HomeRepository _repository;

  GetWalkSummaryUseCase(this._repository);

  /// 산책 요약 조회 실행
  Future<WalkSummary> call() async {
    return _repository.getWalkSummary();
  }
}
