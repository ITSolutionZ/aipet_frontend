import '../../domain/entities/daily_health_record.dart';
import '../../domain/entities/health_analysis.dart';

/// 로컬 데이터소스 인터페이스
abstract class DailyHealthLocalDatasource {
  // Health Records
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId);
  Future<DailyHealthRecord?> getDailyHealthRecord(String id);
  Future<DailyHealthRecord> saveDailyHealthRecord(DailyHealthRecord record);
  Future<DailyHealthRecord> updateDailyHealthRecord(DailyHealthRecord record);
  Future<void> deleteDailyHealthRecord(String id);

  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  );

  // Caching
  Future<void> cacheHealthRecord(DailyHealthRecord record);
  Future<void> cacheHealthRecords(List<DailyHealthRecord> records);

  // Sync management
  Future<void> markForSync(String recordId);
  Future<void> markForDeletion(String recordId);
  Future<List<String>> getPendingSyncRecords();
  Future<List<String>> getPendingDeletionRecords();

  // Health Analysis
  Future<HealthAnalysis> analyzeHealthRecordLocally(DailyHealthRecord record);
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId);
  Future<void> cacheHealthAnalyses(List<HealthAnalysis> analyses);
}