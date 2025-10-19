import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_analysis.freezed.dart';
part 'health_analysis.g.dart';

/// 위험도 레벨 열거형
enum RiskLevel {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

/// 건강 분석 엔티티
@freezed
abstract class HealthAnalysis with _$HealthAnalysis {
  const factory HealthAnalysis({
    required String id,
    required String petId,
    required String recordId,
    required RiskLevel riskLevel,
    required List<String> recommendations,
    @Default([]) List<String> warnings,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _HealthAnalysis;

  const HealthAnalysis._();

  factory HealthAnalysis.fromJson(Map<String, dynamic> json) =>
      _$HealthAnalysisFromJson(json);
}
