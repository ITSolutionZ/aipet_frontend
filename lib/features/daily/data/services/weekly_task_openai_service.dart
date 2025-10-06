import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/ai_http_client_service.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:flutter/foundation.dart';

/// 주차별 펫 케어 할 일 전용 OpenAI API 서비스
class WeeklyTaskOpenAIService extends BaseLoggingService {
  final AiHttpClientService _httpClient;

  WeeklyTaskOpenAIService({AiHttpClientService? httpClient})
    : _httpClient = httpClient ?? AiHttpClientService(),
      super('weekly_task_openai_service');

  /// 펫 종류와 주차 정보를 바탕으로 금주의 할 일 생성
  Future<Result<String>> generateWeeklyTask({
    required String petType,
    required int weekOfYear,
  }) async {
    final apiKey = AppConfig.current.openaiApiKey;

    if (apiKey.isEmpty) {
      return Result.failure('OpenAI API 키가 설정되지 않았습니다');
    }

    try {
      debugPrint(
        '📅 WeeklyTaskOpenAI: Generating weekly task for $petType, week $weekOfYear...',
      );

      final prompt = _buildPrompt(petType, weekOfYear);

      final response = await _httpClient.callOpenAI<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo', // 빠른 응답을 위해 gpt-3.5-turbo 사용
          'messages': [
            {
              'role': 'system',
              'content': '''あなたはペットケアの専門家です。
ペットの種類と週番号に基づいて、その週に特に注意すべきペットケアのタスクを提案してください。

【重要な制約】
- 1行で30文字以内で構成してください
- 簡潔で実用的なアドバイスを日本語で提供してください
- 改行コードを使わず、1行で完結させてください

例: 「爪切りと耳掃除の時期です」「予防接種の確認をしましょう」''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 60, // 1행 응답을 위해 토큰 수 조정
          'temperature': 0.7,
        },
      );

      if (!response.isSuccess) {
        debugPrint('❌ WeeklyTaskOpenAI: API call failed - ${response.message}');
        return _getFallbackTask(petType, weekOfYear);
      }

      final responseData = response.dataOrNull;
      if (responseData == null) {
        debugPrint('❌ WeeklyTaskOpenAI: No response data');
        return _getFallbackTask(petType, weekOfYear);
      }

      // choices 배열에서 응답 추출
      if (responseData['choices'] != null &&
          responseData['choices'] is List &&
          (responseData['choices'] as List).isNotEmpty) {
        final choice = responseData['choices'][0];
        if (choice is Map<String, dynamic> &&
            choice['message'] != null &&
            choice['message']['content'] != null) {
          final content = choice['message']['content'].toString().trim();

          if (content.isEmpty) {
            debugPrint('❌ WeeklyTaskOpenAI: Empty content');
            return _getFallbackTask(petType, weekOfYear);
          }

          debugPrint('✅ WeeklyTaskOpenAI: Success - $content');
          return Result.success('주차별 할 일 생성 성공', content);
        }
      }

      debugPrint('❌ WeeklyTaskOpenAI: Invalid response structure');
      return _getFallbackTask(petType, weekOfYear);
    } catch (e, stackTrace) {
      debugPrint('❌ WeeklyTaskOpenAI: Error - $e');
      debugPrint('Stack trace: $stackTrace');
      return _getFallbackTask(petType, weekOfYear);
    }
  }

  /// 프롬프트 생성
  String _buildPrompt(String petType, int weekOfYear) {
    final petTypeJapanese = _getPetTypeInJapanese(petType);
    return '''ペットの種類: $petTypeJapanese
週番号: $weekOfYear週目

この週に特に注意すべきペットケアのタスクを1行で、30文字以内で簡潔に提案してください。''';
  }

  /// 펫 타입을 일본어로 변환
  String _getPetTypeInJapanese(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'hamster':
        return 'ハムスター';
      case 'rabbit':
        return 'うさぎ';
      case 'turtle':
        return '亀';
      default:
        return 'ペット';
    }
  }

  /// Fallback 할 일 반환 (API 실패 시)
  Result<String> _getFallbackTask(String petType, int weekOfYear) {
    // 주차를 4로 나눈 나머지로 순환하는 기본 할 일 제공
    final taskIndex = weekOfYear % 4;

    final dogTasks = [
      '爪切りと耳掃除の時期です',
      '予防接種の確認をしましょう',
      '歯磨き習慣をチェックしよう',
      '健康診断と体重測定の週です',
    ];

    final catTasks = [
      '爪研ぎ器と爪のケアをチェック',
      'ワクチン記録を確認しましょう',
      'ブラッシングで毛玉予防を',
      '歯のケアと口内健康チェック',
    ];

    final otherTasks = [
      '健康チェックと体調管理の週',
      '環境整備で清潔に保ちましょう',
      '栄養バランスを確認しよう',
      'ケア記録を更新しましょう',
    ];

    List<String> tasks;
    switch (petType.toLowerCase()) {
      case 'dog':
        tasks = dogTasks;
        break;
      case 'cat':
        tasks = catTasks;
        break;
      default:
        tasks = otherTasks;
    }

    return Result.success('기본 할 일 제공', tasks[taskIndex]);
  }
}
