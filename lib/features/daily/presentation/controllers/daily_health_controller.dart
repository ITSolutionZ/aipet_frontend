import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:aipet_frontend/features/daily/domain/repositories/daily_health_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_health_controller.g.dart';

@riverpod
class DailyHealthController extends _$DailyHealthController {
  @override
  Future<List<DailyHealthRecord>> build() async {
    return [];
  }

  Future<void> createHealthRecord(DailyHealthRecord record) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dailyHealthRepositoryProvider);
      await repository.createDailyHealthRecord(record);
      return repository.getDailyHealthRecords(record.petId);
    });
  }

  Future<void> updateHealthRecord(DailyHealthRecord record) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dailyHealthRepositoryProvider);
      await repository.updateDailyHealthRecord(record);
      return repository.getDailyHealthRecords(record.petId);
    });
  }

  Future<void> deleteHealthRecord(String recordId, String petId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dailyHealthRepositoryProvider);
      await repository.deleteDailyHealthRecord(recordId);
      return repository.getDailyHealthRecords(petId);
    });
  }

  Future<void> analyzeCurrentHealth(String petId) async {
    final repository = ref.read(dailyHealthRepositoryProvider);
    final todayRecord = await repository.getTodayHealthRecord(petId);

    if (todayRecord != null) {
      await repository.analyzeHealthRecord(todayRecord);
      // 분석 완료 후 상태 갱신
      ref.invalidate(healthAnalysisProvider(todayRecord.id));
    }
  }
}

@riverpod
Future<DailyHealthRecord?> todayHealthRecord(
  TodayHealthRecordRef ref,
  String petId,
) async {
  final repository = ref.read(dailyHealthRepositoryProvider);
  return repository.getTodayHealthRecord(petId);
}

@riverpod
Future<HealthAnalysis?> healthAnalysis(
  HealthAnalysisRef ref,
  String recordId,
) async {
  final repository = ref.read(dailyHealthRepositoryProvider);
  final analyses = await repository.getHealthAnalysisHistory('demo-pet-1');
  return analyses.where((analysis) => analysis.recordId == recordId).firstOrNull;
}

@riverpod
DailyHealthRepository dailyHealthRepository(DailyHealthRepositoryRef ref) {
  return MockDailyHealthRepository();
}

