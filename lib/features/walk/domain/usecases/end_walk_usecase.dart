import '../entities/walk_record_entity.dart';
import '../repositories/walk_repository.dart';

/// 산책 종료 UseCase
class EndWalkUseCase {
  final WalkRepository repository;

  EndWalkUseCase(this.repository);

  Future<WalkRecordEntity> call(
    String recordId, {
    double? distance,
    String? notes,
  }) async {
    // 비즈니스 로직: 산책 종료 전 유효성 검증
    if (recordId.isEmpty) {
      throw ArgumentError('산책 기록 ID는 필수입니다.');
    }

    // 산책 기록이 존재하는지 확인
    final walkRecord = await repository.getWalkRecordById(recordId);
    if (walkRecord == null) {
      throw ArgumentError('산책 기록을 찾을 수 없습니다.');
    }

    // 산책이 진행 중인지 확인
    if (walkRecord.status != WalkStatus.inProgress) {
      throw StateError('진행 중인 산책만 종료할 수 있습니다.');
    }

    return repository.endWalk(recordId, distance: distance, notes: notes);
  }
}
