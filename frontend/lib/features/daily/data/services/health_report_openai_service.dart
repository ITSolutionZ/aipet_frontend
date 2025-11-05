import 'package:intl/intl.dart';


import '../../../../shared/shared.dart';
import '../../../../app/config/app_config.dart';

/// AI 건강 리포트 생성을 위한 OpenAI API 서비스
class HealthReportOpenAIService extends BaseLoggingService {
  final OpenAiHttpClient _httpClient;

  HealthReportOpenAIService({OpenAiHttpClient? httpClient})
    : _httpClient = httpClient ?? OpenAiHttpClient(),
      super('health_report_openai_service');

  /// 펫의 1개월 건강 리포트 생성
  ///
  /// [petName] 펫 이름
  /// [petType] 펫 종류 (dog, cat 등)
  /// [petAge] 펫 나이
  /// [petWeight] 펫 체중
  /// [healthData] 건강 데이터 (체온, 증상 등)
  /// [vaccineData] 백신 접종 기록
  /// [weightHistory] 체중 변화 기록
  /// [allergyInfo] 알레르기 정보
  Future<Result<String>> generateMonthlyHealthReport({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required Map<String, dynamic> healthData,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) async {
    final apiKey = AppConfig.current.openaiApiKey;

    if (apiKey.isEmpty) {
      // API 키가 없으면 에러 반환
      logWarning('HealthReportOpenAI: API 키가 설정되지 않음');
      return Result.failure('OpenAI API 키가 설정되지 않았습니다.');
    }

    try {
      logDebug('📊 HealthReportOpenAI: Generating monthly health report...');

      final prompt = _buildHealthReportPrompt(
        petName: petName,
        petType: petType,
        petAge: petAge,
        petWeight: petWeight,
        healthData: healthData,
        vaccineData: vaccineData,
        weightHistory: weightHistory,
        allergyInfo: allergyInfo,
      );

      final response = await _httpClient
          .callOpenAIWithRetry(
            '/chat/completions',
            data: {
              'model': 'gpt-3.5-turbo', // 빠른 응답을 위해 gpt-3.5-turbo 사용
              'messages': [
                {
                  'role': 'system',
                  'content': '''あなたは経験豊富な獣医師であり、ペットの健康管理の専門家です。
ペットの1ヶ月間の健康データを分析し、包括的な健康レポートを作成してください。

【レポートに含める内容】
1. 健康状態の総合評価
2. 体重変化の分析とトレンド
3. ワクチン接種状況と次回推奨時期
4. 気になる症状や異常の指摘
5. 栄養面での推奨事項（必要な栄養素）
6. アレルギー食材を除外した食事の提案
7. 運動と生活習慣のアドバイス
8. 獣医師への受診が必要な症状の有無

【重要な制約】
- 専門的かつ親しみやすい日本語で記述
- データに基づいた客観的な分析
- 具体的で実践可能なアドバイス
- アレルギー食材は必ず除外
- 緊急性のある問題は明確に指摘''',
                },
                {'role': 'user', 'content': prompt},
              ],
              'max_completion_tokens':
                  1500, // ✅ max_tokens → max_completion_tokens
              'temperature': 0.7,
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              logWarning('HealthReportOpenAI: API call timeout');
              throw Exception('API呼び出しがタイムアウトしました');
            },
          );

      if (!response.isSuccess) {
        logError('HealthReportOpenAI: API call failed - ${response.message}');
        return Result.failure('リポート生成に失敗しました: ${response.message}');
      }

      final responseData = response.dataOrNull;
      if (responseData == null) {
        logError('HealthReportOpenAI: No response data');
        return Result.failure('リポート生成に失敗しました');
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
            logError('HealthReportOpenAI: Empty content');
            return Result.failure('空のリポートが生成されました');
          }

          logDebug('✅ HealthReportOpenAI: Success');
          return Result.success('健康リポート生成成功', content);
        }
      }

      logError('HealthReportOpenAI: Invalid response structure');
      return Result.failure('無効なレスポンス形式');
    } catch (e, stackTrace) {
      logError('HealthReportOpenAI: Error - $e');
      logDebug('Stack trace: $stackTrace');
      return Result.failure('リポート生成中にエラーが発生しました: $e');
    }
  }

  /// 건강 리포트 프롬프트 생성
  String _buildHealthReportPrompt({
    required String petName,
    required String petType,
    required int petAge,
    required double petWeight,
    required Map<String, dynamic> healthData,
    required List<Map<String, dynamic>> vaccineData,
    required List<Map<String, dynamic>> weightHistory,
    Map<String, dynamic>? allergyInfo,
  }) {
    final petTypeJapanese = _getPetTypeInJapanese(petType);

    // 알레르기 정보 포맷팅
    final allergyItems = allergyInfo?['items'] as List<String>? ?? [];
    final allergySource = allergyInfo?['source'] as String? ?? 'ai';
    final allergyText = allergyItems.isEmpty
        ? 'なし'
        : '${allergyItems.join('、')} (${allergySource == 'test' ? '検査確認済み' : 'AI推定'})';

    // 백신 정보 포맷팅
    final vaccineText = vaccineData.isEmpty
        ? '記録なし'
        : vaccineData
              .map((v) {
                final vaccineName = v['vaccineName'] ?? '不明';
                final vaccinatedDate = v['vaccinatedDate'] as DateTime?;
                final dateStr = vaccinatedDate != null
                    ? DateFormat('yyyy年MM月dd日').format(vaccinatedDate)
                    : '日付不明';
                return '- $vaccineName: $dateStr';
              })
              .join('\n');

    // 체중 변화 정보 포맷팅
    final weightText = weightHistory.isEmpty
        ? '記録なし'
        : weightHistory
              .take(5)
              .map((w) {
                final date = w['date'] as DateTime;
                final dateStr = DateFormat('MM/dd').format(date);
                return '$dateStr: ${w['weight']}kg';
              })
              .join(', ');

    // 건강 데이터 포맷팅
    final temperature = healthData['temperature'];
    final temperatureText = temperature != null ? '$temperature°C' : '記録なし';
    final symptoms = healthData['symptoms'] ?? [];
    final symptomsText = symptoms.isEmpty
        ? '特異事項なし'
        : (symptoms as List).join('、');

    return '''
【ペット基本情報】
名前: $petName
種類: $petTypeJapanese
年齢: $petAge歳
現在の体重: ${petWeight}kg

【健康データ（過去1ヶ月）】
体温記録: $temperatureText
症状: $symptomsText
体重履歴: $weightText

【ワクチン接種記録】
$vaccineText

【アレルギー情報】
除外が必要な食材: $allergyText

上記のデータを基に、$petNameの1ヶ月間の健康状態を総合的に分析し、
詳細な健康レポートを作成してください。

特に以下の点に注目してください：
1. 現在の健康状態の評価
2. 体重変化のトレンドと適正体重との比較
3. ワクチン接種の必要性
4. 栄養面での改善提案（アレルギー食材を除く）
5. 日常生活でのアドバイス
6. 獣医師への相談が必要な事項
''';
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
}
