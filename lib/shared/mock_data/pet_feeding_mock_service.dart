/// 펫 급식 Mock 서비스
///
/// 펫 급식 관련 Mock 데이터를 제공합니다.
class PetFeedingMockService {
  /// Mock 급식 기록 반환
  static List<Map<String, dynamic>> getMockFeedingRecords() {
    return [
      {
        'id': 'feeding-1',
        'petId': 'pet-1',
        'amount': 100.0,
        'foodType': 'ドライフード',
        'feedingTime': DateTime.now().subtract(const Duration(hours: 6)),
        'notes': '通常の給餌',
        'scheduleId': 'schedule-1',
      },
      {
        'id': 'feeding-2',
        'petId': 'pet-1',
        'amount': 80.0,
        'foodType': 'ウェットフード',
        'feedingTime': DateTime.now().subtract(const Duration(days: 1)),
        'notes': 'おやつとして少量',
        'scheduleId': 'schedule-1',
      },
    ];
  }

  /// Mock 급식 스케줄 반환
  static List<Map<String, dynamic>> getMockFeedingSchedules() {
    return [
      {
        'id': 'schedule-1',
        'petId': 'pet-1',
        'name': '基本スケジュール',
        'times': ['08:00', '18:00'],
        'amounts': [100.0, 100.0],
        'foodTypes': ['ドライフード', 'ドライフード'],
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      },
    ];
  }
}
