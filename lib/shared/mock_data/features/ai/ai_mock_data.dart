import 'package:flutter/material.dart';

import '../../../../features/ai/domain/domain.dart';

/// AI 관련 Mock 데이터 서비스
/// 
/// 실제 API 연계 전까지 사용하는 Mock 데이터를 중앙 관리합니다.
/// API 연계 시점에는 이 클래스의 구현만 실제 API 호출로 변경하면 됩니다.
class AiMockDataService {
  /// 초기 메시지
  static const String initialMessage = 'こんにちは！ aipetアシスタントです。 何かお手伝いできますか? 🐾';

  /// 추천 질문 목록
  static const List<Map<String, dynamic>> suggestedQuestions = [
    {
      'id': '1',
      'question': 'お腹の調子が悪い',
      'category': '食事',
      'icon': Icons.restaurant,
      'description': '食事量が少ない理由と解決策',
    },
    {
      'id': '2',
      'question': '散歩の時間はどれくらいかかりますか?',
      'category': '運動',
      'icon': Icons.directions_walk,
      'description': '適切な運動量のガイド',
    },
    {
      'id': '3',
      'question': '予防接種のスケジュールが気になります',
      'category': '健康',
      'icon': Icons.medical_services,
      'description': '予防接種の予定の案内',
    },
    {
      'id': '4',
      'question': '毛づくりのマニュアル',
      'category': 'メンテナンス',
      'icon': Icons.content_cut,
      'description': '季節別毛づくりのマニュアル',
    },
  ];

  /// AI 응답 템플릿
  static const Map<String, String> responseTemplates = {
    'food': '''🍽️ お腹の調子が悪い理由はたくさんあります:

1. **健康上の問題**: 歯の問題, 消化器の問題
2. **ストレス**: 環境の変化, 新しい食事
3. **活動量不足**: 運動が不足すると食欲が落ちます

**解決策:**
• 定められた時間に定期的に食事
• 食器を清潔に保つ
• 十分な運動でエネルギーを消費
• 継続的に症状があれば獣医師に相談を推奨''',

    'exercise': '''🚶‍♂️ ペットの散歩ガイド:

**小型犬 (5kg 未満)**
• 1日30-60分 (2-3回に分けて)

**中型犬 (5-25kg)**
• 1日60-90分 (朝, 夕方)

**大型犬 (25kg 以上)**
• 1日90-120分 (活発な運動が必要)

**注意事項:**
• 暑い時間帯を避ける (アスファルトの熱傷に注意)
• 十分な水分補給
• 段階的に運動量を増やす''',

    'vaccination': '''💉 ペットの予防接種スケジュール:

**犬の基本ワクチン:**
• 6-8週: 1回目の総合ワクチン
• 10-12週: 2回目の総合ワクチン + コロナ
• 14-16週: 3回目の総合ワクチン + 狂犬病

**年1回の追加接種:**
• 総合ワクチン (年1回)
• 狂犬病 (年1回)
• 心臓虫 (月1回)

獣医師と相談して、個別のスケジュールを立てることができます!''',

    'default': '''ペットについての質問ですね! 🐾

より正確な回答のために、より具体的な状況を教えてください:
• ペットの種類と年齢
• 現在の症状や状況
• いつから問題が始まったか

以下の推奨質問も参考にしてください!''',
  };

  /// 키워드별 응답 매핑
  static const Map<String, List<String>> keywordMapping = {
    'food': ['食事', '食事量', '食事量が少ない', 'お腹'],
    'exercise': ['散歩', '運動', '時間'],
    'vaccination': ['接種', 'ワクチン', '予防接種'],
  };

  /// 키워드 기반 응답 생성
  static String getResponseByKeyword(String userMessage) {
    for (final entry in keywordMapping.entries) {
      for (final keyword in entry.value) {
        if (userMessage.contains(keyword)) {
          return responseTemplates[entry.key] ?? responseTemplates['default']!;
        }
      }
    }
    return responseTemplates['default']!;
  }

  /// 채팅 히스토리 Mock 데이터 생성
  static List<Map<String, dynamic>> getChatHistoryMockData() {
    return [
      {
        'id': '1',
        'content': initialMessage,
        'type': 'assistant',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      }
    ];
  }

  /// AI 응답 Mock 데이터 생성
  static Map<String, dynamic> generateAiResponseMockData(String userMessage) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': getResponseByKeyword(userMessage),
      'type': 'assistant',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 채팅 세션 Mock 데이터 생성
  static Map<String, dynamic> createChatSessionMockData(String title, {String? petId}) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'messages': [],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'petId': petId,
      'petName': null,
    };
  }

  /// AI 채팅 기록 목 데이터
  static List<AiMessageEntity> getChatHistory() {
    return [
      AiMessageEntity(
        id: '1',
        content: initialMessage,
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      AiMessageEntity(
        id: '2',
        content: 'Max가 식사를 거부하고 있어요. 어떻게 해야 할까요?',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      AiMessageEntity(
        id: '3',
        content: 'Max의 식사 거부는 여러 원인이 있을 수 있습니다. 먼저 건강 상태를 확인해보시고, 사료를 바꿔보거나 소량으로 나누어 주는 것을 시도해보세요.',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ];
  }

  /// AI 채팅 세션 목 데이터
  static List<AiChatSessionEntity> getChatSessions() {
    return [
      AiChatSessionEntity(
        id: '1',
        title: 'Max 식사 문제 상담',
        messages: getChatHistory(),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 7)),
        petId: '1',
      ),
    ];
  }

  /// AI 추천 질문 목 데이터 (간단한 형태)
  static List<Map<String, dynamic>> getSuggestedQuestions() {
    return [
      {
        'id': '1',
        'question': '반려동물이 식사를 거부할 때는 어떻게 해야 하나요?',
        'category': 'health',
      },
      {
        'id': '2',
        'question': '산책 중 반려동물이 다른 강아지를 무서워해요',
        'category': 'behavior',
      },
      {'id': '3', 'question': '고양이의 적정 사료량은 얼마인가요?', 'category': 'feeding'},
    ];
  }

  /// API 지연 시뮬레이션
  static Future<void> simulateApiDelay({int seconds = 1}) async {
    await Future.delayed(Duration(seconds: seconds));
  }
}