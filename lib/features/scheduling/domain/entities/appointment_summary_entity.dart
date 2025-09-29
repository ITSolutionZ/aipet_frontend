/// 약속 요약 엔티티
class AppointmentSummary {
  final String id;
  final String title;
  final String petName;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime scheduledTime;
  final String type;
  final String status;
  final String? location;
  final String? description;

  const AppointmentSummary({
    required this.id,
    required this.title,
    required this.petName,
    required this.startTime,
    required this.endTime,
    required this.scheduledTime,
    required this.type,
    required this.status,
    this.location,
    this.description,
  });

  /// JSON에서 변환
  factory AppointmentSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      petName: json['petName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      type: json['type'] as String,
      status: json['status'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'petName': petName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'type': type,
      'status': status,
      'location': location,
      'description': description,
    };
  }

  /// 복사본 생성
  AppointmentSummary copyWith({
    String? id,
    String? title,
    String? petName,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? scheduledTime,
    String? type,
    String? status,
    String? location,
    String? description,
  }) {
    return AppointmentSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      petName: petName ?? this.petName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }
}
