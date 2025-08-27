import '../entities/walk_record_entity.dart';
import '../repositories/walk_repository.dart';

/// 산책 시작 UseCase
class StartWalkUseCase {
  final WalkRepository repository;

  StartWalkUseCase(this.repository);

  Future<WalkRecordEntity> call(WalkRecordEntity walkRecord) async {
    // 비즈니스 로직: 산책 시작 전 유효성 검증
    if (walkRecord.title.isEmpty) {
      throw ArgumentError('산책 제목은 필수입니다.');
    }

    if (walkRecord.petId == null || walkRecord.petId!.isEmpty) {
      throw ArgumentError('펫 ID는 필수입니다.');
    }

    // 현재 진행 중인 산책이 있는지 확인
    final currentWalk = await repository.getCurrentWalk();
    if (currentWalk != null) {
      throw StateError('이미 진행 중인 산책이 있습니다.');
    }

    return repository.startWalk(walkRecord);
  }
}
