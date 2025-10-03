# PR #19: アレルギー機能の実装 - ペットの食物アレルギー分析システム

## 📋 概要

ペットの食物アレルギーを特定するための包括的な機能を実装しました。アレルギー反応があった商品となかった商品を登録し、OpenAI API を使用して疑わしい原料を分析します。

## 🎯 実装内容

### 1. **アレルギーメイン画面** (`AllergyMainScreen`)

#### 機能

- ✅ ペット選択機能（複数ペット対応）
- ✅ アレルギー発生/未発生の商品登録ボタン
- ✅ 登録商品の 2 段階タブ表示
  - 1 段階: アレルギー あった / なかった
  - 2 段階: 사료 / 영양제 / 간식 / 생식
- ✅ OpenAI 分析実行ボタン
- ✅ 保存された分析結果アコーディオン

#### UI/UX

- 原料分析案内カード
- 色分けされた選択ボタン（分홍色/緑色）
- ペット情報表示
- スクロール可能なリスト

### 2. **商品選択画面** (`AllergyProductSelectionScreen`)

#### 機能

- ✅ カテゴリタブ（사료/영양제/간식/생식）
- ✅ リアルタイム商品検索
- ✅ 推奨フィルター（퍼피/어덜트/시니어/건식/습식/발습식）
- ✅ 人気ブランド表示（6 個）

#### データ

- ブランド: 6 個（Royal Canin, Hill's, Purina, Orijen, Acana, CIAO）
- 商品: 20 個（各カテゴリ別）

### 3. **分析結果画面** (`AllergyAnalysisResultScreen`)

#### 機能

- ✅ OpenAI GPT-4o 分析結果表示
- ✅ グラデーションヘッダーカード
- ✅ 疑わしい原料リスト
- ✅ 詳細分析説明
- ✅ 推奨事項
- ✅ 分析結果保存機能

#### セクション構成

1. 統計ヘッダー（アレルギー商品/なし商品/信頼度）
2. 疑わしい原料セクション
3. 詳細分析セクション
4. 推奨事項セクション

### 4. **保存された分析結果リスト画面** (`SavedAnalysisListScreen`)

#### 機能

- ✅ ローカルストレージから分析結果をロード
- ✅ 分析結果カード表示
- ✅ 削除機能
- ✅ 再閲覧機能

### 5. **OpenAI API 連携** (`OpenAIAllergyAnalysisService`)

#### 実装

- ✅ GPT-4o モデル使用
- ✅ 30 秒タイムアウト設定
- ✅ 日本語プロンプト設計
- ✅ Fallback ロジック（API 失敗時）
- ✅ キーワード抽出による簡易分析

#### プロンプト設計

```
システム: ペットフード成分分析とアレルギー診断の専門家
ユーザー: アレルギー商品とアレルギーなし商品のリスト

→ 疑わしい原料を特定
→ 詳細分析説明
→ 推奨事項提供
```

### 6. **ローカルストレージ** (`SavedAnalysisRepository`)

#### 実装

- ✅ SharedPreferences 使用
- ✅ JSON 形式で保存
- ✅ 型安全なシリアライゼーション
- ✅ アプリ再起動後もデータ保持

## 📁 ファイル構成

### Domain Layer

```
lib/features/allergy/domain/
├── entities/
│   ├── allergy_post_entity.dart       # アレルギー投稿エンティティ
│   ├── brand_entity.dart              # ブランドエンティティ
│   ├── product_entity.dart            # 商品エンティティ
│   └── saved_analysis_entity.dart     # 保存された分析エンティティ
└── services/
    └── allergy_analysis_service.dart  # 分析サービスインターフェース
```

### Data Layer

```
lib/features/allergy/data/
├── models/
│   ├── allergy_post_model.dart
│   ├── brand_model.dart
│   └── product_model.dart
├── providers/
│   ├── allergy_providers.dart         # アレルギー商品管理
│   ├── allergy_service_providers.dart # 分析サービスProvider
│   └── saved_analysis_provider.dart   # 保存された分析Provider
├── repositories/
│   └── saved_analysis_repository.dart # ローカルストレージRepository
└── services/
    └── openai_allergy_analysis_service.dart  # OpenAI実装
```

