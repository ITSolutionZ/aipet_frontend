/// 레시피 난이도 관련 Mock 데이터 서비스
///
/// 펫 급여 레시피의 난이도 옵션들을 제공합니다.
class RecipeDifficultyMockData {
  /// 기본 난이도 옵션들
  static List<String> getDifficultyLevels() {
    return ['Easy', 'Medium', 'Hard'];
  }

  /// 난이도별 한국어 번역
  static Map<String, String> getDifficultyTranslations() {
    return {'Easy': '쉬움', 'Medium': '보통', 'Hard': '어려움'};
  }

  /// 난이도별 일본어 번역
  static Map<String, String> getDifficultyJapaneseTranslations() {
    return {'Easy': '簡単', 'Medium': '普通', 'Hard': '難しい'};
  }

  /// 난이도별 색상
  static Map<String, String> getDifficultyColors() {
    return {
      'Easy': '#4CAF50', // 녹색
      'Medium': '#FF9800', // 주황색
      'Hard': '#F44336', // 빨간색
    };
  }

  /// 난이도별 아이콘
  static Map<String, String> getDifficultyIcons() {
    return {'Easy': '🟢', 'Medium': '🟡', 'Hard': '🔴'};
  }

  /// 난이도별 예상 조리 시간 (분)
  static Map<String, int> getDifficultyEstimatedTime() {
    return {
      'Easy': 15, // 15분
      'Medium': 30, // 30분
      'Hard': 60, // 60분
    };
  }

  /// 난이도별 설명
  static Map<String, String> getDifficultyDescriptions() {
    return {
      'Easy': '간단한 재료로 빠르게 만들 수 있는 레시피',
      'Medium': '적당한 조리 과정이 필요한 레시피',
      'Hard': '복잡한 조리 과정과 다양한 재료가 필요한 레시피',
    };
  }

  /// 특정 난이도의 한국어 번역 조회
  static String getDifficultyTranslation(String difficulty) {
    final translations = getDifficultyTranslations();
    return translations[difficulty] ?? difficulty;
  }

  /// 특정 난이도의 일본어 번역 조회
  static String getDifficultyJapaneseTranslation(String difficulty) {
    final translations = getDifficultyJapaneseTranslations();
    return translations[difficulty] ?? difficulty;
  }

  /// 특정 난이도의 색상 조회
  static String getDifficultyColor(String difficulty) {
    final colors = getDifficultyColors();
    return colors[difficulty] ?? '#757575'; // 기본 회색
  }

  /// 특정 난이도의 아이콘 조회
  static String getDifficultyIcon(String difficulty) {
    final icons = getDifficultyIcons();
    return icons[difficulty] ?? '⚪';
  }

  /// 특정 난이도의 예상 조리 시간 조회
  static int getEstimatedTimeByDifficulty(String difficulty) {
    final times = getDifficultyEstimatedTime();
    return times[difficulty] ?? 30; // 기본 30분
  }

  /// 특정 난이도의 설명 조회
  static String getDifficultyDescription(String difficulty) {
    final descriptions = getDifficultyDescriptions();
    return descriptions[difficulty] ?? '레시피 난이도';
  }

  /// 난이도가 유효한지 확인
  static bool isValidDifficulty(String difficulty) {
    final levels = getDifficultyLevels();
    return levels.contains(difficulty);
  }

  /// 난이도 레벨을 숫자로 변환 (Easy: 1, Medium: 2, Hard: 3)
  static int getDifficultyLevel(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 1;
      case 'Medium':
        return 2;
      case 'Hard':
        return 3;
      default:
        return 2; // 기본값
    }
  }

  /// 숫자를 난이도 문자열로 변환
  static String getDifficultyFromLevel(int level) {
    switch (level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Medium'; // 기본값
    }
  }
}
