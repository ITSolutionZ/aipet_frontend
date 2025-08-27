/// 백신 접종 기록 도메인 엔티티
///
/// 펫의 백신 접종 기록을 관리하는 도메인 엔티티입니다.
class VaccineRecordEntity {
  final String id;
  final String name;
  final DateTime date;
  final String doctor;
  final String? lot;
  final DateTime? expiryDate;
  final DateTime? validUntil;
  final String? notes;

  const VaccineRecordEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.doctor,
    this.lot,
    this.expiryDate,
    this.validUntil,
    this.notes,
  });

  VaccineRecordEntity copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? doctor,
    String? lot,
    DateTime? expiryDate,
    DateTime? validUntil,
    String? notes,
  }) {
    return VaccineRecordEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      doctor: doctor ?? this.doctor,
      lot: lot ?? this.lot,
      expiryDate: expiryDate ?? this.expiryDate,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
    );
  }

  /// 백신이 아직 유효한지 확인
  bool get isValid {
    if (validUntil == null) return true;
    return DateTime.now().isBefore(validUntil!);
  }

  /// 백신이 곧 만료되는지 확인 (30일 이내)
  bool get isExpiringSoon {
    if (validUntil == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = validUntil!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  /// 백신이 만료되었는지 확인
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// 접종 후 경과 일수
  int get daysSinceVaccination {
    final now = DateTime.now();
    return now.difference(date).inDays;
  }

  /// 유효 기간까지 남은 일수 (음수면 만료)
  int? get daysUntilExpiry {
    if (validUntil == null) return null;
    final now = DateTime.now();
    return validUntil!.difference(now).inDays;
  }

  /// 백신 상태 (valid, expiring, expired)
  VaccineStatus get status {
    if (isExpired) return VaccineStatus.expired;
    if (isExpiringSoon) return VaccineStatus.expiring;
    return VaccineStatus.valid;
  }

  /// 백신이 최근에 접종되었는지 확인 (30일 이내)
  bool get isRecentlyAdministered {
    final daysSince = daysSinceVaccination;
    return daysSince <= 30;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineRecordEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          date == other.date &&
          doctor == other.doctor &&
          lot == other.lot &&
          expiryDate == other.expiryDate &&
          validUntil == other.validUntil &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      date.hashCode ^
      doctor.hashCode ^
      lot.hashCode ^
      expiryDate.hashCode ^
      validUntil.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'VaccineRecordEntity(id: $id, name: $name, date: $date, doctor: $doctor, status: $status)';
  }
}

/// 백신 상태 열거형
enum VaccineStatus { valid, expiring, expired }
