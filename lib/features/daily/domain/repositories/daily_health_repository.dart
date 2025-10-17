import '../entities/daily_health_record.dart';
import '../entities/health_analysis.dart';

abstract class DailyHealthRepository {
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId);

  Future<DailyHealthRecord?> getDailyHealthRecord(String id);

  Future<DailyHealthRecord> createDailyHealthRecord(DailyHealthRecord record);

  Future<DailyHealthRecord> updateDailyHealthRecord(DailyHealthRecord record);

  Future<void> deleteDailyHealthRecord(String id);

  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  );

  Future<DailyHealthRecord?> getTodayHealthRecord(String petId);

  Future<HealthAnalysis> analyzeHealthRecord(DailyHealthRecord record);

  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId);
}
