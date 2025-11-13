import 'package:aipet_frontend/shared/shared.dart';

import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

/// 건강 요약 조회 유스케이스
class GetHealthSummaryUseCase {
  final HomeRepository _repository;

  GetHealthSummaryUseCase(this._repository);

  /// 건강 요약 조회 실행
  Future<Result<HealthSummary>> call() async {
    try {
      final result = await _repository.getPetHealthSummary();
      return Result.success('健康サマリーを取得しました', result);
    } catch (error) {
      return Result.failure('健康サマリーの取得に失敗しました: ${error.toString()}');
    }
  }
}
