import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 산책 요약 정보 조회 UseCase
class GetWalkSummaryUseCase {
  final HomeRepository repository;

  GetWalkSummaryUseCase(this.repository);

  /// 산책 요약 정보 조회
  Future<Result<WalkSummary>> call() async {
    try {
      final data = await repository.getWalkSummary();
      return ResultFactory.success(data, '散歩情報を取得しました');
    } catch (error) {
      return ResultFactory.failure<WalkSummary>(
        '散歩情報の取得に失敗しました: ${error.toString()}',
      );
    }
  }
}
