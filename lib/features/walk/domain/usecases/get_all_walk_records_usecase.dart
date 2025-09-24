import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';

/// 모든 산책 기록 조회 UseCase
class GetAllWalkRecordsUseCase {
  final WalkRepository repository;

  GetAllWalkRecordsUseCase(this.repository);

  Future<List<WalkRecordEntity>> call() async {
    return repository.getAllWalkRecords();
  }
}
