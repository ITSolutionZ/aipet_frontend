# feat(ai): AI ペット選択バブルに画像プロバイダーの非同期取得機能を追加

## 📋 変更概要

AI チャット画面のペット選択バブルで、ペット画像を非同期で読み込む機能を実装し、画像表示の柔軟性と安定性を向上させました。

## 🎯 主な変更内容

### 1. **非同期画像プロバイダー実装**

#### 対応する画像タイプ

-   ✅ **アセット画像**: `assets/images/` で始まるパス
-   ✅ **ネットワーク画像**: `http://` または `https://` で始まる URL
-   ✅ **ローカルファイル**: デバイス内のファイルパス

#### 実装メソッド

```dart
Future<ImageProvider> _getImageProvider(String? imagePath) async {
  if (imagePath == null || imagePath.isEmpty) {
    return const AssetImage('assets/images/placeholder.png');
  }

  // アセット画像
  if (imagePath.startsWith('assets/')) {
    return AssetImage(imagePath);
  }

  // URL画像
  if (imagePath.startsWith('http://') ||
      imagePath.startsWith('https://')) {
    return NetworkImage(imagePath);
  }

  // ローカルファイル
  final file = File(imagePath);
  if (await file.exists()) {
    return FileImage(file);
  }

  // フォールバック
  return const AssetImage('assets/images/placeholder.png');
}
```

### 2. **FutureBuilder による非同期処理**

#### Before (同期処理)

```dart
CircleAvatar(
  backgroundImage: AssetImage(imagePath), // エラーが発生する可能性
)
```

#### After (非同期処理)

```dart
FutureBuilder<ImageProvider>(
  future: _getImageProvider(imagePath),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return CircleAvatar(backgroundImage: snapshot.data!);
    }
    return CircularProgressIndicator(); // ローディング表示
  },
)
```

### 3. **エラーハンドリング強化**

-   ✅ 画像パスが null または空の場合: placeholder 画像を使用
-   ✅ ファイルが存在しない場合: placeholder 画像を使用
-   ✅ 画像読み込み失敗時: デバッグログを出力

## 🔧 技術的な改善

### 画像読み込みの柔軟性

1. **複数の画像ソースに対応**

    - アセット、URL、ローカルファイルを自動判別
    - 適切な ImageProvider を動的に選択

2. **非同期処理**

    - ファイル存在確認を非同期で実施
    - UI のブロッキングを防止

3. **フォールバック戦略**
    - すべての失敗ケースで placeholder 画像を表示
    - アプリのクラッシュを防止

### デバッグ機能

```dart
LoggerService.debug('🖼️ 画像プロバイダー取得開始: $imagePath');
LoggerService.debug('✅ AssetImage使用: $imagePath');
LoggerService.debug('⚠️ ファイルが存在しません: $imagePath');
```

## 📁 変更ファイル

```
lib/features/ai/presentation/widgets/ai_pet_selection_bubble.dart (+65行)
```

## ✅ テスト項目

### 機能テスト

-   [x] アセット画像が正しく表示される
-   [x] ネットワーク画像が正しく表示される
-   [x] ローカルファイルパスの画像が正しく表示される
-   [x] 画像パスが null の場合に placeholder 画像が表示される
-   [x] 存在しないファイルパスの場合に placeholder 画像が表示される
-   [x] 画像読み込み中にローディングインジケーターが表示される

### エッジケース

-   [x] 空文字列の imagePath
-   [x] 無効な URL
-   [x] 削除されたローカルファイル

## 🐛 解決した問題

### Before

-   画像パスのタイプを自動判別できず、エラーが発生
-   同期的な画像読み込みで UI がブロック
-   エラー時の適切なフォールバックがない

### After

-   すべての画像タイプに対応
-   非同期処理でスムーズな読み込み
-   エラー時も placeholder 画像で安定表示

## 🎉 期待される効果

1. **安定性向上**: 画像読み込みエラーでアプリがクラッシュしない
2. **柔軟性向上**: 複数の画像ソースに対応
3. **UX 向上**: ローディング状態を明確に表示

---

**レビュアー確認事項**:

-   [ ] FutureBuilder が正しく動作するか
-   [ ] 各画像タイプ（asset/URL/file）が正しく表示されるか
-   [ ] エラー時に placeholder 画像が表示されるか
-   [ ] デバッグログが適切に出力されるか
