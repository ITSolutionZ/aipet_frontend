import '../entities/walk_record_entity.dart';
import '../repositories/walk_repository.dart';

/// 펫별 산책 기록 조회 UseCase
class GetWalkRecordsByPetUseCase {
  final WalkRepository repository;

  GetWalkRecordsByPetUseCase(this.repository);

  Future<List<WalkRecordEntity>> call(String petId) async {
    if (petId.isEmpty) {
      throw ArgumentError('펫 ID는 필수입니다.');
    }

    return repository.getWalkRecordsByPetId(petId);
  }
}
