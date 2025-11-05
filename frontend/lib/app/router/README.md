# App Router Module {#app-router-module}

[한국어](#app-router-module) | [日本語](#app-router-module-1)

---

앱의 라우팅 시스템을 관리하는 모듈입니다.

## 구조 개요

```txt
lib/app/router/
├── [README.md](README.md)                                    # 이 문서
├── [app_router.dart](app_router.dart)                        # 메인 라우터 클래스
└── [routes/](routes/)                                        # 모듈별 라우트 정의
    ├── [routes.dart](routes/routes.dart)                     # Export 파일
    ├── [route_constants.dart](routes/route_constants.dart)   # 라우트 상수
    ├── [splash_shell_routes.dart](routes/splash_shell_routes.dart) # 스플래시 → 온보딩
    ├── [auth_routes.dart](routes/auth_routes.dart)           # 인증 관련
    ├── [shell_routes.dart](routes/shell_routes.dart)         # 메인 앱 Shell
    ├── [pet_routes.dart](routes/pet_routes.dart)             # 펫 관련
    └── [standalone_routes.dart](routes/standalone_routes.dart) # 독립 라우트
```

## 주요 구성 요소

### 1. AppRouter ([app_router.dart](app_router.dart))

- **역할**: 중앙집중화된 앱 라우터 설정
- **주요 기능**:
  - **모듈형 라우터 구조**: 관심사별로 라우트 분리
  - **라우터 우선순위 관리**: Splash → Auth → Main Shell → Pet → Standalone
  - **라우트 상수 제공**: 모든 라우트 경로를 상수로 관리

#### 라우터 우선순위

```dart
static GoRouter createRouter() {
  return GoRouter(
    initialLocation: splashRoute, // 스플래시 시퀀스로 시작
    routes: [
      // 1. Splash Shell 라우트 (최우선, 스킵 불가)
      SplashShellRoutes.splashShellRoute,

      // 2. 인증 관련 라우트
      ...AuthRoutes.routes,

      // 3. 메인 앱 Shell 라우트 (하단 네비게이션)
      ShellRoutes.shellRoute,

      // 4. 펫 관련 라우트
      ...PetRoutes.routes,

      // 5. 독립적인 전체화면 라우트
      ...StandaloneRoutes.routes,
    ],
  );
}
```

### 2. Route Constants ([routes/route_constants.dart](routes/route_constants.dart))

- **역할**: 모든 라우트 경로를 상수로 정의
- **네이밍 컨벤션**:
  - **메인 라우트**: kebab-case (예: `/home`, `/pet-profile`)
  - **하위 라우트**: kebab-case (예: `/home/pet-empty`, `/settings/profile-edit`)
  - **쿼리 파라미터**: camelCase (예: `/pet-profile?petId=123`)

#### 라우트 카테고리

```dart
class RouteConstants {
  // ===== SPLASH & ONBOARDING =====
  static const String logoRoute = '/';
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';

  // ===== AUTHENTICATION =====
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String welcomeRoute = '/welcome';

  // ===== MAIN APP TABS =====
  static const String homeRoute = '/home';
  static const String schedulingRoute = '/scheduling';
  static const String aiRoute = '/ai';
  static const String walkRoute = '/walk';
  static const String calendarRoute = '/calendar';
  static const String settingsRoute = '/settings';
}
```

### 3. Splash Shell Routes ([routes/splash_shell_routes.dart](routes/splash_shell_routes.dart))

- **역할**: 스플래시 시퀀스 → 온보딩 Shell 라우트
- **특징**: 최우선 실행, 사용자가 스킵할 수 없음
- **라우트 순서**:
  1. `/splash` → 통합 스플래시 시퀀스 (로딩 → ITZ → AI Pet)
  2. `/onboarding` → 온보딩 화면

### 4. Auth Routes ([routes/auth_routes.dart](routes/auth_routes.dart))

- **역할**: 로그인, 회원가입 등 인증 관련 라우트
- **특징**: Shell 밖에서 독립적으로 실행
- **포함 라우트**: `/login`, `/signup`, `/welcome`

### 5. Shell Routes ([routes/shell_routes.dart](routes/shell_routes.dart))

- **역할**: 하단 네비게이션이 있는 메인 앱 화면들
- **특징**: MainNavigationScreen을 통한 하단 네비게이션 제공
- **주요 탭**:
  - **홈**: `/home` 및 하위 라우트 (`/home/pet-profile`, `/home/tricks` 등)
  - **스케줄링**: `/scheduling` 및 하위 라우트 (급식, 훈련, 건강 등)
  - **AI**: `/ai` (AI 챗봇)
  - **산책**: `/walk` (산책 기록)
  - **캘린더**: `/calendar` (시설 예약)
  - **설정**: `/settings` 및 하위 라우트

### 6. Pet Routes ([routes/pet_routes.dart](routes/pet_routes.dart))

- **역할**: 펫 등록 플로우, 펫 프로필, 건강 관련 라우트
- **특징**: Shell 밖에서 독립적으로 실행
- **포함 라우트**:
  - **펫 등록 플로우**: `/pet-type-selection`, `/dog-breed-selection` 등
  - **펫 관리**: `/feeding-main`, `/recipes`, `/all-tricks` 등

### 7. Standalone Routes ([routes/standalone_routes.dart](routes/standalone_routes.dart))

- **역할**: 독립적인 전체화면 라우트
- **특징**: 하단 네비게이션 없이 전체화면으로 표시
- **포함 라우트**: `/weight-tracking`, `/health-records`, `/notifications` 등

## 사용법

### 라우트 상수 사용

```dart
// 라우트 상수 사용
context.go(RouteConstants.homeRoute);
context.go(RouteConstants.petProfileRoute);

// 하위 라우트 네비게이션
context.go('/home/pet-profile');

// 쿼리 파라미터와 함께 네비게이션
context.go('/home/pet-profile?petId=123');
```

### Shell 내에서의 네비게이션

```dart
// Shell 내에서 탭 간 이동
context.go('/scheduling/feeding-schedule');

// Shell 내에서 하위 라우트로 이동
context.go('/home/tricks');
context.go('/settings/profile-edit');
```

### 라우트 가드 및 리다이렉트

```dart
// 펫 등록 후 리다이렉트
GoRoute(
  path: 'pet-empty',
  redirect: (context, state) {
    final afterRegistration =
        state.uri.queryParameters['afterRegistration'] == 'true';

    if (afterRegistration) {
      return RouteConstants.petTypeSelectionRoute;
    }

    return RouteConstants.homeRoute;
  },
),
```

## 라우터 아키텍처

### 모듈형 구조

```dart
// 각 기능별로 라우트 파일 분리
class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
  ];
}

class PetRoutes {
  static List<RouteBase> get routes => [
    GoRoute(path: '/pet-type-selection', builder: (context, state) => PetTypeSelectionScreen()),
    // ... 기타 펫 관련 라우트
  ];
}
```

### Shell Router 활용

```dart
// 하단 네비게이션을 가진 Shell 라우트
ShellRoute(
  builder: (context, state, child) {
    return MainNavigationScreen(child: child);
  },
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/scheduling', builder: (context, state) => SchedulingScreen()),
    // ... 기타 탭 라우트
  ],
)
```

## 베스트 프랙티스

### 1. 라우트 구조

- **계층적 구조**: 메인 라우트 → 하위 라우트 → 쿼리 파라미터
- **일관된 네이밍**: kebab-case 사용으로 가독성 향상
- **라우트 상수**: 하드코딩된 문자열 대신 상수 사용

### 2. 성능 최적화

- **지연 로딩**: 필요할 때만 화면 로드
- **코드 분할**: 각 라우트별로 독립적인 코드 번들
- **캐싱**: 자주 사용되는 화면 캐싱

### 3. 사용자 경험

- **로딩 상태**: 네비게이션 중 적절한 로딩 표시
- **에러 처리**: 라우트 로드 실패 시 에러 화면 표시
- **애니메이션**: 부드러운 화면 전환 애니메이션

### 4. 유지보수성

- **모듈화**: 기능별로 라우트 파일 분리
- **문서화**: 각 라우트의 목적과 사용법 명시
- **테스트**: 라우트별 단위 테스트 작성

## 확장성

### 새로운 기능 모듈 추가

```dart
// 1. 라우트 상수 추가
class RouteConstants {
  // 기존 상수들...
  static const String newFeatureRoute = '/new-feature';
  static const String newFeatureDetailRoute = '/new-feature/detail';
}

// 2. 라우트 정의 추가
class NewFeatureRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteConstants.newFeatureRoute,
      builder: (context, state) => NewFeatureScreen(),
    ),
    GoRoute(
      path: RouteConstants.newFeatureDetailRoute,
      builder: (context, state) => NewFeatureDetailScreen(),
    ),
  ];
}

// 3. AppRouter에 추가
static GoRouter createRouter() {
  return GoRouter(
    routes: [
      // 기존 라우트들...
      ...NewFeatureRoutes.routes,
    ],
  );
}
```

### 새로운 탭 추가

```dart
// 1. 라우트 상수 추가
static const String newTabRoute = '/new-tab';

// 2. Shell 라우트에 추가
ShellRoute(
  builder: (context, state, child) => MainNavigationScreen(child: child),
  routes: [
    // 기존 탭들...
    GoRoute(
      path: RouteConstants.newTabRoute,
      name: 'new-tab',
      builder: (context, state) => NewTabScreen(),
    ),
  ],
)
```

---

## 日本語版 / 日本語バージョン

[한국어](#app-router-module) | [日本語](#app-router-module-1)

---

## App Router Module {#app-router-module-1}

アプリのルーティングシステムを管理するモジュールです。

### 📋 目次 (Table of Contents)

- [構造概要](#structure-overview-jp)
- [主要構成要素](#key-components-jp)
- [使用方法](#usage-jp)
- [ルーターアーキテクチャ](#router-architecture-jp)
- [ベストプラクティス](#best-practices-jp)
- [拡張性](#scalability-jp)

### 構造概要 {#structure-overview-jp}

```txt
lib/app/router/
├── [README.md](README.md)                                    # このドキュメント
├── [app_router.dart](app_router.dart)                        # メインルータークラス
└── [routes/](routes/)                                        # モジュール別ルート定義
    ├── [routes.dart](routes/routes.dart)                     # Exportファイル
    ├── [route_constants.dart](routes/route_constants.dart)   # ルート定数
    ├── [splash_shell_routes.dart](routes/splash_shell_routes.dart) # スプラッシュ→オンボーディング
    ├── [auth_routes.dart](routes/auth_routes.dart)           # 認証関連
    ├── [shell_routes.dart](routes/shell_routes.dart)         # メインアプリShell
    ├── [pet_routes.dart](routes/pet_routes.dart)             # ペット関連
    └── [standalone_routes.dart](routes/standalone_routes.dart) # 独立ルート
```

### 主要構成要素 {#key-components-jp}

#### 1. AppRouter 日本語版 ([app_router.dart](app_router.dart))

- **役割**: 中央集約されたアプリルーター設定
- **主要機能**:
  - **モジュール型ルーター構造**: 関心事別にルート分離
  - **ルーター優先順位管理**: Splash → Auth → Main Shell → Pet → Standalone
  - **ルート定数提供**: 全ルートパスを定数で管理

#### ルーター優先順位

```dart
static GoRouter createRouter() {
  return GoRouter(
    initialLocation: splashRoute, // スプラッシュシーケンスで開始
    routes: [
      // 1. Splash Shellルート (最優先、スキップ不可)
      SplashShellRoutes.splashShellRoute,

      // 2. 認証関連ルート
      ...AuthRoutes.routes,

      // 3. メインアプリShellルート (下部ナビゲーション)
      ShellRoutes.shellRoute,

      // 4. ペット関連ルート
      ...PetRoutes.routes,

      // 5. 独立したフルスクリーンルート
      ...StandaloneRoutes.routes,
    ],
  );
}
```

#### 2. Route Constants 日本語版 ([routes/route_constants.dart](routes/route_constants.dart))

- **役割**: 全ルートパスを定数で定義
- **ネーミング規則**:
  - **メインルート**: kebab-case (例: `/home`, `/pet-profile`)
  - **サブルート**: kebab-case (例: `/home/pet-empty`, `/settings/profile-edit`)
  - **クエリパラメータ**: camelCase (例: `/pet-profile?petId=123`)

#### ルートカテゴリ

```dart
class RouteConstants {
  // ===== SPLASH & ONBOARDING =====
  static const String logoRoute = '/';
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';

  // ===== AUTHENTICATION =====
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String welcomeRoute = '/welcome';

  // ===== MAIN APP TABS =====
  static const String homeRoute = '/home';
  static const String schedulingRoute = '/scheduling';
  static const String aiRoute = '/ai';
  static const String walkRoute = '/walk';
  static const String calendarRoute = '/calendar';
  static const String settingsRoute = '/settings';
}
```

#### 3. Splash Shell Routes 日本語版 ([routes/splash_shell_routes.dart](routes/splash_shell_routes.dart))

- **役割**: スプラッシュシーケンス → オンボーディング Shell ルート
- **特徴**: 最優先実行、ユーザーがスキップ不可
- **ルート順序**:
  1. `/splash` → 統合スプラッシュシーケンス (ローディング →ITZ→AI Pet)
  2. `/onboarding` → オンボーディング画面

#### 4. Auth Routes 日本語版 ([routes/auth_routes.dart](routes/auth_routes.dart))

- **役割**: ログイン、サインアップなど認証関連ルート
- **特徴**: Shell 外で独立実行
- **含むルート**: `/login`, `/signup`, `/welcome`

#### 5. Shell Routes 日本語版 ([routes/shell_routes.dart](routes/shell_routes.dart))

- **役割**: 下部ナビゲーションがあるメインアプリ画面
- **特徴**: MainNavigationScreen による下部ナビゲーション提供
- **主要タブ**:
  - **ホーム**: `/home`及びサブルート (`/home/pet-profile`, `/home/tricks`など)
  - **スケジューリング**: `/scheduling`及びサブルート (給食、訓練、健康など)
  - **AI**: `/ai` (AI チャットボット)
  - **散歩**: `/walk` (散歩記録)
  - **カレンダー**: `/calendar` (施設予約)
  - **設定**: `/settings`及びサブルート

#### 6. Pet Routes 日本語版 ([routes/pet_routes.dart](routes/pet_routes.dart))

- **役割**: ペット登録フロー、ペットプロフィール、健康関連ルート
- **特徴**: Shell 外で独立実行
- **含むルート**:
  - **ペット登録フロー**: `/pet-type-selection`, `/dog-breed-selection`など
  - **ペット管理**: `/feeding-main`, `/recipes`, `/all-tricks`など

#### 7. Standalone Routes 日본語版 ([routes/standalone_routes.dart](routes/standalone_routes.dart))

- **役割**: 独立したフルスクリーンルート
- **特徴**: 下部ナビゲーションなしでフルスクリーン表示
- **含むルート**: `/weight-tracking`, `/health-records`, `/notifications`など

### 使用方法 {#usage-jp}

#### ルート定数使用

```dart
// ルート定数使用
context.go(RouteConstants.homeRoute);
context.go(RouteConstants.petProfileRoute);

// サブルートナビゲーション
context.go('/home/pet-profile');

// クエリパラメータと共にナビゲーション
context.go('/home/pet-profile?petId=123');
```

#### Shell 内でのナビゲーション

```dart
// Shell内でタブ間移動
context.go('/scheduling/feeding-schedule');

// Shell内でサブルートに移動
context.go('/home/tricks');
context.go('/settings/profile-edit');
```

#### ルートガードとリダイレクト

```dart
// ペット登録後リダイレクト
GoRoute(
  path: 'pet-empty',
  redirect: (context, state) {
    final afterRegistration =
        state.uri.queryParameters['afterRegistration'] == 'true';

    if (afterRegistration) {
      return RouteConstants.petTypeSelectionRoute;
    }

    return RouteConstants.homeRoute;
  },
),
```

### ルーターアーキテクチャ {#router-architecture-jp}

#### モジュール型構造

```dart
// 各機能別にルートファイル分離
class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
  ];
}

class PetRoutes {
  static List<RouteBase> get routes => [
    GoRoute(path: '/pet-type-selection', builder: (context, state) => PetTypeSelectionScreen()),
    // ... その他ペット関連ルート
  ];
}
```

#### Shell Router 活用

```dart
// 下部ナビゲーションを持つShellルート
ShellRoute(
  builder: (context, state, child) {
    return MainNavigationScreen(child: child);
  },
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/scheduling', builder: (context, state) => SchedulingScreen()),
    // ... その他タブルート
  ],
)
```

### ベストプラクティス {#best-practices-jp}

#### 1. ルート構造

- **階層的構造**: メインルート → サブルート → クエリパラメータ
- **一貫したネーミング**: kebab-case 使用で可読性向上
- **ルート定数**: ハードコーディングされた文字列ではなく定数使用

#### 2. パフォーマンス最適化

- **遅延読み込み**: 必要時のみ画面読み込み
- **コード分割**: 各ルート別に独立したコードバンドル
- **キャッシング**: 頻繁使用画面のキャッシュ

#### 3. ユーザー体験

- **ローディング状態**: ナビゲーション中の適切なローディング表示
- **エラー処理**: ルート読み込み失敗時のエラー画面表示
- **アニメーション**: 滑らかな画面遷移アニメーション

#### 4. 保守性

- **モジュール化**: 機能別にルートファイル分離
- **ドキュメント化**: 各ルートの目的と使用方法明記
- **テスト**: ルート別単体テスト作成

### 拡張性 {#scalability-jp}

#### 新しい機能モジュール追加

```dart
// 1. ルート定数追加
class RouteConstants {
  // 既存定数...
  static const String newFeatureRoute = '/new-feature';
  static const String newFeatureDetailRoute = '/new-feature/detail';
}

// 2. ルート定義追加
class NewFeatureRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteConstants.newFeatureRoute,
      builder: (context, state) => NewFeatureScreen(),
    ),
    GoRoute(
      path: RouteConstants.newFeatureDetailRoute,
      builder: (context, state) => NewFeatureDetailScreen(),
    ),
  ];
}

// 3. AppRouterに追加
static GoRouter createRouter() {
  return GoRouter(
    routes: [
      // 既存ルート...
      ...NewFeatureRoutes.routes,
    ],
  );
}
```

#### 新しいタブ追加

```dart
// 1. ルート定数追加
static const String newTabRoute = '/new-tab';

// 2. Shellルートに追加
ShellRoute(
  builder: (context, state, child) => MainNavigationScreen(child: child),
  routes: [
    // 既存タブ...
    GoRoute(
      path: RouteConstants.newTabRoute,
      name: 'new-tab',
      builder: (context, state) => NewTabScreen(),
    ),
  ],
)
```
