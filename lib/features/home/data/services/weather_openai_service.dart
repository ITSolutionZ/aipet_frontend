import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 날씨 어드바이스 전용 OpenAI API 서비스
class WeatherOpenAIService extends BaseLoggingService {
  final OpenAiHttpClient _httpClient;

  WeatherOpenAIService({OpenAiHttpClient? httpClient})
    : _httpClient = httpClient ?? OpenAiHttpClient(),
      super('weather_openai_service');

  /// 날씨 정보를 바탕으로 산책 어드바이스 생성
  Future<Result<String>> generateWeatherAdvice(String prompt) async {
    final apiKey = AppConfig.current.openaiApiKey;

    if (apiKey.isEmpty) {
      return Result.failure('OpenAI API 키가 설정되지 않았습니다');
    }

    try {
      logDebug('🌤️ WeatherOpenAI: Generating weather advice...');

      final response = await _httpClient.callOpenAIWithRetry(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo', // 빠른 응답을 위해 gpt-3.5-turbo 사용
          'messages': [
            {
              'role': 'system',
              'content': '''あなたは犬の散歩アドバイザーです。
天気情報に基づいて、犬の散歩に関する簡潔で実用的なアドバイスを日本語で提供してください。
回答は20文字以内の1行で、絵文字を含めて親しみやすく書いてください。''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_completion_tokens': 50, // ✅ max_tokens → max_completion_tokens
          'temperature': 0.7,
        },
      );

      if (!response.isSuccess) {
        logError('WeatherOpenAI: API call failed - ${response.message}');
        return Result.failure(response.message);
      }

      final responseData = response.dataOrNull!;

      if (responseData['choices'] != null &&
          responseData['choices'] is List &&
          responseData['choices'].isNotEmpty) {
        final choice = responseData['choices'][0];
        if (choice is Map<String, dynamic> &&
            choice['message'] != null &&
            choice['message']['content'] != null) {
          final content = choice['message']['content'].toString().trim();
          if (content.isEmpty) {
            return Result<String>.failure(
              'Empty response content from OpenAI API',
            );
          }
          logDebug('✅ WeatherOpenAI: Success - $content');
          return Result<String>.success(
            'Weather advice generated successfully',
            content,
          );
        }
      }

      return Result<String>.failure('No valid response from OpenAI API');
    } catch (e) {
      logError('WeatherOpenAI: Exception - $e');
      return Result<String>.failure('OpenAI API call failed: $e');
    }
  }
}
