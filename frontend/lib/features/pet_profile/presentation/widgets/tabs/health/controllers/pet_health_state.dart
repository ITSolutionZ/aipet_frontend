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

/// 예방접종 히스토리 (각 접종 회차 기록)
class VaccinationHistory {
  final String id;
  final int round; // 회차 (1차, 2차 등)
  final DateTime date; // 접종일
  final String? memo; // 메모

  const VaccinationHistory({
    required this.id,
    required this.round,
    required this.date,
    this.memo,
  });

  VaccinationHistory copyWith({
    String? id,
    int? round,
    DateTime? date,
    String? memo,
  }) {
    return VaccinationHistory(
      id: id ?? this.id,
      round: round ?? this.round,
      date: date ?? this.date,
      memo: memo ?? this.memo,
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round': round,
      'date': date.toIso8601String(),
      'memo': memo,
    };
  }

  /// Map에서 생성
  factory VaccinationHistory.fromMap(Map<String, dynamic> map) {
    return VaccinationHistory(
      id: map['id'] as String? ?? '',
      round: map['round'] as int? ?? 1,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      memo: map['memo'] as String?,
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
  final List<VaccinationHistory> history; // 접종 히스토리

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.status,
    this.lastDate,
    this.nextDate,
    required this.iconName,
    required this.colorName,
    this.history = const [],
  });

  VaccinationRecord copyWith({
    String? id,
    String? name,
    String? status,
    DateTime? lastDate,
    DateTime? nextDate,
    String? iconName,
    String? colorName,
    List<VaccinationHistory>? history,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      lastDate: lastDate ?? this.lastDate,
      nextDate: nextDate ?? this.nextDate,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
      history: history ?? this.history,
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
      'history': history.map((h) => h.toMap()).toList(),
    };
  }

  /// Map에서 생성
  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    final historyData = map['history'] as List<dynamic>?;
    final historyList = historyData
            ?.map((e) => VaccinationHistory.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

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
      history: historyList,
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
