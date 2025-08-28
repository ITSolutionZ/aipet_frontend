# Onboarding Feature / オンボーディング機能

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#overview)
- [아키텍처 (Architecture)](#architecture)
- [주요 기능 (Key Features)](#key-features)
- [디렉토리 구조 (Directory Structure)](#directory-structure)
- [온보딩 플로우 (Onboarding Flow)](#onboarding-flow)
- [UI 구성 (UI Components)](#ui-components)
- [사용 방법 (Usage)](#usage)
- [설정 (Configuration)](#configuration)

### 개요 (Overview)

AI Pet 애플리케이션의 온보딩 기능을 담당하는 모듈입니다. 사용자에게 앱의 주요 기능을 소개하고 첫 사용 경험을 향상시키는 역할을 합니다.

**주요 특징:**

- 🎨 반응형 UI 디자인 (모바일/태블릿 대응)
- 🔄 상태 관리 및 영속성 (SharedPreferences)
- ♿ 접근성 지원 (Semantics)
- 🛡️ 에러 처리 및 Fallback 로직
- 🎯 Clean Architecture 패턴 적용
- 🔧 중복 코드 제거 및 재사용성

### 아키텍처 (Architecture)

```txt
lib/features/onboarding/
├── data/               # 데이터 계층
├── domain/             # 도메인 계층
├── presentation/       # 프레젠테이션 계층
└── README.md           # 문서
```

**Clean Architecture 적용:**

- **Domain Layer**: 비즈니스 로직, 엔티티, UseCase 정의
- **Data Layer**: SharedPreferences 및 상태 관리 구현
- **Presentation Layer**: UI 컨트롤러 및 화면 구성

### 주요 기능 (Key Features)

#### 🎯 온보딩 페이지

- **4개의 온보딩 페이지**: Welcome, Together, Intelligent, Reservations
- **반응형 이미지 표시**: 화면 크기에 따른 최적화된 이미지 배치
- **페이지별 커스텀 설정**: 이미지 정렬, 크기, 줌 레벨 개별 조정

#### 🛡️ 상태 관리

- **Riverpod** 기반 상태 관리
- **SharedPreferences** 영속성 저장
- **자동 상태 복원** - 앱 재시작 시 진행 상태 유지
- **시청 횟수 추적** - 재방문 사용자 식별

#### 🎨 UI/UX 기능

- **Skip 버튼**: 재방문 사용자용 건너뛰기 기능
- **페이지 인디케이터**: 현재 페이지 시각적 표시
- **부드러운 애니메이션**: 페이지 전환 효과
- **접근성**: 스크린 리더 지원

### 디렉토리 구조 (Directory Structure)

```txt
onboarding/
├── onboarding.dart                    # 기능 export 파일
├── README.md                          # 이 파일
├── data/
│   ├── data.dart                      # data 레이어 배럴
│   ├── onboarding_providers.dart      # Riverpod 프로바이더
│   ├── onboarding_providers.g.dart    # 생성된 코드
│   └── repositories/
│       └── onboarding_repository_impl.dart
├── domain/
│   ├── domain.dart                    # domain 레이어 배럴
│   ├── entities/                      # 엔티티
│   │   ├── entities.dart              # entities 배럴
│   │   └── onboarding_page.dart       # OnboardingPage 엔티티
│   ├── onboarding_constants.dart      # 상수 정의
│   ├── onboarding_data.dart           # 정적 데이터
│   ├── onboarding_state.dart          # 상태 모델
│   ├── repositories/                  # 리포지토리 인터페이스
│   │   ├── repositories.dart          # repositories 배럴
│   │   └── onboarding_repository.dart
│   └── usecases/                      # UseCase
│       ├── usecases.dart              # usecases 배럴
│       ├── base_usecase.dart          # UseCase 기본 클래스
│       ├── check_onboarding_status_usecase.dart
│       ├── complete_onboarding_usecase.dart
│       ├── load_onboarding_data_usecase.dart
│       └── restart_onboarding_usecase.dart
└── presentation/                      # Presentation Layer
    ├── presentation.dart              # presentation 레이어 배럴
    ├── controllers/                   # 컨트롤러
    │   ├── controllers.dart           # controllers 배럴
    │   └── onboarding_controller.dart
    ├── screens/                       # 화면
    │   ├── screens.dart               # screens 배럴
    │   └── onboarding_screen.dart
    └── widgets/                       # 위젯
        ├── widgets.dart               # widgets 배럴
        ├── onboarding_background_image.dart
        ├── onboarding_bottom_sheet.dart
        ├── onboarding_skip_button.dart
        └── page_indicator.dart
```

### 온보딩 플로우 (Onboarding Flow)

이 애플리케이션은 사용자 친화적인 온보딩 경험을 제공하기 위한 체계적인 플로우를 구현합니다.

#### 📊 온보딩 플로우 다이어그램

```txt
[앱 시작] → [온보딩 완료 확인] → [온보딩 표시 여부 결정]
    ↓              ↓                      ↓
  첫 실행      완료된 경우            미완료인 경우
  또는        홈 화면으로            온보딩 화면으로
  재설치        이동                   이동
```

#### 🔄 상태 관리 플로우

**1단계: 앱 초기화 시 온보딩 상태 확인**

```dart
// AppInitializationProvider에서 온보딩 상태 로드
final onboardingRepository = ref.read(onboardingRepositoryProvider);
final isOnboardingCompleted = await onboardingRepository.isOnboardingCompleted();

if (isOnboardingCompleted) {
  // 온보딩 완료 - 홈 화면으로 이동
  context.go(AppRouter.homeRoute);
} else {
  // 온보딩 미완료 - 온보딩 화면으로 이동
  context.go(AppRouter.onboardingRoute);
}
```

**2단계: 온보딩 진행 상태 관리**

```dart
// 페이지 변경 시 상태 저장
void _onPageChanged(int page) {
  ref.read(onboardingStateNotifierProvider.notifier).goToPage(page);
  // SharedPreferences에 자동 저장
}

// 온보딩 완료 시
void _completeOnboarding() async {
  final result = await _controller.finishOnboarding();
  if (result.isSuccess) {
    context.go(AppRouter.loginRoute);
  }
}
```

**3단계: 재방문 사용자 처리**

```dart
// 시청 횟수 기반 Skip 버튼 표시
if (onboardingState.hasSeenOnboardingBefore &&
    onboardingState.currentPage < OnboardingData.pages.length - 1) {
  // Skip 버튼 표시
}
```

#### 🎨 UI 상태 관리

**반응형 레이아웃:**

```dart
// 화면 비율에 따른 이미지 표시 조정
final aspectRatio = constraints.maxWidth / constraints.maxHeight;

if (aspectRatio < 0.8) {
  // 세로 화면 (모바일) - 특별한 줌 효과
  if (pageIndex == 2) {
    return Transform.scale(scale: 2.5, alignment: Alignment.center, ...);
  }
} else {
  // 가로 화면 (태블릿) - 표준 표시
}
```

**페이지별 커스텀 설정:**

```dart
// 각 페이지별 최적의 이미지 정렬
switch (pageIndex) {
  case 0: return Alignment.bottomCenter; // Welcome - 하단 중앙
  case 1: return Alignment.topCenter;    // Together - 상단 중앙
  case 2: return Alignment.center;       // Intelligent - 중앙
  case 3: return Alignment.center;       // Reservations - 중앙
}
```

### UI 구성 (UI Components)

#### 1. **온보딩 화면 구조**

```dart
Scaffold(
  body: Column(
    children: [
      // 이미지 섹션 (화면의 55%)
      Expanded(
        flex: 55,
        child: PageView.builder(...),
      ),
      // 바텀 시트 (화면의 45%)
      Expanded(
        flex: 45,
        child: OnboardingBottomSheet(...),
      ),
    ],
  ),
)
```

#### 2. **컴포넌트별 역할**

**OnboardingBackgroundImage:**

- 반응형 이미지 표시
- 페이지별 커스텀 설정 적용
- 에러 시 Fallback UI 제공

**OnboardingBottomSheet:**

- 텍스트 콘텐츠 표시
- 페이지 인디케이터
- Next/Start 버튼

**OnboardingSkipButton:**

- 재방문 사용자용 건너뛰기
- 접근성 지원

**PageIndicator:**

- 현재 페이지 시각적 표시
- 아이콘 기반 인디케이터

### 사용 방법 (Usage)

#### 1. **기본 사용**

```dart
import 'package:your_app/features/onboarding/onboarding.dart';

// 온보딩 화면으로 이동
context.go(AppRouter.onboardingRoute);
```

#### 2. **Controller 사용**

```dart
final controller = OnboardingController(ref);

// 온보딩 완료
final result = await controller.finishOnboarding();
if (result.isSuccess) {
  // 성공 처리
} else {
  // 에러 처리
}

// 온보딩 재시작
final restartResult = await controller.restartOnboarding();
```

#### 3. **Provider 사용**

```dart
final onboardingState = ref.watch(onboardingStateNotifierProvider);
final currentPage = onboardingState.currentPage;
final isCompleted = onboardingState.isCompleted;
final viewCount = onboardingState.viewCount;
```

#### 4. **상태 변경**

```dart
// 페이지 이동
ref.read(onboardingStateNotifierProvider.notifier).nextPage();
ref.read(onboardingStateNotifierProvider.notifier).goToPage(2);

// 온보딩 완료
ref.read(onboardingStateNotifierProvider.notifier).completeOnboarding();
```

### 설정 (Configuration)

#### 상수 설정

`lib/features/onboarding/domain/onboarding_constants.dart`에서 UI 상수들을 수정할 수 있습니다:

```dart
class OnboardingConstants {
  // 화면 비율
  static const int imageSectionFlex = 55;
  static const int bottomSheetFlex = 45;

  // 애니메이션
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // UI 상수
  static const double skipButtonOpacity = 0.3;
  static const double buttonBackgroundOpacity = 0.8;
}
```

#### 온보딩 데이터 수정

`lib/features/onboarding/domain/onboarding_data.dart`에서 페이지 내용을 수정할 수 있습니다:

```dart
static const List<OnboardingPage> pages = [
  OnboardingPage(
    imagePath: 'assets/images/onboarding/onboarding1.png',
    title: 'Welcome',
    subtitle: '毎日の記録、愛に繋ぐ',
    description: '記録から残る愛の痕跡',
    imageAlignment: Alignment.bottomCenter,
    imageFit: BoxFit.cover,
    useCustomImageDisplay: true,
  ),
  // ... 추가 페이지
];
```

#### 의존성

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.3
  shared_preferences: ^2.2.2
  go_router: ^13.2.0
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#overview-1)
- [アーキテクチャ (Architecture)](#architecture-1)
- [主要機能 (Key Features)](#key-features-1)
- [ディレクトリ構造 (Directory Structure)](#directory-structure-1)
- [オンボーディングフロー (Onboarding Flow)](#onboarding-flow-1)
- [UI 構成 (UI Components)](#ui-components-1)
- [使用方法 (Usage)](#usage-1)
- [設定 (Configuration)](#configuration-1)

### 概要 (Overview)

AI Pet アプリケーションのオンボーディング機能を担当するモジュールです。ユーザーにアプリの主要機能を紹介し、初回使用体験を向上させる役割を果たします。

**主な特徴:**

- 🎨 レスポンシブ UI デザイン (モバイル/タブレット対応)
- 🔄 状態管理と永続化 (SharedPreferences)
- ♿ アクセシビリティ対応 (Semantics)
- 🛡️ エラー処理と Fallback ロジック
- 🎯 Clean Architecture パターン適用
- 🔧 重複コード削除と再利用性

### アーキテクチャ (Architecture)

```txt
lib/features/onboarding/
├── data/               # データ層
├── domain/             # ドメイン層
├── presentation/       # プレゼンテーション層
└── README.md           # ドキュメント
```

**Clean Architecture 適用:**

- **Domain Layer**: ビジネスロジック、エンティティ、UseCase 定義
- **Data Layer**: SharedPreferences と状態管理実装
- **Presentation Layer**: UI コントローラーと画面構成

### 主要機能 (Key Features)

#### 🎯 オンボーディングページ

- **4 つのオンボーディングページ**: Welcome, Together, Intelligent, Reservations
- **レスポンシブ画像表示**: 画面サイズに応じた最適化された画像配置
- **ページ別カスタム設定**: 画像配置、サイズ、ズームレベル個別調整

#### 🛡️ 状態管理

- **Riverpod**ベースの状態管理
- **SharedPreferences**永続化保存
- **自動状態復元** - アプリ再起動時の進行状態維持
- **視聴回数追跡** - 再訪問ユーザー識別

#### 🎨 UI/UX 機能

- **Skip ボタン**: 再訪問ユーザー用スキップ機能
- **ページインジケーター**: 現在ページの視覚的表示
- **スムーズなアニメーション**: ページ遷移効果
- **アクセシビリティ**: スクリーンリーダー対応

### ディレクトリ構造 (Directory Structure)

```txt
onboarding/
├── onboarding.dart                    # 機能exportファイル
├── README.md                          # このファイル
├── data/
│   ├── data.dart                      # dataレイヤーバレル
│   ├── onboarding_providers.dart      # Riverpodプロバイダー
│   ├── onboarding_providers.g.dart    # 生成されたコード
│   └── repositories/
│       └── onboarding_repository_impl.dart
├── domain/
│   ├── domain.dart                    # domainレイヤーバレル
│   ├── entities/                      # エンティティ
│   │   ├── entities.dart              # entitiesバレル
│   │   └── onboarding_page.dart       # OnboardingPageエンティティ
│   ├── onboarding_constants.dart      # 定数定義
│   ├── onboarding_data.dart           # 静的データ
│   ├── onboarding_state.dart          # 状態モデル
│   ├── repositories/                  # リポジトリインターフェース
│   │   ├── repositories.dart          # repositoriesバレル
│   │   └── onboarding_repository.dart
│   └── usecases/                      # UseCase
│       ├── usecases.dart              # usecasesバレル
│       ├── base_usecase.dart          # UseCase基本クラス
│       ├── check_onboarding_status_usecase.dart
│       ├── complete_onboarding_usecase.dart
│       ├── load_onboarding_data_usecase.dart
│       └── restart_onboarding_usecase.dart
└── presentation/                      # Presentation Layer
    ├── presentation.dart              # presentationレイヤーバレル
    ├── controllers/                   # コントローラー
    │   ├── controllers.dart           # controllersバレル
    │   └── onboarding_controller.dart
    ├── screens/                       # 画面
    │   ├── screens.dart               # screensバレル
    │   └── onboarding_screen.dart
    └── widgets/                       # ウィジェット
        ├── widgets.dart               # widgetsバレル
        ├── onboarding_background_image.dart
        ├── onboarding_bottom_sheet.dart
        ├── onboarding_skip_button.dart
        └── page_indicator.dart
```

### オンボーディングフロー (Onboarding Flow)

このアプリケーションは、ユーザーフレンドリーなオンボーディング体験を提供するための体系的なフローを実装しています。

#### 📊 オンボーディングフロー図

```txt
[アプリ開始] → [オンボーディング完了確認] → [オンボーディング表示判定]
    ↓              ↓                      ↓
  初回実行      完了済みの場合           未完了の場合
  または        ホーム画面へ             オンボーディング画面へ
  再インストール   移動                    移動
```

#### 🔄 状態管理フロー

**ステップ 1: アプリ初期化時のオンボーディング状態確認**

```dart
// AppInitializationProviderでオンボーディング状態読み込み
final onboardingRepository = ref.read(onboardingRepositoryProvider);
final isOnboardingCompleted = await onboardingRepository.isOnboardingCompleted();

if (isOnboardingCompleted) {
  // オンボーディング完了 - ホーム画面へ移動
  context.go(AppRouter.homeRoute);
} else {
  // オンボーディング未完了 - オンボーディング画面へ移動
  context.go(AppRouter.onboardingRoute);
}
```

**ステップ 2: オンボーディング進行状態管理**

```dart
// ページ変更時の状態保存
void _onPageChanged(int page) {
  ref.read(onboardingStateNotifierProvider.notifier).goToPage(page);
  // SharedPreferencesに自動保存
}

// オンボーディング完了時
void _completeOnboarding() async {
  final result = await _controller.finishOnboarding();
  if (result.isSuccess) {
    context.go(AppRouter.loginRoute);
  }
}
```

**ステップ 3: 再訪問ユーザー処理**

```dart
// 視聴回数ベースのSkipボタン表示
if (onboardingState.hasSeenOnboardingBefore &&
    onboardingState.currentPage < OnboardingData.pages.length - 1) {
  // Skipボタン表示
}
```

#### 🎨 UI 状態管理

**レスポンシブレイアウト:**

```dart
// 画面比率に応じた画像表示調整
final aspectRatio = constraints.maxWidth / constraints.maxHeight;

if (aspectRatio < 0.8) {
  // 縦画面 (モバイル) - 特別なズーム効果
  if (pageIndex == 2) {
    return Transform.scale(scale: 2.5, alignment: Alignment.center, ...);
  }
} else {
  // 横画面 (タブレット) - 標準表示
}
```

**ページ別カスタム設定:**

```dart
// 各ページ別最適の画像配置
switch (pageIndex) {
  case 0: return Alignment.bottomCenter; // Welcome - 下部中央
  case 1: return Alignment.topCenter;    // Together - 上部中央
  case 2: return Alignment.center;       // Intelligent - 中央
  case 3: return Alignment.center;       // Reservations - 中央
}
```

### UI 構成 (UI Components)

#### 1. **オンボーディング画面構造**

```dart
Scaffold(
  body: Column(
    children: [
      // 画像セクション (画面の55%)
      Expanded(
        flex: 55,
        child: PageView.builder(...),
      ),
      // ボトムシート (画面の45%)
      Expanded(
        flex: 45,
        child: OnboardingBottomSheet(...),
      ),
    ],
  ),
)
```

#### 2. **コンポーネント別役割**

**OnboardingBackgroundImage:**

- レスポンシブ画像表示
- ページ別カスタム設定適用
- エラー時の Fallback UI 提供

**OnboardingBottomSheet:**

- テキストコンテンツ表示
- ページインジケーター
- Next/Start ボタン

**OnboardingSkipButton:**

- 再訪問ユーザー用スキップ
- アクセシビリティ対応

**PageIndicator:**

- 現在ページの視覚的表示
- アイコンベースのインジケーター

### 使用方法 (Usage)

#### 1. **基本使用**

```dart
import 'package:your_app/features/onboarding/onboarding.dart';

// オンボーディング画面へ移動
context.go(AppRouter.onboardingRoute);
```

#### 2. **Controller 使用**

```dart
final controller = OnboardingController(ref);

// オンボーディング完了
final result = await controller.finishOnboarding();
if (result.isSuccess) {
  // 成功処理
} else {
  // エラー処理
}

// オンボーディング再開
final restartResult = await controller.restartOnboarding();
```

#### 3. **Provider 使用**

```dart
final onboardingState = ref.watch(onboardingStateNotifierProvider);
final currentPage = onboardingState.currentPage;
final isCompleted = onboardingState.isCompleted;
final viewCount = onboardingState.viewCount;
```

#### 4. **状態変更**

```dart
// ページ移動
ref.read(onboardingStateNotifierProvider.notifier).nextPage();
ref.read(onboardingStateNotifierProvider.notifier).goToPage(2);

// オンボーディング完了
ref.read(onboardingStateNotifierProvider.notifier).completeOnboarding();
```

### 設定 (Configuration)

#### 定数設定

`lib/features/onboarding/domain/onboarding_constants.dart`で UI 定数を修正できます:

```dart
class OnboardingConstants {
  // 画面比率
  static const int imageSectionFlex = 55;
  static const int bottomSheetFlex = 45;

  // アニメーション
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // UI定数
  static const double skipButtonOpacity = 0.3;
  static const double buttonBackgroundOpacity = 0.8;
}
```

#### オンボーディングデータ修正

`lib/features/onboarding/domain/onboarding_data.dart`でページ内容を修正できます:

```dart
static const List<OnboardingPage> pages = [
  OnboardingPage(
    imagePath: 'assets/images/onboarding/onboarding1.png',
    title: 'Welcome',
    subtitle: '毎日の記録、愛に繋ぐ',
    description: '記録から残る愛の痕跡',
    imageAlignment: Alignment.bottomCenter,
    imageFit: BoxFit.cover,
    useCustomImageDisplay: true,
  ),
  // ... 追加ページ
];
```

#### 依存関係

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.3
  shared_preferences: ^2.2.2
  go_router: ^13.2.0
```

---

## 📚 추가 리소스 / その他のリソース

- [Riverpod 가이드 / Riverpod ガイド](https://riverpod.dev/)
- [SharedPreferences 문서 / SharedPreferences ドキュメント](https://pub.dev/packages/shared_preferences)
- [GoRouter 문서 / GoRouter ドキュメント](https://pub.dev/packages/go_router)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**© 2024 AI Pet. 프로덕션 레벨 온보딩 시스템 / Production-ready Onboarding System**
