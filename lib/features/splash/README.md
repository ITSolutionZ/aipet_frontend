# Splash Feature / スプラッシュ機能

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
- [스플래시 시퀀스 플로우 (Splash Sequence Flow)](#splash-sequence-flow)
- [상태 관리 (State Management)](#state-management)
- [사용 방법 (Usage)](#usage)
- [설정 (Configuration)](#configuration)

### 개요 (Overview) {#overview}

AI Pet 애플리케이션의 스플래시 화면 기능을 담당하는 모듈입니다.
Clean Architecture 패턴을 기반으로 한 확장 가능하고 유지보수가 쉬운 스플래시 시스템을 제공합니다.

**주요 특징:**

- 🎨 **완전 순차 표시**: 회사 로고(ITZ) 3초 → 앱 로고(AI Pet) 3초 - **무조건 진행**
- 🔄 **스트림 기반 상태 관리**: 실시간 상태 추적 및 업데이트
- 🛡️ **에러 복구 보장**: 예외 발생 시에도 순차 진행 완료 보장
- 📱 **반응형 디자인**: 다양한 화면 크기 지원
- 🎯 **Clean Architecture**: 완벽한 계층 분리 (Domain/Data/Presentation)
- ⚡ **조건 분기 없음**: 어떤 상황에서도 회사로고 → 앱로고 순서 고정

### 아키텍처 (Architecture) {#architecture}

```txt
lib/features/splash/
├── data/               # 데이터 계층
├── domain/             # 도메인 계층
├── presentation/       # 프레젠테이션 계층
└── splash.dart         # 전체 모듈 export
```

**Clean Architecture 적용:**

- **Domain Layer**: 비즈니스 로직과 상태 모델 정의
- **Data Layer**: 스플래시 설정 및 상태 관리 구현
- **Presentation Layer**: UI 컨트롤러 및 화면 구성

### 주요 기능 (Key Features) {#key-features}

#### 🎬 스플래시 시퀀스 - 완전 고정 순서 진행

- **1단계**: 초기화 (애니메이션 및 회사 로고 준비)
- **2단계**: ITZ 회사 로고 - **무조건 3초간 표시** (조건 없음)
- **3단계**: AI Pet 앱 로고 - **무조건 3초간 표시** (조건 없음)
- **4단계**: 완료 후 온보딩 화면으로 자동 이동

**⚠️ 핵심 요구사항**:

- 회사 로고와 앱 로고 사이에는 **어떤 분기 로직도 존재하지 않음**
- 에러 발생 시에도 동일한 순서로 진행 완료
- 사용자 입력이나 다른 조건과 관계없이 **고정된 6초 시퀀스** 진행

#### 🎨 시각적 효과

- **Fade Animation** - 부드러운 페이드 인/아웃
- **Scale Animation** - 탄성 스케일 효과
- **그라데이션 배경** - 고급스러운 시각적 효과

#### 🛡️ 안정성 기능

- **이미지 로딩 실패** 시 fallback 아이콘 표시
- **스트림 에러** 발생 시에도 다음 화면 진행
- **메모리 누수 방지** - 적절한 dispose 패턴

#### 🔄 상태 관리

- **실시간 상태 추적** - 현재 로고 단계 확인
- **진행률 표시** - 0.0 → 0.5 → 1.0 진행률
- **자동 라우팅** - 상태 기반 다음 화면 결정

### 디렉토리 구조 (Directory Structure) {#directory-structure}

```txt
splash/
├── splash.dart                           # 기능 export 파일
├── data/
│   ├── data.dart                        # 데이터 계층 export
│   ├── splash_providers.dart            # Riverpod 상태 관리
│   └── repositories/
│       ├── repositories.dart            # Repository export
│       └── splash_repository_impl.dart  # 스플래시 설정 구현체
├── domain/
│   ├── domain.dart                      # 도메인 계층 export
│   ├── constants/
│   │   └── splash_constants.dart        # 상수 및 설정값
│   ├── entities/
│   │   ├── entities.dart                # 엔티티 export
│   │   ├── splash_entity.dart          # 스플래시 설정 모델
│   │   ├── splash_result.dart          # Result 패턴 구현
│   │   └── splash_state.dart           # 스플래시 상태 모델
│   ├── repositories/
│   │   ├── repositories.dart            # Repository export
│   │   └── splash_repository.dart       # 추상 인터페이스
│   └── usecases/
│       ├── usecases.dart                # UseCase export
│       ├── get_splash_config_usecase.dart      # 설정 로드 UseCase
│       └── manage_splash_sequence_usecase.dart # 시퀀스 관리 UseCase
└── presentation/
    ├── presentation.dart                # 프레젠테이션 계층 export
    ├── controllers/
    │   ├── controllers.dart             # Controller export
    │   └── splash_controller.dart       # 스플래시 컨트롤러
    ├── screens/
    │   ├── screens.dart                 # Screen export
    │   └── splash_screen.dart          # 스플래시 화면
    └── widgets/
        ├── widgets.dart                 # Widget export
        └── splash_logo_widget.dart      # 로고 위젯
```

### 스플래시 시퀀스 플로우 (Splash Sequence Flow) {#splash-sequence-flow}

스플래시 기능은 스트림 기반의 상태 관리를 통해 순차적인 로고 표시 시퀀스를 구현합니다.

#### 📊 시퀀스 플로우 다이어그램

```txt
[앱 시작] → [초기화] → [회사로고 3초] → [앱로고 3초] → [라우팅] → [다음화면]
     ↓         ↓          ↓            ↓         ↓          ↓
  앱 실행   애니메이션     ITZ          AI Pet    경로      온보딩/
           컨트롤러      로고 표시      로고 표시   결정      로그인
```

#### 🔄 상태 전환 과정

#### 1단계: 초기화 (Initializing)

```dart
// SplashState.initializing() 생성
yield SplashResult.success(
  '스플래시 초기화 중...',
  SplashState.initializing(),
);
```

#### 2단계: 회사 로고 표시 (Company Logo)

```dart
// 회사 로고 상태로 전환 및 3초 대기
yield SplashResult.success(
  '회사 로고 표시 중...',
  SplashState.companyLogo(SplashConstants.companyLogoPath),
);
await Future.delayed(SplashConstants.logoDisplayDuration);
```

#### 3단계: 앱 로고 표시 (App Logo)

```dart
// 앱 로고 상태로 전환 및 3초 대기
yield SplashResult.success(
  '앱 로고 표시 중...',
  SplashState.appLogo(SplashConstants.appLogoPath),
);
await Future.delayed(SplashConstants.logoDisplayDuration);
```

#### 4단계: 완료 및 라우팅 (Completed)

```dart
// 완료 상태로 전환
yield SplashResult.success(
  '스플래시 시퀀스 완료',
  SplashState.completed(),
);
```

#### 🎯 상태별 UI 렌더링

**회사 로고 상태:**

- 크기: 196x130 (SplashConstants.companyLogoWidth/Height)
- 배경: 흰색 컨테이너
- 모서리: 8px 라운드 (SplashConstants.companyLogoRadius)

**앱 로고 상태:**

- 크기: 300x300 (SplashConstants.appLogoSize)
- 배경: 그라데이션 효과
- 모서리: 20px 라운드 (SplashConstants.logoRadius)

#### 🛡️ 에러 복구 시나리오

```dart
// 이미지 로드 실패 시 fallback UI
errorBuilder: (context, error, stackTrace) {
  return Container(
    color: Colors.grey[200],
    child: const Icon(Icons.pets, size: 60, color: Colors.grey),
  );
}
```

### 상태 관리 (State Management) {#state-management}

#### 🔄 Riverpod 기반 상태 관리

**SplashSequenceNotifier:**

```dart
@riverpod
class SplashSequenceNotifier extends _$SplashSequenceNotifier {
  @override
  SplashState build() => SplashState.initializing();

  void updateState(SplashState newState) {
    state = newState;
  }
}
```

**스플래시 상태 모델:**

```dart
enum SplashPhase {
  initializing,    // 초기화 중
  companyLogo,     // 회사 로고 표시
  appLogo,         // 앱 로고 표시
  completed        // 완료
}

class SplashState {
  final SplashPhase phase;
  final String imagePath;
  final int currentStep;
  final int totalSteps;
  final double progress;    // 0.0 ~ 1.0
}
```

#### 📊 상태 추적 예시

```dart
final splashState = ref.watch(splashSequenceNotifierProvider);

switch (splashState.phase) {
  case SplashPhase.companyLogo:
    print('회사 로고 표시 중 (${splashState.progress * 100}%)');
  case SplashPhase.appLogo:
    print('앱 로고 표시 중 (${splashState.progress * 100}%)');
  case SplashPhase.completed:
    print('스플래시 완료');
}
```

### 사용 방법 (Usage) {#usage}

#### 1. **기본 사용법**

```dart
// SplashScreen을 앱 라우터에 등록
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
```

#### 2. **컨트롤러 활용**

```dart
final splashController = SplashController(ref);

// 스플래시 시퀀스 시작
splashController.startSplashSequence().listen(
  (result) {
    if (result.isSuccess && result.data!.isCompleted) {
      // 다음 화면으로 이동
    }
  },
);
```

#### 3. **상태 구독**

```dart
class MySplashWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashSequenceNotifierProvider);

    return SplashLogoWidget(splashState: splashState);
  }
}
```

### 설정 (Configuration) {#configuration}

#### 상수 설정

```dart
class SplashConstants {
  // 타이밍 설정
  static const Duration logoDisplayDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 3000);

  // 이미지 경로
  static const String companyLogoPath = 'assets/icons/itz.png';
  static const String appLogoPath = 'assets/icons/aipet_logo.png';

  // 크기 설정
  static const double companyLogoWidth = 196.0;
  static const double companyLogoHeight = 130.0;
  static const double appLogoSize = 300.0;
}
```

#### Assets 설정

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/icons/itz.png
    - assets/icons/aipet_logo.png
```

#### 의존성

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.6.1
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#overview-1)
- [アーキテクチャ (Architecture)](#architecture-1)
- [主要機能 (Key Features)](#key-features-1)
- [ディレクトリ構造 (Directory Structure)](#directory-structure-1)
- [スプラッシュシーケンスフロー (Splash Sequence Flow)](#splash-sequence-flow-1)
- [状態管理 (State Management)](#state-management-1)
- [使用方法 (Usage)](#usage-1)
- [設定 (Configuration)](#configuration-1)

### 概要 (Overview) {#overview-1}

AI Pet アプリケーションのスプラッシュ画面機能を担当するモジュールです。Clean Architecture パターンをベースにした拡張可能でメンテナンスしやすいスプラッシュシステムを提供します。

**主な特徴:**

- 🎨 **完全順次表示**: 会社ロゴ(ITZ) 3 秒 → アプリロゴ(AI Pet) 3 秒 - **無条件進行**
- 🔄 **ストリームベースの状態管理**: リアルタイム状態追跡・更新
- 🛡️ **エラーリカバリー保証**: 例外発生時も順次進行完了保証
- 📱 **レスポンシブデザイン**: 様々な画面サイズ対応
- 🎯 **Clean Architecture**: 完璧な層分離 (Domain/Data/Presentation)
- ⚡ **条件分岐なし**: どんな状況でも 会社ロゴ → アプリロゴ 順序固定

### アーキテクチャ (Architecture) {#architecture-1}

```txt
lib/features/splash/
├── data/               # データ層
├── domain/             # ドメイン層
├── presentation/       # プレゼンテーション層
└── splash.dart         # 全モジュール export
```

**Clean Architecture 適用:**

- **Domain Layer**: ビジネスロジックと状態モデル定義
- **Data Layer**: スプラッシュ設定と状態管理実装
- **Presentation Layer**: UI コントローラーと画面構成

### 主要機能 (Key Features) {#key-features-1}

#### 🎬 スプラッシュシーケンス - 完全固定順序進行

- **1 段階**: 初期化 (アニメーション及び会社ロゴ準備)
- **2 段階**: ITZ 会社ロゴ - **無条件 3 秒間表示** (条件なし)
- **3 段階**: AI Pet アプリロゴ - **無条件 3 秒間表示** (条件なし)
- **4 段階**: 完了後オンボーディング画面へ自動移動

**⚠️ 核心要求事項**:

- 会社ロゴとアプリロゴの間には **いかなる分岐ロジックも存在しない**
- エラー発生時も同じ順序で進行完了
- ユーザー入力や他の条件と関係なく **固定された 6 秒シーケンス** 進行

#### 🎨 視覚効果

- **Fade Animation** - 滑らかなフェードイン/アウト
- **Scale Animation** - 弾性スケール効果
- **グラデーション背景** - 高級感のある視覚効果

#### 🛡️ 安定性機能

- **画像読み込み失敗** 時のフォールバックアイコン表示
- **ストリームエラー** 発生時も次画面に進行
- **メモリリーク防止** - 適切な dispose パターン

#### 🔄 状態管理

- **リアルタイム状態追跡** - 現在のロゴ段階確認
- **進捗表示** - 0.0 → 0.5 → 1.0 進捗率
- **自動ルーティング** - 状態ベースの次画面決定

### ディレクトリ構造 (Directory Structure) {#directory-structure-1}

```txt
splash/
├── splash.dart                           # 機能 export ファイル
├── data/
│   ├── data.dart                        # データ層 export
│   ├── splash_providers.dart            # Riverpod 状態管理
│   └── repositories/
│       ├── repositories.dart            # Repository export
│       └── splash_repository_impl.dart  # スプラッシュ設定実装
├── domain/
│   ├── domain.dart                      # ドメイン層 export
│   ├── constants/
│   │   └── splash_constants.dart        # 定数と設定値
│   ├── entities/
│   │   ├── entities.dart                # エンティティ export
│   │   ├── splash_entity.dart          # スプラッシュ設定モデル
│   │   ├── splash_result.dart          # Result パターン実装
│   │   └── splash_state.dart           # スプラッシュ状態モデル
│   ├── repositories/
│   │   ├── repositories.dart            # Repository export
│   │   └── splash_repository.dart       # 抽象インターフェース
│   └── usecases/
│       ├── usecases.dart                # UseCase export
│       ├── get_splash_config_usecase.dart      # 設定ロード UseCase
│       └── manage_splash_sequence_usecase.dart # シーケンス管理 UseCase
└── presentation/
    ├── presentation.dart                # プレゼンテーション層 export
    ├── controllers/
    │   ├── controllers.dart             # Controller export
    │   └── splash_controller.dart       # スプラッシュコントローラー
    ├── screens/
    │   ├── screens.dart                 # Screen export
    │   └── splash_screen.dart          # スプラッシュ画面
    └── widgets/
        ├── widgets.dart                 # Widget export
        └── splash_logo_widget.dart      # ロゴウィジェット
```

### スプラッシュシーケンスフロー (Splash Sequence Flow) {#splash-sequence-flow-1}

スプラッシュ機能はストリームベースの状態管理を通じて順次的なロゴ表示シーケンスを実装します。

#### 📊 シーケンスフロー図

```txt
[アプリ開始] → [初期化] → [会社ロゴ3秒] → [アプリロゴ3秒] → [ルーティング] → [次画面]
      ↓         ↓           ↓             ↓            ↓            ↓
   アプリ実行   アニメーション   ITZ          AI Pet       パス        オンボーディング/
             コントローラー    ロゴ表示      ロゴ表示      決定         ログイン
```

#### 🔄 状態遷移プロセス

#### ステップ 1: 初期化 (Initializing)

```dart
// SplashState.initializing() 生成
yield SplashResult.success(
  'スプラッシュ初期化中...',
  SplashState.initializing(),
);
```

#### ステップ 2: 会社ロゴ表示 (Company Logo)

```dart
// 会社ロゴ状態に遷移し3秒待機
yield SplashResult.success(
  '会社ロゴ表示中...',
  SplashState.companyLogo(SplashConstants.companyLogoPath),
);
await Future.delayed(SplashConstants.logoDisplayDuration);
```

#### ステップ 3: アプリロゴ表示 (App Logo)

```dart
// アプリロゴ状態に遷移し3秒待機
yield SplashResult.success(
  'アプリロゴ表示中...',
  SplashState.appLogo(SplashConstants.appLogoPath),
);
await Future.delayed(SplashConstants.logoDisplayDuration);
```

#### ステップ 4: 完了とルーティング (Completed)

```dart
// 完了状態に遷移
yield SplashResult.success(
  'スプラッシュシーケンス完了',
  SplashState.completed(),
);
```

#### 🎯 状態別 UI レンダリング

**会社ロゴ状態:**

- サイズ: 196x130 (SplashConstants.companyLogoWidth/Height)
- 背景: 白いコンテナ
- 角: 8px ラウンド (SplashConstants.companyLogoRadius)

**アプリロゴ状態:**

- サイズ: 300x300 (SplashConstants.appLogoSize)
- 背景: グラデーション効果
- 角: 20px ラウンド (SplashConstants.logoRadius)

#### 🛡️ エラーリカバリーシナリオ

```dart
// 画像読み込み失敗時のフォールバックUI
errorBuilder: (context, error, stackTrace) {
  return Container(
    color: Colors.grey[200],
    child: const Icon(Icons.pets, size: 60, color: Colors.grey),
  );
}
```

### 状態管理 (State Management) {#state-management-1}

#### 🔄 Riverpod ベースの状態管理

**SplashSequenceNotifier:**

```dart
@riverpod
class SplashSequenceNotifier extends _$SplashSequenceNotifier {
  @override
  SplashState build() => SplashState.initializing();

  void updateState(SplashState newState) {
    state = newState;
  }
}
```

**スプラッシュ状態モデル:**

```dart
enum SplashPhase {
  initializing,    // 初期化中
  companyLogo,     // 会社ロゴ表示
  appLogo,         // アプリロゴ表示
  completed        // 完了
}

class SplashState {
  final SplashPhase phase;
  final String imagePath;
  final int currentStep;
  final int totalSteps;
  final double progress;    // 0.0 ~ 1.0
}
```

#### 📊 状態追跡例

```dart
final splashState = ref.watch(splashSequenceNotifierProvider);

switch (splashState.phase) {
  case SplashPhase.companyLogo:
    print('会社ロゴ表示中 (${splashState.progress * 100}%)');
  case SplashPhase.appLogo:
    print('アプリロゴ表示中 (${splashState.progress * 100}%)');
  case SplashPhase.completed:
    print('スプラッシュ完了');
}
```

### 使用方法 (Usage) {#usage-1}

#### 1. **基本使用法**

```dart
// SplashScreen をアプリルーターに登録
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
```

#### 2. **コントローラー活用**

```dart
final splashController = SplashController(ref);

// スプラッシュシーケンス開始
splashController.startSplashSequence().listen(
  (result) {
    if (result.isSuccess && result.data!.isCompleted) {
      // 次画面に移動
    }
  },
);
```

#### 3. **状態購読**

```dart
class MySplashWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashSequenceNotifierProvider);

    return SplashLogoWidget(splashState: splashState);
  }
}
```

### 設定 (Configuration) {#configuration-1}

#### 定数設定

```dart
class SplashConstants {
  // タイミング設定
  static const Duration logoDisplayDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 3000);

  // 画像パス
  static const String companyLogoPath = 'assets/icons/itz.png';
  static const String appLogoPath = 'assets/icons/aipet_logo.png';

  // サイズ設定
  static const double companyLogoWidth = 196.0;
  static const double companyLogoHeight = 130.0;
  static const double appLogoSize = 300.0;
}
```

#### Assets 設定

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/icons/itz.png
    - assets/icons/aipet_logo.png
```

#### 依存関係

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.6.1
```

---

## 📚 추가 리소스 / その他のリソース

- [Flutter Animation ガイド](https://docs.flutter.dev/ui/animations)
- [Riverpod 공식 문서 / Riverpod 公式ドキュメント](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Go Router 공식 가이드 / Go Router 公式ガイド](https://pub.dev/packages/go_router)

---

© 2024 AI Pet. 프로덕션 레벨 스플래시 시스템 / Production-ready Splash System
