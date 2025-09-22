/// 백신 관련 Mock 데이터 서비스
///
/// 펫 백신 기록과 관련된 Mock 데이터를 제공합니다.
class VaccineMockData {
  /// 백신 기록 Mock 데이터
  static Map<String, List<Map<String, dynamic>>> getVaccineData() {
    return {
      '2023': [
        {
          'name': 'Nobivac Parvo-C',
          'date': '11.03.2023',
          'doctor': 'dr. Martha Roth',
          'lot': 'A583D01',
          'expiryDate': '07-2026',
          'vaccinationDate': '18.05.2023',
          'validUntil': '18.09.2025',
          'notes': 'No bad reactions',
        },
      ],
      '2022': [
        {
          'name': 'Nobivac Parvo-C',
          'date': '13.03.2022',
          'doctor': 'dr. Martha Roth',
          'lot': 'B492E02',
          'expiryDate': '06-2025',
          'vaccinationDate': '13.03.2022',
          'validUntil': '13.07.2024',
          'notes': 'Normal reaction',
        },
        {
          'name': 'Rabisin',
          'date': '20.08.2022',
          'doctor': 'dr. Martha Roth',
          'lot': 'C301F03',
          'expiryDate': '08-2025',
          'vaccinationDate': '20.08.2022',
          'validUntil': '20.12.2024',
          'notes': 'No adverse effects',
        },
        {
          'name': 'Nobivac KV',
          'date': '08.06.2022',
          'doctor': 'dr. Martha Roth',
          'lot': 'D210G04',
          'expiryDate': '05-2025',
          'vaccinationDate': '08.06.2022',
          'validUntil': '08.10.2024',
          'notes': 'Good response',
        },
      ],
      '2021': [
        {
          'name': 'Nobivac Parvo-C',
          'date': '13.03.2021',
          'doctor': 'dr. Martha Roth',
          'lot': 'E129H05',
          'expiryDate': '03-2024',
          'vaccinationDate': '13.03.2021',
          'validUntil': '13.07.2023',
          'notes': 'Initial vaccination',
        },
        {
          'name': 'Rabisin',
          'date': '15.09.2021',
          'doctor': 'dr. Martha Roth',
          'lot': 'F038I06',
          'expiryDate': '09-2024',
          'vaccinationDate': '15.09.2021',
          'validUntil': '15.01.2024',
          'notes': 'Booster shot',
        },
      ],
    };
  }

  /// 특정 연도의 백신 기록 조회
  static List<Map<String, dynamic>>? getVaccinesByYear(String year) {
    final vaccineData = getVaccineData();
    return vaccineData[year];
  }

  /// 모든 백신 기록을 단일 리스트로 반환
  static List<Map<String, dynamic>> getAllVaccines() {
    final vaccineData = getVaccineData();
    final allVaccines = <Map<String, dynamic>>[];
    
    for (final yearlyVaccines in vaccineData.values) {
      allVaccines.addAll(yearlyVaccines);
    }
    
    return allVaccines;
  }
}