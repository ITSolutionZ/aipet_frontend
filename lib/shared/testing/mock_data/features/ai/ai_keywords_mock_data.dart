/// AI 키워드 관련 Mock 데이터 서비스
///
/// 펫 관련 키워드와 제외 키워드를 중앙에서 관리하며, 향후 설정 파일에서 로드할 수 있도록 설계
class AiKeywordsMockData {
  /// 펫 관련 키워드 목록 (일본어)
  static List<String> getPetKeywords() {
    return [
      // 동물 종류 (일본어)
      '犬', 'いぬ', 'ワンちゃん', 'わんちゃん', 'dog', 'puppy',
      '猫', 'ねこ', 'ニャンコ', 'にゃんこ', 'cat', 'kitty', 'kitten',
      'ハムスター', 'hamster', 'うさぎ', 'ウサギ', 'rabbit', 'bunny',
      '鳥', 'とり', 'bird', 'オウム', 'おうむ', 'parrot', 'インコ', 'いんこ', 'parakeet',
      '魚', 'さかな', 'fish', '金魚', 'きんぎょ', 'goldfish', '熱帯魚', 'ねったいぎょ',
      '亀', 'かめ', 'turtle', 'トカゲ', 'とかげ', 'lizard', 'ヘビ', 'へび', 'snake',

      // 펫 관련 용어 (일본어)
      'ペット', 'pets', '愛犬', 'あいけん', '愛猫', 'あいねこ',
      'フード', 'えさ', '餌', 'おやつ', 'オヤツ', 'food', 'treat',
      'おもちゃ', 'オモチャ', 'toy', 'リード', 'りーど', 'leash', '首輪', 'くびわ', 'collar',
      'トイレ', 'といれ', '排便', 'はいべん', 'litter', 'toilet', 'うんち', 'おしっこ',
      '散歩', 'さんぽ', 'walk', '運動', 'うんどう', 'exercise',
      '訓練', 'くんれん', '教育', 'きょういく', 'training', 'しつけ', 'シツケ',
      '病院', 'びょういん', '獣医', 'じゅうい', 'vet', 'veterinarian', '診療', 'しんりょう',
      '予防接種', 'よぼうせっしゅ', 'ワクチン', 'わくちん', 'vaccination', 'vaccine',
      '去勢', 'きょせい', '避妊', 'ひにん', 'neuter', 'spay',
      'グルーミング', 'ぐるーみんぐ', 'grooming', 'お風呂', 'おふろ', 'bath',
      '毛', 'け', 'fur', 'hair', '抜け毛', 'ぬけげ',
      '爪', 'つめ', 'nail', '肉球', 'にくきゅう', 'paw',
      '尻尾', 'しっぽ', 'tail', '耳', 'みみ', 'ear',

      // 행동 관련 (일본어)
      '吠える', 'ほえる', '鳴く', 'なく', 'bark', 'meow', 'にゃー',
      '噛む', 'かむ', '引っ掻く', 'ひっかく', 'bite', 'scratch',
      '走る', 'はしる', 'run', '遊ぶ', 'あそぶ', 'play',
      '寝る', 'ねる', 'sleep', '眠る', 'ねむる',

      // 건강 관련 (일본어)
      '病気', 'びょうき', '具合が悪い', 'ぐあいがわるい', 'sick', 'disease', 'illness',
      '下痢', 'げり', 'diarrhea', '嘔吐', 'おうと', 'vomit',
      '咳', 'せき', 'cough', 'くしゃみ', 'sneeze',
      'アレルギー', 'あれるぎー', 'allergy', '痒い', 'かゆい', 'itch',
      '怪我', 'けが', '傷', 'きず', 'injury', 'wound',

      // 케어 관련 (일본語)
      'ケア', 'けあ', 'care', '世話', 'せわ', '管理', 'かんり',
      '愛情', 'あいじょう', 'love', '家族', 'かぞく',
      '飼育', 'しいく', '里親', 'さとおや', 'adoption',
    ];
  }

