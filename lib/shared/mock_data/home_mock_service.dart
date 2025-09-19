/// 홈 Mock 서비스
///
/// 홈 화면 관련 Mock 데이터를 제공합니다.
class HomeMockService {
  /// Mock 급식 요약 데이터 반환
  static Map<String, dynamic> getMockFeedingSummary() {
    return {
      'todayFeedings': 2,
      'nextFeedingTime': DateTime.now().add(const Duration(hours: 2)),
      'lastFeedingAmount': 100.0,
      'totalDailyAmount': 200.0,
      'recommendedAmount': 250.0,
    };
  }

  /// Mock 약속 요약 데이터 반환
  static Map<String, dynamic> getMockAppointmentSummary() {
    return {
      'todayAppointments': 1,
      'nextAppointment': {
        'id': 'appointment-1',
        'title': '獣医師診察',
        'time': DateTime.now().add(const Duration(hours: 3)),
        'location': 'ペットクリニック',
        'petName': 'Maxi',
      },
      'upcomingAppointments': 3,
    };
  }

  /// Mock 산책 요약 데이터 반환
  static Map<String, dynamic> getMockWalkSummary() {
    return {
      'todayWalks': 2,
      'totalDistance': 3.5,
      'totalDuration': const Duration(minutes: 45),
      'lastWalkTime': DateTime.now().subtract(const Duration(hours: 2)),
      'nextWalkTime': DateTime.now().add(const Duration(hours: 4)),
    };
  }

  /// Mock 펫 프로필 데이터 반환
  static Map<String, dynamic> getMockPetProfile() {
    return {
      'id': 'pet-1',
      'name': 'Maxi',
      'type': 'dog',
      'breed': '柴犬',
      'age': 3,
      'weight': 15.5,
      'profileImage': 'assets/images/dogs/shiba.png',
      'healthStatus': 'good',
      'lastVetVisit': DateTime.now().subtract(const Duration(days: 30)),
    };
  }

  /// Mock 오늘 식사 데이터 반환
  static Map<String, dynamic> getMockTodayMeals() {
    return {
      'completedMeals': 2,
      'totalMeals': 3,
      'nextMealTime': DateTime.now().add(const Duration(hours: 2)),
      'nextMealType': '夕食',
    };
  }

  /// Mock 다음 식사 정보 반환
  static Map<String, dynamic> getMockNextMealInfo() {
    return {
      'time': DateTime.now().add(const Duration(hours: 2)),
      'type': '夕食',
      'description': 'ドライフード + ウェットフード',
    };
  }

  /// Mock 예상 칼로리 반환
  static Map<String, dynamic> getMockExpectedCalories() {
    return {'daily': 800, 'consumed': 520, 'remaining': 280};
  }

  /// Mock 다음 예약 타입 반환
  static String getMockNextAppointmentType() {
    return '健康診断';
  }

  /// Mock 다음 산책 시간 반환
  static DateTime getMockNextWalkTime() {
    return DateTime.now().add(const Duration(hours: 1));
  }

  /// Mock 펫 활동 데이터 반환
  static List<Map<String, dynamic>> getMockPetActivities() {
    return [
      {
        'id': 'activity-1',
        'type': 'walk',
        'title': '朝の散歩',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'duration': 30,
      },
      {
        'id': 'activity-2',
        'type': 'feeding',
        'title': '朝食',
        'time': DateTime.now().subtract(const Duration(hours: 4)),
        'duration': 10,
      },
    ];
  }
}
