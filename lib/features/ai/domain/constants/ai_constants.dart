/// 🎯 AI 관련 상수 정의
///
/// AI 모듈에서 사용되는 모든 상수들을 중앙화하여 관리합니다.
/// 환경별 설정, API 설정, UI 설정 등을 포함합니다.
library;

/// AI API 관련 상수
class AiApiConstants {
  // OpenAI API 설정
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiModel = 'gpt-3.5-turbo';
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

/// AI 에러 메시지 상수
class AiErrorMessages {
  // 네트워크 에러
  static const String networkError = 'ネットワーク接続を確認してください。';
  static const String timeoutError = '接続がタイムアウトしました。しばらくしてから再試行してください。';
  static const String connectionError = 'ネットワーク接続に問題があります。インターネット接続を確認してください。';

  // OpenAI API 에러
  static const String apiKeyError = 'OpenAI API キーが設定されていません。';
  static const String apiLimitError = 'API リクエスト制限を超えました。しばらくしてから再試行してください。';
  static const String apiServerError =
      'OpenAI サーバーに一時的な問題が発生しています。しばらくしてから再試行してください。';

  // 콘텐츠 검증 에러
  static const String contentTooShort = '内容が短すぎます。ペット関連の具体的な質問を入力してください。';
  static const String contentNotPetRelated = 'ペットに関連する内容を含めてご質問ください。';
  static const String contentExcluded = 'ペットと関連していない話題です。';

  // 로컬 저장소 에러
  static const String storageSaveError = 'データの保存に失敗しました。';
  static const String storageLoadError = 'データの読み込みに失敗しました。';
  static const String storageDeleteError = 'データの削除に失敗しました。';

  // 일반 에러
  static const String unexpectedError = '予期しないエラーが発生しました。しばらくしてから再試行してください。';
  static const String validationError = '入力内容を確認してください。';
  static const String configError = '設定に問題があります。管理者にお問い合わせください。';
}

/// AI 성공 메시지 상수
class AiSuccessMessages {
  static const String messageSent = 'メッセージを送信しました。';
  static const String favoriteAdded = 'お気に入りに追加しました。';
  static const String favoriteRemoved = 'お気に入りから削除しました。';
  static const String chatSaved = 'チャットを保存しました。';
  static const String chatDeleted = 'チャットを削除しました。';
  static const String historyCleared = 'チャット履歴をクリアしました。';
}

/// AI 시스템 프롬프트 상수
class AiSystemPrompts {
  static const String basePrompt = '''あなたはペット専門のAIアシスタントです。
ペットの健康、行動、トレーニング、栄養、一般的なケアに関する質問にのみお答えください。
回答は親しみやすく、わかりやすく書いてください。
深刻な健康問題が疑われる場合は、必ず獣医師への相談をお勧めしてください。

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

/// AI 카테고리 관련 상수
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

  static const Map<String, String> categoryDisplayNames = {
    'health': '健康管理',
    'behavior': '行動・しつけ',
    'feeding': '食事・栄養',
    'training': 'トレーニング',
    'grooming': 'グルーミング',
    'exercise': '運動・散歩',
    'general': '一般的な相談',
  };
}
