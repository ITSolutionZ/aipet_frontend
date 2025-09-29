import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// Pet Health Feature 전용 Mock 데이터 서비스
class PetHealthMockService extends BaseMockService {
  // ==================== 백신 기록 데이터 ====================

  /// Mock 백신 기록 목록
  static List<Map<String, dynamic>> getMockVaccineRecords() {
    return [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'vaccineName': 'DHPP (종합백신)',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 365)),
        'nextDueDate': DateTime.now().add(const Duration(days: 30)),
        'veterinarian': '김수의사',
        'clinic': '우리동물병원',
        'batchNumber': 'VAC2024-001',
        'notes': '정상적으로 접종 완료',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'vaccineName': '광견병 백신',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 400)),
        'nextDueDate': DateTime.now().add(const Duration(days: 95)),
        'veterinarian': '김수의사',
        'clinic': '우리동물병원',
        'batchNumber': 'RAB2023-155',
        'notes': '부작용 없음',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'vaccineName': 'FVRCP (고양이 종합백신)',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 200)),
        'nextDueDate': DateTime.now().add(const Duration(days: 165)),
        'veterinarian': '박수의사',
        'clinic': '24시 응급동물병원',
        'batchNumber': 'CAT2024-032',
        'notes': '건강 상태 양호',
      },
    ];
  }

  // ==================== 체중 기록 데이터 ====================

  /// Mock 체중 기록 목록
  static List<Map<String, dynamic>> getMockWeightRecords({String? petId}) {
    final baseRecords = [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'weight': 15.8,
        'recordedDate': DateTime.now(),
        'notes': '정상 범위 내',
        'measuredBy': '집',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'weight': 15.6,
        'recordedDate': DateTime.now().subtract(const Duration(days: 7)),
        'notes': '약간 감소',
        'measuredBy': '병원',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'weight': 15.9,
        'recordedDate': DateTime.now().subtract(const Duration(days: 14)),
        'notes': '정상',
        'measuredBy': '집',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'weight': 3.5,
        'recordedDate': DateTime.now(),
        'notes': '이상적 체중',
        'measuredBy': '집',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'weight': 3.4,
        'recordedDate': DateTime.now().subtract(const Duration(days: 7)),
        'notes': '안정적',
        'measuredBy': '병원',
      },
    ];

    if (petId != null) {
      return baseRecords.where((record) => record['petId'] == petId).toList();
    }

    return baseRecords;
  }

  /// 체중 차트 데이터
  static Map<String, dynamic> getMockWeightChartData({String? petId}) {
    final weightRecords = getMockWeightRecords(petId: petId);

    return {
      'chartData': weightRecords
          .map(
            (record) => {
              'date': record['recordedDate'],
              'weight': record['weight'],
            },
          )
          .toList(),
      'idealWeight': petId == '1' ? 16.0 : 3.6,
      'weightRange': {
        'min': petId == '1' ? 14.0 : 3.0,
        'max': petId == '1' ? 18.0 : 4.0,
      },
      'trend': 'stable', // stable, increasing, decreasing
      'trendPercentage': 2.1, // 변화율
      'recommendations': _getWeightRecommendations(petId),
    };
  }

  static List<String> _getWeightRecommendations(String? petId) {
    switch (petId) {
      case '1':
        return ['현재 체중이 이상적입니다', '꾸준한 운동을 유지해주세요', '정기적인 체중 측정을 권장합니다'];
      case '2':
        return ['소형견 기준으로 적정 체중입니다', '과식하지 않도록 주의해주세요', '활동량을 늘려보세요'];
      default:
        return ['수의사와 상담을 권장합니다'];
    }
  }
}
