/// 🎯 AI 키워드 상수
///
/// 펫 관련 키워드와 제외 키워드를 중앙에서 관리합니다.
/// 콘텐츠 필터링 및 검증에 사용됩니다.
class AiKeywords {
  /// 생성자 비활성화 (상수 클래스)
  const AiKeywords._();

  /// 펫 관련 키워드 목록 (일본어/영어)
  static const List<String> petRelated = [
    // 일반
    'ペット',
    'pet',
    '犬',
    '猫',
    'dog',
    'cat',

    // 건강
    '健康',
    'health',
    '病気',
    'sick',
    '獣医',
    'vet',

    // 식사
    'フード',
    'food',
    '餌',
    'feed',
    '栄養',
    'nutrition',

    // 훈련/행동
    'しつけ',
    'training',
    'トレーニング',
    '行動',
    'behavior',

    // 그루밍
    'グルーミング',
    'grooming',
    'お手入れ',
    'care',

    // 운동
    '散歩',
    'walk',
    '運動',
    'exercise',

    // 예방접종
    '予防接種',
    'vaccination',
    'ワクチン',
    'vaccine',

    // 배변
    'トイレ',
    'toilet',
    '排泄',
    'excretion',

    // 연령별
    '子犬',
    'puppy',
    '子猫',
    'kitten',
    '老犬',
    'senior dog',
    '老猫',
    'senior cat',
  ];

  /// 제외할 키워드 (펫과 무관한 주제)
  static const List<String> excluded = [
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

  /// 키워드 검색 (펫 관련 키워드인지 확인)
  static bool isPetRelated(String text) {
    final lowerText = text.toLowerCase();
    return petRelated.any(
      (keyword) => lowerText.contains(keyword.toLowerCase()),
    );
  }

  /// 제외 키워드 포함 여부 확인
  static bool containsExcludedKeyword(String text) {
    final lowerText = text.toLowerCase();
    return excluded.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }
}
