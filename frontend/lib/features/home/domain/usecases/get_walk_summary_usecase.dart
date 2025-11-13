import 'package:aipet_frontend/shared/shared.dart';

import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

/// 산책 요약 조회 유스케이스
class GetWalkSummaryUseCase {
  final HomeRepository _repository;

  GetWalkSummaryUseCase(this._repository);

  /// 산책 요약 조회 실행
  Future<Result<WalkSummary>> call() async {
    try {
      final result = await _repository.getWalkSummary();
      return Result.success('散歩サマリーを取得しました', result);
    } catch (error) {
      return Result.failure('散歩サマリーの取得に失敗しました: ${error.toString()}');
    }
  }
}
