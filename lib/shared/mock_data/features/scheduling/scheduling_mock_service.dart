import '../../core/base_mock_service.dart';

/// Scheduling Feature 전용 Mock 데이터 서비스
class SchedulingMockService extends BaseMockService {
  
  // ==================== 스케줄링 데이터 ====================
  
  /// Mock 피딩 스케줄 목록
  static List<Map<String, dynamic>> getMockFeedingSchedules() {
    return [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'petName': 'MAX',
        'scheduleName': '아침 식사',
        'time': '08:00',
        'amount': '300g',
        'foodType': '건사료',
        'isActive': true,
        'repeatDays': [1, 2, 3, 4, 5, 6, 7], // 매일
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'petName': 'MAX',
        'scheduleName': '저녁 식사',
        'time': '18:00',
        'amount': '300g',
        'foodType': '건사료',
        'isActive': true,
        'repeatDays': [1, 2, 3, 4, 5, 6, 7],
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'petName': 'LUNA',
        'scheduleName': '아침 식사',
        'time': '08:30',
        'amount': '150g',
        'foodType': '습식사료',
        'isActive': true,
        'repeatDays': [1, 2, 3, 4, 5, 6, 7],
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }
  
  /// 펫별 피딩 스케줄 조회
  static List<Map<String, dynamic>> getMockFeedingSchedulesByPet(String petId) {
    final allSchedules = getMockFeedingSchedules();
    return allSchedules.where((schedule) => schedule['petId'] == petId).toList();
  }
  
  /// 오늘의 식사 일정 조회
  static List<Map<String, dynamic>> getMockTodayMealsForSchedule() {
    final now = DateTime.now();
    
    return [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'petName': 'MAX',
        'scheduleName': '아침 식사',
        'scheduledTime': DateTime(now.year, now.month, now.day, 8, 0),
        'actualTime': DateTime(now.year, now.month, now.day, 8, 15),
        'amount': '300g',
        'isCompleted': true,
        'isLate': true,
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'petName': 'MAX',
        'scheduleName': '저녁 식사',
        'scheduledTime': DateTime(now.year, now.month, now.day, 18, 0),
        'amount': '300g',
        'isCompleted': false,
        'isLate': false,
      },
    ];
  }
  
  // ==================== 급수 데이터 ====================
  
  /// Mock 급수 데이터
  static Map<String, dynamic> getMockWateringData() {
    return {
      'todayWater': 450, // ml
      'targetWater': 500,
      'lastRefillTime': DateTime.now().subtract(const Duration(hours: 3)),
      'refillHistory': [
        {
          'time': DateTime.now().subtract(const Duration(hours: 3)),
          'amount': 200,
          'bowlLevel': 'full',
        },
        {
          'time': DateTime.now().subtract(const Duration(hours: 8)),
          'amount': 150,
          'bowlLevel': 'half',
        },
      ],
      'weeklyAverage': 420,
      'tips': [
        '신선한 물을 매일 교체해주세요',
        '물그릇은 항상 청결하게 유지해주세요',
        '활동량이 많은 날에는 물 섭취량이 늘어날 수 있습니다',
      ],
    };
  }
  
  /// 펫별 급수 데이터 조회
  static Map<String, dynamic> getMockWateringDataByPet(String petId) {
    final baseData = getMockWateringData();
    
    // 펫별 맞춤 데이터
    switch (petId) {
      case '1': // MAX
        baseData['todayWater'] = 450;
        baseData['targetWater'] = 500;
        break;
      case '2': // LUNA
        baseData['todayWater'] = 280;
        baseData['targetWater'] = 300;
        break;
      case '3': // MOMO
        baseData['todayWater'] = 320;
        baseData['targetWater'] = 350;
        break;
    }
    
    return baseData;
  }
  
  // ==================== 트레이닝 데이터 ====================
  
  /// Mock 트레이닝 데이터
  static Map<String, dynamic> getMockTrainingData() {
    return {
      'todaySessions': 2,
      'totalMinutes': 45,
      'completedTricks': 3,
      'inProgressTricks': 2,
      'nextSession': DateTime.now().add(const Duration(hours: 2)),
      'weeklyGoal': 5, // 주간 세션 목표
      'weeklyProgress': 8, // 주간 완료 세션
      'recentSessions': [
        {
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'duration': 20, // 분
          'tricksWorked': ['앉기', '기다리기'],
          'success': true,
        },
        {
          'date': DateTime.now().subtract(const Duration(hours: 5)),
          'duration': 25,
          'tricksWorked': ['손 내밀기'],
          'success': true,
        },
      ],
      'tips': [
        '짧고 빈번한 세션이 효과적입니다',
        '성공할 때마다 즉시 보상해주세요',
        '일관된 명령어를 사용해주세요',
      ],
    };
  }
  