  /// 제외할 키워드 (펫과 무관한 주제) - 일본어
  static List<String> getExcludeKeywords() {
    return [
      // 정치/사회
      '政治', 'せいじ', '選挙', 'せんきょ', '総理', 'そうり', '政府', 'せいふ',
      '国会', 'こっかい', '議員', 'ぎいん', '法律', 'ほうりつ',

      // 금융/투자
      '株', 'かぶ', '株式', 'かぶしき', '投資', 'とうし', '仮想通貨', 'かそうつうか',
      'ビットコイン', '暗号通貨', 'あんごうつうか', 'FX', '銀行', 'ぎんこう',

      // 엔터테인먼트
      '芸能人', 'げいのうじん', 'アイドル', 'あいどる', 'ドラマ', 'どらま',
      '映画', 'えいが', 'アニメ', 'あにめ', '漫画', 'まんが', 'テレビ', 'てれび',

      // 게임
      'ゲーム', 'げーむ', 'オンラインゲーム', 'ビデオゲーム', 'スマホゲーム',

      // 요리/음식
      '料理', 'りょうり', 'レシピ', 'れしぴ', 'レストラン', 'れすとらん',
      'グルメ', 'ぐるめ', '食べ物', 'たべもの', '飲み物', 'のみもの',

      // 여행
      '旅行', 'りょこう', '観光', 'かんこう', 'ホテル', 'ほてる',
      '航空券', 'こうくうけん', '電車', 'でんしゃ', '飛行機', 'ひこうき',

      // 패션/뷰티
      'ファッション', 'ふぁっしょん', 'ショッピング', 'しょっぴんぐ',
      '化粧品', 'けしょうひん', 'ビューティー', 'びゅーてぃー', '服', 'ふく',

      // 기술/개발
      'プログラミング', 'ぷろぐらみんぐ', '開発', 'かいはつ', 'コーディング', 'こーでぃんぐ',
      'アプリ', 'あぷり', 'ソフトウェア', 'そふとうぇあ',

      // 학문
      '数学', 'すうがく', '物理', 'ぶつり', '化学', 'かがく', '科学', 'かがく',
      '歴史', 'れきし', '地理', 'ちり', '文学', 'ぶんがく',

      // 스포츠
      'スポーツ', 'すぽーつ', 'サッカー', 'さっかー', '野球', 'やきゅう',
      'バスケ', 'ばすけ', 'テニス', 'てにす', 'ゴルフ', 'ごるふ',
    ];
  }

  /// 키워드 검색 (펫 관련 키워드인지 확인)
  static bool isPetRelatedKeyword(String text) {
    final petKeywords = getPetKeywords();
    final excludeKeywords = getExcludeKeywords();

    // 제외 키워드가 포함되어 있으면 false
    if (excludeKeywords.any((keyword) => text.contains(keyword))) {
      return false;
    }

    // 펫 관련 키워드가 포함되어 있으면 true
    return petKeywords.any((keyword) => text.contains(keyword));
  }

  /// 동물 종류별 키워드 조회
  static List<String> getAnimalTypeKeywords(String animalType) {
    final allKeywords = getPetKeywords();

    switch (animalType.toLowerCase()) {
      case 'dog':
        return allKeywords
            .where(
              (keyword) =>
                  keyword.contains('犬') ||
                  keyword.contains('いぬ') ||
                  keyword.contains('ワンちゃん') ||
                  keyword.contains('dog') ||
                  keyword.contains('puppy'),
            )
            .toList();
      case 'cat':
        return allKeywords
            .where(
              (keyword) =>
                  keyword.contains('猫') ||
                  keyword.contains('ねこ') ||
                  keyword.contains('ニャンコ') ||
                  keyword.contains('cat') ||
                  keyword.contains('kitty'),
            )
            .toList();
      default:
        return allKeywords;
    }
  }

  /// 카테고리별 키워드 조회
  static List<String> getKeywordsByCategory(String category) {
    final allKeywords = getPetKeywords();

    switch (category.toLowerCase()) {
      case 'health':
        return allKeywords
            .where(
              (keyword) =>
                  keyword.contains('病気') ||
                  keyword.contains('病院') ||
                  keyword.contains('獣医') ||
                  keyword.contains('ワクチン') ||
                  keyword.contains('sick') ||
                  keyword.contains('vet'),
            )
            .toList();
      case 'food':
        return allKeywords
            .where(
              (keyword) =>
                  keyword.contains('フード') ||
                  keyword.contains('えさ') ||
                  keyword.contains('おやつ') ||
                  keyword.contains('food'),
            )
            .toList();
      case 'behavior':
        return allKeywords
            .where(
              (keyword) =>
                  keyword.contains('しつけ') ||
                  keyword.contains('訓練') ||
                  keyword.contains('吠える') ||
                  keyword.contains('training'),
            )
            .toList();
      default:
        return allKeywords;
    }
  }
}
