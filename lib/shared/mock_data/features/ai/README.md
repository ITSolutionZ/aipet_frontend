# AI Mock Data

## 概要

このディレクトリには、AIアシスタント機能で使用されるモックデータが含まれています。実際のAPI連携が完成するまで、テスト用のデータとして活用されます。

## ファイル構成

### `ai_mock_data.dart`

AIアシスタント機能のモックデータサービスクラス。

#### 主要機能

##### 1. 初期メッセージ

- AIアシスタントの最初の挨拶メッセージ
- 日本語対応: "こんにちは！aipetアシスタントです。何かお手伝いできますか? 🐾"

##### 2. 推奨質問リスト (`suggestedQuestions`)

- 食事、運動、健康、メンテナンスの4つのカテゴリ
- 各質問にはアイコンと詳細説明が含まれる

| カテゴリ | 質問例 | アイコン |
|----------|--------|----------|
| 食事 | お腹の調子が悪い | restaurant |
| 運動 | 散歩の時間はどれくらいかかりますか? | directions_walk |
| 健康 | 予防接種のスケジュールが気になります | medical_services |
| メンテナンス | 毛づくりのマニュアル | content_cut |

##### 3. 回答テンプレート (`responseTemplates`)

- キーワードベースの自動回答システム
- 食事、運動、予防接種の詳細な回答を提供
- デフォルト回答で追加情報を要求

##### 4. チャット履歴管理

- メッセージ履歴の生成機能
- 複数のチャットセッション管理
- タイムスタンプとメッセージタイプの管理

##### 5. API遅延シミュレーション

- 実際のAPI呼び出しを模擬する遅延機能
- テスト環境でのUX確認用

## 使用方法

```dart
// 初期メッセージの取得
String greeting = AiMockDataService.initialMessage;

// 推奨質問の取得
List<Map<String, dynamic>> questions = AiMockDataService.suggestedQuestions;

// キーワードベースの回答生成
String response = AiMockDataService.getResponseByKeyword("食事");

// チャット履歴の取得
List<AiMessageEntity> history = AiMockDataService.getChatHistory();

// API遅延のシミュレーション
await AiMockDataService.simulateApiDelay(seconds: 2);
```

## API連携時の注意点

実際のAPI連携時には、このクラスの実装を実際のAPI呼び出しに置き換える必要があります。モックデータの構造は実際のAPIレスポンス構造と一致するように設計されているため、フロントエンドのコード変更を最小限に抑えることができます。

## データ形式

### メッセージエンティティ

```dart
{
  'id': String,
  'content': String,
  'type': 'user' | 'assistant',
  'timestamp': DateTime
}
```

### チャットセッションエンティティ

```dart
{
  'id': String,
  'title': String,
  'messages': List<AiMessageEntity>,
  'createdAt': DateTime,
  'updatedAt': DateTime,
  'petId': String?
}
```

## 多言語対応

現在、AIの回答は日本語に対応しており、ペットケアに関する専門的な情報を提供しています。将来的には他言語への対応も検討できます。
