import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/daily_health_repository_impl.dart';
import '../entities/daily_health_record.dart';
import '../entities/health_analysis.dart';
import '../repositories/daily_health_repository.dart';

part 'analyze_health_usecase.g.dart';

/// 건강 분석 Use Case
class AnalyzeHealthUseCase {
  final DailyHealthRepository _repository;

  const AnalyzeHealthUseCase(this._repository);

  /// 건강 기록을 분석하여 건강 분석 결과 생성
  Future<HealthAnalysis> analyzeRecord(DailyHealthRecord record) async {
    return _repository.analyzeHealthRecord(record);
  }

  /// 특정 펫의 건강 분석 히스토리 조회
  Future<List<HealthAnalysis>> getAnalysisHistory(String petId) async {
    return _repository.getHealthAnalysisHistory(petId);
  }

  /// 건강 위험도 평가
  RiskLevel evaluateRiskLevel(DailyHealthRecord record) {
    // 비즈니스 로직: 체온과 증상을 기반으로 위험도 평가
    final temperature = record.temperature;
    final symptoms = record.symptoms;

    // 고위험 조건
    if (temperature != null && (temperature > 39.5 || temperature < 36.0)) {
      return RiskLevel.high;
    }

    // 중위험 조건
    if (temperature != null && (temperature > 38.5 || temperature < 36.5)) {
      return RiskLevel.medium;
    }

    if (symptoms.isNotEmpty) {
      final criticalSymptoms = ['발작', '의식불명', '호흡곤란', '심한출혈'];
      if (symptoms.any((symptom) => criticalSymptoms.contains(symptom))) {
        return RiskLevel.high;
      }

      final moderateSymptoms = ['발열', '구토', '설사', '식욕부진'];
      if (symptoms.any((symptom) => moderateSymptoms.contains(symptom))) {
        return RiskLevel.medium;
      }
    }

    return RiskLevel.low;
  }

  /// 건강 상태 기반 권장사항 생성
  List<String> generateRecommendations(DailyHealthRecord record) {
    final recommendations = <String>[];
    final temperature = record.temperature;
    final symptoms = record.symptoms;

    // 체온 기반 권장사항
    if (temperature != null) {
      if (temperature > 38.5) {
        recommendations.add('체온이 높습니다. 충분한 휴식과 수분 공급이 필요합니다.');
      } else if (temperature < 36.5) {
        recommendations.add('체온이 낮습니다. 따뜻한 환경을 유지해주세요.');
      } else {
        recommendations.add('정상 체온입니다. 현재 상태를 유지해주세요.');
      }
    }

    // 증상 기반 권장사항
    if (symptoms.isNotEmpty) {
      recommendations.add('증상이 지속되면 수의사와 상담하세요.');
    }

    // 기본 권장사항
    if (recommendations.isEmpty) {
      recommendations.addAll([
        '규칙적인 운동을 해주세요.',
        '균형 잡힌 식사를 제공해주세요.',
        '충분한 수분 섭취를 보장해주세요.',
      ]);
    }

    return recommendations;
  }
}

/// Use Case Provider
@riverpod
AnalyzeHealthUseCase analyzeHealthUseCase(AnalyzeHealthUseCaseRef ref) {
  final repository = ref.watch(dailyHealthRepositoryProvider);
  return AnalyzeHealthUseCase(repository);
}