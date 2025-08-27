# App Module Architecture

[한국어](#app-module-architecture) | [日本語](#app-module-architecture-1)

---

앱의 핵심 구조와 초기화 로직을 관리하는 모듈입니다.

## 구조 개요

```
lib/app/
├── [README.md](README.md)                           # 이 문서
├── [app.dart](app.dart)                           # 모듈 export 파일
├── [bootstrap.dart](bootstrap.dart)                     # 앱 부트스트랩 및 메인 위젯
├── [config/](config/)                       # 앱 설정 관리
│   ├── [config.dart](config/config.dart)               # 설정 배럴 파일
│   └── [app_config.dart](config/app_config.dart)          # 환경별 설정 클래스
├── [controllers/](controllers/)                       # 앱 레벨 컨트롤러들
│   ├── [controllers.dart](controllers/controllers.dart)               # Export 파일
│   └── [base_controller.dart](controllers/base_controller.dart)          # 기본 컨트롤러 클래스
├── [providers/](providers/)                        # 앱 레벨 Riverpod 프로바이더들
│   ├── [providers.dart](providers/providers.dart)               # Provider 배럴 파일
│   ├── [app_initialization_provider.dart](providers/app_initialization_provider.dart)  # 앱 초기화 상태 관리
│   ├── [app_state_provider.dart](providers/app_state_provider.dart)       # 글로벌 앱 상태 관리
│   └── [router_provider.dart](providers/router_provider.dart)          # 라우터 프로바이더
└── [router/](router/)                           # 라우팅 시스템
    ├── [app_router.dart](router/app_router.dart)               # 메인 라우터 클래스
    └── [routes/](router/routes/)                       # 모듈별 라우트 정의
        ├── [routes.dart](router/routes/routes.dart)               # Export 파일
        ├── [route_constants.dart](router/routes/route_constants.dart)      # 라우트 상수들
        ├── [splash_shell_routes.dart](router/routes/splash_shell_routes.dart)  # 로고 시퀀스 라우트
        ├── [auth_routes.dart](router/routes/auth_routes.dart)          # 인증 관련 라우트
        ├── [shell_routes.dart](router/routes/shell_routes.dart)         # 메인 앱 Shell 라우트
        ├── [pet_routes.dart](router/routes/pet_routes.dart)            # 펫 관련 라우트
        └── [standalone_routes.dart](router/routes/standalone_routes.dart)    # 독립 전체화면 라우트
```

## 주요 구성 요소

### 1. Bootstrap ([bootstrap.dart](bootstrap.dart))

- **역할**: 앱의 진입점이자 최상위 위젯 관리
- **기능**:
  - 앱 초기화 트리거
  - 초기화 상태에 따른 UI 분기
  - 메인 MaterialApp.router 설정
  - 테마 및 라우터 설정

### 2. App Configuration ([config/app_config.dart](config/app_config.dart))

- **역할**: 환경별 설정값들을 중앙에서 관리
- **지원 환경**:
  - **Development**: 개발 환경 (디버그 모드 활성화)
  - **Staging**: 스테이징 환경 (프로덕션과 유사하지만 디버깅 기능 일부 활성화)
  - **Production**: 프로덕션 환경 (성능과 보안 최우선)

### 3. App Initialization Provider ([providers/app_initialization_provider.dart](providers/app_initialization_provider.dart))

- **역할**: 앱 시작 시 필요한 모든 초기화 작업 관리
- **초기화 단계**:
  1. 기본 서비스 초기화 (에러 핸들러, 성능 모니터링 등)
  2. 앱 설정 로드 (테마, 언어, 알림 설정 등)
  3. 사용자 인증 상태 확인
  4. 온보딩 완료 상태 확인
  5. 네트워크 연결 확인
  6. 앱 버전 확인
  7. 필수 데이터 로드
  8. 리소스 초기화 (폰트, 이미지 등)

### 4. Base Controller ([controllers/base_controller.dart](controllers/base_controller.dart))

- **역할**: 모든 Controller의 기본 클래스
- **기능**:
  - 메모리 리크 방지 (StreamSubscription, Timer, ChangeNotifier 자동 정리)
  - 에러 처리 및 사용자 친화적 메시지 생성
  - 안전한 비동기 작업 실행 (타임아웃, 재시도 로직 포함)

### 5. Router System ([router/](router/))

- **모듈형 라우터 아키텍처**:
  - **[SplashShellRoutes](router/routes/splash_shell_routes.dart)**: 로고 시퀀스 → 온보딩 (최우선, 스킵 불가)
  - **[AuthRoutes](router/routes/auth_routes.dart)**: 로그인, 회원가입 등 인증 관련
  - **[ShellRoutes](router/routes/shell_routes.dart)**: 하단 네비게이션이 있는 메인 앱 화면들
  - **[PetRoutes](router/routes/pet_routes.dart)**: 펫 등록, 프로필, 건강 관련 라우트
  - **[StandaloneRoutes](router/routes/standalone_routes.dart)**: 독립 전체화면 라우트

#### 라우터 우선순위

1. **Splash Shell**: `/`, `/splash`, `/onboarding` - 최우선, 스킵 불가
2. **Auth Routes**: `/login`, `/signup`, `/welcome` - 인증 관련
3. **Main Shell**: `/home`, `/scheduling`, `/ai`, `/walk`, `/calendar` - 하단 네비게이션
4. **Pet Routes**: 펫 등록 플로우, 펫 프로필 등 - 독립 화면
5. **Standalone**: 기타 독립 전체화면 라우트

## 개선 사항

### ✅ 완료된 개선사항

1. **모듈형 라우터 구조**: 관심사별로 라우트 분리
2. **Shell Router 활용**: 하단 네비게이션 체계적 관리
3. **초기화 단계 세분화**: 8단계 체계적 초기화 프로세스
4. **에러 핸들링**: 각 초기화 단계별 에러 처리
5. **상태 관리 최적화**: Riverpod를 활용한 반응형 상태 관리
6. **환경별 설정 관리**: 개발/스테이징/프로덕션 환경별 설정 분리
7. **배럴 파일 구조**: Import 규칙 준수를 위한 배럴 파일 구현
8. **문서화 개선**: 모든 클래스와 메서드에 상세한 한국어 문서화 주석 추가

### 🔄 추천 개선사항

#### 1. 의존성 주입 시스템

```dart
// lib/app/di/
├── di_container.dart        # DI 컨테이너
├── service_locator.dart     # 서비스 로케이터
└── module_registrar.dart    # 모듈별 의존성 등록
```

#### 2. 미들웨어 시스템

```dart
// lib/app/middleware/
├── auth_middleware.dart     # 인증 미들웨어
├── logging_middleware.dart  # 로깅 미들웨어
└── analytics_middleware.dart # 분석 미들웨어
```

#### 3. 앱 생명주기 관리

```dart
// lib/app/lifecycle/
├── app_lifecycle_observer.dart  # 앱 생명주기 관찰자
└── background_task_manager.dart # 백그라운드 작업 관리
```

## 베스트 프랙티스

### 1. 라우터 사용법

```dart
// 라우트 상수 사용
context.go(RouteConstants.homeRoute);

// 하위 라우트 네비게이션
context.go('/home/pet-profile');

// Shell 내에서의 네비게이션
context.go('/scheduling/feeding-schedule');
```

### 2. 초기화 상태 활용

```dart
// 초기화 상태 구독
final initState = ref.watch(appInitializationProvider);

// 인증 상태 확인
if (initState.isAuthenticated) {
  // 인증된 사용자 로직
}

// 온보딩 상태 확인
if (!initState.isOnboardingCompleted) {
  // 온보딩 필요
}
```

### 3. 에러 처리

```dart
// 초기화 에러 처리
if (initState.error != null) {
  // 에러 UI 표시
  return ErrorWidget(error: initState.error);
}
```

### 4. 환경별 설정 사용

```dart
// 현재 환경 설정 가져오기
final config = AppConfig.current;

// API URL 사용
final apiUrl = config.apiBaseUrl;

// 디버그 모드 확인
if (config.isDebugMode) {
  // 디버그 전용 로직
}
```

## 확장성 고려사항

1. **모듈 추가**: 새로운 기능 모듈 추가 시 해당 라우트를 적절한 라우트 파일에 추가
2. **미들웨어 확장**: 인증, 로깅, 분석 등 횡단 관심사 처리
3. **환경별 설정**: 개발/스테이징/프로덕션 환경별 설정 분리 (✅ 완료)
4. **성능 최적화**: 라우트별 지연 로딩 및 코드 분할 적용 가능

이 구조는 확장 가능하고 유지보수가 용이하도록 설계되었으며, 팀 개발에 적합한 모듈형 아키텍처를 제공합니다.

---

## 日本語版 / 日本語バージョン

[한국어](#app-module-architecture) | [日本語](#app-module-architecture-1)

---

# App Module Architecture

アプリのコア構造と初期化ロジックを管理するモジュールです。

## 構造概要

```
lib/app/
├── [README.md](README.md)                           # このドキュメント
├── [app.dart](app.dart)                           # モジュール export ファイル
├── [bootstrap.dart](bootstrap.dart)                     # アプリブートストラップとメインウィジェット
├── [config/](config/)                       # アプリ設定管理
│   ├── [config.dart](config/config.dart)               # 設定バレルファイル
│   └── [app_config.dart](config/app_config.dart)          # 環境別設定クラス
├── [controllers/](controllers/)                       # アプリレベルコントローラー
│   ├── [controllers.dart](controllers/controllers.dart)               # Export ファイル
│   └── [base_controller.dart](controllers/base_controller.dart)          # 基本コントローラークラス
├── [providers/](providers/)                        # アプリレベル Riverpod プロバイダー
│   ├── [providers.dart](providers/providers.dart)               # Provider バレルファイル
│   ├── [app_initialization_provider.dart](providers/app_initialization_provider.dart)  # アプリ初期化状態管理
│   ├── [app_state_provider.dart](providers/app_state_provider.dart)       # グローバルアプリ状態管理
│   └── [router_provider.dart](providers/router_provider.dart)          # ルータープロバイダー
└── [router/](router/)                           # ルーティングシステム
    ├── [app_router.dart](router/app_router.dart)               # メインルータークラス
    └── [routes/](router/routes/)                       # モジュール別ルート定義
        ├── [routes.dart](router/routes/routes.dart)               # Export ファイル
        ├── [route_constants.dart](router/routes/route_constants.dart)      # ルート定数
        ├── [splash_shell_routes.dart](router/routes/splash_shell_routes.dart)  # ロゴシーケンスルート
        ├── [auth_routes.dart](router/routes/auth_routes.dart)          # 認証関連ルート
        ├── [shell_routes.dart](router/routes/shell_routes.dart)         # メインアプリ Shell ルート
        ├── [pet_routes.dart](router/routes/pet_routes.dart)            # ペット関連ルート
        └── [standalone_routes.dart](router/routes/standalone_routes.dart)    # 独立フルスクリーンルート
```

## 主要構成要素

### 1. Bootstrap ([bootstrap.dart](bootstrap.dart))

- **役割**: アプリのエントリーポイントと最上位ウィジェット管理
- **機能**:
  - アプリ初期化トリガー
  - 初期化状態に応じた UI 分岐
  - メイン MaterialApp.router 設定
  - テーマとルーター設定

### 2. App Configuration ([config/app_config.dart](config/app_config.dart))

- **役割**: 環境別設定値を中央で管理
- **対応環境**:
  - **Development**: 開発環境 (デバッグモード有効)
  - **Staging**: ステージング環境 (本番と類似だがデバッグ機能一部有効)
  - **Production**: 本番環境 (パフォーマンスとセキュリティ最優先)

### 3. App Initialization Provider ([providers/app_initialization_provider.dart](providers/app_initialization_provider.dart))

- **役割**: アプリ起動時に必要な全ての初期化作業を管理
- **初期化段階**:
  1. 基本サービス初期化 (エラーハンドラー、パフォーマンス監視など)
  2. アプリ設定読み込み (テーマ、言語、通知設定など)
  3. ユーザー認証状態確認
  4. オンボーディング完了状態確認
  5. ネットワーク接続確認
  6. アプリバージョン確認
  7. 必須データ読み込み
  8. リソース初期化 (フォント、画像など)

### 4. Base Controller ([controllers/base_controller.dart](controllers/base_controller.dart))

- **役割**: 全ての Controller の基本クラス
- **機能**:
  - メモリリーク防止 (StreamSubscription、Timer、ChangeNotifier 自動クリーンアップ)
  - エラー処理とユーザーフレンドリーなメッセージ生成
  - 安全な非同期作業実行 (タイムアウト、リトライロジック含む)

### 5. Router System ([router/](router/))

- **モジュール型ルーターアーキテクチャ**:
  - **[SplashShellRoutes](router/routes/splash_shell_routes.dart)**: ロゴシーケンス → オンボーディング (最優先、スキップ不可)
  - **[AuthRoutes](router/routes/auth_routes.dart)**: ログイン、サインアップなど認証関連
  - **[ShellRoutes](router/routes/shell_routes.dart)**: 下部ナビゲーションがあるメインアプリ画面
  - **[PetRoutes](router/routes/pet_routes.dart)**: ペット登録、プロフィール、健康関連ルート
  - **[StandaloneRoutes](router/routes/standalone_routes.dart)**: 独立フルスクリーンルート

#### ルーター優先順位

1. **Splash Shell**: `/`, `/splash`, `/onboarding` - 最優先、スキップ不可
2. **Auth Routes**: `/login`, `/signup`, `/welcome` - 認証関連
3. **Main Shell**: `/home`, `/scheduling`, `/ai`, `/walk`, `/calendar` - 下部ナビゲーション
4. **Pet Routes**: ペット登録フロー、ペットプロフィールなど - 独立画面
5. **Standalone**: その他の独立フルスクリーンルート

## 改善事項

### ✅ 完了した改善事項

1. **モジュール型ルーター構造**: 関心事別にルート分離
2. **Shell Router 活用**: 下部ナビゲーション体系的管理
3. **初期化段階細分化**: 8 段階体系的な初期化プロセス
4. **エラーハンドリング**: 各初期化段階別エラー処理
5. **状態管理最適化**: Riverpod を活用した反応型状態管理
6. **環境別設定管理**: 開発/ステージング/本番環境別設定分離
7. **バレルファイル構造**: Import 規則遵守のためのバレルファイル実装
8. **ドキュメント化改善**: 全てのクラスとメソッドに詳細な韓国語ドキュメント化コメント追加

### 🔄 推奨改善事項

#### 1. 依存性注入システム

```dart
// lib/app/di/
├── di_container.dart        # DIコンテナ
├── service_locator.dart     # サービスロケーター
└── module_registrar.dart    # モジュール別依存性登録
```

#### 2. ミドルウェアシステム

```dart
// lib/app/middleware/
├── auth_middleware.dart     # 認証ミドルウェア
├── logging_middleware.dart  # ログミドルウェア
└── analytics_middleware.dart # 分析ミドルウェア
```

#### 3. アプリライフサイクル管理

```dart
// lib/app/lifecycle/
├── app_lifecycle_observer.dart  # アプリライフサイクルオブザーバー
└── background_task_manager.dart # バックグラウンド作業管理
```

## ベストプラクティス

### 1. ルーター使用方法

```dart
// ルート定数使用
context.go(RouteConstants.homeRoute);

// サブルートナビゲーション
context.go('/home/pet-profile');

// Shell内でのナビゲーション
context.go('/scheduling/feeding-schedule');
```

### 2. 初期化状態活用

```dart
// 初期化状態購読
final initState = ref.watch(appInitializationProvider);

// 認証状態確認
if (initState.isAuthenticated) {
  // 認証済みユーザーロジック
}

// オンボーディング状態確認
if (!initState.isOnboardingCompleted) {
  // オンボーディング必要
}
```

### 3. エラー処理

```dart
// 初期化エラー処理
if (initState.error != null) {
  // エラーUI表示
  return ErrorWidget(error: initState.error);
}
```

### 4. 環境別設定使用

```dart
// 現在の環境設定取得
final config = AppConfig.current;

// API URL使用
final apiUrl = config.apiBaseUrl;

// デバッグモード確認
if (config.isDebugMode) {
  // デバッグ専用ロジック
}
```

## 拡張性考慮事項

1. **モジュール追加**: 新しい機能モジュール追加時に該当ルートを適切なルートファイルに追加
2. **ミドルウェア拡張**: 認証、ログ、分析など横断的関心事処理
3. **環境別設定**: 開発/ステージング/本番環境別設定分離 (✅ 完了)
4. **パフォーマンス最適化**: ルート別遅延読み込みとコード分割適用可能

この構造は拡張可能で保守性が高く設計されており、チーム開発に適したモジュール型アーキテクチャを提供します。
