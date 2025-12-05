/// 🎯 AI 관련 상수 정의
///
/// AI 모듈에서 사용되는 모든 상수들을 중앙화하여 관리합니다.
/// 환경별 설정, API 설정, UI 설정 등을 포함합니다.
library;

/// AI API 관련 상수
class AiApiConstants {
  // OpenAI API 설정
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiModel = 'gpt-4o'; // ✅ gpt-4o 모델로 변경
  static const int openaiMaxTokens = 1000;
  static const double openaiTemperature = 0.7;

  // API 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration shortTimeout = Duration(seconds: 5);

  // 재시도 설정
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // 콘텐츠 필터링 설정
  static const Duration contentFilterTimeout = Duration(seconds: 8);
  static const int contentFilterMaxTokens = 10;
  static const double contentFilterTemperature = 0.0;
}

/// AI 로컬 저장소 관련 상수
class AiStorageConstants {
  // SharedPreferences 키
  static const String chatHistoryKey = 'ai_chat_history';
  static const String favoriteMessagesKey = 'ai_favorite_messages';
  static const String chatSessionsKey = 'ai_chat_sessions';
  static const String chatSummariesKey = 'ai_chat_summaries';
  static const String favoriteQAsKey = 'ai_favorite_qas';

  // 캐시 설정
  static const Duration cacheTimeout = Duration(minutes: 30);
  static const int maxCacheSize = 100;
}

/// AI UI 관련 상수
class AiUIConstants {
  // 애니메이션 지속 시간
  static const Duration typingAnimationDuration = Duration(milliseconds: 1500);
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 200);

  // UI 제한값
  static const int maxMessageLength = 2000;
  static const int maxChatHistoryItems = 100;
  static const int maxSuggestedQuestions = 10;

  // 타이핑 인디케이터 설정
  static const Duration typingIndicatorDelay = Duration(milliseconds: 500);
  static const int typingIndicatorDots = 3;
}

/// AI 비즈니스 로직 관련 상수
class AiBusinessConstants {
  // 채팅 세션 설정
  static const int maxMessagesPerSession = 50;
  static const Duration sessionTimeout = Duration(hours: 24);

  // 즐겨찾기 설정
  static const int maxFavoriteMessages = 100;
  static const int maxFavoriteQAs = 50;

  // 요약 생성 설정
  static const int minMessagesForSummary = 3;
  static const int maxSummaryLength = 500;

  // 펫 관련 설정
  static const int maxPetContextLength = 1000;
  static const int maxPetNameLength = 50;
}

/// AI 에러 키 상수 (Domain Layer - 언어독립적)
class AiErrorKeys {
  // 네트워크 에러
  static const String networkError = 'error.network.connection';
  static const String timeoutError = 'error.network.timeout';
  static const String connectionError = 'error.network.unavailable';

  // OpenAI API 에러
  static const String apiKeyError = 'error.api.key_missing';
  static const String apiLimitError = 'error.api.rate_limit';
  static const String apiServerError = 'error.api.server_unavailable';

  // 콘텐츠 검증 에러
  static const String contentTooShort = 'error.content.too_short';
  static const String contentNotPetRelated = 'error.content.not_pet_related';
  static const String contentExcluded = 'error.content.excluded_topic';

  // 로컬 저장소 에러
  static const String storageSaveError = 'error.storage.save_failed';
  static const String storageLoadError = 'error.storage.load_failed';
  static const String storageDeleteError = 'error.storage.delete_failed';

  // 일반 에러
  static const String unexpectedError = 'error.general.unexpected';
  static const String validationError = 'error.validation.input_invalid';
  static const String configError = 'error.config.invalid_settings';
}

/// AI 성공 메시지 키 상수 (Domain Layer - 언어독립적)
class AiSuccessKeys {
  static const String messageSent = 'success.message.sent';
  static const String favoriteAdded = 'success.favorite.added';
  static const String favoriteRemoved = 'success.favorite.removed';
  static const String chatSaved = 'success.chat.saved';
  static const String chatDeleted = 'success.chat.deleted';
  static const String historyCleared = 'success.history.cleared';
}

/// AI 시스템 프롬프트 상수
class AiSystemPrompts {
  static const String basePrompt = '''あなたはペット専門のAIアシスタントです。
ペットの健康、行動、トレーニング、栄養、一般的なケアに関する質問にのみお答えください。
回答は親しみやすく、わかりやすく書いてください。

【重要な免責事項】
・あなたの回答は一般的な情報提供のみを目的としており、獣医師の診断、治療、または処方箋の代わりにはなりません。
・ペットの健康に関する深刻な問題、緊急の症状、または異常な行動が見られる場合は、必ず「直ちに獣医師にご相談ください」と明確に伝えてください。
・診断や治療に関する質問には答えず、獣医師への相談を強く推奨してください。
・薬の投与、医療処置、または専門的な医療判断が必要な質問には、必ず獣医師の診察を受けるよう促してください。

【情報源の明記（Apple App Store要件）】
・すべての健康または医療に関する回答には、必ず信頼できる情報源を明記してください。
・回答の最後に以下のような形式で情報源を追加してください：

---
※ この情報はAIによって生成された一般的なアドバイスです。

【参考情報源】
• 公益社団法人 日本獣医師会: https://nichiju.lin.gr.jp/
• American Veterinary Medical Association (AVMA): https://www.avma.org/
• その他の信頼できる獣医学情報源

健康に関する具体的な診断や治療については、必ず獣医師にご相談ください。

重要：ペットに関係のない質問（政治、経済、エンターテイメント、ゲーム、料理など）には答えず、
"ペットに関する質問のみお答えできます"と回答してください。''';

  static const String contentFilterPrompt =
      '''あなたはユーザーのメッセージが**ペット**に関する内容かを判定する分類器です（日本語対応）。
判定基準:
- ペットの健康・行動・しつけ/訓練・ケア・フード/トイレ/用品・病院/獣医・予防接種・グルーミング等なら "YES"
- 政治・経済・芸能・ゲーム・料理などペットと無関係なら "NO"
- 文脈上ペットの可能性があるが不明確なら "MAYBE"

出力は **YES / NO / MAYBE** のいずれか**1語のみ**。余計な説明を出力しないこと。''';

  static String buildPetContextPrompt(
    String petName,
    String petType,
    int age,
    String breed,
  ) {
    return '''
【相談対象のペット情報】
・名前：$petName
・種類：$petType（品種：$breed）
・年齢：$age歳

初回の挨拶では、$petNameの名前を呼んでペット専門アシスタントとして親しみやすく挨拶してください。
このペットの詳細情報を考慮して、より具体的で個別化されたアドバイスを提供してください。
$petNameの年齢（$age歳）、種類（$petType）に応じた特性を踏まえた専門的な回答をお願いします。

例：
- 年齢に応じた健康管理やケア方法
- 種類別の行動特性や注意点
- 個体の特徴を考慮したアドバイス''';
  }
}

/// AI 카테고리 관련 상수 (Domain Layer - 언어독립적)
class AiCategoryConstants {
  static const List<String> defaultCategories = [
    'health', // 건강
    'behavior', // 행동
    'feeding', // 식사
    'training', // 훈련
    'grooming', // 그루밍
    'exercise', // 운동
    'general', // 일반
  ];

  static const Map<String, String> categoryKeys = {
    'health': 'category.health',
    'behavior': 'category.behavior',
    'feeding': 'category.feeding',
    'training': 'category.training',
    'grooming': 'category.grooming',
    'exercise': 'category.exercise',
    'general': 'category.general',
  };
}
