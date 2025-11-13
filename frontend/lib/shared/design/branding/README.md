# Branding

이 디렉토리는 AI Pet Frontend 앱의 브랜딩 관련 컴포넌트들을 관리합니다.

## 개요

브랜딩 모듈은 앱의 로고, 색상, 아이덴티티와 관련된 모든 UI 컴포넌트를 포함합니다. 일관된 브랜드 경험을 제공하기 위해 중앙에서 관리됩니다.

## 주요 구성 요소

### LogoWidget

- 앱 로고를 표시하는 재사용 가능한 위젯
- 크기, 배경색, 이미지 경로를 커스터마이징 가능
- 에러 처리 및 플레이스홀더 지원

## 사용 방법

```dart
import 'package:aipet_frontend/shared/branding/branding.dart';

// 기본 로고 위젯
LogoWidget(
  imagePath: 'assets/icons/aipet_logo.png',
  width: 196,
  height: 130,
)

// 커스텀 배경색이 있는 로고
LogoWidget(
  imagePath: 'assets/icons/aipet_logo.png',
  backgroundColor: AppColors.pointCream,
  width: 150,
  height: 100,
)
```

## 파일 구조

```text
lib/shared/branding/
├── README.md           # 이 파일
├── branding.dart       # 배럴 파일
└── logo_widget.dart    # 로고 위젯
```

## 확장 방법

새로운 브랜딩 컴포넌트를 추가하려면:

1. 새로운 위젯 파일 생성
2. `branding.dart` 배럴 파일에 export 추가
3. 이 README.md에 문서화

## 관련 파일

- `lib/shared/design/`: 디자인 시스템 (색상, 폰트, 테마)
- `assets/icons/`: 로고 및 아이콘 이미지
- `assets/images/`: 브랜딩 관련 이미지

---

## 日本語版 / 日本語バージョン

[한국어](#branding) | [日本語](#branding-1)

---

## Branding {#branding-1}

このディレクトリは、AI Pet Frontend アプリのブランディング関連コンポーネントを管理します。

### 📋 目次 (Table of Contents)

- [概要](#overview-1)
- [主要構成要素](#key-components-1)
- [使用方法](#usage-1)
- [ファイル構造](#file-structure-1)
- [拡張方法](#extension-methods-1)
- [関連ファイル](#related-files-1)

### 概要 {#overview-1}

ブランディングモジュールは、アプリのロゴ、色、アイデンティティに関連するすべての UI コンポーネントを含みます。一貫したブランド体験を提供するために中央で管理されます。

### 主要構成要素 {#key-components-1}

#### LogoWidget {#logo-widget-1}

- アプリロゴを表示する再利用可能なウィジェット
- サイズ、背景色、画像パスをカスタマイズ可能
- エラー処理とプレースホルダーサポート

### 使用方法 {#usage-1}

```dart
import 'package:aipet_frontend/shared/branding/branding.dart';

// 基本ロゴウィジェット
LogoWidget(
  imagePath: 'assets/icons/aipet_logo.png',
  width: 196,
  height: 130,
)

// カスタム背景色付きロゴ
LogoWidget(
  imagePath: 'assets/icons/aipet_logo.png',
  backgroundColor: AppColors.pointCream,
  width: 150,
  height: 100,
)
```

### ファイル構造 {#file-structure-1}

```text
lib/shared/branding/
├── README.md           # このファイル
├── branding.dart       # バレルファイル
└── logo_widget.dart    # ロゴウィジェット
```

### 拡張方法 {#extension-methods-1}

新しいブランディングコンポーネントを追加するには：

1. 新しいウィジェットファイルを作成
2. `branding.dart`バレルファイルに export を追加
3. この README.md に文書化

### 関連ファイル {#related-files-1}

- `lib/shared/design/`: デザインシステム（色、フォント、テーマ）
- `assets/icons/`: ロゴとアイコン画像
- `assets/images/`: ブランディング関連画像
