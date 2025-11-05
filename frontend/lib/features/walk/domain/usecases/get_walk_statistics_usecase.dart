import '../../../../../features/walk/domain/entities/walk_statistics_entity.dart';
import '../../../../../features/walk/domain/repositories/walk_repository.dart';

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

      // 최대 1년 제한
      final difference = endDate.difference(startDate);
      if (difference.inDays > 365) {
        throw ArgumentError('조회 기간은 최대 1년까지 가능합니다.');
      }
    }

    return repository.getWalkStatistics(
      petId: petId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 오늘 산책 통계 조회
  Future<WalkStatistics> getTodayStatistics({String? petId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return call(petId: petId, startDate: today, endDate: tomorrow);
  }

  /// 이번 주 산책 통계 조회
  Future<WalkStatistics> getThisWeekStatistics({String? petId}) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return call(petId: petId, startDate: startOfWeek, endDate: endOfWeek);
  }

  /// 이번 달 산책 통계 조회
  Future<WalkStatistics> getThisMonthStatistics({String? petId}) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return call(petId: petId, startDate: startOfMonth, endDate: endOfMonth);
  }

  /// 지난 N일간 산책 통계 조회
  Future<WalkStatistics> getLastNDaysStatistics(
    int days, {
    String? petId,
  }) async {
    if (days <= 0) {
      throw ArgumentError('일수는 1 이상이어야 합니다.');
    }

    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startDate = endDate.subtract(Duration(days: days));

    return call(petId: petId, startDate: startDate, endDate: endDate);
  }
}
