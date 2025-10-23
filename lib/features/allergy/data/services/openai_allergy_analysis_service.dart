import 'dart:convert';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/domain.dart';

/// OpenAI를 사용한 알레르기 분석 서비스
class OpenAIAllergyAnalysisService implements AllergyAnalysisService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// OpenAI API 키
  String get _apiKey => EnvironmentConstants.openAiApiKey;

  @override
  Future<AllergyAnalysisResult> analyzeIngredients({
    required List<ProductEntity> allergyProducts,
    required List<ProductEntity> nonAllergyProducts,
    String? petType,
  }) async {
    // API 키가 없으면 즉시 fallback
    if (_apiKey.isEmpty) {
      return _getFallbackResult(allergyProducts, nonAllergyProducts);
    }

    try {
      // 프롬프트 생성
      final prompt = _buildPrompt(
        allergyProducts,
        nonAllergyProducts,
        petType ?? 'dog',
      );

      // OpenAI API 호출 (30초 타임아웃)
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': AllergyConstants.openAiModel,
              'messages': [
                {'role': 'system', 'content': _getSystemPrompt()},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': AllergyConstants.openAiTemperature,
              'max_tokens': AllergyConstants.openAiMaxTokens,
            }),
          )
          .timeout(
            const Duration(seconds: AllergyConstants.openAiTimeoutSeconds),
            onTimeout: () {
              throw Exception('API Timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;

        // GPT 응답을 파싱
        return _parseGPTResponse(content);
      } else {
        throw Exception('OpenAI API Error: ${response.statusCode}');
      }
    } catch (e) {
      // 에러 발생 시 기본 분석 결과 반환
      LoggerService.debug('OpenAI Analysis Error: $e');
      return _getFallbackResult(allergyProducts, nonAllergyProducts);
    }
  }

  /// 시스템 프롬프트
  String _getSystemPrompt() {
    return '''
あなたはペットフードの成分分析とアレルギー診断の専門家です。
提供された情報を基に、アレルギーの疑いがある原料を特定し、
飼い主が理解しやすい日本語で説明してください。

分析結果は以下の形式で返してください：
{
  "suspected_ingredients": ["原料1", "原料2", "原料3"],
  "analysis": "詳細な分析説明（日本語）",
  "confidence": 0.85,
  "recommendations": ["推奨事項1", "推奨事項2"]
}
''';
  }

  /// 프롬프트 생성
  String _buildPrompt(
    List<ProductEntity> allergyProducts,
    List<ProductEntity> nonAllergyProducts,
    String petType,
  ) {
    final allergyProductNames = allergyProducts.map((p) => p.name).join('\n');
    final nonAllergyProductNames = nonAllergyProducts
        .map((p) => p.name)
        .join('\n');

    return '''
ペットタイプ: $petType

【アレルギー反応があった商品】
$allergyProductNames

【アレルギー反応がなかった商品】
$nonAllergyProductNames

上記の情報を基に、アレルギーの疑いがある原料を特定してください。
各商品の一般的な原料を考慮し、アレルギー商品に共通して含まれる原料を分析してください。
''';
  }

  /// GPT 응답 파싱
  AllergyAnalysisResult _parseGPTResponse(String content) {
    try {
      // JSON 형식으로 파싱 시도
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final data = jsonDecode(jsonStr);

        return AllergyAnalysisResult(
          suspectedIngredients: List<String>.from(
            data['suspected_ingredients'] ?? [],
          ),
          analysis: data['analysis'] ?? content,
          confidence: (data['confidence'] ?? 0.7).toDouble(),
          recommendations: List<String>.from(data['recommendations'] ?? []),
        );
      }
    } catch (e) {
      // JSON 파싱 실패 시 텍스트 그대로 사용
    }

    // 기본 파싱
    return AllergyAnalysisResult(
      suspectedIngredients: _extractIngredients(content),
      analysis: content,
      confidence: AllergyConstants.defaultConfidence,
      recommendations: [],
    );
  }

  /// 텍스트에서 원료 추출
  List<String> _extractIngredients(String text) {
    final ingredients = <String>[];
    final lines = text.split('\n');

    for (final line in lines) {
      if (line.contains('•') || line.contains('-') || line.contains('・')) {
        final cleaned = line.replaceAll(RegExp(r'[•\-・]'), '').trim();
        if (cleaned.isNotEmpty) {
          ingredients.add(cleaned);
        }
      }
    }

    return ingredients.take(10).toList();
  }

  /// Fallback 결과 (API 실패 시)
  AllergyAnalysisResult _getFallbackResult(
    List<ProductEntity> allergyProducts,
    List<ProductEntity> nonAllergyProducts,
  ) {
    // 제품명에서 키워드 추출
    final allergyProductNames = allergyProducts
        .map((p) => p.name.toLowerCase())
        .join(' ');
    final suspectedKeywords = <String>[];

    // 일반적인 알레르기 원료 키워드 검색
    final commonAllergens = {
      'チキン': ['チキン', 'chicken', '鶏肉', '鶏', 'とり'],
      '小麦': ['小麦', 'wheat', '麦', 'むぎ'],
      '大豆': ['大豆', 'soy', '豆', 'まめ'],
      'トウモロコシ': ['トウモロコシ', 'corn', 'コーン'],
      '牛肉': ['牛肉', 'beef', 'ビーフ', '牛'],
      '乳製品': ['乳', 'milk', 'ミルク', 'dairy'],
    };

    for (final entry in commonAllergens.entries) {
      if (entry.value.any((keyword) => allergyProductNames.contains(keyword))) {
        suspectedKeywords.add(entry.key);
      }
    }

    // 키워드가 없으면 기본값
    if (suspectedKeywords.isEmpty) {
      suspectedKeywords.addAll(['トウモロコシ', '鶏肉ミール', '小麦']);
    }

    return AllergyAnalysisResult(
      suspectedIngredients: suspectedKeywords.take(3).toList(),
      analysis:
          '''
アレルギー反応があった「${allergyProducts.first.name}」には、一般的にトウモロコシ、鶏肉ミール、小麦などが含まれており、これらは犬にとってアレルギーを引き起こす可能性のある原料です。

これらの原料は多くのドッグフードに使用されていますが、個体によってはアレルギー反応を示すことがあります。

※ この分析はサンプルデータに基づく一般的な情報です。OpenAI APIと連携することで、より詳細な分析が可能になります。
''',
      confidence: AllergyConstants.fallbackConfidence,
      recommendations: [
        '獣医師に相談し、正確なアレルギーテストを受けることをお勧めします',
        '疑わしい原料を含まないフードを試してみてください',
        'フード切り替えは徐々に行い、反応を観察してください',
      ],
    );
  }
}
