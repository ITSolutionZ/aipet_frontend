import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 펫 요약 조회 유스케이스
class GetPetSummaryUseCase {
  final HomeRepository _repository;

  GetPetSummaryUseCase(this._repository);

  /// 펫 요약 목록 조회 실행
  Future<Result<List<PetSummaryEntity>>> call() async {
    try {
      final result = await _repository.getPetSummaries();
      return Result.success('ペットサマリーを取得しました', result);
    } catch (error) {
      return Result.failure('ペットサマリーの取得に失敗しました: ${error.toString()}');
    }
  }
}
