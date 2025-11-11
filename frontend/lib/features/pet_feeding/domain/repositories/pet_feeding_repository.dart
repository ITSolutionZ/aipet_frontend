import '../../../../../features/pet_feeding/domain/entities/feeding_record_entity.dart';

abstract class PetFeedingRepository {
  Future<List<FeedingRecordEntity>> getFeedingRecords(String petId);
  Future<List<FeedingRecordEntity>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  );
  Future<FeedingRecordEntity> addFeedingRecord(FeedingRecordEntity record);
  Future<FeedingRecordEntity> updateFeedingRecord(FeedingRecordEntity record);

  /// 급여 기록 삭제
  /// Backend API 요구사항: petId와 recordId 모두 필요
  Future<void> deleteFeedingRecord(String petId, String recordId);

  Future<FeedingStatistics> getFeedingStatistics(String petId);
}