### Presentation Layer

```
lib/features/allergy/presentation/
├── screens/
│   ├── allergy_main_screen.dart              # メイン画面
│   ├── allergy_product_selection_screen.dart # 商品選択画面
│   ├── allergy_analysis_result_screen.dart   # 分析結果画面
│   └── saved_analysis_list_screen.dart       # 保存リスト画面
└── widgets/
    ├── allergy_filter_chips.dart      # フィルターチップ
    ├── allergy_pet_selector.dart      # ペット選択
    ├── allergy_post_card.dart         # 投稿カード
    └── saved_analysis_accordion.dart  # 保存リストアコーディオン
```

### Mock Data

```
lib/shared/mock_data/
├── allergy_mock_data.dart           # アレルギー投稿Mock
├── brand_mock_data.dart             # ブランドMock（6個）
├── product_mock_data.dart           # 商品Mock（20個）
└── saved_analysis_mock_data.dart    # 保存された分析Mock（3個）
```

## 🔄 データフロー

### アレルギー商品管理

```dart
AllergyProductData {
  allergyProducts: List<ProductEntity>,      // アレルギー発生商品
  nonAllergyProducts: List<ProductEntity>,   // アレルギーなし商品
}
```

### 分析プロセス

```
1. 商品登録（アレルギー発生/未発生別）
   ↓
2. 「アレルギー原料を分析」ボタン
   ↓
3. OpenAI API呼び出し（GPT-4o）
   ↓
4. 分析結果表示
   ↓
5. 保存（SharedPreferences）
```

## 🎨 UI/UX 特徴

### 色分け

