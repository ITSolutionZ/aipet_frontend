# Design System

이 디렉토리는 AI Pet Frontend 앱의 디자인 시스템을 중앙에서 관리합니다.

## 개요

Design System은 앱의 모든 UI 요소에 일관된 디자인을 적용하기 위한 색상, 폰트, 간격,
테마 등을 정의합니다. 브랜드 아이덴티티를 유지하고 개발 효율성을 높이기 위해 중앙에서
관리됩니다.

## 주요 구성 요소

### AppColors

- Point Colors: 브랜드의 주요 색상 (pointGreen, pointBlue, pointPink, pointBrown 등)
- Tone Colors: 톤과 매너를 위한 색상 (toneOffWhite, tonePeach, toneBeige 등)
- 모든 색상은 16진수 값으로 정의되어 일관성 보장

### AppFonts

- 기본 폰트: Noto Sans JP (일본어 지원)
- 포인트 폰트: M PLUS 1 (강조용)
- 특별 폰트: Fredoka (제목용), Aldrich (버튼용)
- 미리 정의된 텍스트 스타일 (caption, body, title, headline, display)

### AppSpacing

- 일관된 간격 시스템 (xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px)
- UI 요소 간의 여백을 표준화하여 일관된 레이아웃 제공

### AppRadius

- 모서리 둥글기 상수 (small: 6px, medium: 12px, large: 20px, circle: 9999px)
- 카드, 버튼, 입력 필드 등의 모서리 스타일 통일

### AppElevation

- 그림자 효과 정의 (현재 구현 예정)
- 카드, 모달, 버튼 등의 깊이감 표현

### AppTheme

- Material 3 기반의 라이트 테마
- 브랜드 색상을 적용한 일관된 테마 시스템
- AppBar, Card, BottomNavigationBar 등의 테마 설정

### AppTextStyles

- 미리 정의된 텍스트 스타일
- h1, h2, body, caption 등의 일관된 텍스트 스타일

## 사용 방법

### 색상 사용

```dart
import 'package:aipet_frontend/shared/design/design.dart';

// Point Colors 사용
Container(
  color: AppColors.pointBrown,
  child: Text('브랜드 색상'),
)

// Tone Colors 사용
Container(
  color: AppColors.toneOffWhite,
  child: Text('배경 색상'),
)
```

### 폰트 사용

```dart
// 기본 폰트
Text(
  '기본 텍스트',
  style: AppFonts.base(fontSize: 16),
)

// 포인트 폰트
Text(
  '강조 텍스트',
  style: AppFonts.point(fontSize: 18, fontWeight: FontWeight.bold),
)

// 특별 폰트
Text(
  '제목',
  style: AppFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold),
)

// 미리 정의된 스타일
Text(
  '제목',
  style: AppFonts.titleLarge,
)
```

### 간격 사용

```dart
// 간격 상수 사용
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Text('일관된 간격'),
)

// 간격 조합
Container(
  margin: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  ),
  child: Text('여백 조합'),
)
```

