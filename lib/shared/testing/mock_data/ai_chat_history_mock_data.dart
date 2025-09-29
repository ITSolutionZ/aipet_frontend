import 'package:flutter/material.dart';

/// AI 채팅 히스토리 Mock 데이터
///
/// AI 채팅 관련 Mock 데이터를 제공합니다.
class AiChatHistoryMockData {
  /// Mock 채팅 히스토리 세션 반환 (화면에서 사용)
  static List<Map<String, dynamic>> getChatHistorySessions() {
    return [
      {
        'id': 'chat-1',
        'title': 'ペットの健康相談',
        'summary': 'Maxiの健康管理について相談しました。定期的な健康診断の重要性について話し合いました。',
        'category': 'health',
        'categoryIcon': Icons.medical_services,
        'categoryColor': Colors.green,
        'petName': 'Maxi',
        'petId': 'pet-1',
        'lastMessageTime': DateTime.now().subtract(Duration(hours: 2)),
        'messageCount': 8,
        'isManualSaved': false,
        'hasFavorites': true,
        'createdAt': DateTime.now().subtract(Duration(hours: 2)),
      },
      {
        'id': 'chat-2',
        'title': 'しつけについて',
        'summary': 'お手の教え方について相談しました。段階的なトレーニング方法を学びました。',
        'category': 'training',
        'categoryIcon': Icons.school,
        'categoryColor': Colors.blue,
        'petName': 'Maxi',
        'petId': 'pet-1',
        'lastMessageTime': DateTime.now().subtract(Duration(days: 1)),
        'messageCount': 12,
        'isManualSaved': true,
        'hasFavorites': false,
        'createdAt': DateTime.now().subtract(Duration(days: 1)),
      },
      {
        'id': 'chat-3',
        'title': '食事の相談',
        'summary': '適切なフードの選び方について相談しました。栄養バランスの重要性を学びました。',
        'category': 'feeding',
        'categoryIcon': Icons.restaurant,
        'categoryColor': Colors.orange,
        'petName': 'Luna',
        'petId': 'pet-2',
        'lastMessageTime': DateTime.now().subtract(Duration(days: 2)),
        'messageCount': 6,
        'isManualSaved': false,
        'hasFavorites': true,
        'createdAt': DateTime.now().subtract(Duration(days: 2)),
      },
    ];
  }

  /// Mock 채팅 히스토리 반환
  static List<Map<String, dynamic>> getMockChatHistory() {
    return [
      {
        'id': 'chat-1',
        'title': 'ペットの健康相談',
        'petId': 'pet-1',
        'petName': 'Maxi',
        'messages': [
          {
            'id': 'msg-1',
            'content': 'こんにちは、Maxiの健康について相談があります',
            'type': 'user',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)),
          },
          {
            'id': 'msg-2',
            'content': 'こんにちは！Maxiの健康について、どのようなご相談でしょうか？',
            'type': 'assistant',
            'timestamp': DateTime.now().subtract(
              Duration(hours: 2, minutes: -1),
            ),
          },
        ],
        'category': 'health',
        'isManualSaved': false,
        'createdAt': DateTime.now().subtract(Duration(hours: 2)),
      },
      {
        'id': 'chat-2',
        'title': 'しつけについて',
        'petId': 'pet-1',
        'petName': 'Maxi',
        'messages': [
          {
            'id': 'msg-3',
            'content': 'お手の教え方を教えてください',
            'type': 'user',
            'timestamp': DateTime.now().subtract(Duration(days: 1)),
          },
          {
            'id': 'msg-4',
            'content': 'お手を教えるには、まずおやつを使って...',
            'type': 'assistant',
            'timestamp': DateTime.now().subtract(
              Duration(days: 1, minutes: -2),
            ),
          },
        ],
        'category': 'training',
        'isManualSaved': true,
        'createdAt': DateTime.now().subtract(Duration(days: 1)),
      },
    ];
  }
}
