import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_health_controller.g.dart';

/// Daily Health Controller
@riverpod
class DailyHealthController extends _$DailyHealthController {
  @override
  Future<void> build() async {
    // 초기화 로직
  }

  /// 건강 기록 추가
  Future<void> addHealthRecord(DailyHealthRecord record) async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 데이터 처리
    print('건강 기록 추가: ${record.toJson()}');
  }

  /// 건강 기록 업데이트
  Future<void> updateHealthRecord(DailyHealthRecord record) async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 데이터 처리
    print('건강 기록 업데이트: ${record.toJson()}');
  }

  /// 건강 기록 삭제
  Future<void> deleteHealthRecord(String recordId) async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 데이터 처리
    print('건강 기록 삭제: $recordId');
  }
}

/// 특정 펫의 건강 기록 Provider
@riverpod
Future<DailyHealthRecord?> dailyHealthRecord(
  DailyHealthRecordRef ref,
  String petId,
) async {
  // TODO: 실제 API 호출로 교체
  await Future.delayed(const Duration(milliseconds: 500));

  // Mock 데이터 반환
  return DailyHealthRecord(
    id: 'mock-record-1',
    petId: petId,
    date: DateTime.now(),
    temperature: 37.5,
    overallHealth: HealthStatus.good,
    symptoms: ['食欲不振'],
    notes: 'いつもより少し食欲がありません',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// 특정 펫의 건강 분석 Provider
@riverpod
Future<HealthAnalysis?> dailyHealthAnalysis(
  DailyHealthAnalysisRef ref,
  String petId,
) async {
  // TODO: 실제 API 호출로 교체
  await Future.delayed(const Duration(milliseconds: 500));

  // Mock 데이터 반환
  return HealthAnalysis(
    id: 'mock-analysis-1',
    petId: petId,
    recordId: 'mock-record-1',
    riskLevel: RiskLevel.low,
    recommendations: [
      '定期的な運動を心がけてください',
      'バランスの取れた食事を与えてください',
      '十分な水分補給を確保してください',
    ],
    warnings: [],
    summary: '全体的に健康な状態です。継続的な観察をお勧めします。',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
