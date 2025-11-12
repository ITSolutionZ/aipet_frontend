# 📱 レスポンシブデザインガイド

## 概要

`ResponsiveHelper`を使用して、すべての画面を端末サイズに対応させるためのガイドです。

## 基本的な使い方

### 1. インポート

```dart
import 'package:aipet_frontend/shared/shared.dart';
```

### 2. ResponsiveHelperの初期化

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    // または
    final responsive = context.responsive;

    return Scaffold(
      body: Container(
        width: responsive.rw(100),  // レスポンシブ幅
        height: responsive.rh(50),  // レスポンシブ高さ
        padding: responsive.rPadding(16),  // レスポンシブパディング
      ),
    );
  }
}
```

## 主な機能

### 📏 画面サイズ判定

```dart
final responsive = ResponsiveHelper(context);

// デバイスタイプの判定
if (responsive.isMobile) {
  // スマートフォン用レイアウト
} else if (responsive.isTablet) {
  // タブレット用レイアウト
} else if (responsive.isDesktop) {
  // デスクトップ用レイアウト
}

// 画面サイズ
final width = responsive.screenWidth;
final height = responsive.screenHeight;
```

### 📐 レスポンシブサイズ計算

```dart
// 幅のパーセンテージ
final halfWidth = responsive.wp(50);  // 画面幅の50%

// 高さのパーセンテージ
final quarterHeight = responsive.hp(25);  // 画面高さの25%

// レスポンシブ幅（ベース: 375px）
final width = responsive.rw(100);  // 375pxベースで100pxに相当

// レスポンシブ高さ（ベース: 812px）
final height = responsive.rh(200);  // 812pxベースで200pxに相当

// フォントサイズ
final fontSize = responsive.rf(16);  // 16pxをレスポンシブにスケーリング

// アイコンサイズ
final iconSize = responsive.ri(24);  // 24pxをレスポンシブにスケーリング

// スペーシング
final spacing = responsive.rs(16);  // 16pxをレスポンシブにスケーリング
```

### 📦 レスポンシブEdgeInsets

```dart
// 全方向パディング
final padding1 = responsive.rPadding(16);

// 対称パディング
final padding2 = responsive.rPaddingSymmetric(
  horizontal: 24,
  vertical: 16,
);

// 個別パディング
final padding3 = responsive.rPaddingOnly(
  left: 16,
  top: 8,
  right: 16,
  bottom: 24,
);
```

### 🔄 条件付きレイアウト

```dart
// 値の切り替え
final columns = responsive.responsiveValue(
  mobile: 1,
  tablet: 2,
  desktop: 3,
);

// ウィジェットの切り替え
final widget = responsive.responsiveWidget(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
);
```

### 🛡️ セーフエリア

```dart
// セーフエリアのパディング
final topPadding = responsive.topPadding;
final bottomPadding = responsive.bottomPadding;

// セーフエリアを考慮した画面サイズ
final safeHeight = responsive.safeHeight;
final safeWidth = responsive.safeWidth;

// ステータスバー・ナビゲーションバーの高さ
final statusBarHeight = responsive.statusBarHeight;
final navigationBarHeight = responsive.navigationBarHeight;
```

### ⌨️ キーボード対応

```dart
// キーボードが表示されているか
if (responsive.isKeyboardVisible) {
  // キーボード表示時の処理
}

// キーボードの高さ
final keyboardHeight = responsive.keyboardHeight;
```

## 実装例

### 例1: 基本的なレイアウト

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'プロフィール',
          style: TextStyle(fontSize: responsive.rf(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: responsive.rPadding(16),
        child: Column(
          children: [
            // プロフィール画像
            Container(
              width: responsive.rw(100),
              height: responsive.rw(100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: responsive.rs(24)),

            // 名前
            Text(
              'ユーザー名',
              style: TextStyle(
                fontSize: responsive.rf(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.rs(16)),

            // 詳細情報
            _buildInfoCard(context, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      width: responsive.wp(100),
      padding: responsive.rPadding(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.rs(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: responsive.rs(8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 情報表示
        ],
      ),
    );
  }
}
```

### 例2: グリッドレイアウト

```dart
class GridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    // デバイスサイズに応じたカラム数
    final crossAxisCount = responsive.responsiveValue(
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return Scaffold(
      body: GridView.builder(
        padding: responsive.rPadding(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: responsive.rs(16),
          mainAxisSpacing: responsive.rs(16),
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(responsive.rs(12)),
            ),
          );
        },
      ),
    );
  }
}
```

### 例3: フォーム入力

```dart
class FormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      body: SingleChildScrollView(
        padding: responsive.rPaddingSymmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Column(
          children: [
            TextField(
              style: TextStyle(fontSize: responsive.rf(16)),
              decoration: InputDecoration(
                labelText: '名前',
                labelStyle: TextStyle(fontSize: responsive.rf(14)),
                contentPadding: responsive.rPaddingSymmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            SizedBox(height: responsive.rs(16)),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  responsive.wp(100),
                  responsive.rh(56),
                ),
                padding: responsive.rPaddingSymmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                '送信',
                style: TextStyle(fontSize: responsive.rf(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## BuildContext拡張の使用

より簡潔に書くことができます:

```dart
class SimpleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.screenWidth,  // 画面幅
        height: context.screenHeight,  // 画面高さ
        child: Center(
          child: Text(
            context.isMobile ? 'モバイル' : 'タブレット/デスクトップ',
          ),
        ),
      ),
    );
  }
}
```

## ベストプラクティス

### ✅ 推奨

```dart
// レスポンシブヘルパーを使用
final responsive = context.responsive;
final width = responsive.rw(100);

// パーセンテージベースのサイズ
final halfWidth = responsive.wp(50);

// レスポンシブフォントサイズ
Text('タイトル', style: TextStyle(fontSize: responsive.rf(24)))
```

### ❌ 非推奨

```dart
// ハードコードされたサイズ
Container(width: 100, height: 50)

// 固定フォントサイズ
Text('タイトル', style: TextStyle(fontSize: 24))

// MediaQuery.of(context)を直接使用
final width = MediaQuery.of(context).size.width * 0.5;
```

## デザインベース

- **ベース幅**: 375px（iPhone 11 Pro）
- **ベース高さ**: 812px（iPhone 11 Pro）
- **ブレークポイント**:
  - モバイル: < 600px
  - タブレット: 600px ~ 900px
  - デスクトップ: >= 900px

## トラブルシューティング

### 問題: テキストが小さすぎる/大きすぎる

```dart
// フォントサイズの範囲を制限
final fontSize = responsive.rf(16);  // 自動的に 16*0.8 ~ 16*1.2 の範囲に制限
```

### 問題: レイアウトが崩れる

```dart
// セーフエリアを考慮
SafeArea(
  child: SingleChildScrollView(
    // コンテンツ
  ),
)

// または
Padding(
  padding: EdgeInsets.only(
    top: responsive.topPadding,
    bottom: responsive.bottomPadding,
  ),
  child: // コンテンツ
)
```

## まとめ

`ResponsiveHelper`を使用することで:

- ✅ すべての端末サイズに対応
- ✅ 一貫したレスポンシブデザイン
- ✅ 簡潔で読みやすいコード
- ✅ メンテナンスが容易

すべての新しい画面とウィジェットでこのヘルパーを使用してください！
