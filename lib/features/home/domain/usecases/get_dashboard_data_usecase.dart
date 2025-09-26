import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';

/// 대시보드 데이터 조회 유스케이스
class GetDashboardDataUseCase {
  final HomeRepository _repository;

  GetDashboardDataUseCase(this._repository);

  /// 대시보드 데이터 조회 실행
  Future<HomeDashboardEntity> call() async {
    return _repository.getDashboardData();
  }
}
