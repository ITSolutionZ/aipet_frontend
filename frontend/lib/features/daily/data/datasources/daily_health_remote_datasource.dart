import '../../domain/entities/daily_health_record.dart';
import '../../domain/entities/health_analysis.dart';

/// 원격 데이터소스 인터페이스
abstract class DailyHealthRemoteDatasource {
  // Health Records
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

  // Health Analysis
  Future<HealthAnalysis> analyzeHealthRecord(DailyHealthRecord record);
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId);
}
