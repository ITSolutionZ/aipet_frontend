/// 펫 건강 Mock 서비스
///
/// 펫 건강 관련 Mock 데이터를 제공합니다.
class PetHealthMockService {
  /// Mock 체중 데이터 반환
  static List<Map<String, dynamic>> getMockWeightData() {
    return [
      {
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'weight': 15.2,
        'notes': '定期測定',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'weight': 15.4,
        'notes': '健康診断',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'weight': 15.5,
        'notes': '通常測定',
      },
      {'date': DateTime.now(), 'weight': 15.5, 'notes': '最新測定'},
    ];
  }

  /// Mock 건강 기록 반환
  static Map<String, dynamic> getMockHealthRecord() {
    return {
      'petId': 'pet-1',
      'lastCheckup': DateTime.now().subtract(const Duration(days: 30)),
      'nextCheckup': DateTime.now().add(const Duration(days: 30)),
      'vaccinations': [
        {
          'name': '狂犬病ワクチン',
          'date': DateTime.now().subtract(const Duration(days: 90)),
          'nextDue': DateTime.now().add(const Duration(days: 275)),
        },
        {
          'name': '混合ワクチン',
          'date': DateTime.now().subtract(const Duration(days: 60)),
          'nextDue': DateTime.now().add(const Duration(days: 305)),
        },
      ],
      'medications': [
        {
          'name': 'フィラリア予防薬',
          'startDate': DateTime.now().subtract(const Duration(days: 15)),
          'endDate': DateTime.now().add(const Duration(days: 15)),
          'frequency': '月1回',
        },
      ],
    };
  }

  /// Mock 체중 기록 반환 (getMockWeightData와 동일한 데이터)
  static List<Map<String, dynamic>> getMockWeightRecords() {
    return getMockWeightData();
  }
}
