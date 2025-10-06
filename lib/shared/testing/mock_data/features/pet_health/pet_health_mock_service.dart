import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// Pet Health Feature 전용 Mock 데이터 서비스
class PetHealthMockService extends BaseMockService {
  // ==================== 백신 기록 데이터 ====================

  /// Mock 백신 기록 목록
  static List<Map<String, dynamic>> getMockVaccineRecords() {
    return [
      // MAX (petId: 1) - 강아지
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'vaccineName': 'DHPP (総合ワクチン)',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 365)),
        'nextDueDate': DateTime.now().add(const Duration(days: 30)),
        'veterinarian': '田中獣医師',
        'clinic': 'ペット動物病院',
        'batchNumber': 'VAC2024-001',
        'notes': '正常に接種完了',
        'status': 'scheduled', // 接種予定
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'vaccineName': '狂犬病ワクチン',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 400)),
        'nextDueDate': null,
        'veterinarian': '田中獣医師',
        'clinic': 'ペット動物病院',
        'batchNumber': 'RAB2023-155',
        'notes': '副作用なし',
        'status': 'completed', // 接種完了
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'vaccineName': 'コロナウイルスワクチン',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 180)),
        'nextDueDate': null,
        'veterinarian': '田中獣医師',
        'clinic': 'ペット動物病院',
        'batchNumber': 'COR2024-089',
        'notes': '異常なし',
        'status': 'completed', // 接種完了
      },
      // LUNA (petId: 2) - 강아지
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'vaccineName': 'DHPP (総合ワクチン)',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 200)),
        'nextDueDate': DateTime.now().add(const Duration(days: 165)),
        'veterinarian': '佐藤獣医師',
        'clinic': '24時間緊急動物病院',
        'batchNumber': 'DOG2024-032',
        'notes': '健康状態良好',
        'status': 'scheduled', // 接種予定
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'vaccineName': '狂犬病ワクチン',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 100)),
        'nextDueDate': null,
        'veterinarian': '佐藤獣医師',
        'clinic': '24時間緊急動物病院',
        'batchNumber': 'RAB2024-210',
        'notes': '問題なし',
        'status': 'completed', // 接種完了
      },
      // MOMO (petId: 3) - 고양이
      {
        'id': MockHelper.generateId(),
        'petId': '3',
        'vaccineName': 'FVRCP (猫総合ワクチン)',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 150)),
        'nextDueDate': DateTime.now().add(const Duration(days: 215)),
        'veterinarian': '鈴木獣医師',
        'clinic': 'キャットクリニック',
        'batchNumber': 'CAT2024-045',
        'notes': '順調',
        'status': 'scheduled', // 接種予定
      },
      {
        'id': MockHelper.generateId(),
        'petId': '3',
        'vaccineName': '狂犬病ワクチン',
        'vaccinatedDate': DateTime.now().subtract(const Duration(days: 90)),
        'nextDueDate': null,
        'veterinarian': '鈴木獣医師',
        'clinic': 'キャットクリニック',
        'batchNumber': 'RAB2024-333',
        'notes': '異常なし',
        'status': 'completed', // 接種完了
      },
      // ココ (petId: 4) - 토끼 (백신 없음)
    ];
  }

  /// 펫별 백신 기록 조회
  static List<Map<String, dynamic>> getMockVaccineRecordsByPetId(String petId) {
    return getMockVaccineRecords()
        .where((record) => record['petId'] == petId)
        .toList();
  }

  /// 펫별 접종 예정 백신 조회
  static List<Map<String, dynamic>> getScheduledVaccines(String petId) {
    return getMockVaccineRecordsByPetId(
      petId,
    ).where((record) => record['status'] == 'scheduled').toList();
  }

  /// 펫별 접종 완료 백신 조회
  static List<Map<String, dynamic>> getCompletedVaccines(String petId) {
    return getMockVaccineRecordsByPetId(
      petId,
    ).where((record) => record['status'] == 'completed').toList();
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
