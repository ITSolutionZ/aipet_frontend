import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/feeding_record_entity.dart';
import '../../domain/repositories/pet_feeding_repository.dart';

class PetFeedingRepositoryImpl implements PetFeedingRepository {
  // 메모리 기반 저장소 (MockDataService의 데이터로 초기화)
  late final List<FeedingRecordEntity> _feedingRecords;

  PetFeedingRepositoryImpl() {
    // MockDataService에서 초기 데이터 로드
    _feedingRecords = List.from(MockDataService.getMockFeedingRecords());
  }

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _feedingRecords.where((record) => record.petId == petId).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _feedingRecords
          .where(
            (record) =>
                record.petId == petId &&
                record.fedTime.year == date.year &&
                record.fedTime.month == date.month &&
                record.fedTime.day == date.day,
          )
          .toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<FeedingRecordEntity> addFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      _feedingRecords.add(record);
      return record;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<FeedingRecordEntity> updateFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      final index = _feedingRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _feedingRecords[index] = record;
        return record;
      }
      throw Exception('급여 기록을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteFeedingRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      _feedingRecords.removeWhere((record) => record.id == recordId);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<FeedingStatistics> getFeedingStatistics(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      final records = _feedingRecords
          .where((record) => record.petId == petId)
          .toList();

      final completedRecords = records
          .where((r) => r.status == FeedingStatus.completed)
          .toList();
      final skippedRecords = records
          .where((r) => r.status == FeedingStatus.skipped)
          .toList();

      final totalAmount = completedRecords.fold<double>(
        0,
        (sum, record) => sum + record.amount,
      );
      final averageAmount = completedRecords.isNotEmpty
          ? totalAmount / completedRecords.length
          : 0.0;
      final completionRate = records.isNotEmpty
          ? completedRecords.length / records.length
          : 0.0;

      final feedingsByHour = <String, int>{};
      for (var record in records) {
        final hour = record.fedTime.hour.toString().padLeft(2, '0');
        feedingsByHour[hour] = (feedingsByHour[hour] ?? 0) + 1;
      }

      return FeedingStatistics(
        totalFeedings: records.length,
        completedFeedings: completedRecords.length,
        skippedFeedings: skippedRecords.length,
        totalAmount: totalAmount,
        averageAmount: averageAmount,
        completionRate: completionRate,
        feedingsByHour: feedingsByHour,
      );
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }
}
