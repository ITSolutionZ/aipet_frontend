import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_analysis.freezed.dart';
part 'health_analysis.g.dart';

@freezed
class HealthAnalysis with _$HealthAnalysis {
  const factory HealthAnalysis({
    required String id,
    required String petId,
    required String recordId,
    required AnalysisResult result,
    required List<HealthRecommendation> recommendations,
    required List<WarningSign> warnings,
    required DateTime analysisDate,
    String? aiComment,
  }) = _HealthAnalysis;

  factory HealthAnalysis.fromJson(Map<String, dynamic> json) =>
      _$HealthAnalysisFromJson(json);
}

@freezed
class AnalysisResult with _$AnalysisResult {
  const factory AnalysisResult({
    required HealthRiskLevel riskLevel,
    required String summary,
    required double confidenceScore,
    required List<String> detectedIssues,
  }) = _AnalysisResult;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);
}

@freezed
class HealthRecommendation with _$HealthRecommendation {
  const factory HealthRecommendation({
    required String id,
    required String title,
    required String description,
    required RecommendationType type,
    required int priority,
  }) = _HealthRecommendation;

  factory HealthRecommendation.fromJson(Map<String, dynamic> json) =>
      _$HealthRecommendationFromJson(json);
}

@freezed
class WarningSign with _$WarningSign {
  const factory WarningSign({
    required String symptom,
    required String description,
    required WarningLevel level,
    required bool requiresVeterinaryVisit,
  }) = _WarningSign;

  factory WarningSign.fromJson(Map<String, dynamic> json) =>
      _$WarningSignFromJson(json);
}

enum HealthRiskLevel {
  @JsonValue('low')
  low('low', '낮음', '건강 상태가 양호합니다'),
  @JsonValue('medium')
  medium('medium', '보통', '주의가 필요합니다'),
  @JsonValue('high')
  high('high', '높음', '병원 방문을 권장합니다'),
  @JsonValue('critical')
  critical('critical', '위험', '즉시 병원에 가세요');

  const HealthRiskLevel(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;
}

enum RecommendationType {
  @JsonValue('diet')
  diet('diet', '식단'),
  @JsonValue('exercise')
  exercise('exercise', '운동'),
  @JsonValue('medication')
  medication('medication', '약물'),
  @JsonValue('monitoring')
  monitoring('monitoring', '관찰'),
  @JsonValue('veterinary')
  veterinary('veterinary', '병원 방문');

  const RecommendationType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum WarningLevel {
  @JsonValue('info')
  info('info', '정보'),
  @JsonValue('warning')
  warning('warning', '주의'),
  @JsonValue('urgent')
  urgent('urgent', '긴급');

  const WarningLevel(this.value, this.displayName);
  final String value;
  final String displayName;
}