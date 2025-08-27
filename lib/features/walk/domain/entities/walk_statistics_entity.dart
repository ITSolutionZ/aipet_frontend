/// 산책 통계 엔티티
class WalkStatistics {
  final int totalWalks;
  final double totalDistance;
  final Duration totalDuration;
  final double averageDistance;
  final Duration averageDuration;
  final DateTime? lastWalkDate;

  const WalkStatistics({
    required this.totalWalks,
    required this.totalDistance,
    required this.totalDuration,
    required this.averageDistance,
    required this.averageDuration,
    this.lastWalkDate,
  });

  /// 빈 통계 생성
  factory WalkStatistics.empty() {
    return const WalkStatistics(
      totalWalks: 0,
      totalDistance: 0.0,
      totalDuration: Duration.zero,
      averageDistance: 0.0,
      averageDuration: Duration.zero,
    );
  }

  /// 복사본 생성
  WalkStatistics copyWith({
    int? totalWalks,
    double? totalDistance,
    Duration? totalDuration,
    double? averageDistance,
    Duration? averageDuration,
    DateTime? lastWalkDate,
  }) {
    return WalkStatistics(
      totalWalks: totalWalks ?? this.totalWalks,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      averageDistance: averageDistance ?? this.averageDistance,
      averageDuration: averageDuration ?? this.averageDuration,
      lastWalkDate: lastWalkDate ?? this.lastWalkDate,
    );
  }

  @override
  String toString() {
    return 'WalkStatistics(totalWalks: $totalWalks, totalDistance: $totalDistance, totalDuration: $totalDuration, averageDistance: $averageDistance, averageDuration: $averageDuration, lastWalkDate: $lastWalkDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalkStatistics &&
        other.totalWalks == totalWalks &&
        other.totalDistance == totalDistance &&
        other.totalDuration == totalDuration &&
        other.averageDistance == averageDistance &&
        other.averageDuration == averageDuration &&
        other.lastWalkDate == lastWalkDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalWalks,
      totalDistance,
      totalDuration,
      averageDistance,
      averageDuration,
      lastWalkDate,
    );
  }
}