- **分홍色 (#FF6B9D)**: アレルギー発生商品
- **緑色 (#4CAF50)**: アレルギーなし商品
- **茶色 (AppColors.pointBrown)**: アクション・強調

### タブ構造

```
メインタブ: [⚠ あった(3)] [✓ なかった(2)]
  └─ カテゴリタブ: [사료] [영양제] [간식] [생식]
      └─ 商品リスト（スクロール可能）
```

### レスポンシブデザイン

- LayoutBuilder 使用
- SingleChildScrollView + IntrinsicHeight
- 固定高さ(500px)のタブビュー

## 🔧 技術的実装

### 1. **State 管理**

- Riverpod (riverpod_annotation)
- AsyncNotifier for 非同期データ
- Provider 間の依存関係管理

### 2. **データ永続化**

- SharedPreferences
- JSON シリアライゼーション
- 型安全な変換（List<dynamic> → List<String>）

### 3. **OpenAI API**

```dart
Model: gpt-4o
Timeout: 30秒
Temperature: 0.7
Max Tokens: 1500
```

### 4. **エラーハンドリング**

- API 失敗時の Fallback
- タイムアウト処理
- ローディング表示
- ユーザーフィードバック（SnackBar）

## 🧪 テスト

### Mock Data

- ✅ ブランド: 6 個（主要ペットフードブランド）
- ✅ 商品: 20 個（カテゴリ別）
- ✅ 保存された分析: 3 個（異なる日付）

### テストシナリオ

1. 商品検索機能
2. 商品追加/削除
3. タブ切り替え
4. 分析実行
5. 結果保存
6. 保存リスト表示

## 📱 ルーティング

```dart
RouteConstants.allergyRoute = '/home/allergy'
```

ホームメニューの「アレルギー」ボタンからアクセス

## 🔐 環境変数

```.env
OPENAI_API_KEY=sk-proj-xxxxxxxx  # OpenAI API連携用
```

## 📊 統計

### 追加されたファイル

- Entity: 4 個
- Model: 3 個
- Provider: 3 個
- Repository: 1 個
- Service: 2 個
- Screen: 4 個
- Widget: 4 個
- Mock Data: 4 個

**合計: 25 ファイル**

### コード行数

- Dart: 約 2,500 行
- Mock Data: 約 500 行

## 🚀 次のステップ

### Phase 1: 基本機能完成 ✅

- [x] アレルギー商品登録
- [x] OpenAI 分析機能
- [x] ローカル保存機能

### Phase 2: API 連携（今後）

- [ ] バックエンド API 実装
- [ ] 実際の商品データベース連携
- [ ] 原料データベース構築
- [ ] より詳細な分析アルゴリズム

### Phase 3: 機能拡張（今後）

- [ ] 分析履歴グラフ
- [ ] アレルギー原料統計
- [ ] コミュニティ投稿機能
- [ ] エクスポート機能（PDF）

## 🎯 主な改善点

### コード品質

- ✅ Clean Architecture 原則準拠
- ✅ 型安全性の確保
- ✅ エラーハンドリング強化
- ✅ DRY 原則適用

### パフォーマンス

- ✅ ListView.builder 使用
- ✅ 適切な Widget 分離
- ✅ const constructor 活用

### ユーザー体験

- ✅ 直感的な UI/UX
- ✅ 明確なフィードバック
- ✅ スムーズなナビゲーション
- ✅ アクセシビリティ考慮

## 📝 注意事項

### Mock Data 使用

現在は Mock Data を使用しています。API 連携時には以下を更新:

- `product_mock_data.dart` → API 呼び出し
- `brand_mock_data.dart` → API 呼び出し
- `saved_analysis_mock_data.dart` → 削除

### OpenAI API

- API キーが未設定の場合、自動的に Fallback 分析を使用
- Fallback では一般的なアレルギー原料を表示

## 🔗 関連 Issue

- #XX: ペットアレルギー管理機能の実装

## 📸 スクリーンショット

### 1. アレルギーメイン画面

- ペット選択ドロップダウン
- 原料分析案内
- アレルギー発生/未発生ボタン
- 登録商品タブリスト

### 2. 商品選択画面

- カテゴリタブ
- 検索バー
- 推奨フィルター
- 人気ブランド

### 3. 分析結果画面

- 統計ヘッダー
- 疑わしい原料
- 詳細分析
- 推奨事項

### 4. 保存リスト画面

- 分析履歴カード
- 日付表示
- 削除機能

## ✅ チェックリスト

- [x] コード品質
  - [x] Lint エラーなし
  - [x] 適切な命名規則
  - [x] コメント・ドキュメント追加
- [x] 機能
  - [x] すべての画面が正常動作
  - [x] OpenAI API 連携準備完了
  - [x] ローカルストレージ動作確認
- [x] UI/UX
  - [x] デザインシステム準拠
  - [x] 日本語 UI
  - [x] レスポンシブデザイン
- [x] データ管理
  - [x] Clean Architecture 適用
  - [x] Riverpod 状態管理
  - [x] 適切なエラーハンドリング

## 🎓 学習ポイント

### 1. **2 段階タブ構造**

- TabController 複数管理
- StatefulWidget 内でのネスト

### 2. **型安全な JSON 変換**

```dart
// List<dynamic> → List<String>
List<String>.from(json['key'] as List)
```

### 3. **PopupMenuButton 活用**

- カスタムコンテンツ表示
- アコーディオン風 UI

### 4. **SharedPreferences 活用**

- 複雑なデータ構造の永続化
- JSON 変換パターン

## 🐛 既知の制限事項

1. **ブランドロゴ**

   - 現在はテキスト表示
   - 今後、実際のロゴ画像に置き換え予定

2. **OpenAI API**

   - API キーが必要
   - Fallback 分析は簡易版

3. **商品データ**
   - Mock Data のみ
   - API 連携で実データに置き換え予定

## 📖 使用方法

1. ホーム画面から「アレルギー」メニューをタップ
2. ペットを選択
3. 「アレルギー あった」または「なかった」ボタンをタップ
4. 商品を検索・選択
5. 両方の商品が登録されたら「アレルギー原料を分析」をタップ
6. 分析結果を確認
7. 必要に応じて「保存」をタップ
8. 左上のフォルダアイコンから過去の分析を確認

## 🙏 レビューポイント

1. **アーキテクチャ**: Clean Architecture 原則の適用
2. **OpenAI 連携**: プロンプト設計とエラーハンドリング
3. **UI/UX**: タブ構造とスクロール動作
4. **データ永続化**: SharedPreferences の使用方法
5. **型安全性**: JSON 変換ロジック

---

**作成者**: @j-lee
**日付**: 2025 年 10 月 3 日
**ブランチ**: `feature/alregic`
**マージ先**: `main`
