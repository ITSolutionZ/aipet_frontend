/// 산책 Mock 서비스
///
/// 산책 관련 Mock 데이터를 제공합니다.
class WalkMockService {
  /// Mock 산책 기록 반환
  static List<Map<String, dynamic>> getMockWalkRecords() {
    return [
      {
        'id': 'walk-1',
        'petId': 'pet-1',
        'startTime': DateTime.now().subtract(const Duration(hours: 2)),
        'endTime': DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        'distance': 2.5,
        'duration': const Duration(minutes: 30),
        'route': '公園コース',
        'notes': '良い天気で楽しい散歩でした',
        'weather': 'sunny',
        'temperature': 22.0,
      },
      {
        'id': 'walk-2',
        'petId': 'pet-1',
        'startTime': DateTime.now().subtract(const Duration(days: 1)),
        'endTime': DateTime.now().subtract(const Duration(days: 1, hours: -1)),
        'distance': 1.8,
        'duration': const Duration(minutes: 25),
        'route': '近所コース',
        'notes': '短い散歩',
        'weather': 'cloudy',
        'temperature': 18.0,
      },
    ];
  }

  /// Mock 산책 통계 반환
  static Map<String, dynamic> getMockWalkStatistics() {
    return {
      'totalWalks': 15,
      'totalDistance': 45.2,
      'totalDuration': const Duration(hours: 8, minutes: 30),
      'averageDistance': 3.0,
      'averageDuration': const Duration(minutes: 34),
      'longestWalk': 5.2,
      'shortestWalk': 1.2,
      'weeklyStats': {'thisWeek': 4, 'lastWeek': 5},
      'monthlyStats': {'thisMonth': 18, 'lastMonth': 16},
    };
  }
}
