import 'dart:convert';

import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/daily_health_record.dart';
import '../../../domain/entities/health_analysis.dart';
import '../daily_health_local_datasource.dart';
import '../daily_health_remote_datasource.dart';

part 'daily_health_local_datasource_impl.g.dart';

/// 실제 로컬 데이터소스 구현체
///
/// SharedPreferences를 사용한 로컬 저장소 구현
class DailyHealthLocalDatasourceImpl implements DailyHealthLocalDatasource {
  static const String _recordsKey = 'daily_health_records';
  static const String _analysesKey = 'health_analyses';
  static const String _pendingSyncKey = 'pending_sync_records';
  static const String _pendingDeletionKey = 'pending_deletion_records';

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId) async {
    final recordsJson = await SecureStorageService.getString(_recordsKey);
    if (recordsJson == null) return [];

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    final records = recordsList
        .map((json) => DailyHealthRecord.fromJson(json as Map<String, dynamic>))
        .where((record) => record.petId == petId)
        .toList();

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<DailyHealthRecord?> getDailyHealthRecord(String id) async {
    final recordsJson = await SecureStorageService.getString(_recordsKey);
    if (recordsJson == null) return null;

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    final records = recordsList
        .map((json) => DailyHealthRecord.fromJson(json as Map<String, dynamic>))
        .toList();

    try {
      return records.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DailyHealthRecord> saveDailyHealthRecord(
    DailyHealthRecord record,
  ) async {
    final records = await _getAllRecords();

    final newRecord = record.copyWith(
      id: record.id.isEmpty ? _generateId() : record.id,
      createdAt: record.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    records.add(newRecord);
    await _saveAllRecords(records);
    return newRecord;
  }

  @override
  Future<DailyHealthRecord> updateDailyHealthRecord(
    DailyHealthRecord record,
  ) async {
    final records = await _getAllRecords();
    final index = records.indexWhere((r) => r.id == record.id);

    if (index == -1) {
      throw Exception('Record not found: ${record.id}');
    }

    final updatedRecord = record.copyWith(updatedAt: DateTime.now());
    records[index] = updatedRecord;
    await _saveAllRecords(records);
    return updatedRecord;
  }

  @override
  Future<void> deleteDailyHealthRecord(String id) async {
    final records = await _getAllRecords();
    records.removeWhere((record) => record.id == id);
    await _saveAllRecords(records);

    // 관련 분석 결과도 삭제
    final analyses = await _getAllAnalyses();
    analyses.removeWhere((analysis) => analysis.recordId == id);
    await _saveAllAnalyses(analyses);
  }

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allRecords = await getDailyHealthRecords(petId);
    return allRecords
        .where(
          (record) =>
              record.date.isAfter(
                startDate.subtract(const Duration(seconds: 1)),
              ) &&
              record.date.isBefore(endDate.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  @override
  Future<void> cacheHealthRecord(DailyHealthRecord record) async {
    // 이미 로컬에 저장되므로 추가 캐싱 불필요
  }

  @override
  Future<void> cacheHealthRecords(List<DailyHealthRecord> records) async {
    // 이미 로컬에 저장되므로 추가 캐싱 불필요
  }

  @override
  Future<void> markForSync(String recordId) async {
    final pending = await _getPendingList(_pendingSyncKey);
    if (!pending.contains(recordId)) {
      pending.add(recordId);
      await _savePendingList(_pendingSyncKey, pending);
    }
  }

  @override
  Future<void> markForDeletion(String recordId) async {
    final pending = await _getPendingList(_pendingDeletionKey);
    if (!pending.contains(recordId)) {
      pending.add(recordId);
      await _savePendingList(_pendingDeletionKey, pending);
    }
  }

  @override
  Future<List<String>> getPendingSyncRecords() async {
    return _getPendingList(_pendingSyncKey);
  }

  @override
  Future<List<String>> getPendingDeletionRecords() async {
    return _getPendingList(_pendingDeletionKey);
  }

  @override
  Future<HealthAnalysis> analyzeHealthRecordLocally(
    DailyHealthRecord record,
  ) async {
    // 로컬 AI 분석 (간단한 규칙 기반)
    final analysis = _generateLocalAnalysis(record);

    // 분석 결과 저장
    final analyses = await _getAllAnalyses();
    analyses.add(analysis);
    await _saveAllAnalyses(analyses);

    return analysis;
  }

  @override
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId) async {
    final analysesJson = await SecureStorageService.getString(_analysesKey);
    if (analysesJson == null) return [];

    final List<dynamic> analysesList = jsonDecode(analysesJson);
    final analyses = analysesList
        .map((json) => HealthAnalysis.fromJson(json as Map<String, dynamic>))
        .where((analysis) => analysis.petId == petId)
        .toList();

    analyses.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.now();
      final bTime = b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    return analyses;
  }

  @override
  Future<void> cacheHealthAnalyses(List<HealthAnalysis> analyses) async {
    // 이미 로컬에 저장되므로 추가 캐싱 불필요
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  Future<List<DailyHealthRecord>> _getAllRecords() async {
    final recordsJson = await SecureStorageService.getString(_recordsKey);
    if (recordsJson == null) return [];

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    return recordsList
        .map((json) => DailyHealthRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAllRecords(List<DailyHealthRecord> records) async {
    final recordsJson = jsonEncode(records.map((r) => r.toJson()).toList());
    await SecureStorageService.setString(_recordsKey, recordsJson);
  }

  Future<List<HealthAnalysis>> _getAllAnalyses() async {
    final analysesJson = await SecureStorageService.getString(_analysesKey);
    if (analysesJson == null) return [];

    final List<dynamic> analysesList = jsonDecode(analysesJson);
    return analysesList
        .map((json) => HealthAnalysis.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAllAnalyses(List<HealthAnalysis> analyses) async {
    final analysesJson = jsonEncode(analyses.map((a) => a.toJson()).toList());
    await SecureStorageService.setString(_analysesKey, analysesJson);
  }

  Future<List<String>> _getPendingList(String key) async {
    final pendingJson = await SecureStorageService.getString(key);
    if (pendingJson == null) return [];

    final List<dynamic> pendingList = jsonDecode(pendingJson);
    return pendingList.cast<String>();
  }

  Future<void> _savePendingList(String key, List<String> pending) async {
    final pendingJson = jsonEncode(pending);
    await SecureStorageService.setString(key, pendingJson);
  }

  /// 로컬 분석 생성 (규칙 기반)
  HealthAnalysis _generateLocalAnalysis(DailyHealthRecord record) {
    final temperature = record.temperature ?? 37.0;
    final symptoms = record.symptoms;

    // 위험도 평가
    RiskLevel riskLevel;
    final List<String> recommendations = [];
    final List<String> warnings = [];
    String summary;

    if (temperature > 39.0 ||
        symptoms.any((s) => s.contains('発作') || s.contains('意識不明'))) {
      riskLevel = RiskLevel.high;
      warnings.addAll(['すぐに獣医師の診療が必要です', '緊急状況の可能性があります']);
      recommendations.addAll(['今すぐ最寄りの動物病院へ行ってください', '移動時はペットを安定させてください']);
      summary = 'すぐに獣医師の診療が必要な状態です。';
    } else if (temperature > 38.5 || symptoms.isNotEmpty) {
      riskLevel = RiskLevel.medium;
      warnings.addAll(['健康状態に注意が必要です', '症状が続く場合は獣医師に相談してください']);
      recommendations.addAll([
        '十分な休息を取らせてください',
        '水分補給を増やしてください',
        '24時間以内に獣医師の相談を推奨します',
      ]);
      summary = '健康状態に注意が必要です。経過を見守ってください。';
    } else {
      riskLevel = RiskLevel.low;
      recommendations.addAll([
        '現在の健康状態は良好です',
        '定期的な運動を続けてください',
        'バランスの取れた食事を提供してください',
      ]);
      summary = '健康状態は良好です。現在の管理を継続してください。';
    }

    return HealthAnalysis(
      id: _generateId(),
      petId: record.petId,
      recordId: record.id,
      riskLevel: riskLevel,
      recommendations: recommendations,
      warnings: warnings,
      summary: summary,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 간단한 ID 생성기
  String _generateId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }
}

/// 로컬 Remote Datasource 구현체 (개발 중)
///
/// 개발 중에는 Local과 동일한 로직 사용
class DailyHealthRemoteDatasourceImpl implements DailyHealthRemoteDatasource {
  final DailyHealthLocalDatasourceImpl _localDatasource;

  DailyHealthRemoteDatasourceImpl(this._localDatasource);

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId) =>
      _localDatasource.getDailyHealthRecords(petId);

  @override
  Future<DailyHealthRecord?> getDailyHealthRecord(String id) =>
      _localDatasource.getDailyHealthRecord(id);

  @override
  Future<DailyHealthRecord> createDailyHealthRecord(DailyHealthRecord record) =>
      _localDatasource.saveDailyHealthRecord(record);

  @override
  Future<DailyHealthRecord> updateDailyHealthRecord(DailyHealthRecord record) =>
      _localDatasource.updateDailyHealthRecord(record);

  @override
  Future<void> deleteDailyHealthRecord(String id) =>
      _localDatasource.deleteDailyHealthRecord(id);

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) => _localDatasource.getDailyHealthRecordsByDateRange(
    petId,
    startDate,
    endDate,
  );

  @override
  Future<HealthAnalysis> analyzeHealthRecord(DailyHealthRecord record) =>
      _localDatasource.analyzeHealthRecordLocally(record);

  @override
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId) =>
      _localDatasource.getHealthAnalysisHistory(petId);
}

/// Local Datasource Provider
@riverpod
DailyHealthLocalDatasource dailyHealthLocalDatasource(Ref ref) {
  return DailyHealthLocalDatasourceImpl();
}

/// Remote Datasource Provider (개발 중 - Local과 동일)
@riverpod
DailyHealthRemoteDatasource dailyHealthRemoteDatasource(Ref ref) {
  final localDatasource = DailyHealthLocalDatasourceImpl();
  return DailyHealthRemoteDatasourceImpl(localDatasource);
}
