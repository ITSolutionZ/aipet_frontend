import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 건강 요약 정보 조회 UseCase
class GetHealthSummaryUseCase {
  final HomeRepository repository;

  GetHealthSummaryUseCase(this.repository);

  /// 건강 요약 정보 조회
  Future<Result<HealthSummary>> call() async {
    try {
      final data = await repository.getPetHealthSummary();
      return ResultFactory.success(data, '健康情報を取得しました');
    } catch (error) {
      return ResultFactory.failure<HealthSummary>(
        '健康情報の取得に失敗しました: ${error.toString()}',
      );
    }
  }
}
