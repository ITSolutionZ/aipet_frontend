import '../repositories/walk_repository.dart';

/// 산책 통계 조회 UseCase
class GetWalkStatisticsUseCase {
  final WalkRepository repository;

  GetWalkStatisticsUseCase(this.repository);

  Future<WalkStatistics> call({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 비즈니스 로직: 날짜 범위 유효성 검증
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('시작 날짜는 종료 날짜보다 이전이어야 합니다.');
      }
    }

    return repository.getWalkStatistics(
      petId: petId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
