/// 펫 몸무게 기록 엔티티
class WeightRecordEntity {
  final String id;
  final String petId;
  final String petName;
  final DateTime recordedDate;
  final double weight; // kg 단위
  final String? notes; // 메모
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WeightRecordEntity({
    required this.id,
    required this.petId,
    required this.petName,
    required this.recordedDate,
    required this.weight,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  WeightRecordEntity copyWith({
    String? id,
    String? petId,
    String? petName,
    DateTime? recordedDate,
    double? weight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightRecordEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      recordedDate: recordedDate ?? this.recordedDate,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 몸무게 통계 정보
class WeightStatistics {
  final double currentWeight;
  final double? previousWeight;
  final double? weightChange; // 이전 대비 변화량
  final double? weightChangePercentage; // 변화율
  final double? averageWeight; // 평균 몸무게
  final double? minWeight; // 최소 몸무게
  final double? maxWeight; // 최대 몸무게
  final int totalRecords; // 총 기록 수
  final DateTime? firstRecordDate; // 첫 기록 날짜
  final DateTime? lastRecordDate; // 마지막 기록 날짜

  // 작년 대비 데이터
  final double? lastYearWeight; // 작년 동일 시기 몸무게
  final double? yearOverYearChange; // 작년 대비 변화량
  final double? yearOverYearChangePercentage; // 작년 대비 변화율

  const WeightStatistics({
    required this.currentWeight,
    this.previousWeight,
    this.weightChange,
    this.weightChangePercentage,
    this.averageWeight,
    this.minWeight,
    this.maxWeight,
    required this.totalRecords,
    this.firstRecordDate,
    this.lastRecordDate,
    this.lastYearWeight,
    this.yearOverYearChange,
    this.yearOverYearChangePercentage,
  });

  /// 체중 변화 상태
  WeightChangeStatus get changeStatus {
    if (weightChange == null) return WeightChangeStatus.noChange;
    if (weightChange! > 0.5) return WeightChangeStatus.increased;
    if (weightChange! < -0.5) return WeightChangeStatus.decreased;
    return WeightChangeStatus.stable;
  }
}

/// 체중 변화 상태
enum WeightChangeStatus {
  increased, // 증가
  decreased, // 감소
  stable, // 안정
  noChange, // 변화 없음
}
