# feat(pet_profile): ペットプロフィール画面のインライン編集機能を実装

## 📋 変更概要

ペットプロフィール画面の編集機能を、ダイアログ形式からインライン編集形式に変更し、ユーザビリティを大幅に向上させました。

## 🎯 主な変更内容

### 1. **インライン編集 UI 実装**

-   ❌ **変更前**: 各フィールドを編集するたびにダイアログが表示される
-   ✅ **変更後**: 現在の画面上で直接フィールドを編集可能

### 2. **編集可能フィールド**

-   ✅ **名前**: TextField で直接入力
-   ✅ **性別**: オス/メス ボタンで選択
-   ✅ **体重**: TextField で直接入力（数値キーボード）
-   ✅ **去勢・避妊手術**: 読み取り専用表示（済み/未実施）
-   ✅ **マイクロチップ**: TextField で直接入力
-   ✅ **誕生日**: タップで日付ピッカー表示
-   ✅ **家に来た日**: タップで日付ピッカー表示
-   ✅ **外見**: TextField で直接入力

### 3. **データベーススキーマ更新** (バージョン 11)

新しいカラムを追加:

-   `size` - ペットのサイズ
-   `microchip_number` - マイクロチップ番号
-   `arrival_date` - 家に来た日

### 4. **Firebase 互換性修正**

-   Firebase SDK: 12.4.0 → 11.15.0 にダウングレード
-   Swift 6.0 互換性問題を解決
-   Podfile 設定: Swift 5.9 を明示的に指定

## 🔧 技術的な改善

### フィールドマッピング修正

データベースカラム名と Entity フィールド名の不一致を修正:

-   `profile_image` → `imagePath`
-   `birth_date` → `birthDate`
-   `is_neutered` → `neutered`
-   `microchip_number` → `microchipNumber`

### UI コンポーネント

新しいカスタムウィジェット `_buildInlineEditCard` を実装:

-   編集モード OFF: 通常テキスト表示
-   編集モード ON: TextField 表示（ダイアログなし）
-   編集中のフィールドには視覚的フィードバック（ボーダー強調）

### Riverpod 状態管理

-   `PetBasicInfoTabController` でフィールド状態を管理
-   リアルタイムで入力内容を反映
-   `updateGender()` などの専用メソッドで状態更新

## 🎨 UX/UI 改善

### 編集モード切り替え

-   "編集" ボタン → 全フィールドが編集可能に
-   "保存" ボタン → 変更を保存してビューモードに戻る
-   "キャンセル" ボタン → 変更を破棄してビューモードに戻る

### 視覚的フィードバック

-   編集可能フィールドにはボーダー色を強調
-   日付フィールドにはカレンダーアイコン表示
-   性別選択は選択状態を明確に表示

## 🐛 修正したバグ

### 1. **フィールドロード問題**

-   写真、誕生日、去勢状況、家に来た日、おやつなどのフィールドが正しくロードされない問題を修正
-   `PetProfileRepositoryImpl._safeCreatePetEntity` のフィールドマッピングを改善

### 2. **Firebase/Xcode 互換性**

```
Swift Compiler Error: Access level on imports require
'-enable-experimental-feature AccessLevelOnImport'
```

→ Firebase SDK 11.15.0 へのダウングレードで解決

### 3. **データベース移行**

-   既存の pets テーブルに新しいカラムを追加（`ALTER TABLE`）
-   `_onUpgrade` でバージョン 11 への移行を実装

## 📁 変更ファイル一覧

```
lib/features/pet_profile/presentation/widgets/tabs/pet_basic_info_tab.dart  (+651行)
lib/features/pet_profile/presentation/screens/pet_profile_screen.dart
lib/features/pet_profile/data/repositories/pet_profile_repository_impl.dart
lib/features/pet_profile/data/services/local_pet_service.dart
lib/shared/services/local_database_service.dart (バージョン11)
lib/app/bootstrap/app_bootstrap.dart
lib/features/daily/presentation/screens/daily_pet_registration_screen.dart
ios/Podfile (+17行)
ios/Podfile.lock
pubspec.yaml
.vscode/settings.json
```

## ✅ テスト項目

### 機能テスト

-   [x] ペットプロフィール画面で「編集」ボタンをクリック
-   [x] 全フィールドがインラインで編集可能
-   [x] 名前、体重、マイクロチップ番号を直接入力
-   [x] 性別をボタンで選択
-   [x] 誕生日と家に来た日を日付ピッカーで選択
-   [x] 外見フィールドにテキスト入力
-   [x] 「保存」ボタンで変更を保存
-   [x] 「キャンセル」ボタンで変更を破棄

### ビルドテスト

-   [x] iOS: Firebase 11.15.0 でビルド成功
-   [x] Android: ビルド成功
-   [x] CocoaPods: Swift 5.9 設定でインストール成功

## 🔄 影響範囲

### 直接影響

-   ペットプロフィール基本情報タブ
-   ペット登録/編集画面
-   データベースマイグレーション（自動実行）

### 間接影響

-   Firebase SDK 更新によるプロジェクト全体
-   iOS Podfile 設定変更

## 📝 備考

### Firebase SDK ダウングレードの理由

Firebase 12.x は Swift 6.0 専用機能（`sending`型、実験的インポート機能）を使用しているため、現在の Xcode/Swift 環境（Swift 5.9）と互換性がありません。Firebase 11.15.0 は Swift 5.9 と完全互換です。

### 今後の対応

-   Swift 6.0 にアップグレード後、Firebase 12.x への再アップグレードを検討
-   現時点では Firebase 11.x で安定稼働を優先

## 🎉 期待される効果

1. **ユーザビリティ向上**: ダイアログの繰り返し表示がなくなり、編集がスムーズに
2. **入力効率 UP**: 複数フィールドを一度に編集可能
3. **視認性向上**: 全情報を一画面で確認しながら編集
4. **データ整合性**: フィールドマッピング修正により、全データが正しく保存/ロード

---

**レビュアー確認事項**:

-   [ ] インライン編集 UI が正常に動作するか
-   [ ] データベースマイグレーションが正常に実行されるか
-   [ ] iOS/Android でビルドエラーがないか
-   [ ] 既存のペットデータが正しくロードされるか
