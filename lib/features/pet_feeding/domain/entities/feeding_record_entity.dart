/// 급여 기록 엔티티
class FeedingRecordEntity {
  final String id;
  final String petId;
  final String petName;
  final DateTime fedTime; // 실제 급여 시간
  final double amount; // 급여량 (g)
  final String foodType; // 사료 종류
  final String foodBrand; // 사료 브랜드
  final FeedingStatus status; // 급여 상태
  final String? notes; // 급여 기록 메모
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeedingRecordEntity({
    required this.id,
    required this.petId,
    required this.petName,
    required this.fedTime,
    required this.amount,
    required this.foodType,
    required this.foodBrand,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  FeedingRecordEntity copyWith({
    String? id,
    String? petId,
    String? petName,
    DateTime? fedTime,
    double? amount,
    String? foodType,
    String? foodBrand,
    FeedingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedingRecordEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      fedTime: fedTime ?? this.fedTime,
      amount: amount ?? this.amount,
      foodType: foodType ?? this.foodType,
      foodBrand: foodBrand ?? this.foodBrand,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 급여 상태
enum FeedingStatus {
  completed, // 완료
  skipped, // 건너뜀
  partial, // 부분 급여
}

/// 급여 통계
class FeedingStatistics {
  final int totalFeedings; // 총 급여 횟수
  final int completedFeedings; // 완료된 급여 횟수
  final int skippedFeedings; // 건너뛴 급여 횟수
  final double totalAmount; // 총 급여량
  final double averageAmount; // 평균 급여량
  final double completionRate; // 급여 완료율
  final Map<String, int> feedingsByHour; // 시간대별 급여 횟수

  const FeedingStatistics({
    required this.totalFeedings,
    required this.completedFeedings,
    required this.skippedFeedings,
    required this.totalAmount,
    required this.averageAmount,
    required this.completionRate,
    required this.feedingsByHour,
  });
}