// Mock 구현체 (실제 구현 시 data 계층으로 이동)
class MockDailyHealthRepository implements DailyHealthRepository {
  static final List<DailyHealthRecord> _records = [];
  static final List<HealthAnalysis> _analyses = [];

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _records.where((record) => record.petId == petId).toList();
  }

  @override
  Future<DailyHealthRecord?> getDailyHealthRecord(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _records.where((record) => record.id == id).firstOrNull;
  }

  @override
  Future<DailyHealthRecord> createDailyHealthRecord(DailyHealthRecord record) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newRecord = record.copyWith(
      id: 'record_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _records.add(newRecord);
    return newRecord;
  }

  @override
  Future<DailyHealthRecord> updateDailyHealthRecord(DailyHealthRecord record) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      final updatedRecord = record.copyWith(updatedAt: DateTime.now());
      _records[index] = updatedRecord;
      return updatedRecord;
    }
    throw Exception('Record not found');
  }

  @override
  Future<void> deleteDailyHealthRecord(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<DailyHealthRecord>> getDailyHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _records
        .where((record) =>
            record.petId == petId &&
            record.date.isAfter(startDate) &&
            record.date.isBefore(endDate))
        .toList();
  }

  @override
  Future<DailyHealthRecord?> getTodayHealthRecord(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final today = DateTime.now();
    return _records
        .where((record) =>
            record.petId == petId &&
            record.date.year == today.year &&
            record.date.month == today.month &&
            record.date.day == today.day)
        .firstOrNull;
  }

  @override
  Future<HealthAnalysis> analyzeHealthRecord(DailyHealthRecord record) async {
    await Future.delayed(const Duration(seconds: 2)); // AI 분석 시뮬레이션

    // Mock AI 분석 결과 생성
    final analysis = HealthAnalysis(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      petId: record.petId,
      recordId: record.id,
      result: _generateMockAnalysisResult(record),
      recommendations: _generateMockRecommendations(record),
      warnings: _generateMockWarnings(record),
      analysisDate: DateTime.now(),
      aiComment: _generateMockAIComment(record),
    );

    _analyses.add(analysis);
    return analysis;
  }

  @override
  Future<List<HealthAnalysis>> getHealthAnalysisHistory(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _analyses.where((analysis) => analysis.petId == petId).toList();
  }

  AnalysisResult _generateMockAnalysisResult(DailyHealthRecord record) {
    HealthRiskLevel riskLevel;
    String summary;
    double confidenceScore = 0.85;
    List<String> detectedIssues = [];

    // 체온 기반 분석
    if (record.temperature > 39.5) {
      riskLevel = HealthRiskLevel.high;
      summary = '체온이 정상 범위를 넘어 발열 증상이 있습니다. 즉시 수의사 상담을 권장합니다.';
      detectedIssues.add('발열');
    } else if (record.temperature < 37.0) {
      riskLevel = HealthRiskLevel.medium;
      summary = '체온이 낮아 저체온증 가능성이 있습니다. 보온에 신경쓰세요.';
      detectedIssues.add('저체온');
    } else if (record.overallHealth == HealthStatus.poor ||
               record.overallHealth == HealthStatus.critical) {
      riskLevel = HealthRiskLevel.high;
      summary = '전반적인 건강 상태가 좋지 않습니다. 수의사 진료를 받아보세요.';
      detectedIssues.add('전반적 건강 악화');
    } else if (record.symptoms.isNotEmpty) {
      riskLevel = HealthRiskLevel.medium;
      summary = '몇 가지 증상이 관찰됩니다. 지속적인 관찰이 필요합니다.';
      detectedIssues.addAll(record.symptoms.map((s) => s.name));
    } else {
      riskLevel = HealthRiskLevel.low;
      summary = '전반적으로 건강한 상태입니다. 현재 상태를 유지하세요.';
    }

    return AnalysisResult(
      riskLevel: riskLevel,
      summary: summary,
      confidenceScore: confidenceScore,
      detectedIssues: detectedIssues,
    );
  }

  List<HealthRecommendation> _generateMockRecommendations(DailyHealthRecord record) {
    final recommendations = <HealthRecommendation>[];

    if (record.temperature > 39.5) {
      recommendations.add(const HealthRecommendation(
        id: 'rec_1',
        title: '충분한 수분 공급',
        description: '신선한 물을 자주 제공하여 탈수를 방지하세요.',
        type: RecommendationType.diet,
        priority: 1,
      ));
    }

    if (record.overallHealth == HealthStatus.poor) {
      recommendations.add(const HealthRecommendation(
        id: 'rec_2',
        title: '휴식 환경 조성',
        description: '조용하고 편안한 환경에서 충분히 쉴 수 있도록 해주세요.',
        type: RecommendationType.monitoring,
        priority: 2,
      ));
    }

    if (record.symptoms.any((s) => s.severity == SymptomSeverity.severe)) {
      recommendations.add(const HealthRecommendation(
        id: 'rec_3',
        title: '동물병원 방문',
        description: '심각한 증상이 있으므로 가능한 빨리 수의사 진료를 받으세요.',
        type: RecommendationType.veterinary,
        priority: 1,
      ));
    }

    return recommendations;
  }

  List<WarningSign> _generateMockWarnings(DailyHealthRecord record) {
    final warnings = <WarningSign>[];

    if (record.temperature > 40.0) {
      warnings.add(const WarningSign(
        symptom: '고열',
        description: '체온이 40도를 넘어 위험한 수준입니다.',
        level: WarningLevel.urgent,
        requiresVeterinaryVisit: true,
      ));
    }

    if (record.symptoms.any((s) => s.name.contains('구토') || s.name.contains('설사'))) {
      warnings.add(const WarningSign(
        symptom: '소화기 증상',
        description: '탈수나 영양 불균형이 발생할 수 있습니다.',
        level: WarningLevel.warning,
        requiresVeterinaryVisit: false,
      ));
    }

    return warnings;
  }

  String _generateMockAIComment(DailyHealthRecord record) {
    if (record.temperature > 39.5) {
      return 'AI 분석 결과, 발열 증상이 확인됩니다. 즉시 동물병원 방문을 권장드립니다.';
    } else if (record.overallHealth == HealthStatus.excellent) {
      return '건강 상태가 매우 양호합니다. 현재 관리 방식을 계속 유지하시기 바랍니다.';
    } else {
      return '지속적인 관찰과 관리가 필요한 상태입니다. 변화가 있으면 기록해 주세요.';
    }
  }
}