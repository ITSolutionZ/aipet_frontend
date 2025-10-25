# feat(pet_profile): 全タブのインライン編集機能と健康管理システムを実装

## 📋 変更概要

ペットプロフィール画面の全タブでインライン編集機能を実装し、健康管理、栄養管理機能を大幅に強化しました。また、Firebase 互換性問題と Weather API 最適化も実施しました。

## 🎯 主な変更内容

### 1. **全タブのインライン編集機能実装**

#### 基本情報タブ

-   ✅ 名前、性別、体重、外見をインラインで編集可能
-   ✅ 誕生日、家に来た日を DatePicker で選択
-   ✅ マイクロチップ番号を直接入力
-   ✅ 中性化状態を表示

#### 健康タブ

-   ✅ 日本の犬ワクチン接種体系を実装
    -   コアワクチン 5 種（ジステンパー、パルボ、肝炎、アデノ、パラインフル）
    -   法定接種（狂犬病）
    -   予防薬（フィラリア、ノミ・ダニ）
    -   追加ワクチン（コロナ、レプトスピラ、ライム病、ケンネルコフ等）
-   ✅ 診療記録を追加・管理可能
-   ✅ 予約・スケジュールを追加・管理可能
-   ✅ 前回/次回接種日を縦配置で表示

#### 栄養タブ

-   ✅ 食べる餌、栄養剤、おやつを SearchableDropdown で選択
-   ✅ PetFoodLocalDatasource の内部リストを使用
-   ✅ 選択した商品が additionalInfo に自動保存

#### 活動・入養タブ

-   ✅ isEditMode パラメータを追加（今後の拡張に対応）

### 2. **データベース連携強化**

#### additionalInfo 構造拡張

```json
{
    // 基本情報
    "appearance": "外見の特徴",
    "guardianName": "保護者名",
    "institutionName": "登録機関",
    "isNeutered": true,

    // 栄養情報（新規追加）
    "food": "ドッグフード（ドライ）",
    "supplement": "ビタミン剤",
    "treat": "ドッグクッキー",

    // 健康情報（新規追加）
    "vaccinations": [
        {
            "type": "ジステンパー",
            "lastDate": "2024-03-15",
            "nextDate": "2025-03-15",
            "status": "完了"
        }
    ],
    "medicalRecords": [
        {
            "title": "定期健康診断",
            "hospital": "田中動物病院",
            "date": "2024-07-20",
            "status": "正常"
        }
    ],
    "appointments": [
        {
            "title": "次回健康診断",
            "hospital": "田中動物病院",
            "date": "2025-01-20",
            "time": "10:00"
        }
    ]
}
```

#### データ型修正

-   ✅ food/supplement/treat を String 型で保存（以前は List として誤処理）
-   ✅ vaccinations/medicalRecords/appointments を List<Map>で保存
-   ✅ didUpdateWidget で自動データ更新

### 3. **Firebase/Xcode 互換性修正**

#### 問題

```
Swift Compiler Error: Access level on imports require
'-enable-experimental-feature AccessLevelOnImport'
```

#### 解決策

-   ✅ Firebase SDK: 12.4.0 → 11.15.0 にダウングレード
-   ✅ ios/Podfile: Swift 5.9 を明示的に設定
-   ✅ Swift 6.0 実験的機能を無効化

### 4. **Weather API 最適化**

#### Before

```
One Call API 3.0 → 401エラー → 基本APIにフォールバック
```

#### After

```
基本API (2.5) を直接使用 → 200成功
```

**改善効果**:

-   不要な API 呼び出しを削減
-   レスポンス速度向上
-   ログがシンプルに

### 5. **Mock データ削除**

-   ❌ Before: データがなくても Mock 予防接種記録 7 件を表示
-   ✅ After: データがない場合は「記録がありません」と明確に表示

### 6. **日本語ローカリゼーション追加**

```yaml
flutter_localizations:
    sdk: flutter
```

```dart
localizationsDelegates: [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
]
```

DatePicker が日本語で正常に表示されるように修正。

## 🔧 技術的な改善

### UI/UX 改善

#### ダイアログ不要のインライン編集

-   編集モード ON: 各フィールドが直接編集可能に
-   編集モード OFF: 読み取り専用で表示
-   視覚的フィードバック: 編集中のフィールドはボーダー強調

#### データ表示の改善

-   前回/次回接種日: 縦配置で視認性向上
-   空状態: アイコン+メッセージで明確化
-   ステータス: ドロップダウンで変更可能

### データフロー

```
1. ユーザー入力 → TextEditingController
2. onChanged → updateFormData()
3. editFormData更新
4. 保存ボタン → savePetProfile()
5. _buildUpdatedPetFromFormData()
6. additionalInfo更新 → DB保存
7. didUpdateWidget() → Controller更新
8. UI自動更新
```

## 📁 変更ファイル一覧

### 主要ファイル

