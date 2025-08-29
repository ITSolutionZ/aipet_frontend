import 'package:dio/dio.dart';

import '../../../../app/config/app_config.dart';

/// 펫 관련 콘텐츠 필터링 서비스
class PetContentFilterService {
  late final Dio _dio;

  // 펫 관련 키워드 목록 (일본어)
  static const List<String> _petKeywords = [
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

  // 제외할 키워드 (펫과 무관한 주제) - 일본어
  static const List<String> _excludeKeywords = [
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

  PetContentFilterService() {
    _dio = Dio();
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
    // Changed: Set timeouts to avoid hanging
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 8);
  }

  /// 메시지가 펫 관련 질문인지 검증
  Future<PetContentValidationResult> validatePetContent(String message) async {
    // Changed: Early return for empty/short inputs
    if (message.trim().isEmpty || message.trim().length < 2) {
      return const PetContentValidationResult(
        isValid: false,
        reason: '内容が短すぎます。ペット関連の具体的な質問を入力してください',
        confidence: 0.2,
      );
    }
    // 1단계: 키워드 기반 사전 필터링
    final keywordResult = _validateByKeywords(message);

    if (keywordResult.isValid) {
      return keywordResult;
    }

    // 2단계: 키워드 검증에 실패한 경우 AI로 재검증 (선택적)
    if (AppConfig.current.openaiApiKey.isNotEmpty) {
      try {
        return await _validateByAI(message);
      } catch (e) {
        // AI 검증 실패 시 키워드 결과 사용
        return keywordResult;
      }
    }

    return keywordResult;
  }

  /// 키워드 기반 검증
  PetContentValidationResult _validateByKeywords(String message) {
    final lowerMessage = message.toLowerCase();

    // 제외 키워드가 있는지 확인
    for (final excludeKeyword in _excludeKeywords) {
      if (lowerMessage.contains(excludeKeyword.toLowerCase())) {
        return const PetContentValidationResult(
          isValid: false,
          reason: 'ペットと関連していない話題です',
          confidence: 0.9,
        );
      }
    }

    // 펫 관련 키워드가 있는지 확인
    // Changed: count unique matches only
    final matched = <String>{};
    for (final petKeyword in _petKeywords) {
      if (lowerMessage.contains(petKeyword.toLowerCase())) {
        matched.add(petKeyword.toLowerCase());
      }
    }
    final matchCount = matched.length;

    if (matchCount > 0) {
      return PetContentValidationResult(
        isValid: true,
        reason: 'ペット関連のご質問です',
        confidence: (0.55 + (matchCount.clamp(1, 5) * 0.08)).clamp(
          0.6,
          0.95,
        ), // Changed
      );
    }

    // 키워드가 없는 경우 - 애매한 상황
    return const PetContentValidationResult(
      isValid: false,
      reason: 'ペットに関連する内容を含めてご質問ください',
      confidence: 0.3,
    );
  }

  /// AI 기반 검증 (GPT-3.5-turbo 사용)
  Future<PetContentValidationResult> _validateByAI(String message) async {
    final apiKey = AppConfig.current.openaiApiKey;

    final response = await _dio
        .post(
          '/chat/completions',
          options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
          data: {
            'model': AppConfig.current.openaiModel,
            'messages': [
              {
                'role': 'system',
                'content':
                    '''あなたはユーザーのメッセージが**反\u200bりょう動物（ペット）**に関する内容かを判定する分類器です（日本語対応）。
判定基準:
- ペットの健康・行動・しつけ/訓練・ケア・フード/トイレ/用品・病院/獣医・予防接種・グルーミング等なら "YES"
- 政治・経済・芸能・ゲーム・料理などペットと無関係なら "NO"
- 文脈上ペットの可能性があるが不明確なら "MAYBE"

出力は **YES / NO / MAYBE** のいずれか**1語のみ**。余計な説明を出力しないこと。''',
              },
              {'role': 'user', 'content': message},
            ],
            'max_tokens': 10,
            'temperature': 0.0, // Changed
          },
        )
        .timeout(const Duration(seconds: 10)); // Changed

    final aiResponse = response.data['choices'][0]['message']['content']
        .toString()
        .trim()
        .toUpperCase();

    switch (aiResponse) {
      case 'YES':
        return const PetContentValidationResult(
          isValid: true,
          reason: 'ペット関連のご質問です',
          confidence: 0.9,
        );
      case 'NO':
        return const PetContentValidationResult(
          isValid: false,
          reason: 'ペットに関連していないご質問です',
          confidence: 0.9,
        );
      default:
        return const PetContentValidationResult(
          isValid: false,
          reason: 'ペットに関連する内容をより具体的にご質問ください',
          confidence: 0.5,
        );
    }
  }

  // Changed: convenience helper so callers can quickly decide
  Future<bool> isPetRelated(String message) async {
    final result = await validatePetContent(message);
    return result.isValid;
  }
}

/// 펫 콘텐츠 검증 결과
class PetContentValidationResult {
  final bool isValid;
  final String reason;
  final double confidence;

  const PetContentValidationResult({
    required this.isValid,
    required this.reason,
    required this.confidence,
  });

  @override
  String toString() {
    return 'PetContentValidationResult(isValid: $isValid, reason: $reason, confidence: $confidence)';
  }
}
