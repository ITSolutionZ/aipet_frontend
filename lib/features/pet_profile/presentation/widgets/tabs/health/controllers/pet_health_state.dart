/// Pet Health Tab 상태 클래스
///
/// 건강 정보 편집 상태를 관리합니다.
class PetHealthState {
  // 예방접종 기록 리스트
  final List<VaccinationRecord> vaccinationRecords;

  // 진료 기록 리스트
  final List<MedicalRecord> medicalRecords;

  // 예약/스케줄 리스트
  final List<AppointmentRecord> appointments;

  // 체중 정보
  final double? currentWeight;
  final double? idealWeight;

  const PetHealthState({
    this.vaccinationRecords = const [],
    this.medicalRecords = const [],
    this.appointments = const [],
    this.currentWeight,
    this.idealWeight,
  });

  PetHealthState copyWith({
    List<VaccinationRecord>? vaccinationRecords,
    List<MedicalRecord>? medicalRecords,
    List<AppointmentRecord>? appointments,
    double? currentWeight,
    double? idealWeight,
  }) {
    return PetHealthState(
      vaccinationRecords: vaccinationRecords ?? this.vaccinationRecords,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      appointments: appointments ?? this.appointments,
      currentWeight: currentWeight ?? this.currentWeight,
      idealWeight: idealWeight ?? this.idealWeight,
    );
  }
}

/// 예방접종 기록
class VaccinationRecord {
  final String id;
  final String name; // コアワクチン, 狂犬病予防接種 등
  final String status; // 完了, 接種中, 期限切れ
  final DateTime? lastDate;
  final DateTime? nextDate;
  final String iconName; // vaccines, healing, bug_report
  final String colorName; // green, blue, pink

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.status,
    this.lastDate,
    this.nextDate,
    required this.iconName,
    required this.colorName,
  });

  VaccinationRecord copyWith({
    String? id,
    String? name,
    String? status,
    DateTime? lastDate,
    DateTime? nextDate,
    String? iconName,
    String? colorName,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      lastDate: lastDate ?? this.lastDate,
      nextDate: nextDate ?? this.nextDate,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'lastDate': lastDate?.toIso8601String(),
      'nextDate': nextDate?.toIso8601String(),
      'iconName': iconName,
      'colorName': colorName,
    };
  }

  /// Map에서 생성
  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      status: map['status'] as String? ?? '',
      lastDate: map['lastDate'] != null
          ? DateTime.tryParse(map['lastDate'] as String)
          : null,
      nextDate: map['nextDate'] != null
          ? DateTime.tryParse(map['nextDate'] as String)
          : null,
      iconName: map['iconName'] as String? ?? 'vaccines',
      colorName: map['colorName'] as String? ?? 'green',
    );
  }
}

/// 진료 기록
class MedicalRecord {
  final String id;
  final String title; // 定期健康診断, デンタルケア 등
  final DateTime date;
  final String hospital; // 病院名
  final String status; // 正常, 完了 등
  final String iconName; // local_hospital, cleaning_services
  final String colorName; // pink, blue

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.hospital,
    required this.status,
    required this.iconName,
    required this.colorName,
  });

  MedicalRecord copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? hospital,
    String? status,
    String? iconName,
    String? colorName,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      hospital: hospital ?? this.hospital,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'hospital': hospital,
      'status': status,
      'iconName': iconName,
      'colorName': colorName,
    };
  }

  /// Map에서 생성
  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      hospital: map['hospital'] as String? ?? '',
      status: map['status'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'local_hospital',
      colorName: map['colorName'] as String? ?? 'pink',
    );
  }
}

/// 예약/스케줄
class AppointmentRecord {
  final String id;
  final String title; // 次回健康診断, グルーミング 등
  final DateTime dateTime;
  final String location; // 田中動物病院, ペットサロン花 등
  final String status; // 予約済み
  final String iconName; // schedule, content_cut
  final String colorName; // blue, pink

  const AppointmentRecord({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.iconName,
    required this.colorName,
  });

  AppointmentRecord copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? location,
    String? status,
    String? iconName,
    String? colorName,
  }) {
    return AppointmentRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'status': status,
      'iconName': iconName,
      'colorName': colorName,
    };
  }

  /// Map에서 생성
  factory AppointmentRecord.fromMap(Map<String, dynamic> map) {
    return AppointmentRecord(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      dateTime: DateTime.tryParse(map['dateTime'] as String? ?? '') ??
          DateTime.now(),
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'schedule',
      colorName: map['colorName'] as String? ?? 'blue',
    );
  }
}
