import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';

/// 펫 요약 조회 유스케이스
class GetPetSummaryUseCase {
  final HomeRepository _repository;

  GetPetSummaryUseCase(this._repository);

  /// 펫 요약 목록 조회 실행
  Future<List<PetSummaryEntity>> call() async {
    return _repository.getPetSummaries();
  }
}
