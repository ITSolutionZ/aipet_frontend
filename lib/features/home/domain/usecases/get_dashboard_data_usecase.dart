import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 대시보드 데이터 조회 유스케이스
class GetDashboardDataUseCase {
  final HomeRepository _repository;

  GetDashboardDataUseCase(this._repository);

  /// 대시보드 데이터 조회 실행
  Future<Result<HomeDashboardEntity>> call() async {
    try {
      final result = await _repository.getDashboardData();
      return Result.success('ダッシュボードデータを取得しました', result);
    } catch (error) {
      return Result.failure('ダッシュボードデータの取得に失敗しました: ${error.toString()}');
    }
  }
}