  /// 펫별 트레이닝 데이터 조회
  static Map<String, dynamic> getMockTrainingDataByPet(String petId) {
    final baseData = getMockTrainingData();
    
    // 펫별 맞춤 데이터
    switch (petId) {
      case '1': // MAX - 활발한 훈련 진행
        baseData['completedTricks'] = 5;
        baseData['inProgressTricks'] = 3;
        break;
      case '2': // LUNA - 기초 훈련 중
        baseData['completedTricks'] = 2;
        baseData['inProgressTricks'] = 1;
        baseData['todaySessions'] = 1;
        break;
      case '3': // MOMO - 고양이는 다른 훈련법
        baseData['completedTricks'] = 1;
        baseData['inProgressTricks'] = 1;
        baseData['todaySessions'] = 1;
        baseData['tips'] = [
          '고양이는 개보다 짧은 훈련 시간이 적합합니다',
          '놀이를 통한 훈련이 효과적입니다',
          '고양이만의 자연스러운 행동을 활용하세요',
        ];
        break;
    }
    
    return baseData;
  }
  
  // ==================== 건강 관리 데이터 ====================
  
  /// Mock 건강 관리 데이터
  static Map<String, dynamic> getMockHealthData() {
    return {
      'upcomingAppointments': 2,
      'overdueVaccines': 0,
      'medicationReminders': 1,
      'healthAlerts': [
        {
          'type': 'vaccination',
          'message': 'MAX의 연간 예방접종이 다음 주에 예정되어 있습니다.',
          'priority': 'medium',
          'dueDate': DateTime.now().add(const Duration(days: 7)),
        },
      ],
      'recentHealthRecords': [
        {
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'type': '체중 측정',
          'value': '15.8kg',
          'note': '정상 범위 내',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'type': '건강 검진',
          'value': '양호',
          'note': '정기 검진 완료',
        },
      ],
      'nextCheckup': DateTime.now().add(const Duration(days: 180)),
    };
  }
  
  /// 펫별 건강 관리 데이터 조회
  static Map<String, dynamic> getMockHealthDataByPet(String petId) {
    final baseData = getMockHealthData();
    
    // 펫별 맞춤 데이터
    switch (petId) {
      case '1': // MAX
        baseData['healthAlerts'][0]['message'] = 'MAX의 연간 예방접종이 다음 주에 예정되어 있습니다.';
        break;
      case '2': // LUNA
        baseData['upcomingAppointments'] = 1;
        baseData['healthAlerts'][0]['message'] = 'LUNA의 미용 예약이 이번 주에 있습니다.';
        break;
      case '3': // MOMO
        baseData['upcomingAppointments'] = 1;
        baseData['medicationReminders'] = 0;
        baseData['healthAlerts'][0]['message'] = 'MOMO의 정기 검진이 다음 달에 예정되어 있습니다.';
        break;
    }
    
    return baseData;
  }
  
  // ==================== 통계 및 분석 ====================
  
  /// 피딩 통계 데이터
  static Map<String, dynamic> getMockFeedingStatisticsForRecords() {
    return {
      'totalMeals': 42, // 지난 주
      'averageMealsPerDay': 6.0,
      'onTimeRate': 85.7, // 정시 급식률 (%)
      'favouriteFoodType': '건사료',
      'weeklyTrend': 'increasing', // increasing, decreasing, stable
    };
  }
  
  /// 주간 스케줄 준수율
  static Map<String, dynamic> getMockScheduleAdherence({String? petId}) {
    return {
      'feedingAdherence': 87, // %
      'walkingAdherence': 92,
      'trainingAdherence': 78,
      'medicationAdherence': 95,
      'weeklyAverage': 88,
      'bestDay': 'Tuesday',
      'improvementArea': 'training',
    };
  }
  
  /// 월별 진행상황
  static List<Map<String, dynamic>> getMockMonthlyProgress({
    String? petId,
    int months = 6,
  }) {
    final progress = <Map<String, dynamic>>[];
    
    for (int i = months; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i * 30));
      progress.add({
        'month': date,
        'schedulesCreated': 3 + (i % 2),
        'schedulesCompleted': 85 + (i % 10),
        'averageMealsPerDay': 5.5 + (i * 0.1),
        'healthCheckups': (i % 2 == 0) ? 1 : 0,
        'trainingSessions': 15 + (i % 5),
      });
    }
    
    return progress;
  }
}