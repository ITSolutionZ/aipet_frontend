import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_health_record.freezed.dart';
part 'daily_health_record.g.dart';

@freezed
class DailyHealthRecord with _$DailyHealthRecord {
  const factory DailyHealthRecord({
    required String id,
    required String petId,
    required DateTime date,
    required double temperature,
    required HealthStatus overallHealth,
    required List<HealthSymptom> symptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DailyHealthRecord;

  factory DailyHealthRecord.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthRecordFromJson(json);
}

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

enum HealthStatus {
  @JsonValue('excellent')
  excellent('excellent', '매우 좋음'),
  @JsonValue('good')
  good('good', '좋음'),
  @JsonValue('fair')
  fair('fair', '보통'),
  @JsonValue('poor')
  poor('poor', '나쁨'),
  @JsonValue('critical')
  critical('critical', '위험');

  const HealthStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum SymptomSeverity {
  @JsonValue('mild')
  mild('mild', '경미함'),
  @JsonValue('moderate')
  moderate('moderate', '보통'),
  @JsonValue('severe')
  severe('severe', '심각함');

  const SymptomSeverity(this.value, this.displayName);
  final String value;
  final String displayName;
}