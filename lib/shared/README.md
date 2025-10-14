# Shared Module

이 디렉토리는 AI Pet Frontend 앱의 공통 모듈들을 중앙에서 관리합니다.

## 개요

Shared 모듈은 앱 전체에서 재사용 가능한 모든 공통 컴포넌트, 서비스, 유틸리티, 디자인 시스템 등을
포함합니다. Clean Architecture 원칙에 따라 도메인 로직과 분리되어 관리되며, 모든 feature에서 공통으로
사용됩니다.

## 주요 구성 요소

### Branding

- 로고, 브랜드 아이덴티티 관련 컴포넌트
- `LogoWidget`: 재사용 가능한 로고 위젯

### Constants

- 앱 전체에서 사용하는 상수들
- `ErrorCodes`: 표준화된 에러 코드 및 메시지

### Design System

- 색상, 폰트, 간격, 테마 등 디자인 시스템
- `AppColors`, `AppFonts`, `AppSpacing`, `AppRadius`, `AppTheme`

### Mock Data

- API 연계 전까지 사용하는 Mock 데이터
- `MockDataService`: 중앙 집중식 Mock 데이터 관리

### Services

- 비즈니스 로직, API 통신, 에러 처리 등 서비스
- `ApiService`, `ErrorHandlerService`, `NotificationService` 등

### Utils

- 유틸리티 함수들
- `LoadingState`, `ValidationUtils` 등

### Widgets

- 재사용 가능한 UI 컴포넌트들
- `CustomButton`, `LoadingWidget`, `CommonAppBar` 등

## 사용 방법

### 전체 Shared 모듈 import

```dart
import 'package:aipet_frontend/shared/shared.dart';

// 모든 공통 컴포넌트 사용 가능
```

### 특정 모듈만 import

```dart
// 디자인 시스템만 사용
import 'package:aipet_frontend/shared/design/design.dart';

// 서비스만 사용
import 'package:aipet_frontend/shared/core/services/services.dart';

// Mock 데이터만 사용
```

## 파일 구조

```text
lib/shared/
├── README.md           # 이 파일
├── shared.dart         # 메인 배럴 파일
├── branding/           # 브랜딩 관련 컴포넌트
├── constants/          # 상수 정의
├── design/             # 디자인 시스템
├── services/           # 공통 서비스들
├── utils/              # 유틸리티 함수들
└── widgets/            # 재사용 가능한 UI 컴포넌트들
```

## 확장 방법

새로운 공통 모듈을 추가하려면:

1. 새로운 폴더 생성
2. 해당 폴더에 `README.md` 작성
3. `shared.dart`에 export 추가
4. 이 README.md에 문서화

## 관련 파일

- `lib/features/*/`: 기능별 모듈
- `lib/app/`: 앱 설정 및 라우팅
- `assets/`: 이미지, 폰트, 아이콘 등 리소스

---

## 日本語版 / 日本語バージョン

[한국어](#shared-module) | [日本語](#shared-module-1)

---

## Shared Module {#shared-module-1}

このディレクトリは、AI Pet Frontend アプリの共通モジュールを中央で管理します。

### 📋 目次 (Table of Contents)

- [概要](#overview)
- [主要構成要素](#key-components)
- [使用方法](#usage)
- [ファイル構造](#file-structure)
- [拡張方法](#extension-methods)
- [関連ファイル](#related-files)

### 概要 {#overview}

Shared モジュールは、アプリ全体で再利用可能なすべての共通コンポーネント、サービス、ユーティリティ、デザインシステムなどを
含みます。Clean Architecture の原則に従ってドメインロジックと分離されて管理され、すべての feature で共通して使用されます。

### 主要構成要素 {#key-components}

#### Branding {#branding-1}

- ロゴ、ブランドアイデンティティ関連コンポーネント
- `LogoWidget`: 再利用可能なロゴウィジェット

#### Constants {#constants-1}

- アプリ全体で使用する定数
- `ErrorCodes`: 標準化されたエラーコードとメッセージ

#### Design System {#design-system-1}

- 色、フォント、間隔、テーマなどのデザインシステム
- `AppColors`, `AppFonts`, `AppSpacing`, `AppRadius`, `AppTheme`

#### Mock Data {#mock-data-1}

- API 連携前まで使用する Mock データ
- `MockDataService`: 中央集約型 Mock データ管理

#### Services {#services-1}

- ビジネスロジック、API 通信、エラー処理などのサービス
- `ApiService`, `ErrorHandlerService`, `NotificationService`など

#### Utils {#utils-1}

- ユーティリティ関数
- `LoadingState`, `ValidationUtils`など

#### Widgets {#widgets-1}

- 再利用可能な UI コンポーネント
- `CustomButton`, `LoadingWidget`, `CommonAppBar`など

### 使用方法 {#usage}

#### 全体 Shared モジュールの import

```dart
import 'package:aipet_frontend/shared/shared.dart';

// すべての共通コンポーネントが使用可能
```

#### 特定モジュールのみ import

```dart
// デザインシステムのみ使用
import 'package:aipet_frontend/shared/design/design.dart';

// サービスのみ使用
import 'package:aipet_frontend/shared/core/services/services.dart';

// Mockデータのみ使用
```

### ファイル構造 {#file-structure}

```text
lib/shared/
├── README.md           # このファイル
├── shared.dart         # メインバレルファイル
├── branding/           # ブランディング関連コンポーネント
├── constants/          # 定数定義
├── design/             # デザインシステム
├── services/           # 共通サービス
├── utils/              # ユーティリティ関数
└── widgets/            # 再利用可能なUIコンポーネント
```

### 拡張方法 {#extension-methods}

新しい共通モジュールを追加するには：

1. 新しいフォルダを作成
2. 該当フォルダに`README.md`を作成
3. `shared.dart`に export を追加
4. この README.md に文書化

### 関連ファイル {#related-files}

- `lib/features/*/`: 機能別モジュール
- `lib/app/`: アプリ設定とルーティング
- `assets/`: 画像、フォント、アイコンなどのリソース
