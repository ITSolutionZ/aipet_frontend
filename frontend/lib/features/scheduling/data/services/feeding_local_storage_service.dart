import 'helpers/helpers.dart';

/// 급여 로컬 저장소 서비스
///
/// 급여 기록 및 설정을 SharedPreferences에 저장/관리합니다
class FeedingLocalStorageService {
  /// 급여 기록 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingRecords() async {
    return FeedingStorageHelper.getFeedingRecords();
  }

  /// 급여 기록 추가
  static Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    return FeedingStorageHelper.addFeedingRecord(record);
  }

  /// 급여 스케줄 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingSchedules() async {
    return FeedingStorageHelper.getFeedingSchedules();
  }

  /// 급여 스케줄 업데이트
  static Future<void> updateFeedingSchedule(
    String mealType,
    String time,
    String amount,
  ) async {
    return FeedingStorageHelper.updateFeedingSchedule(mealType, time, amount);
  }

  /// 펫 상태 저장
  static Future<void> updatePetStatus(
    String petId,
    Map<String, String> statusValues,
  ) async {
    return PetStatusHelper.updatePetStatus(petId, statusValues);
  }

  /// 펫 상태 가져오기
  static Future<Map<String, dynamic>> getPetStatus(String petId) async {
    return PetStatusHelper.getPetStatus(petId);
  }

  /// 오늘의 급여 상태 가져오기
  static Future<List<Map<String, dynamic>>> getTodayMeals() async {
    return FeedingStorageHelper.getTodayMeals();
  }

  /// 펫 사이즈 및 급여량 정보 가져오기
  static Map<String, dynamic> getPetSizeFeedingInfo() {
    return {
      '1': {
        'id': '1',
        'name': 'マックス',
        'size': '中型犬',
        'weight': 15.8,
        'recommendedAmount': 300,
        'imagePath': 'assets/images/dogs/golden_retriever.png',
      },
      '2': {
        'id': '2',
        'name': 'ルナ',
        'size': '小型犬',
        'weight': 5.2,
        'recommendedAmount': 150,
        'imagePath': 'assets/images/cats/white_cat.png',
      },
    };
  }

  /// 펫 사이즈별 급여 가이드
  static Map<String, dynamic> getPetSizeFeedingGuide() {
    return {
      '小型犬': {
        'description': '小型犬の適正な食事量を維持しましょう',
        'recommendedRange': '100-200g',
        'tips': '1日2-3回に分けて与えてください',
      },
      '中型犬': {
        'description': '中型犬の適正な食事量を維持しましょう',
        'recommendedRange': '250-350g',
        'tips': '1日2回に分けて与えてください',
      },
      '大型犬': {
        'description': '大型犬の適正な食事量を維持しましょう',
        'recommendedRange': '400-600g',
        'tips': '1日2回に分けて与えてください',
      },
    };
  }

  /// 펫 상태 옵션
  static List<String> getPetStatusOptions() {
    return ['元気', '疲れ', '食欲あり', '食欲なし', '活発', '落ち着き'];
  }

  /// 급여 분석 데이터 계산
  static Future<Map<String, dynamic>> getFeedingAnalysisData() async {
    return FeedingAnalysisHelper.getFeedingAnalysisData();
  }
}
