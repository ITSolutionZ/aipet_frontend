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

  // petId에 따른 다른 Mock 데이터 반환
  final petIndex = petId.hashCode % 3; // 3가지 패턴

  switch (petIndex) {
    case 0:
      return DailyHealthRecord(
        id: 'mock-record-$petId',
        petId: petId,
        date: DateTime.now(),
        temperature: 37.5,
        overallHealth: HealthStatus.good,
        symptoms: ['食欲不振'],
        notes: 'いつもより少し食欲がありません',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    case 1:
      return DailyHealthRecord(
        id: 'mock-record-$petId',
        petId: petId,
        date: DateTime.now(),
        temperature: 38.2,
        overallHealth: HealthStatus.fair,
        symptoms: ['発熱', '元気がない'],
        notes: '少し熱があるようです。注意深く観察が必要です。',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    default:
      return DailyHealthRecord(
        id: 'mock-record-$petId',
        petId: petId,
        date: DateTime.now(),
        temperature: 36.8,
        overallHealth: HealthStatus.excellent,
        symptoms: [],
        notes: '非常に元気で健康的です！',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
  }
}

/// 특정 펫의 건강 분석 Provider
@riverpod
Future<HealthAnalysis?> dailyHealthAnalysis(
  DailyHealthAnalysisRef ref,
  String petId,
) async {
  // TODO: 실제 API 호출로 교체
  await Future.delayed(const Duration(milliseconds: 500));

  // petId에 따른 다른 Mock 데이터 반환
  final petIndex = petId.hashCode % 3; // 3가지 패턴

  switch (petIndex) {
    case 0:
      return HealthAnalysis(
        id: 'mock-analysis-$petId',
        petId: petId,
        recordId: 'mock-record-$petId',
        riskLevel: RiskLevel.low,
        recommendations: [
          '定期的な運動を心がけてください',
          'バランスの取れた食事を与えてください',
          '十分な水分補給を確保してください',
        ],
        warnings: ['食欲不振が続く場合は獣医に相談してください'],
        summary: '軽微な食欲不振が見られますが、全体的に健康です。',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    case 1:
      return HealthAnalysis(
        id: 'mock-analysis-$petId',
        petId: petId,
        recordId: 'mock-record-$petId',
        riskLevel: RiskLevel.medium,
        recommendations: [
          '発熱のため安静にしてください',
          '水分補給を十分に行ってください',
          '24時間以内に獣医に相談することをお勧めします',
        ],
        warnings: [
          '体温が正常より高めです',
          '元気がない症状が見られます',
        ],
        summary: '発熱と元気がない症状があります。早めの獣医診断をお勧めします。',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    default:
      return HealthAnalysis(
        id: 'mock-analysis-$petId',
        petId: petId,
        recordId: 'mock-record-$petId',
        riskLevel: RiskLevel.low,
        recommendations: [
          '現在の健康管理を継続してください',
          '定期的な運動を維持してください',
          '栄養バランスの良い食事を続けてください',
        ],
        warnings: [],
        summary: '非常に良好な健康状態です。現在のケアを継続してください。',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
  }
}
