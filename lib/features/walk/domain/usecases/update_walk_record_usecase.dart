import '../entities/walk_record_entity.dart';
import '../repositories/walk_repository.dart';

/// 산책 기록 수정 UseCase
class UpdateWalkRecordUseCase {
  final WalkRepository _repository;

  UpdateWalkRecordUseCase(this._repository);

  /// 산책 기록 수정
  Future<void> call(WalkRecordEntity walkRecord) async {
    return _repository.updateWalkRecord(walkRecord);
  }
}