### 모서리 둥글기 사용

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.medium),
    color: AppColors.pointCream,
  ),
  child: Text('둥근 모서리'),
)
```

### 테마 사용

```dart
MaterialApp(
  theme: AppTheme.light,
  home: MyHomePage(),
)
```

## 파일 구조

```text
lib/shared/design/
├── README.md           # 이 파일
├── design.dart         # 배럴 파일
├── color.dart          # 색상 정의
├── font.dart           # 폰트 정의
├── spacing.dart        # 간격 정의
├── radius.dart         # 모서리 둥글기 정의
├── elevation.dart      # 그림자 효과 정의
├── text_styles.dart    # 텍스트 스타일 정의
└── theme.dart          # 테마 정의
```

## 디자인 원칙

1. **일관성**: 모든 UI 요소에 동일한 디자인 언어 적용
2. **접근성**: 색상 대비와 폰트 크기를 고려한 접근성 확보
3. **확장성**: 새로운 디자인 요소 추가 시 기존 시스템과 일관성 유지
4. **성능**: 효율적인 폰트 로딩과 색상 관리

## 확장 방법

새로운 디자인 요소를 추가하려면:

1. 적절한 파일에 새로운 상수/클래스 추가
2. `design.dart` 배럴 파일에 export 추가
3. 이 README.md에 문서화
4. 기존 디자인 시스템과의 일관성 확인

## 관련 파일

- `lib/shared/branding/`: 브랜딩 관련 컴포넌트
- `assets/fonts/`: 폰트 파일
- `assets/icons/`: 아이콘 및 이미지
- `lib/features/*/`: 기능별 UI 컴포넌트

---

## 日本語版 / 日本語バージョン

[한국어](#design-system) | [日本語](#design-system-1)

---

## Design System {#design-system-1}

このディレクトリは、AI Pet Frontend アプリのデザインシステムを中央で管理します。

### 📋 目次 (Table of Contents)

- [概要](#overview-1)
- [主要構成要素](#key-components-1)
- [使用方法](#usage-1)
- [ファイル構造](#file-structure-1)
- [デザイン原則](#design-principles-1)
- [拡張方法](#extension-methods-1)
- [関連ファイル](#related-files-1)

### 概要 {#overview-1}

Design System は、アプリのすべての UI 要素に一貫したデザインを適用するための色、フォント、間隔、テーマなどを定義します。ブランドアイデンティティを維持し、開発効率を向上させるために中央で管理されます。

### 主要構成要素 {#key-components-1}

#### AppColors {#app-colors-1}

- Point Colors: ブランドの主要色（pointGreen, pointBlue, pointPink, pointBrown など）
- Tone Colors: トーンとマナーのための色（toneOffWhite, tonePeach, toneBeige など）
- すべての色は 16 進数値で定義され、一貫性が保証されます

#### AppFonts {#app-fonts-1}

- 基本フォント: Noto Sans JP（日本語対応）
- ポイントフォント: M PLUS 1（強調用）
- 特別フォント: Fredoka（タイトル用）、Aldrich（ボタン用）
- 事前定義されたテキストスタイル（caption, body, title, headline, display）

#### AppSpacing {#app-spacing-1}

- 一貫した間隔システム（xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px）
- UI 要素間の余白を標準化し、一貫したレイアウトを提供

#### AppRadius {#app-radius-1}

- 角丸定数（small: 6px, medium: 12px, large: 20px, circle: 9999px）
- カード、ボタン、入力フィールドなどの角丸スタイルを統一

#### AppElevation {#app-elevation-1}

- 影効果の定義（現在実装予定）
- カード、モーダル、ボタンなどの深さ感表現

#### AppTheme {#app-theme-1}

- Material 3 ベースのライトテーマ
- ブランド色を適用した一貫したテーマシステム
- AppBar、Card、BottomNavigationBar などのテーマ設定

#### AppTextStyles {#app-text-styles-1}

- 事前定義されたテキストスタイル
- h1、h2、body、caption などの一貫したテキストスタイル

### 使用方法 {#usage-1}

#### 色の使用

```dart
import 'package:aipet_frontend/shared/design/design.dart';

// Point Colorsの使用
Container(
  color: AppColors.pointBrown,
  child: Text('ブランド色'),
)

// Tone Colorsの使用
Container(
  color: AppColors.toneOffWhite,
  child: Text('背景色'),
)
```

#### フォントの使用

```dart
// 基本フォント
Text(
  '基本テキスト',
  style: AppFonts.base(fontSize: 16),
)

// ポイントフォント
Text(
  '強調テキスト',
  style: AppFonts.point(fontSize: 18, fontWeight: FontWeight.bold),
)

// 特別フォント
Text(
  'タイトル',
  style: AppFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold),
)

// 事前定義されたスタイル
Text(
  'タイトル',
  style: AppFonts.titleLarge,
)
```

#### 間隔の使用

```dart
// 間隔定数の使用
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Text('一貫した間隔'),
)

// 間隔の組み合わせ
Container(
  margin: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  ),
  child: Text('余白の組み合わせ'),
)
```

#### 角丸の使用

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.medium),
    color: AppColors.pointCream,
  ),
  child: Text('角丸'),
)
```

#### テーマの使用

```dart
MaterialApp(
  theme: AppTheme.light,
  home: MyHomePage(),
)
```

### ファイル構造 {#file-structure-1}

```text
lib/shared/design/
├── README.md           # このファイル
├── design.dart         # バレルファイル
├── color.dart          # 色の定義
├── font.dart           # フォントの定義
├── spacing.dart        # 間隔の定義
├── radius.dart         # 角丸の定義
├── elevation.dart      # 影効果の定義
├── text_styles.dart    # テキストスタイルの定義
└── theme.dart          # テーマの定義
```

### デザイン原則 {#design-principles-1}

1. **一貫性**: すべての UI 要素に同じデザイン言語を適用
2. **アクセシビリティ**: 色のコントラストとフォントサイズを考慮したアクセシビリティの確保
3. **拡張性**: 新しいデザイン要素の追加時に既存システムとの一貫性を維持
4. **パフォーマンス**: 効率的なフォント読み込みと色管理

### 拡張方法 {#extension-methods-1}

新しいデザイン要素を追加するには：

1. 適切なファイルに新しい定数/クラスを追加
2. `design.dart`バレルファイルに export を追加
3. この README.md に文書化
4. 既存デザインシステムとの一貫性を確認

### 関連ファイル {#related-files-1}

- `lib/shared/branding/`: ブランディング関連コンポーネント
- `assets/fonts/`: フォントファイル
- `assets/icons/`: アイコンと画像
- `lib/features/*/`: 機能別 UI コンポーネント
