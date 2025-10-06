import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_health_record.freezed.dart';
part 'daily_health_record.g.dart';

/// 건강 상태 열거형
enum HealthStatus {
  @JsonValue('excellent')
  excellent,
  @JsonValue('good')
  good,
  @JsonValue('fair')
  fair,
  @JsonValue('poor')
  poor,
  @JsonValue('critical')
  critical,
}

/// 증상 심각도 열거형
enum SymptomSeverity {
  @JsonValue('mild')
  mild,
  @JsonValue('moderate')
  moderate,
  @JsonValue('severe')
  severe,
}

/// 건강 증상 엔티티
@freezed
class HealthSymptom with _$HealthSymptom {
  const factory HealthSymptom({
    required String id,
    required String name,
    required SymptomSeverity severity,
    String? description,
  }) = _HealthSymptom;

  factory HealthSymptom.fromJson(Map<String, dynamic> json) =>
      _$HealthSymptomFromJson(json);
}

/// 일일 건강 기록 엔티티
@freezed
class DailyHealthRecord with _$DailyHealthRecord {
  const factory DailyHealthRecord({
    required String id,
    required String petId,
    required DateTime date,
    double? temperature,
    required HealthStatus overallHealth,
    @Default([]) List<String> symptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DailyHealthRecord;

  factory DailyHealthRecord.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthRecordFromJson(json);
}
