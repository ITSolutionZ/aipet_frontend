import '../../../../shared/shared.dart';

import '../../../../app/config/app_config.dart';
import '../../domain/domain.dart';


/// AI 채팅용 OpenAI 서비스
class AiChatOpenAIService extends BaseLoggingService {
  final OpenAiHttpClient _httpClient;

  // ✅ Rate Limit 관리를 위한 마지막 요청 시간 추적
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(milliseconds: 500); // 최소 500ms 간격

  AiChatOpenAIService({OpenAiHttpClient? httpClient})
    : _httpClient = httpClient ?? OpenAiHttpClient(),
      super('ai_chat_openai_service');

  /// OpenAI ChatGPT API를 사용하여 메시지에 대한 응답 생성 (재시도 로직 포함)
  Future<Result<String>> generateResponse(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
  }) async {
    final apiKey = AppConfig.current.openaiApiKey;

    if (apiKey.isEmpty) {
      return Result.failure('OpenAI API 키가 설정되지 않았습니다');
    }

    // ✅ Content Filter 비활성화: AI 채팅 화면에 접근한 사용자는 펫 관련 질문 의도가 있음
    // ペット関連コンテンツ検証은 사용자 경험을 위해 비활성화
    // 만약 펫 관련 없는 질문이 들어오면 AI가 시스템 프롬프트에 따라 적절히 응답함
    logInfo('Content filter skipped for better user experience');

    // ✅ Rate Limit 방지: 이전 요청과의 최소 간격 확보
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final remainingWait = _minRequestInterval - timeSinceLastRequest;
        logInfo('Rate limit 방지: ${remainingWait.inMilliseconds}ms 대기 중...');
        await Future.delayed(remainingWait);
      }
    }
    _lastRequestTime = DateTime.now();

    // 🪙 토큰 사용량 사전 체크
    final canMakeRequest = TokenUsageService.canMakeRequest(
      estimatedTokens: AiApiConstants.openaiMaxTokens,
    );
    if (!canMakeRequest.isSuccess) {
      return Result.failure(
        canMakeRequest.error?.toString() ?? 'Token limit exceeded',
      );
    }

    final systemPrompt = _buildSystemPrompt(
      petContext,
      weatherAdvice,
      walkGuide,
    );

    logDebug('📤 OpenAI Request:');
    logDebug('   - Model: ${AppConfig.current.openaiModel}');
    logDebug('   - User message: "$message"');
    logDebug('   - System prompt length: ${systemPrompt.length} chars');
    logDebug('   - Max tokens: ${AiApiConstants.openaiMaxTokens}');

    return _httpClient
        .callOpenAIWithRetry(
          '/chat/completions',
          data: {
            'model': AppConfig.current.openaiModel,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': message},
            ],
            'max_completion_tokens': AiApiConstants.openaiMaxTokens,
          },
        )
        .then((response) async {
          if (!response.isSuccess) {
            logError('OpenAI API call failed: ${response.message}');
            return Result.failure(response.message);
          }

          final responseData = response.dataOrNull!;
          logDebug(
            'OpenAI API response received: ${responseData.keys.join(", ")}',
          );

          // 🪙 토큰 사용량 기록
          if (responseData['usage'] != null) {
            final usage = responseData['usage'] as Map<String, dynamic>;
            final promptTokens = usage['prompt_tokens'] as int? ?? 0;
            final completionTokens = usage['completion_tokens'] as int? ?? 0;

            final usageResult = TokenUsageService.recordUsage(
              promptTokens: promptTokens,
              completionTokens: completionTokens,
              model: AppConfig.current.openaiModel,
              userId: petContext?.id, // 펫 ID를 사용자 식별자로 사용
            );

            if (usageResult.isSuccess) {
              logInfo(
                'Token usage recorded: ${usageResult.dataOrNull!.totalTokens} tokens',
              );
            } else {
              logWarning(
                'Failed to record token usage: ${usageResult.error?.toString() ?? 'Unknown error'}',
              );
            }
          }

          if (responseData['choices'] != null &&
              responseData['choices'] is List &&
              responseData['choices'].isNotEmpty) {
            logDebug('Choices found: ${responseData['choices'].length}');
            final choice = responseData['choices'][0];
            logDebug(
              'Choice structure: ${choice.runtimeType} - keys: ${choice is Map ? (choice).keys.join(", ") : "not a map"}',
            );

            if (choice is Map<String, dynamic>) {
              logDebug('Message exists: ${choice['message'] != null}');
              if (choice['message'] != null) {
                final message = choice['message'] as Map<String, dynamic>;
                logDebug('Message keys: ${message.keys.join(", ")}');

                // ✅ OpenAI의 새로운 응답 구조: refusal 필드 확인
                logDebug('Refusal exists: ${message['refusal'] != null}');
                logDebug('Refusal value: "${message['refusal']}"');

                if (message['refusal'] != null &&
                    message['refusal'].toString().isNotEmpty) {
                  final refusal = message['refusal'].toString();
                  logError('OpenAI refused to respond: $refusal');
                  return Result.failure('AI応答拒否: $refusal');
                }

                logDebug('Content exists: ${message['content'] != null}');
                logDebug('Content value: "${message['content']}"');

                if (message['content'] != null) {
                  final content = message['content'].toString().trim();
                  logDebug(
                    'Content after trim: "$content" (length: ${content.length})',
                  );

                  if (content.isEmpty) {
                    logError('Empty content in OpenAI response');
                    return Result.failure(
                      'Empty response content from OpenAI API',
                    );
                  }
                  logDebug(
                    'OpenAI response parsed successfully: ${content.length} chars',
                  );
                  return Result.success('OpenAI API 応答が成功的に生成されました', content);
                } else {
                  logError('Content field is null');
                }
              } else {
                logError('Message field is null');
              }
            } else {
              logError(
                'Choice is not a Map<String, dynamic>: ${choice.runtimeType}',
              );
            }
            logError(
              'Invalid choice structure: ${choice is Map ? (choice).keys.join(", ") : "not a map"}',
            );
          } else {
            logError(
              'No choices in response. Keys: ${responseData.keys.join(", ")}',
            );
          }

          // 에러 정보가 있는 경우 포함
          final errorInfo = responseData['error'] != null
              ? ' Error: ${responseData['error']}'
              : '';
          final errorMsg = 'No valid response from OpenAI API$errorInfo';
          logError(errorMsg);
          return Result.failure(errorMsg);
        });
  }

  /// システムプロンプトを構築
  String _buildSystemPrompt(
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
  ) {
    String basePrompt = '''あなたは経験豊富なペット専門のAIアシスタントです。

【対応可能な相談内容】
・ペットの健康、病気の兆候、予防接種について
・行動問題、しつけ、トレーニング方法
・フード選び、栄養管理、アレルギー対策
・グルーミング、日常ケア、衛生管理
・ペット用品の選び方、環境整備
・多頭飼育、ペット同士の相性
・年齢別ケア（子犬・子猫、シニアペット）
・季節ごとの注意点、災害対策

【対応言語】
・日本語、韓国語、英語でのペット関連の質問にすべて対応します
・質問の言語に関わらず、ペットに関する内容であればお答えします
・回答は日本語で提供しますが、韓国語や英語の質問も理解できます

【回答スタイル】
・親しみやすく、わかりやすい日本語で説明
・具体的な例やステップを含める
・必要に応じて注意点やリスクを明確に伝える
・深刻な健康問題が疑われる場合は、必ず獣医師への相談を推奨

【重要な制約】
・ペットに関係のない質問（政治、経済、エンターテイメント、ゲーム、一般料理など）のみ、
  "申し訳ございませんが、ペットに関する質問のみお答えできます"と回答
・「펫이 밥을 안먹어」「강아지가 짖어요」のような韓国語のペット相談も歓迎します
・診断や処方箋の代わりにはなりません
・緊急時は必ず動物病院への受診を優先するよう案内''';

    // 날씨 및 산책 정보 추가
    if (weatherAdvice != null || walkGuide != null) {
      basePrompt += '\n\n【今日の情報】';

      if (weatherAdvice != null) {
        basePrompt += '\n・天気アドバイス：$weatherAdvice';
      }

      if (walkGuide != null) {
        basePrompt += '\n・散歩ガイド：$walkGuide';
      }

      basePrompt += '\n\n上記の情報を参考にして、必要に応じて散歩や外出に関するアドバイスに反映してください。';
    }

    if (petContext != null) {
      final age = petContext.age;
      final breedInfo = petContext.breed != null
          ? '（品種：${petContext.breed}）'
          : '';
      final birthYear = petContext.birthDate.year;
      final birthMonth = petContext.birthDate.month;
      final birthDay = petContext.birthDate.day;
      final createdYear = petContext.createdAt.year;
      final createdMonth = petContext.createdAt.month;
      final createdDay = petContext.createdAt.day;

      // 추가 정보가 있는 경우 포함
      String additionalDetails = '';
      if (petContext.additionalInfo != null &&
          petContext.additionalInfo!.isNotEmpty) {
        additionalDetails = '\n・追加情報：';
        petContext.additionalInfo!.forEach((key, value) {
          additionalDetails += '\n  - $key: $value';
        });
      }

      basePrompt +=
          '''

【相談対象のペット情報】
・名前：${petContext.name}
・種類：${petContext.typeName}$breedInfo
・年齢：$age歳（生年月日：$birthYear年$birthMonth月$birthDay日）
・登録日：$createdYear年$createdMonth月$createdDay日$additionalDetails

【初回の挨拶ガイドライン（ペット登録済み）】
1. ${petContext.name}ちゃん/くんの名前を呼んで親しみやすく挨拶
2. ${petContext.typeName}の$age歳という情報を踏まえた簡単なコメント
3. 対応可能な相談内容を簡潔に紹介
4. ${petContext.name}について何でも聞いてくださいと促す

例：
「こんにちは！${petContext.name}ちゃんですね🐶
$age歳の${petContext.typeName}なら、[年齢に応じた特徴]の時期ですね。

【${petContext.name}ちゃんについてご相談いただけること】
・健康状態や病気の兆候について
・しつけや問題行動の改善方法
・適切なフードや栄養管理
・日常ケアやお手入れのコツ
・年齢に応じた注意点

【対応言語】
日本語、韓国語、英語でご質問いただけます。
「밥을 안먹어요」「계속 짖어요」など、どの言語でも大丈夫です！

${petContext.name}ちゃんのことで気になることがあれば、
何でもお気軽にご質問ください！」

【回答時の重要ポイント】
・${petContext.name}の年齢（$age歳）に適した具体的なアドバイス
・${petContext.typeName}特有の特性や注意点を考慮
・個別の状況に応じたカスタマイズされた提案
・必要に応じて、獣医師への相談を推奨''';
    } else {
      basePrompt += '''

【初回の挨拶ガイドライン】
こんにちは！と親しみやすく挨拶してから、以下の内容を含めてください：
1. あなたがペット専門AIアシスタントであることの紹介
2. 対応可能な主要な相談分野を簡潔に列挙（健康、しつけ、フード、ケアなど）
3. より具体的なアドバイスのために、ペット情報の登録を推奨
4. 気軽に質問してほしいという親しみやすいメッセージ

例：
「こんにちは！私はペット専門のAIアシスタントです🐶🐱

【ご相談いただける内容】
・健康管理と病気の予防
・しつけとトレーニング方法
・フード選びと栄養管理
・日常ケアとグルーミング
・行動の悩みや疑問

【対応言語】
日本語、韓国語、英語でご質問いただけます。
どの言語でも、ペットに関することなら何でもお答えします！

ペット情報を登録いただくと、より個別化されたアドバイスが可能です。
どんなことでもお気軽にご質問ください！」''';
    }

    return basePrompt;
  }
}
