import 'package:flutter/material.dart';

import '../../domain/entities/ai_message_entity.dart';

/// AI 채팅 컨트롤러
///
/// AI 채팅의 비즈니스 로직을 담당합니다.
class AiChatController {
  final List<AiMessageEntity> _messages = [];
  final List<AiSuggestedQuestionEntity> _suggestedQuestions = [];

  AiChatController() {
    _initializeMessages();
    _initializeSuggestedQuestions();
  }

  /// 메시지 목록 가져오기
  List<AiMessageEntity> get messages => List.unmodifiable(_messages);

  /// 추천 질문 목록 가져오기
  List<AiSuggestedQuestionEntity> get suggestedQuestions =>
      List.unmodifiable(_suggestedQuestions);

  /// 초기 메시지 설정
  void _initializeMessages() {
    _messages.add(
      AiMessageEntity(
        id: '1',
        content: 'こんにちは！ aipetアシスタントです。 何かお手伝いできますか? 🐾',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );
  }

  /// 추천 질문 초기화
  void _initializeSuggestedQuestions() {
    _suggestedQuestions.addAll([
      const AiSuggestedQuestionEntity(
        id: '1',
        question: 'お腹の調子が悪い',
        category: '食事',
        icon: Icons.restaurant,
        description: '食事量が少ない理由と解決策',
      ),
      const AiSuggestedQuestionEntity(
        id: '2',
        question: '散歩の時間はどれくらいかかりますか?',
        category: '運動',
        icon: Icons.directions_walk,
        description: '適切な運動量のガイド',
      ),
      const AiSuggestedQuestionEntity(
        id: '3',
        question: '予防接種のスケジュールが気になります',
        category: '健康',
        icon: Icons.medical_services,
        description: '予防接種の予定の案内',
      ),
      const AiSuggestedQuestionEntity(
        id: '4',
        question: '毛づくりのマニュアル',
        category: 'メンテナンス',
        icon: Icons.content_cut,
        description: '季節別毛づくりのマニュアル',
      ),
    ]);
  }

  /// 메시지 전송
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _notifyMessagesChanged();

    // AI 응답 생성
    final aiResponse = await _generateAiResponse(content.trim());
    _messages.add(aiResponse);
    _notifyMessagesChanged();
  }

  /// AI 응답 생성
  Future<AiMessageEntity> _generateAiResponse(String userMessage) async {
    // 실제로는 AI API 호출
    await Future.delayed(const Duration(seconds: 2));

    final String aiResponse = _getResponseByKeyword(userMessage);

    return AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: aiResponse,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
    );
  }

  /// 키워드별 응답 생성
  String _getResponseByKeyword(String userMessage) {
    if (userMessage.contains('食事') ||
        userMessage.contains('食事量') ||
        userMessage.contains('食事量が少ない')) {
      return '''🍽️ お腹の調子が悪い理由はたくさんあります:

1. **健康上の問題**: 歯の問題, 消化器の問題
2. **ストレス**: 環境の変化, 新しい食事
3. **活動量不足**: 運動が不足すると食欲が落ちます

**解決策:**
• 定められた時間に定期的に食事定められた時間に定期的に食事
• 食器を清潔に保つ
• 十分な運動でエネルギーを消費
• 継続的に症状があれば獣医師に相談を推奨継続的に症状があれば獣医師に相談を推奨''';
    } else if (userMessage.contains('散歩') || userMessage.contains('運動')) {
      return '''🚶‍♂️ ペットの散歩ガイド:ペットの散歩ガイド

**小型犬 (5kg 未満)**
• 1日30-60分 (2-3回に分けて)2-3回に分けて

**中型犬 (5-25kg)**
• 1日60-90分 (朝, 夕方)

  **大型犬 (25kg 以上)**
• 1日90-120分 (活発な運動が必要)活発な運動が必要

**注意事項:**
• 暑い時間帯を避ける (アスファルトの熱傷に注意)アスファルトの熱傷に注意
• 十分な水分補給
• 段階的に運動量を増やす''';
    } else if (userMessage.contains('接種') || userMessage.contains('ワクチン')) {
      return '''💉 ペットの予防接種スケジュール:

**犬の基本ワクチン:**
• 6-8週: 1回目の総合ワクチン
• 10-12週: 2回目の総合ワクチン + コロナ
• 14-16週: 3回目の総合ワクチン + 狂犬病

**年1回の追加接種:**
• 総合ワクチン (年1回)
• 狂犬病 (年1回)
• 心臓虫 (月1回)

獣医師と相談して、個別のスケジュールを立てることができます!''';
    } else {
      return '''ペットについての質問ですね! 🐾

より正確な回答のために、より具体的な状況を教えてください:
• ペットの種類と年齢
• 現在の症状や状況
• いつから問題が始まったか

以下の推奨質問も参考にしてください!''';
    }
  }

  /// 채팅 기록 초기화
  void clearChatHistory() {
    _messages.clear();
    _initializeMessages();
    _notifyMessagesChanged();
  }

  /// 메시지 추가 (외부에서 사용)
  void addMessage(AiMessageEntity message) {
    _messages.add(message);
  }

  /// 메시지 목록 업데이트 알림을 위한 콜백
  Function()? onMessagesChanged;

  /// 메시지 변경 알림
  void _notifyMessagesChanged() {
    onMessagesChanged?.call();
  }
}
