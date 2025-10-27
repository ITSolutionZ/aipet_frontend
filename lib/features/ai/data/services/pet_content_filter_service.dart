import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/services/ai_http_client_service.dart';

import '../../domain/domain.dart';

/// 펫 관련 콘텐츠 필터링 서비스
class PetContentFilterService {
  // ✅ Shared AiHttpClientService 사용
  final AiHttpClientService _httpClient;

  // 펫 관련 키워드 목록
  List<String> get _petKeywords => AiKeywords.petRelated;

  // 제외할 키워드
  List<String> get _excludeKeywords => AiKeywords.excluded;

  PetContentFilterService({AiHttpClientService? httpClient})
    : _httpClient = httpClient ?? AiHttpClientService();

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
    // ✅ Shared AiHttpClientService 사용
    final response = await _httpClient.callOpenAI<Map<String, dynamic>>(
      '/chat/completions',
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
        'max_completion_tokens': AiApiConstants
            .contentFilterMaxTokens, // ✅ max_tokens → max_completion_tokens
        'temperature': AiApiConstants.contentFilterTemperature,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception('AIによる検証に失敗しました');
    }

    final aiResponse = response.data!['choices'][0]['message']['content']
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
