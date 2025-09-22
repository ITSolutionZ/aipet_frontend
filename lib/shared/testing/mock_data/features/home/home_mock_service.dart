import '../../core/base_mock_service.dart';

/// Home Feature 전용 Mock 데이터 서비스
class HomeMockService extends BaseMockService {
  
  // ==================== 날씨 데이터 ====================
  
  /// Mock 날씨 정보
  static Map<String, dynamic> getMockWeatherInfo() {
    return {
      'temperature': 23.5,
      'location': '東京都品川区', 
      'condition': '맑음',
      'iconCode': '01d',
      'humidity': 65,
      'windSpeed': 2.5,
      'uvIndex': 5.0,
      'pressure': 1013.25,
      'visibility': 10000,
    };
  }
  
  // ==================== 펫 활동 데이터 ====================
  
  /// 펫별 활동 정보 조회
  static List<Map<String, dynamic>> getMockPetActivities({String? petId}) {
    final baseActivities = [
      {'icon': '🎾', 'label': '공놀이', 'isActive': true},
      {'icon': '🚶', 'label': '산책', 'isActive': true},
      {'icon': '🍖', 'label': '간식시간', 'isActive': false},
      {'icon': '💤', 'label': '낮잠', 'isActive': false},
    ];
    
    // 펫 ID에 따른 맞춤 활동 (실제로는 DB에서 조회)
    if (petId == '2') {
      baseActivities[2]['isActive'] = true; // 간식시간 활성화
    }
    
    return baseActivities;
  }
  
  // ==================== 요약 카드 데이터 ====================
  
  /// 다음 산책 시간 조회
  static String getMockNextWalkTime({String? petId}) {
    // 펫별 맞춤 산책 시간
    switch (petId) {
      case '1':
        return '오후 3:30';
      case '2':
        return '오후 4:00';
      case '3':
        return '오후 2:30';
      default:
        return '오후 3:00';
    }
  }
  
  /// 다음 식사 정보 조회  
  static Map<String, dynamic> getMockNextMealInfo({String? petId}) {
    final baseMeals = {
      '1': {'time': '오후 6:00', 'type': '저녁식사'},
      '2': {'time': '오후 6:30', 'type': '저녁식사'},
      '3': {'time': '오후 5:30', 'type': '저녁식사'},
    };
    
    return baseMeals[petId] ?? {'time': '오후 6:00', 'type': '저녁식사'};
  }
  
  /// 예상 칼로리 조회
  static int getMockExpectedCalories({String? petId}) {
    final baseCalories = {
      '1': 450, // 중형견
      '2': 320, // 소형견  
      '3': 380, // 고양이
    };
    
    return baseCalories[petId] ?? 400;
  }
  
  /// 다음 예약 유형 조회
  static String getMockNextAppointmentType({String? petId}) {
    final appointments = {
      '1': '건강검진',
      '2': '미용', 
      '3': '예방접종',
    };
    
    return appointments[petId] ?? '건강검진';
  }
  
  // ==================== 대시보드 통합 데이터 ====================
  
  /// 오늘의 식사 기록 조회
  static List<Map<String, dynamic>> getMockTodayMeals({String? petId}) {
    return [
      {
        'id': MockHelper.generateId(),
        'petId': petId ?? '1',
        'time': '08:00',
        'type': '아침식사',
        'completed': true,
        'calories': 150,
      },
      {
        'id': MockHelper.generateId(),
        'petId': petId ?? '1', 
        'time': '18:00',
        'type': '저녁식사',
        'completed': false,
        'calories': getMockExpectedCalories(petId: petId) - 150,
      },
    ];
  }
  
  /// 산책 요약 정보 조회
  static Map<String, dynamic> getMockWalkSummary({String? petId}) {
    return {
      'todayWalks': 2,
      'todayDistance': 3.2,
      'todayDuration': const Duration(minutes: 45),
      'weeklyGoal': 15.0,
      'weeklyProgress': 8.5,
      'nextWalkTime': getMockNextWalkTime(petId: petId),
    };
  }
  
  /// 체중 기록 조회
  static List<Map<String, dynamic>> getMockWeightRecords({
    String? petId,
    int days = 30,
  }) {
    final records = <Map<String, dynamic>>[];
    final baseWeight = petId == '2' ? 3.5 : (petId == '3' ? 4.2 : 15.8);
    
    for (int i = days; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final variation = (i % 7 == 0) ? 0.1 : 0.0; // 주간 변동
      
      records.add({
        'date': date,
        'weight': baseWeight + variation,
        'petId': petId ?? '1',
      });
    }
    
    return records;
  }

  /// 건강 요약 정보 조회
  static Map<String, dynamic> getMockHealthSummary({String? petId}) {
    return {
      'overall': 'good', // excellent, good, fair, poor
      'lastCheckup': DateTime.now().subtract(const Duration(days: 45)),
      'nextCheckup': DateTime.now().add(const Duration(days: 45)),
      'vaccines': {
        'upToDate': true,
        'nextDue': DateTime.now().add(const Duration(days: 120)),
      },
      'weight': {
        'current': petId == '2' ? 3.5 : (petId == '3' ? 4.2 : 15.8),
        'target': petId == '2' ? 3.6 : (petId == '3' ? 4.3 : 16.0),
        'trend': 'stable',
      },
      'activities': {
        'walkToday': true,
        'feedingOnTime': true,
        'medicationTaken': petId == '3' ? true : null,
      },
      'alerts': [],
      'recommendations': [
        '정기적인 운동을 유지하세요',
        '체중 관리에 주의하세요',
      ],
    };
  }
}