/// 식사 타입 관련 Mock 데이터 서비스
///
/// 급여 스케줄링과 관련된 식사 타입 옵션들을 제공합니다.
class MealTypesMockData {
  /// 기본 식사 타입 목록
  static List<String> getMealTypes() {
    return [
      '朝食', // 아침 식사
      '昼食', // 점심 식사
      '夕食', // 저녁 식사
      'おやつ', // 간식
    ];
  }

  /// 식사 타입별 한국어 번역
  static Map<String, String> getMealTypeTranslations() {
    return {'朝食': '아침 식사', '昼食': '점심 식사', '夕食': '저녁 식사', 'おやつ': '간식'};
  }

  /// 식사 타입별 영어 번역
  static Map<String, String> getMealTypeEnglishTranslations() {
    return {'朝食': 'Breakfast', '昼食': 'Lunch', '夕食': 'Dinner', 'おやつ': 'Snack'};
  }

  /// 식사 타입별 기본 시간
  static Map<String, String> getDefaultMealTimes() {
    return {'朝食': '08:00', '昼食': '12:00', '夕食': '18:00', 'おやつ': '15:00'};
  }

  /// 식사 타입별 아이콘
  static Map<String, String> getMealTypeIcons() {
    return {'朝食': '🌅', '昼食': '☀️', '夕食': '🌙', 'おやつ': '🍪'};
  }

  /// 특정 식사 타입의 한국어 번역 조회
  static String getMealTypeTranslation(String mealType) {
    final translations = getMealTypeTranslations();
    return translations[mealType] ?? mealType;
  }

  /// 특정 식사 타입의 영어 번역 조회
  static String getMealTypeEnglishTranslation(String mealType) {
    final translations = getMealTypeEnglishTranslations();
    return translations[mealType] ?? mealType;
  }

  /// 특정 식사 타입의 기본 시간 조회
  static String getDefaultMealTime(String mealType) {
    final defaultTimes = getDefaultMealTimes();
    return defaultTimes[mealType] ?? '12:00';
  }

  /// 특정 식사 타입의 아이콘 조회
  static String getMealTypeIcon(String mealType) {
    final icons = getMealTypeIcons();
    return icons[mealType] ?? '🍽️';
  }

  /// 식사 타입이 유효한지 확인
  static bool isValidMealType(String mealType) {
    final mealTypes = getMealTypes();
    return mealTypes.contains(mealType);
  }
}
