# App Module Architecture

## 🌏 Language Selection

[English](#english-version) | [한국어](#korean-version) | [日本語](#japanese-version)

---

## English Version

### 📋 Overview

The App module manages the core structure and initialization logic of the AIPet
application. It serves as the foundation layer that orchestrates all feature
modules and provides essential services like routing, configuration, and global
state management.

### 🏗️ Structure Overview

```txt
lib/app/
├── README.md                           # This documentation
├── app.dart                            # Module export file
├── bootstrap.dart                      # App bootstrap and main widget
├── config/                             # App configuration management
│   ├── config.dart                     # Configuration barrel file
│   └── app_config.dart                 # Environment-specific config
├── controllers/                        # App-level controllers
│   ├── controllers.dart                # Controllers export file
│   └── base_controller.dart            # Base controller class
├── providers/                          # App-level Riverpod providers
│   ├── providers.dart                  # Providers barrel file
│   ├── app_initialization_provider.dart # App initialization
│   ├── app_state_provider.dart         # Global app state
│   └── router_provider.dart            # Router provider
└── router/                             # Routing system
    ├── app_router.dart                 # Main router class
    └── routes/                         # Module-specific routes
        ├── routes.dart                 # Routes export file
        └── route_constants.dart        # Route path constants
```

### 🔧 Key Components

#### 1. Bootstrap System ([bootstrap.dart](bootstrap.dart))

**Purpose**: Application initialization and main widget setup

**Key Features**:

- App lifecycle management
- Global error handling
- Performance monitoring
- Firebase initialization
- Root widget configuration

```dart
Future<void> bootstrap() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  // Configure global error handling
  FlutterError.onError = (details) {
    // Error logging and reporting
  };

  // Run the application
  runApp(const AIPetApp());
}
```

#### 2. Configuration System ([config/](config/))

**Purpose**: Environment-specific configuration management

**Features**:

- Development/Staging/Production configs
- API endpoint management
- Feature flags
- Environment variable handling

```dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.aipet.com',
  );

  static const bool enableMockData = bool.fromEnvironment(
    'ENABLE_MOCK_DATA',
    defaultValue: false,
  );
}
```

#### 3. Base Controller ([controllers/base_controller.dart](controllers/base_controller.dart))

**Purpose**: Foundation class for all feature controllers

**Key Features**:

- Memory leak prevention
- Automatic resource cleanup
- Centralized error handling
- Safe async operations
- Timer and subscription management

#### 4. Global Providers ([providers/](providers/))

**Purpose**: Application-wide state management

**Components**:

- **App Initialization Provider**: Manages app startup sequence
- **App State Provider**: Global application state
- **Router Provider**: Navigation state management

#### 5. Routing System ([router/](router/))

**Purpose**: Application navigation and route management

**Features**:

- Declarative routing with GoRouter
- Route guards and middleware
- Deep linking support
- Nested navigation
- Route animation configuration

```dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) => const AiChatScreen(),
    ),
    // More routes...
  ],
);
```

### 💡 Usage Examples

#### App Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap the application
  await bootstrap();
}
```

#### Using Base Controller

```dart
class FeatureController extends BaseController {
  FeatureController(super.ref);

  Future<void> performAction() async {
    // Safe async operation with automatic error handling
    await safeExecute(() async {
      // Business logic here
    });
  }
}
```

#### Configuration Access

```dart
class ApiService {
  static const baseUrl = AppConfig.apiBaseUrl;

  Future<Response> getData() async {
    return await dio.get('$baseUrl/api/data');
  }
}
```

### 🎯 Best Practices

1. **Dependency Injection**

   - Use Riverpod providers for dependency injection
   - Keep controllers stateless when possible
   - Prefer composition over inheritance

2. **Error Handling**

   - Leverage BaseController for consistent error handling
   - Log errors with appropriate severity levels
   - Provide user-friendly error messages

3. **Resource Management**

   - Always extend BaseController for automatic cleanup
   - Register all long-lived resources (timers, streams)
   - Dispose resources properly in dispose() method

4. **Configuration**
   - Use environment-specific configurations
   - Avoid hardcoding sensitive information
   - Leverage feature flags for gradual rollouts

---

## Korean Version

### 📋 개요

App 모듈은 AIPet 애플리케이션의 핵심 구조와 초기화 로직을 관리합니다.
모든 기능 모듈을 조율하고 라우팅, 구성, 전역 상태 관리와 같은 필수 서비스를
제공하는 기반 계층 역할을 합니다.

### 🏗️ 구조 개요

```txt
lib/app/
├── README.md                           # 이 문서
├── app.dart                            # 모듈 내보내기 파일
├── bootstrap.dart                      # 앱 부트스트랩 및 메인 위젯
├── config/                             # 앱 구성 관리
│   ├── config.dart                     # 구성 배럴 파일
│   └── app_config.dart                 # 환경별 구성
├── controllers/                        # 앱 레벨 컨트롤러
│   ├── controllers.dart                # 컨트롤러 내보내기 파일
│   └── base_controller.dart            # 기본 컨트롤러 클래스
├── providers/                          # 앱 레벨 Riverpod 프로바이더
│   ├── providers.dart                  # 프로바이더 배럴 파일
│   ├── app_initialization_provider.dart # 앱 초기화
│   ├── app_state_provider.dart         # 전역 앱 상태
│   └── router_provider.dart            # 라우터 프로바이더
└── router/                             # 라우팅 시스템
    ├── app_router.dart                 # 메인 라우터 클래스
    └── routes/                         # 모듈별 라우트
        ├── routes.dart                 # 라우트 내보내기 파일
        └── route_constants.dart        # 라우트 경로 상수
