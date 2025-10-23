import 'package:aipet_frontend/features/pet_feeding/data/models/feeding_record_model.dart';
import 'package:aipet_frontend/features/pet_feeding/data/services/pet_feeding_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/entities/feeding_record_entity.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/repositories/pet_feeding_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 급여 기록 Repository 구현체
/// Hybrid 패턴: 로컬 스토리지 서비스 사용 (추후 API 연동 예정)
class PetFeedingRepositoryImpl implements PetFeedingRepository {
  PetFeedingRepositoryImpl();

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await PetFeedingLocalStorageService.getFeedingRecords(
      petId: petId,
    );

    LoggerService.debug(
      '✅ PetFeedingRepository: 급여 기록 ${recordsData.length}개 조회',
    );
    return recordsData
        .map((data) => FeedingRecordModel.fromJson(data).toEntity())
        .toList();
  }

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await PetFeedingLocalStorageService.getFeedingRecords(
      petId: petId,
    );

    return recordsData
        .where((data) {
          final fedTime = DateTime.parse(data['fedTime'] as String);
          return fedTime.year == date.year &&
              fedTime.month == date.month &&
              fedTime.day == date.day;
        })
        .map((data) => FeedingRecordModel.fromJson(data).toEntity())
        .toList();
  }

  @override
  Future<FeedingRecordEntity> addFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final model = FeedingRecordModel.fromEntity(record);
    final recordData = model.toJson();

    await PetFeedingLocalStorageService.addFeedingRecord(recordData);

    LoggerService.debug('✅ PetFeedingRepository: 급여 기록 추가 - ID: ${record.id}');
    return record;
  }

  @override
  Future<FeedingRecordEntity> updateFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final model = FeedingRecordModel.fromEntity(record);
    final recordData = model.toJson();

    await PetFeedingLocalStorageService.updateFeedingRecord(recordData);

    LoggerService.debug(
      '✅ PetFeedingRepository: 급여 기록 업데이트 - ID: ${record.id}',
    );
    return record;
  }

  @override
  Future<void> deleteFeedingRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    await PetFeedingLocalStorageService.deleteFeedingRecord(recordId);
    LoggerService.debug('✅ PetFeedingRepository: 급여 기록 삭제 - ID: $recordId');
  }

  @override
  Future<FeedingStatistics> getFeedingStatistics(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await PetFeedingLocalStorageService.getFeedingRecords(
      petId: petId,
    );

    final records = recordsData
        .map((data) => FeedingRecordModel.fromJson(data).toEntity())
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
    for (final record in completedRecords) {
      // ✅ DateTimeUtils 사용
      final timeStr = DateTimeUtils.formatTime(record.fedTime);
      final hour = timeStr.split(':')[0];
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
}
