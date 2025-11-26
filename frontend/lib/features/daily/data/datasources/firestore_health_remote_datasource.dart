import 'package:aipet_frontend/shared/core/services/firestore_health_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import '../../domain/entities/daily_health_record.dart';
import '../../domain/entities/health_analysis.dart';
import '../datasources/daily_health_remote_datasource.dart';

/// Firestore를 사용하는 건강 기록 Remote Datasource 구현체
class FirestoreHealthRemoteDatasource implements DailyHealthRemoteDatasource {
  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.getDailyHealthRecords($petId) 호출',
    );

    final result = await FirestoreHealthService.getHealthRecords(petId);

    if (result.isSuccess) {
      LoggerService.debug(
        '✅ getDailyHealthRecords 성공: ${result.dataOrNull?.length}개',
      );
      return result.dataOrNull ?? [];
    } else {
      LoggerService.debug('❌ getDailyHealthRecords 실패: ${result.error}');
      throw Exception('건강 기록 조회 실패: ${result.error}');
    }
  }

  @override
  Future<DailyHealthRecord?> getDailyHealthRecord(String id) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.getDailyHealthRecord($id) 호출',
    );

    // ID 형식: "petId_recordId"
    final parts = id.split('_');
    if (parts.length >= 2) {
      final petId = parts[0];
      final recordId = parts.sublist(1).join('_');
      final result = await FirestoreHealthService.getHealthRecordById(
        petId,
        recordId,
      );

      if (result.isSuccess) {
        LoggerService.debug('✅ getDailyHealthRecord 성공');
        return result.dataOrNull;
      } else {
        LoggerService.debug('❌ getDailyHealthRecord 실패: ${result.error}');
        throw Exception('건강 기록 조회 실패: ${result.error}');
      }
    }

    LoggerService.debug('⚠️ getDailyHealthRecord: 잘못된 ID 형식 - $id');
    return null;
  }

  @override
  Future<DailyHealthRecord> createDailyHealthRecord(
    DailyHealthRecord record,
  ) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.createDailyHealthRecord() 호출',
    );

    final result = await FirestoreHealthService.createHealthRecord(record);

    if (result.isSuccess && result.dataOrNull != null) {
      LoggerService.debug('✅ createDailyHealthRecord 성공');
      return result.dataOrNull!;
    } else {
      LoggerService.debug('❌ createDailyHealthRecord 실패: ${result.error}');
      throw Exception('건강 기록 생성 실패: ${result.error}');
    }
  }

  @override
  Future<DailyHealthRecord> updateDailyHealthRecord(
    DailyHealthRecord record,
  ) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.updateDailyHealthRecord() 호출',
    );

    final result = await FirestoreHealthService.updateHealthRecord(record);

    if (result.isSuccess && result.dataOrNull != null) {
      LoggerService.debug('✅ updateDailyHealthRecord 성공');
      return result.dataOrNull!;
    } else {
      LoggerService.debug('❌ updateDailyHealthRecord 실패: ${result.error}');
      throw Exception('건강 기록 업데이트 실패: ${result.error}');
    }
  }

  @override
  Future<void> deleteDailyHealthRecord(String id) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.deleteDailyHealthRecord($id) 호출',
    );

    // ID 형식: "petId_recordId"
    final parts = id.split('_');
    if (parts.length >= 2) {
      final petId = parts[0];
      final recordId = parts.sublist(1).join('_');

      final result = await FirestoreHealthService.deleteHealthRecord(
        petId,
        recordId,
      );

      if (!result.isSuccess) {
        LoggerService.debug('❌ deleteDailyHealthRecord 실패: ${result.error}');
        throw Exception('건강 기록 삭제 실패: ${result.error}');
      }

      LoggerService.debug('✅ deleteDailyHealthRecord 성공');
      return;
    }

    LoggerService.debug('❌ deleteDailyHealthRecord: 잘못된 ID 형식 - $id');
    throw Exception('건강 기록 삭제 실패: 잘못된 ID 형식');
  }

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.getDailyHealthRecordsByDateRange() 호출',
    );
    LoggerService.debug('   Pet: $petId, 범위: $startDate ~ $endDate');

    final result = await FirestoreHealthService.getHealthRecordsByDateRange(
      petId,
      startDate,
      endDate,
    );

    if (result.isSuccess) {
      LoggerService.debug(
        '✅ getDailyHealthRecordsByDateRange 성공: ${result.dataOrNull?.length}개',
      );
      return result.dataOrNull ?? [];
    } else {
      LoggerService.debug(
        '❌ getDailyHealthRecordsByDateRange 실패: ${result.error}',
      );
      throw Exception('건강 기록 조회 실패: ${result.error}');
    }
  }

  @override
  Future<HealthAnalysis> analyzeHealthRecord(DailyHealthRecord record) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.analyzeHealthRecord() 호출',
    );
    LoggerService.debug('   Record ID: ${record.id}, Pet ID: ${record.petId}');

    // 건강 상태에 따른 위험도 결정
    final riskLevel = _healthStatusToRiskLevel(record.overallHealth);

    // 권장사항 생성
    final recommendations = <String>[];
    if (record.overallHealth == HealthStatus.poor ||
        record.overallHealth == HealthStatus.critical) {
      recommendations.add('獣医の診察を検討してください');
    }
    if (record.symptoms.isNotEmpty) {
      recommendations.add('症状を注意深く観察してください');
    }
    if (record.temperature != null && record.temperature! > 39.5) {
      recommendations.add('体温が高いです。水分補給を確認してください');
    }

    // 경고사항 생성
    final warnings = <String>[];
    if (record.overallHealth == HealthStatus.critical) {
      warnings.add('緊急の対応が必要かもしれません');
    }

    LoggerService.debug('✅ analyzeHealthRecord 성공: 위험도 ${riskLevel.name}');

    return HealthAnalysis(
      id: 'analysis_${record.id}',
      petId: record.petId,
      recordId: record.id,
      riskLevel: riskLevel,
      recommendations: recommendations,
      warnings: warnings,
      summary: _generateHealthSummary(record),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId) async {
    LoggerService.debug(
      '📡 FirestoreHealthRemoteDatasource.getHealthAnalysisHistory($petId) 호출',
    );

    // 최근 30일간의 건강 기록 조회
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final result = await FirestoreHealthService.getHealthRecordsByDateRange(
      petId,
      startDate,
      endDate,
    );

    if (!result.isSuccess) {
      LoggerService.debug('❌ getHealthAnalysisHistory 실패: ${result.error}');
      throw Exception('건강 분석 기록 조회 실패: ${result.error}');
    }

    final records = result.dataOrNull ?? [];
    final analyses = <HealthAnalysis>[];

    for (final record in records) {
      final analysis = await analyzeHealthRecord(record);
      analyses.add(analysis);
    }

    LoggerService.debug('✅ getHealthAnalysisHistory 성공: ${analyses.length}개');
    return analyses;
  }

  /// 건강 상태를 위험도로 변환
  RiskLevel _healthStatusToRiskLevel(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
      case HealthStatus.good:
        return RiskLevel.low;
      case HealthStatus.fair:
        return RiskLevel.medium;
      case HealthStatus.poor:
      case HealthStatus.critical:
        return RiskLevel.high;
    }
  }

  /// 건강 요약 생성
  String _generateHealthSummary(DailyHealthRecord record) {
    final buffer = StringBuffer();

    // 전반적인 건강 상태
    switch (record.overallHealth) {
      case HealthStatus.excellent:
        buffer.write('健康状態は非常に良好です。');
        break;
      case HealthStatus.good:
        buffer.write('健康状態は良好です。');
        break;
      case HealthStatus.fair:
        buffer.write('健康状態は普通です。');
        break;
      case HealthStatus.poor:
        buffer.write('健康状態に注意が必要です。');
        break;
      case HealthStatus.critical:
        buffer.write('健康状態が深刻です。早急な対応を検討してください。');
        break;
    }

    // 체온 정보
    if (record.temperature != null) {
      buffer.write(' 体温: ${record.temperature?.toStringAsFixed(1)}°C');
    }

    // 증상 정보
    if (record.symptoms.isNotEmpty) {
      buffer.write(' 症状: ${record.symptoms.join(", ")}');
    }

    return buffer.toString();
  }
}
