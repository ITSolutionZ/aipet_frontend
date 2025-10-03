# Allergy Feature (アレルギー機能)

## 概要

ペットの食物アレルギーを特定するための機能です。アレルギー反応があった商品となかった商品を登録し、OpenAI API を使用して疑わしい原料を分析します。

## 機能構成

### 1. **アレルギーメイン画面** (`allergy_main_screen.dart`)

- ペット選択（複数ペット対応）
- アレルギー発生/未発生の商品登録
- 登録商品のタブ表示（発生/未発生 → カテゴリ別）
- OpenAI 分析実行

### 2. **商品選択画面** (`allergy_product_selection_screen.dart`)

- カテゴリタブ（사료/영양제/간식/생식）
- 商品検索機能
- ブランドフィルター
- 推奨フィルター

### 3. **OpenAI 分析サービス** (`openai_allergy_analysis_service.dart`)

- GPT-4o モデル使用
- 商品名から原料を推測
- 疑わしい原料の特定
- 信頼度算出
- 推奨事項提供

## データ構造

### AllergyProductData

```dart
{
  allergyProducts: List<ProductEntity>,      // アレルギー発生商品
  nonAllergyProducts: List<ProductEntity>,   // アレルギー未発生商品
}
```

### AllergyAnalysisResult

```dart
{
  suspectedIngredients: List<String>,   // 疑わしい原料
  analysis: String,                     // 分析説明
  confidence: double,                   // 信頼度 (0.0~1.0)
  recommendations: List<String>,        // 推奨事項
}
```

## OpenAI API 設定

### 1. 環境変数設定

`.env` ファイルに以下を追加:

```env
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxx
```

### 2. API 使用方法

```dart
// 分析サービス取得
final service = ref.read(allergyAnalysisServiceProvider);

// 分析実行
final result = await ref
  .read(selectedAllergyProductsProvider.notifier)
  .analyzeAllergyIngredients(petId, service);
```

## GPT プロンプト設計

### システムプロンプト

```
あなたはペットフードの成分分析とアレルギー診断の専門家です。
提供された情報を基に、アレルギーの疑いがある原料を特定し、
飼い主が理解しやすい日本語で説明してください。
```

### ユーザープロンプト

```
ペットタイプ: dog

【アレルギー反応があった商品】
ロイヤルカナン ドッグフード 小型犬用 8kg
ヒルズ サイエンスダイエット 成犬用 6.5kg

【アレルギー反応がなかった商品】
CIAO ちゅ〜る まぐろ味 14g×20本

上記の情報を基に、アレルギーの疑いがある原料を特定してください。
```

## 分析ロジック

1. **商品名収集**: アレルギー発生/未発生商品のリスト化
2. **OpenAI 呼 � び出し**: GPT-4o で原料分析
3. **結果パース**: JSON 形式で構造化データ取得
4. **フォールバック**: API 失敗時は一般的なアレルギー原料を表示

## エラーハンドリング

- **API 接続失敗**: フォールバック結果を返す
- **データなし**: エラーメッセージ表示
- **パース失敗**: テキストそのままを表示

## UI/UX

### タブ構造

```
[⚠ あった(3)] [✓ なかった(2)]  ← メインタブ
  ↓
[사료(2)] [영양제(1)] [간식(0)] [생식(0)]  ← カテゴリタブ
  ↓
[商品リスト（スクロール可能）]
```

### 分析結果ダイアログ

- 商品数の表示
- 信頼度の表示
- 疑わしい原料リスト
- 詳細分析説明
- 推奨事項

## ルーティング

```dart
RouteConstants.allergyRoute = '/home/allergy'
```

ホームメニューの「アレルギー」ボタンからアクセス可能

## Mock Data

- **ブランド**: 6 個（ロイヤルカナン、ヒルズ、ピュリナ、オリジン、アカナ、CIAO）
- **商品**: 20 個（사료11、간식3、영양제3、생식2、영양제3）

## TODO

- [ ] OpenAI API キーの設定
- [ ] 実際の商品データベースとの連携
- [ ] 原料データベースの構築
- [ ] より詳細な分析アルゴリズム
- [ ] 分析履歴の保存機能
