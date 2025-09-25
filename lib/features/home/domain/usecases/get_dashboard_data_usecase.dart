import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

class GetDashboardDataUseCase {
  final HomeRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<Result<HomeDashboardEntity>> call() async {
    try {
      final data = await repository.getDashboardData();
      return ResultFactory.success(data, 'ダッシュボードデータを取得しました');
    } catch (error) {
      return ResultFactory.failure<HomeDashboardEntity>(
        'ダッシュボードデータの取得に失敗しました: ${error.toString()}',
      );
    }
  }
}
