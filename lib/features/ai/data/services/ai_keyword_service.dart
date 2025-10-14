/// AI 키워드 데이터 관리 서비스
///
/// 펫 관련 키워드와 제외 키워드를 중앙에서 관리하며, 향후 설정 파일에서 로드할 수 있도록 설계
class AiKeywordService {
  /// 펫 관련 키워드 목록 (일본어)
  static List<String> getPetKeywords() {
    return [
      'ペット',
      'pet',
      '犬',
      '猫',
      'dog',
      'cat',
      '健康',
      'health',
      '病気',
      'sick',
      '獣医',
      'vet',
      'フード',
      'food',
      '餌',
      'feed',
      '栄養',
      'nutrition',
      'しつけ',
      'training',
      'トレーニング',
      '行動',
      'behavior',
      'グルーミング',
      'grooming',
      'お手入れ',
      'care',
      '散歩',
      'walk',
      '運動',
      'exercise',
      '予防接種',
      'vaccination',
      'ワクチン',
      'vaccine',
      'トイレ',
      'toilet',
      '排泄',
      'excretion',
      '子犬',
      'puppy',
      '子猫',
      'kitten',
      '老犬',
      'senior dog',
      '老猫',
      'senior cat',
    ];
  }

  /// 제외할 키워드 (펫과 무관한 주제) - 일본어
  static List<String> getExcludeKeywords() {
    return [
      '政治',
      'politics',
      '経済',
      'economy',
      'スポーツ',
      'sports',
      '芸能',
      'entertainment',
      '料理',
      'cooking',
      'レシピ',
      'recipe',
      'ゲーム',
      'game',
      '映画',
      'movie',
      '音楽',
      'music',
      'ニュース',
      'news',
    ];
  }

  /// 키워드 검색 (펫 관련 키워드인지 확인)
  static bool isPetRelatedKeyword(String text) {
    final lowerText = text.toLowerCase();
    return getPetKeywords().any(
      (keyword) => lowerText.contains(keyword.toLowerCase()),
    );
  }
}
