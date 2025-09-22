import '../../../../../features/ai/ai.dart';

/// AI 채팅 메시지 관련 Mock 데이터 서비스
///
/// 채팅 메시지와 대화 내용을 중앙에서 관리합니다.
class AiChatMessagesMockData {
  /// Mock 채팅 히스토리 데이터 생성 (펫 선택부터 모든 상호작용 포함)
  static List<AiMessageEntity> getChatHistory() {
    final now = DateTime.now();
    return [
      // 펫 선택 과정
      AiMessageEntity(
        id: 'system_1',
        content: 'こんにちは！ペット専門AIアシスタントです。🐾\\n\\nまず、どのペットについて相談したいですか？',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      AiMessageEntity(
        id: 'user_1',
        content: 'ポチについて相談したいです',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 58)),
      ),

      // 카테고리 선택 과정
      AiMessageEntity(
        id: 'system_2',
        content:
            'ポチについてですね！🐕\\n\\nどのような内容でお困りですか？カテゴリを選択してください：\\n\\n• 健康 - 病気、怪我、健康管理\\n• 食事 - フード、栄養、給餌\\n• 行動 - しつけ、問題行動\\n• グルーミング - お手入れ、毛づくろい\\n• その他',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 55)),
      ),
      AiMessageEntity(
        id: 'user_2',
        content: '健康について相談したいです',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 50)),
      ),

      // 구체적인 질문 안내
      AiMessageEntity(
        id: 'system_3',
        content:
            'ポチの健康について、どのような症状や心配事がありますか？\\n\\nポチの状況を詳しく教えてください。症状、期間、食欲の変化なども含めて説明していただけると、より正確なアドバイスができます。',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
      ),
      // 오늘 대화
      AiMessageEntity(
        id: 'msg_1',
        content: 'ポチが最近食事を拒否していて心配です。どうしたら良いでしょうか？',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
      ),
      AiMessageEntity(
        id: 'msg_2',
        content: '''ポチの食事拒否について心配ですね。🍽️

まず確認していただきたいことがあります：
• 最近フードを変更しましたか？
• 体調や元気さはいかがでしょうか？
• 普段と違う行動はありませんか？

一般的に食事拒否の原因として：
- ストレスや環境の変化
- フードの好み
- 体調不良
- 歯や口腔内の問題

などが考えられます。2-3日続くようでしたら獣医師にご相談されることをお勧めします。''',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 28)),
      ),
      AiMessageEntity(
        id: 'msg_3',
        content: 'フードは変えていませんが、最近引っ越しをしました。それが関係しているのでしょうか？',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 25)),
      ),
      AiMessageEntity(
        id: 'msg_4',
        content: '''引っ越しが原因の可能性が高いですね！🏠

ペットは環境の変化にとても敏感です。引っ越しによるストレスで食欲が落ちることはよくあります。

対処法をご提案します：
• 静かで落ち着ける場所で食事をさせる
• 慣れ親しんだ食器やおもちゃを使用
• 普段通りの食事時間を維持
• 無理強いせず、様子を見る

通常は1-2週間で慣れることが多いです。ただし、食事を全く取らない日が2日以上続く場合は、脱水や栄養不足のリスクがあるため獣医師にご相談ください。

ポチが新しい環境に早く慣れることを願っています！''',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
      ),
      AiMessageEntity(
        id: 'msg_5',
        content: 'ありがとうございます！安心しました。様子を見てみます。',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
      ),

      // 어제 대화
      AiMessageEntity(
        id: 'msg_6',
        content: '子犬の適切な食事量はどのくらいですか？生後3ヶ月のトイプードルです。',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      AiMessageEntity(
        id: 'msg_7',
        content: '''生後3ヶ月のトイプードルですね！🐕

子犬の食事量は体重と成長段階によって決まります：

**基本的な目安：**
• 体重1kgあたり50-70gのドライフード
• 1日3-4回に分けて給餌
• 成長期なので栄養価の高い子犬用フードを選択

**トイプードル特有の注意点：**
• 低血糖症になりやすいので定期的な給餌が重要
• 小粒のフードを選ぶ
• 食べきれる分を少量ずつ与える

フードのパッケージに記載されている給餌量を参考に、子犬の体調と成長を見ながら調整してください。心配であれば獣医師やペットショップでも相談できます。

元気に成長してくれるといいですね！''',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 55)),
      ),

      // 3일 전 대화
      AiMessageEntity(
        id: 'msg_8',
        content: '無駄吠えがひどくて困っています。しつけ方法を教えてください。',
        type: MessageType.user,
        timestamp: now.subtract(const Duration(days: 3, hours: 5)),
      ),
      AiMessageEntity(
        id: 'msg_9',
        content: '''無駄吠えのお悩みですね。効果的な改善方法をご紹介します！🔊

**基本的なアプローチ：**
1. **原因を特定**
   - 警戒心、退屈、要求、興奮など

2. **無視する方法**
   - 要求吠えには一切反応しない
   - 静かになったらご褒美を与える

3. **代替行動を教える**
   - 「おすわり」「まて」などの指示に従ったら褒める
   - 吠える前に気をそらす

4. **環境を整える**
   - 吠える原因となる刺激を取り除く
   - 十分な運動と精神的刺激を提供

**重要なポイント：**
• 叱るのではなく、正しい行動を褒める
• 一貫性を持って継続する
• 家族全員で同じ方法で対応

根気強く続けることが大切です！''',
        type: MessageType.assistant,
        timestamp: now.subtract(const Duration(days: 3, hours: 4, minutes: 50)),
      ),
    ];
  }
}