```

### 🔧 주요 구성 요소

#### 1. 부트스트랩 시스템 ([bootstrap.dart](bootstrap.dart))

**목적**: 애플리케이션 초기화 및 메인 위젯 설정

**주요 기능**:

- 앱 라이프사이클 관리
- 전역 오류 처리
- 성능 모니터링
- Firebase 초기화
- 루트 위젯 구성

#### 2. 구성 시스템 ([config/](config/))

**목적**: 환경별 구성 관리

**기능**:

- 개발/스테이징/프로덕션 구성
- API 엔드포인트 관리
- 기능 플래그
- 환경 변수 처리

#### 3. 기본 컨트롤러 ([controllers/base_controller.dart](controllers/base_controller.dart))

**목적**: 모든 기능 컨트롤러의 기본 클래스

**주요 기능**:

- 메모리 누수 방지
- 자동 리소스 정리
- 중앙화된 오류 처리
- 안전한 비동기 작업
- 타이머 및 구독 관리

#### 4. 전역 프로바이더 ([providers/](providers/))

**목적**: 애플리케이션 전체 상태 관리

**구성 요소**:

- **앱 초기화 프로바이더**: 앱 시작 순서 관리
- **앱 상태 프로바이더**: 전역 애플리케이션 상태
- **라우터 프로바이더**: 내비게이션 상태 관리

#### 5. 라우팅 시스템 ([router/](router/))

**목적**: 애플리케이션 내비게이션 및 라우트 관리

**기능**:

- GoRouter를 사용한 선언적 라우팅
- 라우트 가드 및 미들웨어
- 딥링크 지원
- 중첩 내비게이션
- 라우트 애니메이션 구성

---

## Japanese Version

### 📋 概要

App モジュールは、AIPet アプリケーションのコア構造と初期化ロジックを管理
します。すべての機能モジュールを統率し、ルーティング、設定、グローバル
状態管理などの必須サービスを提供する基盤層の役割を果たします。

### 🏗️ 構造概要

```txt
lib/app/
├── README.md                           # このドキュメント
├── app.dart                            # モジュールエクスポートファイル
├── bootstrap.dart                      # アプリブートストラップとメインウィジェット
├── config/                             # アプリ設定管理
│   ├── config.dart                     # 設定バレルファイル
│   └── app_config.dart                 # 環境別設定
├── controllers/                        # アプリレベルコントローラー
│   ├── controllers.dart                # コントローラーエクスポートファイル
│   └── base_controller.dart            # ベースコントローラークラス
├── providers/                          # アプリレベルRiverpodプロバイダー
│   ├── providers.dart                  # プロバイダーバレルファイル
│   ├── app_initialization_provider.dart # アプリ初期化
│   ├── app_state_provider.dart         # グローバルアプリ状態
│   └── router_provider.dart            # ルータープロバイダー
└── router/                             # ルーティングシステム
    ├── app_router.dart                 # メインルータークラス
    └── routes/                         # モジュール別ルート
        ├── routes.dart                 # ルートエクスポートファイル
        └── route_constants.dart        # ルートパス定数
```

### 🔧 主要コンポーネント

#### 1. ブートストラップシステム ([bootstrap.dart](bootstrap.dart))

**目的**: アプリケーション初期化とメインウィジェット設定

**主要機能**:

- アプリライフサイクル管理
- グローバルエラーハンドリング
- パフォーマンス監視
- Firebase 初期化
- ルートウィジェット設定

#### 2. 設定システム ([config/](config/))

**目的**: 環境別設定管理

**機能**:

- 開発/ステージング/本番設定
- API エンドポイント管理
- 機能フラグ
- 環境変数処理

#### 3. ベースコントローラー ([controllers/base_controller.dart](controllers/base_controller.dart))

**目的**: すべての機能コントローラーの基本クラス

**主要機能**:

- メモリリーク防止
- 自動リソースクリーンアップ
- 中央化されたエラーハンドリング
- 安全な非同期操作
- タイマーとサブスクリプション管理

#### 4. グローバルプロバイダー ([providers/](providers/))

**目的**: アプリケーション全体の状態管理

**コンポーネント**:

- **アプリ初期化プロバイダー**: アプリ起動シーケンス管理
- **アプリ状態プロバイダー**: グローバルアプリケーション状態
- **ルータープロバイダー**: ナビゲーション状態管理

#### 5. ルーティングシステム ([router/](router/))

**目的**: アプリケーションナビゲーションとルート管理

**機能**:

- GoRouter を使用した宣言的ルーティング
- ルートガードとミドルウェア
- ディープリンク対応
- ネストナビゲーション
- ルートアニメーション設定

---

## 📚 Additional Information

For detailed information about controllers, see [controllers/README.md](controllers/README.md)

컨트롤러에 대한 자세한 정보는 [controllers/README.md](controllers/README.md)를 참조하세요

コントローラーの詳細情報については、[controllers/README.md](controllers/README.md)を参照してください
