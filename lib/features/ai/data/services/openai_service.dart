import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/shared.dart';

import '../../domain/domain.dart';

/// OpenAI API와 통신하는 서비스
class OpenAIService extends BaseLoggingService {
  final AiHttpClientService _httpClient;

  OpenAIService({AiHttpClientService? httpClient})
    : _httpClient = httpClient ?? AiHttpClientService(),
      super('openai_service');

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

    return _httpClient.executeWithRetry(() async {
      // 🪙 토큰 사용량 사전 체크
      final canMakeRequest = TokenUsageService.canMakeRequest(
        estimatedTokens: AiApiConstants.openaiMaxTokens,
      );
      if (!canMakeRequest.isSuccess) {
        return Result.failure(
          canMakeRequest.error?.toString() ?? 'Token limit exceeded',
        );
      }

      final response = await _httpClient.callOpenAI<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': AppConfig.current.openaiModel,
          'messages': [
            {
              'role': 'system',
              'content': _buildSystemPrompt(
                petContext,
                weatherAdvice,
                walkGuide,
              ),
            },
            {'role': 'user', 'content': message},
          ],
          'max_completion_tokens': AiApiConstants
              .openaiMaxTokens, // ✅ max_tokens → max_completion_tokens
          // ✅ temperature는 모델 기본값(1.0) 사용 - gpt-4o-mini는 기본값만 지원
        },
      );

      if (!response.isSuccess) {
        logError('OpenAI API call failed: ${response.message}');
        return Result.failure(response.message ?? 'Unknown error');
      }

      final responseData = response.dataOrNull!;

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
        final choice = responseData['choices'][0];
        if (choice is Map<String, dynamic> &&
            choice['message'] != null &&
            choice['message']['content'] != null) {
          final content = choice['message']['content'].toString().trim();
          if (content.isEmpty) {
            return Result.failure('Empty response content from OpenAI API');
          }
          return Result.success('OpenAI API 응답이 성공적으로 생성되었습니다', content);
        }
      }

      // 에러 정보가 있는 경우 포함
      final errorInfo = responseData['error'] != null
          ? ' Error: ${responseData['error']}'
          : '';
      return Result.failure('No valid response from OpenAI API$errorInfo');
    });
  }

  /// システムプロンプトを構築
  String _buildSystemPrompt(
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
  ) {
    String basePrompt = '''あなたはペット専門のAIアシスタントです。
ペットの健康、行動、トレーニング、栄養、一般的なケアに関する質問にのみお答えください。
回答は親しみやすく、わかりやすく書いてください。
深刻な健康問題が疑われる場合は、必ず獣医師への相談をお勧めしてください。

重要：ペットに関係のない質問（政治、経済、エンターテイメント、ゲーム、料理など）には答えず、
"ペットに関する質問のみお答えできます"と回答してください。''';

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

初回の挨拶では、${petContext.name}の名前を呼んでペット専門アシスタントとして親しみやすく挨拶してください。
このペットの詳細情報を考慮して、より具体的で個別化されたアドバイスを提供してください。
${petContext.name}の年齢（$age歳）、種類（${petContext.typeName}）に応じた特性を踏まえた専門的な回答をお願いします。

例：
- 年齢に応じた健康管理やケア方法
- 種類別の行動特性や注意点
- 個体の特徴を考慮したアドバイス''';
    } else {
      basePrompt += '''

初回の挨拶では、ペット専門アシスタントとして親しみやすく挨拶してください。
ペット全般に関する基本的なアドバイスを提供し、より具体的な相談のためにペット情報の登録をお勧めしてください。''';
    }

    return basePrompt;
  }
}
