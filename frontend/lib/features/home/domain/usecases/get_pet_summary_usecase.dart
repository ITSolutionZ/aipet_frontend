import '../../../../shared/shared.dart';

import '../entities/pet_summary_entity.dart';
import '../repositories/home_repository.dart';


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