```
lib/features/pet_profile/
  presentation/
    screens/pet_profile_screen.dart (+29行)
    widgets/tabs/
      pet_basic_info_tab.dart (インライン編集実装)
      pet_health_tab.dart (+1000行以上)
      pet_nutrition_tab.dart (+170行)
      pet_activity_tab.dart (isEditMode追加)
      pet_adoption_tab.dart (isEditMode追加)
    controllers/
      pet_profile_unified_controller.dart (データ型修正)
  data/
    repositories/pet_profile_repository_impl.dart (フィールドマッピング修正)

lib/features/home/
  data/services/weather_service.dart (-48行)

lib/features/daily/
  presentation/screens/daily_pet_registration_screen.dart (データロード改善)

lib/shared/services/
  local_database_service.dart (バージョン11)

lib/app/
  bootstrap.dart (localization追加)

ios/Podfile (Swift 5.9設定)
pubspec.yaml (Firebase 11.x, flutter_localizations)
```

## ✅ テスト項目

### 機能テスト

#### 基本情報タブ

-   [x] 名前、体重を TextField で直接入力
-   [x] 性別をボタンで選択
-   [x] 誕生日、入養日を DatePicker で選択
-   [x] マイクロチップ番号を入力
-   [x] 外見を入力
-   [x] 保存後 UI が自動更新

#### 健康タブ

-   [x] コアワクチン 5 種を一括追加
-   [x] 追加ワクチンを個別追加
-   [x] 接種日を DatePicker で選択
-   [x] ステータスをドロップダウンで変更
-   [x] 診療記録を追加（内容、病院、日付、結果）
-   [x] 予約を追加（内容、病院、日付、時刻）
-   [x] データがない場合は空状態メッセージ表示
-   [x] 保存後データが永続化

#### 栄養タブ

-   [x] 餌を SearchableDropdown で選択
-   [x] 栄養剤を選択
-   [x] おやつを選択
-   [x] 保存後 UI が自動更新
-   [x] 選択値が正しく additionalInfo に保存

#### システム

-   [x] iOS: Firebase 11.15.0 でビルド成功
-   [x] DatePicker が日本語で表示
-   [x] Weather API が基本 API (2.5)で正常動作
-   [x] 編集 → 保存 → ビューモード移行がスムーズ

## 🔄 影響範囲

### 直接影響

-   ペットプロフィール全タブ（基本、健康、栄養、活動、入養）
-   データベース additionalInfo 構造
-   Weather API 呼び出しロジック

### 間接影響

-   Firebase SDK（プロジェクト全体）
-   iOS Podfile 設定
-   日本語ローカリゼーション（プロジェクト全体）

## 🐛 修正したバグ

### 1. データロード・保存問題

-   写真、誕生日、去勢状況が正しくロードされない → 修正
-   food/supplement が additionalInfo に保存されない → String 型で保存
-   保存後 UI が更新されない → didUpdateWidget で自動更新

### 2. Firebase/Xcode 互換性

-   Swift 6.0 互換性エラー → Firebase 11.15.0 で解決
-   DatePicker localization エラー → flutter_localizations 追加

### 3. Weather API

-   One Call 3.0 の 401 エラー → 基本 API 直接使用に変更

### 4. Mock データ問題

-   実データがないのに Mock データ表示 → 完全削除、空状態表示

## 📝 備考

### データ永続化について

すべての健康・栄養データは SQLite の additionalInfo カラム（JSON）に保存されます。

-   保存タイミング: 「保存」ボタンクリック時
-   自動更新: 保存後、didUpdateWidget で自動的に UI 更新
-   データロード: 画面表示時に自動ロード

### 今後の拡張

-   [ ] 活動タブのインライン編集詳細実装
-   [ ] 入養タブのインライン編集詳細実装
-   [ ] 診療記録・予約の個別編集・削除機能
-   [ ] 体重推移グラフ実装
-   [ ] 外部 API との連携（楽天商品選択等）

## 🎉 期待される効果

1. **ユーザビリティ大幅向上**

    - ダイアログの繰り返し表示がなくなり、編集がスムーズ
    - 全情報を一画面で確認しながら編集可能

2. **日本の獣医療基準に準拠**

    - コアワクチン 5 種を基本として実装
    - 病院ごとに異なる接種プログラムに対応

3. **データ整合性向上**

    - フィールドマッピング修正で全データが正しく保存/ロード
    - String/List 型の適切な処理

4. **パフォーマンス向上**
    - 不要な API 呼び出し削減
    - Swift 5.9 との安定した互換性

---

## 📊 統計

**総変更量**:

-   変更ファイル: 15+
-   追加行: 2500+
-   削除行: 800+

**コミット数**: 12 件

**ブランチ**: fix/mediaquery

---

**レビュアー確認事項**:

-   [ ] 全タブでインライン編集が正常に動作するか
-   [ ] 健康データ（ワクチン、診療、予約）が保存/ロードされるか
-   [ ] 栄養データ（餌、栄養剤、おやつ）が保存/ロードされるか
-   [ ] iOS 実機でビルド・動作するか
-   [ ] Weather API が正常に動作するか
-   [ ] Mock データが表示されず、実データのみ表示されるか
