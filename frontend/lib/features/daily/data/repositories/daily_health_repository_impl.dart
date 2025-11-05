import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/daily_health_record.dart';
import '../../domain/entities/health_analysis.dart';
import '../../domain/repositories/daily_health_repository.dart';
import '../datasources/daily_health_local_datasource.dart';
import '../datasources/daily_health_remote_datasource.dart';
import '../datasources/impl/daily_health_local_datasource_impl.dart';


part 'daily_health_repository_impl.g.dart';

/// Daily Health Repository 구현체
///
/// Local과 Remote 데이터소스를 조합하여 데이터 액세스를 처리합니다.
class DailyHealthRepositoryImpl implements DailyHealthRepository {
  final DailyHealthLocalDatasource _localDatasource;
  final DailyHealthRemoteDatasource _remoteDatasource;

  const DailyHealthRepositoryImpl(
    this._localDatasource,
    this._remoteDatasource,
  );

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId) async {
    try {
      // 원격 데이터를 먼저 시도
      final remoteRecords = await _remoteDatasource.getDailyHealthRecords(
        petId,
      );

      // 로컬에 캐시
      await _localDatasource.cacheHealthRecords(remoteRecords);

      return remoteRecords;
    } catch (e) {
      // 원격 실패 시 로컬 데이터 반환
      return _localDatasource.getDailyHealthRecords(petId);
    }
  }

  @override
  Future<DailyHealthRecord?> getDailyHealthRecord(String id) async {
    try {
      // 원격 데이터를 먼저 시도
      final remoteRecord = await _remoteDatasource.getDailyHealthRecord(id);

      if (remoteRecord != null) {
        // 로컬에 캐시
        await _localDatasource.cacheHealthRecord(remoteRecord);
      }

      return remoteRecord;
    } catch (e) {
      // 원격 실패 시 로컬 데이터 반환
      return _localDatasource.getDailyHealthRecord(id);
    }
  }

  @override
  Future<DailyHealthRecord> createDailyHealthRecord(
    DailyHealthRecord record,
  ) async {
    // 로컬에 먼저 저장 (오프라인 지원)
    final localRecord = await _localDatasource.saveDailyHealthRecord(record);

    try {
      // 원격 서버에 동기화
      final remoteRecord = await _remoteDatasource.createDailyHealthRecord(
        record,
      );

      // 원격 성공 시 로컬 업데이트
      return await _localDatasource.updateDailyHealthRecord(remoteRecord);
    } catch (e) {
      // 원격 실패 시 로컬 데이터 반환 (나중에 동기화)
      await _localDatasource.markForSync(localRecord.id);
      return localRecord;
    }
  }

  @override
  Future<DailyHealthRecord> updateDailyHealthRecord(
    DailyHealthRecord record,
  ) async {
    // 로컬에 먼저 저장
    final localRecord = await _localDatasource.updateDailyHealthRecord(record);

    try {
      // 원격 서버에 동기화
      final remoteRecord = await _remoteDatasource.updateDailyHealthRecord(
        record,
      );

      // 원격 성공 시 로컬 업데이트
      return await _localDatasource.updateDailyHealthRecord(remoteRecord);
    } catch (e) {
      // 원격 실패 시 로컬 데이터 반환 (나중에 동기화)
      await _localDatasource.markForSync(localRecord.id);
      return localRecord;
    }
  }

  @override
  Future<void> deleteDailyHealthRecord(String id) async {
    // 로컬에서 먼저 삭제
    await _localDatasource.deleteDailyHealthRecord(id);

    try {
      // 원격 서버에서 삭제
      await _remoteDatasource.deleteDailyHealthRecord(id);
    } catch (e) {
      // 원격 실패 시 삭제 표시 (나중에 동기화)
      await _localDatasource.markForDeletion(id);
    }
  }

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 원격 데이터를 먼저 시도
      final remoteRecords = await _remoteDatasource
          .getDailyHealthRecordsByDateRange(petId, startDate, endDate);

      // 로컬에 캐시
      await _localDatasource.cacheHealthRecords(remoteRecords);

      return remoteRecords;
    } catch (e) {
      // 원격 실패 시 로컬 데이터 반환
      return _localDatasource.getDailyHealthRecordsByDateRange(
        petId,
        startDate,
        endDate,
      );
    }
  }

  @override
  Future<DailyHealthRecord?> getTodayHealthRecord(String petId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    final records = await getDailyHealthRecordsByDateRange(
      petId,
      startOfDay,
      endOfDay,
    );

    return records.isNotEmpty ? records.first : null;
  }

  @override
  Future<HealthAnalysis> analyzeHealthRecord(DailyHealthRecord record) async {
    try {
      // AI 분석 서비스 호출
      return await _remoteDatasource.analyzeHealthRecord(record);
    } catch (e) {
      // AI 서비스 실패 시 로컬 분석 로직 사용
      return _localDatasource.analyzeHealthRecordLocally(record);
    }
  }

  @override
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId) async {
    try {
      // 원격 데이터를 먼저 시도
      final remoteAnalyses = await _remoteDatasource.getHealthAnalysisHistory(
        petId,
      );

      // 로컬에 캐시
      await _localDatasource.cacheHealthAnalyses(remoteAnalyses);

      return remoteAnalyses;
    } catch (e) {
      // 원격 실패 시 로컬 데이터 반환
      return _localDatasource.getHealthAnalysisHistory(petId);
    }
  }
}

/// Repository Provider
@riverpod
DailyHealthRepository dailyHealthRepository(Ref ref) {
  final localDatasource = ref.watch(dailyHealthLocalDatasourceProvider);
  final remoteDatasource = ref.watch(dailyHealthRemoteDatasourceProvider);

  return DailyHealthRepositoryImpl(localDatasource, remoteDatasource);
}
