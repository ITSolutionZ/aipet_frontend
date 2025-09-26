import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/ai/domain/constants/ai_constants.dart';
import 'package:aipet_frontend/features/ai/domain/errors/ai_errors.dart';
import 'package:aipet_frontend/features/ai/domain/services/token_usage_service.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/core/services/ai_http_client_service.dart';
import 'package:aipet_frontend/shared/core/services/unified_error_handler.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';

import 'pet_content_filter_service.dart';

/// OpenAI API와 통신하는 서비스
class OpenAIService extends BaseLoggingService {
  final PetContentFilterService _contentFilter = PetContentFilterService();
  final AiHttpClientService _httpClient;

  OpenAIService({AiHttpClientService? httpClient})
    : _httpClient = httpClient ?? AiHttpClientService(),
      super('openai_service');

  /// OpenAI ChatGPT API를 사용하여 메시지에 대한 응답 생성 (재시도 로직 포함)
  Future<String> generateResponse(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    final apiKey = AppConfig.current.openaiApiKey;

    if (apiKey.isEmpty) {
      throw AiOpenAIException(AiErrorKeys.apiKeyError, code: 'MISSING_API_KEY');
    }

    // ペット関連コンテンツ検証 (펫 컨텍스트가 있으면 스킵)
    if (petContext == null) {
      try {
        final validationResult = await _contentFilter.validatePetContent(
          message,
        );
        if (!validationResult.isValid) {
          logInfo(
            'Non-pet related content detected: ${validationResult.reason}',
          );
          return '''こんにちは！私はペット専門のAIアシスタントです。🐶🐱

${_translateReasonToJapanese(validationResult.reason)}

以下のような内容についてご質問ください：
• ペットの健康と病気について
• フードと栄養管理
• 行動矯正とトレーニング
• グルーミングとケア
• ペット用品と環境
• 保護と譲渡相談

具体的な状況を教えていただければ、より正確なサポートを提供できます！😊''';
        }
      } catch (e) {
        logError('Content filter validation failed: $e');
        // 통합 에러 핸들러로 에러 처리
        await UnifiedErrorHandler.handleUnifiedError(
          e,
          context: {'operation': 'content_filter_validation'},
        );
        // 컨텐츠 필터링 실패 시에도 계속 진행
      }
    }

    return _httpClient.executeWithRetry(() async {
      // 🪙 토큰 사용량 사전 체크
      final canMakeRequest = TokenUsageService.canMakeRequest(
        estimatedTokens: AiApiConstants.openaiMaxTokens,
      );
      if (!canMakeRequest.isSuccess) {
        throw AiOpenAIException(
          canMakeRequest.errorOrNull ?? 'Token limit exceeded',
          code: 'TOKEN_LIMIT_EXCEEDED',
        );
      }

      final response = await _httpClient.callOpenAI<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': AiApiConstants.openaiModel,
          'messages': [
            {'role': 'system', 'content': _buildSystemPrompt(petContext)},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': AiApiConstants.openaiMaxTokens,
          'temperature': AiApiConstants.openaiTemperature,
        },
      );

      // 🪙 토큰 사용량 기록
      if (response['usage'] != null) {
        final usage = response['usage'] as Map<String, dynamic>;
        final promptTokens = usage['prompt_tokens'] as int? ?? 0;
        final completionTokens = usage['completion_tokens'] as int? ?? 0;

        final usageResult = TokenUsageService.recordUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          model: AiApiConstants.openaiModel,
          userId: petContext?.id, // 펫 ID를 사용자 식별자로 사용
        );

        if (usageResult.isSuccess) {
          logInfo(
            'Token usage recorded: ${usageResult.dataOrNull!.totalTokens} tokens',
          );
        } else {
          logWarning(
            'Failed to record token usage: ${usageResult.errorOrNull ?? 'Unknown error'}',
          );
        }
      }

      if (response['choices'] != null &&
          response['choices'] is List &&
          response['choices'].isNotEmpty) {
        final choice = response['choices'][0];
        if (choice is Map<String, dynamic> &&
            choice['message'] != null &&
            choice['message']['content'] != null) {
          final content = choice['message']['content'].toString().trim();
          if (content.isEmpty) {
            throw AiOpenAIException(
              'Empty response content from OpenAI API',
              code: 'EMPTY_RESPONSE',
            );
          }
          return content;
        }
      }

      // 에러 정보가 있는 경우 포함
      final errorInfo = response['error'] != null
          ? ' Error: ${response['error']}'
          : '';
      throw AiOpenAIException(
        'No valid response from OpenAI API$errorInfo',
        code: 'NO_VALID_RESPONSE',
      );
    });
  }

  /// 検証理由を日本語に翻訳 (필터 서비스와 동일한 메시지)
  String _translateReasonToJapanese(String reason) {
    switch (reason) {
      case 'ペットと関連していない話題です':
        return 'ペットと関連していない話題です';
      case 'ペットに関連する内容を含めてご質問ください':
        return 'ペットに関連する内容を含めてご質問ください';
      case 'ペットに関連していないご質問です':
        return 'ペットに関連していないご質問です';
      case 'ペットに関連する内容をより具体的にご質問ください':
        return 'ペットに関連する内容をより具体的にご質問ください';
      case 'ペット関連のご質問です':
        return 'ペット関連のご質問です';
      case '内容が短すぎます。ペット関連の具体的な質問を入力してください':
        return '内容が短すぎます。ペット関連の具体的な質問を入力してください';
      default:
        return 'ペットに関連する内容を含めてご質問ください';
    }
  }

  /// システムプロンプトを構築
  String _buildSystemPrompt(PetProfileEntity? petContext) {
    String basePrompt = '''あなたはペット専門のAIアシスタントです。
ペットの健康、行動、トレーニング、栄養、一般的なケアに関する質問にのみお答えください。
回答は親しみやすく、わかりやすく書いてください。
深刻な健康問題が疑われる場合は、必ず獣医師への相談をお勧めしてください。

重要：ペットに関係のない質問（政治、経済、エンターテイメント、ゲーム、料理など）には答えず、
"ペットに関する質問のみお答えできます"と回答してください。''';

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

  // BaseLoggingService의 로깅 메서드들을 사용
  // logError, logInfo, logWarning, logDebug 메서드들이 자동으로 사용 가능
}
