import 'package:flutter/material.dart';

import '../../../../features/ai/domain/domain.dart';
import '../../../../features/pet_registor/domain/entities/pet_profile_entity.dart';

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
    return [];
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

  /// AI 채팅 기록 목 데이터 (빈 상태로 시작)
  static List<AiMessageEntity> getChatHistory() {
    return [];
  }

  /// AI 채팅 세션 목 데이터 (일본어)
  static List<AiChatSessionEntity> getChatSessions() {
    return [
      AiChatSessionEntity(
        id: '1',
        title: 'ゆうくん食事問題相談',
        messages: getChatHistory(),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 7)),
        petId: '1',
      ),
    ];
  }

  /// AI 추천 질문 목 데이터 (일본語)
  static List<Map<String, dynamic>> getSuggestedQuestions() {
    return [
      {
        'id': '1',
        'question': 'ペットが食事を拒否する時はどうしたらいいですか？',
        'category': 'health',
      },
      {
        'id': '2',
        'question': '散歩中にペットが他の犬を怖がります',
        'category': 'behavior',
      },
      {'id': '3', 'question': '猫の適正なフード量はどれくらいですか？', 'category': 'feeding'},
    ];
  }

  /// 즐겨찾기 QA Mock 데이터 생성
  static List<AiFavoriteQaEntity> getFavoriteQAsMockData() {
    final now = DateTime.now();
    final mockPet1 = PetProfileEntity(
      id: 'pet1',
      name: 'ゆうくん',
      type: 'dog',
      breed: '柴犬',
      birthDate: DateTime(2020, 3, 15),
      ownerId: 'user1',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
      imagePath: null,
    );
    
    final mockPet2 = PetProfileEntity(
      id: 'pet2', 
      name: 'みゃあちゃん',
      type: 'cat',
      breed: 'マンチカン',
      birthDate: DateTime(2021, 7, 20),
      ownerId: 'user1',
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now.subtract(const Duration(days: 1)),
      imagePath: null,
    );
    
    return [
      AiFavoriteQaEntity(
        id: 'fav1',
        question: 'ペットが食事を拒否する時はどうしたらいいですか？',
        answer: '🍽️ お腹の調子が悪い理由はたくさんあります:\n\n1. **健康上の問題**: 歯の問題, 消化器の問題\n2. **ストレス**: 環境の変化, 新しい食事\n3. **活動量不足**: 運動が不足すると食欲が落ちます\n\n**解決策:**\n• 定められた時間に定期的に食事\n• 食器を清潔に保つ\n• 十分な運動でエネルギーを消費\n• 継続的に症状があれば獣医師に相談を推奨',
        pet: mockPet1,
        categoryId: 'health',
        categoryName: '健康',
        createdAt: now.subtract(const Duration(days: 2)),
        originalTimestamp: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      AiFavoriteQaEntity(
        id: 'fav2',
        question: '散歩の時間はどれくらいかかりますか?',
        answer: '🚶‍♂️ ペットの散歩ガイド:\n\n**小型犬 (5kg 未満)**\n• 1日30-60分 (2-3回に分けて)\n\n**中型犬 (5-25kg)**\n• 1日60-90分 (朝, 夕方)\n\n**大型犬 (25kg 以上)**\n• 1日90-120分 (活発な運動が必要)\n\n**注意事項:**\n• 暑い時間帯を避ける (アスファルトの熱傷に注意)\n• 十分な水分補給\n• 段階的に運動量を増やす',
        pet: mockPet1,
        categoryId: 'exercise',
        categoryName: '運動',
        createdAt: now.subtract(const Duration(days: 1)),
        originalTimestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      AiFavoriteQaEntity(
        id: 'fav3',
        question: '猫の適正なフード量はどれくらいですか？',
        answer: '🐱 猫のフード量ガイド:\n\n**年齢別の基準:**\n• 子猫 (2-12か月): 体重×80-100kcal/日\n• 成猫 (1-7歳): 体重×70-80kcal/日\n• 高齢猫 (7歳以上): 体重×60-70kcal/日\n\n**フードタイプ別:**\n• ドライフード: 1日2-3回に分けて\n• ウェットフード: 1日2回が理想\n\n**注意事項:**\n• 急な変更は避ける\n• 水分摂取量も重要\n• 体重変化を定期的にチェック',
        pet: mockPet2,
        categoryId: 'feeding',
        categoryName: '食事',
        createdAt: now.subtract(const Duration(hours: 5)),
        originalTimestamp: now.subtract(const Duration(hours: 6)),
      ),
      AiFavoriteQaEntity(
        id: 'fav4',
        question: '一般的なペットケアについて教えてください',
        answer: '🐾 一般的なペットケアの基本:\n\n**日常ケア:**\n• 定期的なブラッシング\n• 歯磨きまたは歯のケア\n• 爪切り\n• 耳掃除\n\n**健康管理:**\n• 年1-2回の健康チェック\n• 予防接種の継続\n• 体重管理\n• 異常な行動や症状の観察\n\n**環境整備:**\n• 清潔な生活空間\n• 適切な温度管理\n• 十分な運動と遊び時間',
        pet: null,
        categoryId: 'general',
        categoryName: '一般',
        createdAt: now.subtract(const Duration(hours: 3)),
        originalTimestamp: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  /// API 지연 시뮬레이션
  static Future<void> simulateApiDelay({int seconds = 1}) async {
    await Future.delayed(Duration(seconds: seconds));
  }
}