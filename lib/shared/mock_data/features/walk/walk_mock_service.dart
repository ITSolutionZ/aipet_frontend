import '../../core/base_mock_service.dart';

/// Walk Feature 전용 Mock 데이터 서비스
class WalkMockService extends BaseMockService {
  static bool isEnabled = true;

  // ==================== 산책 기록 데이터 ====================

  /// Mock 산책 기록 목록
  static List<Map<String, dynamic>> getMockWalkRecords() {
    return [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'petName': 'ぺっと１',
        'startTime': DateTime.now().subtract(const Duration(hours: 2)),
        'endTime': DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        'duration': const Duration(minutes: 30),
        'distance': 2.1, // km
        'steps': 2800,
        'calories': 150,
        'route': '한강공원',
        'weather': '맑음',
        'notes': '활발하게 뛰어다님',
        'photos': ['walk1.jpg', 'walk2.jpg'],
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'startTime': DateTime.now().subtract(
          const Duration(days: 1, hours: 10),
        ),
        'endTime': DateTime.now().subtract(
          const Duration(days: 1, hours: 9, minutes: 45),
        ),
        'duration': const Duration(minutes: 15),
        'distance': 0.8,
        'steps': 1200,
        'calories': 60,
        'route': '아파트 단지',
        'weather': '흐림',
        'notes': '짧은 산책',
        'photos': [],
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'startTime': DateTime.now().subtract(const Duration(hours: 4)),
        'endTime': DateTime.now().subtract(
          const Duration(hours: 3, minutes: 45),
        ),
        'duration': const Duration(minutes: 15),
        'distance': 0.5,
        'steps': 800,
        'calories': 40,
        'route': '근처 공원',
        'weather': '맑음',
        'notes': '차분한 산책',
        'photos': ['luna_walk1.jpg'],
      },
    ];
  }

  /// 펫별 산책 기록 조회
  static List<Map<String, dynamic>> getMockWalkRecordsByPet(String petId) {
    final allRecords = getMockWalkRecords();
    return allRecords.where((record) => record['petId'] == petId).toList();
  }

  /// 오늘의 산책 통계
  static Map<String, dynamic> getMockTodayWalkStats({String? petId}) {
    final todayRecords = getMockWalkRecords()
        .where((record) => _isToday(record['startTime']))
        .where((record) => petId == null || record['petId'] == petId)
        .toList();

    final totalDistance = todayRecords.fold<double>(
      0.0,
      (sum, record) => sum + (record['distance'] as double),
    );

    final totalDuration = todayRecords.fold<int>(
      0,
      (sum, record) => sum + (record['duration'] as Duration).inMinutes,
    );

    return {
      'walks': todayRecords.length,
      'totalDistance': totalDistance,
      'totalDuration': Duration(minutes: totalDuration),
      'totalCalories': todayRecords.fold<int>(
        0,
        (sum, record) => sum + (record['calories'] as int),
      ),
      'averageSpeed': totalDistance > 0 && totalDuration > 0
          ? (totalDistance / (totalDuration / 60.0)).toStringAsFixed(1)
          : '0.0',
    };
  }

  /// 주간 산책 통계
  static Map<String, dynamic> getMockWeeklyWalkStats({String? petId}) {
    final weekRecords = getMockWalkRecords()
        .where((record) => _isThisWeek(record['startTime']))
        .where((record) => petId == null || record['petId'] == petId)
        .toList();

    return {
      'totalWalks': weekRecords.length,
      'totalDistance': weekRecords.fold<double>(
        0.0,
        (sum, record) => sum + (record['distance'] as double),
      ),
      'totalTime': Duration(
        minutes: weekRecords.fold<int>(
          0,
          (sum, record) => sum + (record['duration'] as Duration).inMinutes,
        ),
      ),
      'averageDistance': weekRecords.isNotEmpty
          ? (weekRecords.fold<double>(
                      0.0,
                      (sum, record) => sum + (record['distance'] as double),
                    ) /
                    weekRecords.length)
                .toStringAsFixed(1)
          : '0.0',
      'dailyGoal': 2.0, // km
      'goalAchieved':
          weekRecords.fold<double>(
            0.0,
            (sum, record) => sum + (record['distance'] as double),
          ) >=
          14.0, // 주간 목표 14km
    };
  }

  /// 산책 루트 추천
  static List<Map<String, dynamic>> getMockWalkRouteRecommendations({
    String? petId,
  }) {
    return [
      {
        'id': '1',
        'name': '한강공원 산책로',
        'distance': 3.2,
        'estimatedTime': 45, // 분
        'difficulty': 'easy',
        'rating': 4.8,
        'features': ['강변', '넓은 공간', '다른 강아지들'],
        'imageUrl': 'assets/images/routes/hangang.jpg',
      },
      {
        'id': '2',
        'name': '올림픽공원',
        'distance': 2.1,
        'estimatedTime': 30,
        'difficulty': 'moderate',
        'rating': 4.6,
        'features': ['언덕', '숲길', '조용함'],
        'imageUrl': 'assets/images/routes/olympic.jpg',
      },
      {
        'id': '3',
        'name': '근린공원 둘레길',
        'distance': 1.5,
        'estimatedTime': 20,
        'difficulty': 'easy',
        'rating': 4.3,
        'features': ['가까움', '안전함', '초보자용'],
        'imageUrl': 'assets/images/routes/local.jpg',
      },
    ];
  }

  // ==================== 헬퍼 메소드들 ====================

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}
