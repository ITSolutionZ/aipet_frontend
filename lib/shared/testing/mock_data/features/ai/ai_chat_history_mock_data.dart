import 'package:flutter/material.dart';

/// AI 채팅 히스토리 관련 Mock 데이터 서비스
///
/// 채팅 세션 리스트와 히스토리 데이터를 중앙에서 관리합니다.
class AiChatHistoryMockData {
  /// 채팅 히스토리 세션 목록
  static List<Map<String, dynamic>> getChatHistorySessions() {
    final now = DateTime.now();
    return [
      {
        'id': 'session_1',
        'title': 'ポチの食事相談',
        'summary': 'ポチが最近食事を拒否していて心配です...',
        'category': '健康',
        'categoryIcon': Icons.medical_services,
        'categoryColor': Colors.red,
        'petName': 'ポチ',
        'messageCount': 5,
        'lastMessageTime': now.subtract(const Duration(hours: 2)),
        'hasFavorites': true,
        'isManualSaved': true,
      },
      {
        'id': 'session_2',
        'title': '子犬の食事量相談',
        'summary': '生後3ヶ月のトイプードルの適切な食事量について...',
        'category': '食事',
        'categoryIcon': Icons.restaurant,
        'categoryColor': Colors.orange,
        'petName': 'ポチ',
        'messageCount': 3,
        'lastMessageTime': now.subtract(const Duration(days: 1)),
        'hasFavorites': false,
        'isManualSaved': false,
      },
      {
        'id': 'session_3',
        'title': '無駄吠え対策相談',
        'summary': '無駄吠えがひどくて困っています。しつけ方法を教えて...',
        'category': '行動',
        'categoryIcon': Icons.psychology,
        'categoryColor': Colors.blue,
        'petName': 'ポチ',
        'messageCount': 4,
        'lastMessageTime': now.subtract(const Duration(days: 3)),
        'hasFavorites': true,
        'isManualSaved': true,
      },
      {
        'id': 'session_4',
        'title': 'グルーミング方法',
        'summary': 'トイプードルの毛玉対策とブラッシング方法について...',
        'category': 'グルーミング',
        'categoryIcon': Icons.content_cut,
        'categoryColor': Colors.purple,
        'petName': 'ポチ',
        'messageCount': 6,
        'lastMessageTime': now.subtract(const Duration(days: 5)),
        'hasFavorites': false,
        'isManualSaved': false,
      },
      {
        'id': 'session_5',
        'title': 'ワクチン接種相談',
        'summary': '予防接種のスケジュールと副作用について心配で...',
        'category': '健康',
        'categoryIcon': Icons.medical_services,
        'categoryColor': Colors.red,
        'petName': 'ポチ',
        'messageCount': 7,
        'lastMessageTime': now.subtract(const Duration(days: 7)),
        'hasFavorites': true,
        'isManualSaved': false,
      },
    ];
  }

  /// 특정 세션의 채팅 히스토리 조회
  static List<Map<String, dynamic>> getChatSessionMessages(String sessionId) {
    switch (sessionId) {
      case 'session_1':
        return [
          {
            'id': 'msg_1',
            'content': 'ポチが最近食事を拒否していて心配です。どうしたら良いでしょうか？',
            'isUser': true,
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          },
          {
            'id': 'msg_2',
            'content':
                'ポチの食事拒否について心配ですね。🍽️\n\nまず確認していただきたいことがあります：\n• 最近フードを変更しましたか？\n• 体調や元気さはいかがでしょうか？',
            'isUser': false,
            'timestamp': DateTime.now().subtract(
              const Duration(hours: 1, minutes: 58),
            ),
          },
        ];
      default:
        return [];
    }
  }

  /// 검색 기능을 위한 필터링된 세션 목록
  static List<Map<String, dynamic>> searchChatSessions(String query) {
    if (query.isEmpty) return getChatHistorySessions();

    final lowerQuery = query.toLowerCase();
    return getChatHistorySessions().where((session) {
      final title = (session['title'] as String).toLowerCase();
      final summary = (session['summary'] as String).toLowerCase();
      final category = (session['category'] as String).toLowerCase();
      final petName = (session['petName'] as String).toLowerCase();

      return title.contains(lowerQuery) ||
          summary.contains(lowerQuery) ||
          category.contains(lowerQuery) ||
          petName.contains(lowerQuery);
    }).toList();
  }

  /// 카테고리별 세션 필터링
  static List<Map<String, dynamic>> getChatSessionsByCategory(String category) {
    return getChatHistorySessions()
        .where((session) => session['category'] == category)
        .toList();
  }

  /// 즐겨찾기가 있는 세션만 조회
  static List<Map<String, dynamic>> getFavoriteChatSessions() {
    return getChatHistorySessions()
        .where((session) => session['hasFavorites'] == true)
        .toList();
  }

  /// 특정 펫의 세션만 조회
  static List<Map<String, dynamic>> getChatSessionsByPet(String petName) {
    return getChatHistorySessions()
        .where((session) => session['petName'] == petName)
        .toList();
  }
}
