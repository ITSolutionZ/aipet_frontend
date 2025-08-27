import '../../domain/entities/schedule_entity.dart';

/// 스케줄 모델 (데이터 레이어)
class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.title,
    super.description,
    required super.startDateTime,
    super.endDateTime,
    super.duration,
    required super.type,
    super.status = ScheduleStatus.pending,
    super.priority = SchedulePriority.normal,
    required super.petId,
    required super.petName,
    super.petImagePath,
    super.location,
    super.latitude,
    super.longitude,
    super.facilityId,
    super.facilityName,
    super.staffName,
    super.staffPhone,
    super.price,
    super.services,
    super.hasReminder = false,
    super.reminderTime,
    super.reminderTimes,
    super.isRecurring = false,
    super.recurrenceRule,
    super.notes,
    super.specialRequests,
    super.customData,
    required super.createdAt,
    super.updatedAt,
  });

  /// JSON에서 모델 생성
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScheduleType.custom,
      ),
      status: ScheduleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScheduleStatus.pending,
      ),
      priority: SchedulePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => SchedulePriority.normal,
      ),
      petId: json['petId'] as String,
      petName: json['petName'] as String,
      petImagePath: json['petImagePath'] as String?,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      facilityId: json['facilityId'] as String?,
      facilityName: json['facilityName'] as String?,
      staffName: json['staffName'] as String?,
      staffPhone: json['staffPhone'] as String?,
      price: json['price'] as double?,
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : null,
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderTime: json['reminderTime'] != null
          ? Duration(minutes: json['reminderTime'] as int)
          : null,
      reminderTimes: json['reminderTimes'] != null
          ? (json['reminderTimes'] as List)
                .map((e) => Duration(minutes: e as int))
                .toList()
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrenceRule: json['recurrenceRule'] as String?,
      notes: json['notes'] as String?,
      specialRequests: json['specialRequests'] as String?,
      customData: json['customData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'duration': duration?.inMinutes,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'petId': petId,
      'petName': petName,
      'petImagePath': petImagePath,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'staffName': staffName,
      'staffPhone': staffPhone,
      'price': price,
      'services': services,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.inMinutes,
      'reminderTimes': reminderTimes?.map((e) => e.inMinutes).toList(),
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'notes': notes,
      'specialRequests': specialRequests,
      'customData': customData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 엔티티로 변환
  ScheduleEntity toEntity() {
    return this;
  }

  /// 엔티티에서 모델 생성
  factory ScheduleModel.fromEntity(ScheduleEntity entity) {
    return ScheduleModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      duration: entity.duration,
      type: entity.type,
      status: entity.status,
      priority: entity.priority,
      petId: entity.petId,
      petName: entity.petName,
      petImagePath: entity.petImagePath,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      facilityId: entity.facilityId,
      facilityName: entity.facilityName,
      staffName: entity.staffName,
      staffPhone: entity.staffPhone,
      price: entity.price,
      services: entity.services,
      hasReminder: entity.hasReminder,
      reminderTime: entity.reminderTime,
      reminderTimes: entity.reminderTimes,
      isRecurring: entity.isRecurring,
      recurrenceRule: entity.recurrenceRule,
      notes: entity.notes,
      specialRequests: entity.specialRequests,
      customData: entity.customData,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
