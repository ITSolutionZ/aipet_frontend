import '../entities/feeding_record_entity.dart';

abstract class PetFeedingRepository {
  Future<List<FeedingRecordEntity>> getFeedingRecords(String petId);
  Future<List<FeedingRecordEntity>> getFeedingRecordsByDate(String petId, DateTime date);
  Future<FeedingRecordEntity> addFeedingRecord(FeedingRecordEntity record);
  Future<FeedingRecordEntity> updateFeedingRecord(FeedingRecordEntity record);
  Future<void> deleteFeedingRecord(String recordId);
  Future<FeedingStatistics> getFeedingStatistics(String petId);
}