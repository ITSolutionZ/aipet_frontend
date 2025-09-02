# App Providers Module {#app-providers-module}

[한국어](#app-providers-module) | [日本語](#app-providers-module-1)

---

앱 레벨의 Riverpod 프로바이더들을 관리하는 모듈입니다.

## 구조 개요

```txt
lib/app/providers/
├── [README.md](README.md)                                    # 이 문서
├── [providers.dart](providers.dart)                          # 프로바이더 배럴 파일
├── [app_initialization_provider.dart](app_initialization_provider.dart) # 앱 초기화
├── [app_state_provider.dart](app_state_provider.dart)        # 앱 전역 상태 관리
└── [router_provider.dart](router_provider.dart)              # 라우터 프로바이더
```

## 주요 구성 요소

### 1. App Initialization Provider ([app_initialization_provider.dart](app_initialization_provider.dart))

- **역할**: 앱 시작 시 필요한 모든 초기화 작업 관리
- **초기화 단계**:
  1. **기본 서비스 초기화**: 에러 핸들러, 성능 모니터링, 사용자 경험, 알림 서비스
  2. **앱 설정 로드**: 환경별 설정 및 사용자 설정
  3. **사용자 인증 상태 확인**: Firebase Auth 상태 및 토큰 관리
  4. **온보딩 완료 상태 확인**: 사용자 온보딩 진행 상태
  5. **네트워크 연결 확인**: Connectivity Plus를 통한 연결 상태 확인
  6. **앱 버전 확인**: Package Info Plus를 통한 버전 정보
  7. **필수 데이터 로드**: 앱 실행에 필요한 기본 데이터
  8. **리소스 초기화**: 폰트, 이미지, 로컬 저장소 등

#### 앱 초기화 상태 데이터 구조

```dart
class AppInitializationState {
  final bool isInitialized;           // 초기화 완료 여부
  final bool isLoading;               // 초기화 진행 중 여부
  final String? error;                // 초기화 에러 메시지
  final bool isAuthenticated;         // 인증 상태
  final bool isOnboardingCompleted;   // 온보딩 완료 상태
  final String appVersion;            // 앱 버전
  final bool isNetworkConnected;      // 네트워크 연결 상태
}
```

### 2. App State Provider ([app_state_provider.dart](app_state_provider.dart))

- **역할**: 앱의 전역 상태 관리
- **주요 상태**:
  - **로딩 상태**: `isLoading`
  - **에러 상태**: `error`
  - **현재 시간**: `currentTime` (HH:MM 형식)
  - **온라인 상태**: `isOnline`
  - **앱 버전**: `appVersion`
  - **마지막 동기화 시간**: `lastSyncTime`

#### 앱 상태 데이터 구조

```dart
class AppStateData {
  final bool isLoading;
  final String? error;
  final String? currentTime;
  final bool isOnline;
  final String appVersion;
  final DateTime? lastSyncTime;

  // 계산된 속성
  bool get hasError => error != null;
  bool get isOffline => !isOnline;
  int? get minutesSinceLastSync => /* 계산 로직 */;
}
```

### 3. Router Provider ([router_provider.dart](router_provider.dart))

- **역할**: GoRouter 인스턴스 및 현재 라우트 정보 제공
- **주요 프로바이더**:
  - **routerProvider**: GoRouter 인스턴스
  - **currentRouteProvider**: 현재 활성화된 라우트 경로

## 사용법

### 앱 초기화 상태 구독

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitializationProvider);

    if (initState.isLoading) {
      return const LoadingScreen();
    }

    if (initState.error != null) {
      return ErrorScreen(error: initState.error!);
    }

    if (!initState.isOnboardingCompleted) {
      return const OnboardingScreen();
    }

    if (!initState.isAuthenticated) {
      return const LoginScreen();
    }

    return const HomeContent();
  }
}
```

### 앱 상태 관리

```dart
class AppController {
  final WidgetRef ref;

  AppController(this.ref);

  void updateCurrentTime() {
    ref.read(appStateProvider.notifier).updateCurrentTime();
  }

  void setOnlineStatus(bool isOnline) {
    ref.read(appStateProvider.notifier).setOnlineStatus(isOnline);
  }

  void setError(String? error) {
    ref.read(appStateProvider.notifier).setError(error);
  }
}
```

### 라우터 사용

```dart
class NavigationService {
  final WidgetRef ref;

  NavigationService(this.ref);

  void navigateToHome() {
    final router = ref.read(routerProvider);
    router.go('/home');
  }

  String getCurrentRoute() {
    return ref.read(currentRouteProvider);
  }
}
```

## 프로바이더 구조

### 의존성 관계

```dart
// 앱 초기화 프로바이더
@riverpod
class AppInitialization extends _$AppInitialization {
  // 다른 프로바이더들과의 의존성
  final onboardingRepository = ref.read(onboardingRepositoryProvider);
  final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
}

// 앱 상태 프로바이더
@riverpod
class AppState extends _$AppState {
  // 독립적인 상태 관리
}

// 라우터 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter();
});
```

### 상태 업데이트 패턴

```dart
// 상태 업데이트
state = state.copyWith(
  isLoading: false,
  isInitialized: true,
  error: null,
);

// 부분 업데이트
state = state.copyWith(isLoading: false);
```

## 베스트 프랙티스

### 1. 상태 관리

- **불변성 유지**: copyWith를 통한 상태 업데이트
- **단일 책임**: 각 프로바이더는 하나의 주요 상태만 관리
- **에러 처리**: 초기화 실패 시 적절한 에러 상태 설정

### 2. 성능 최적화

- **선택적 구독**: 필요한 상태만 watch
- **자동 정리**: AutoDisposeNotifier 사용으로 메모리 관리
- **지연 초기화**: 필요할 때만 초기화 작업 수행

### 3. 테스트 가능성

- **의존성 주입**: ref를 통한 의존성 주입으로 테스트 용이
- **상태 격리**: 각 프로바이더의 상태를 독립적으로 테스트
- **Mock 지원**: 다른 프로바이더를 Mock으로 대체 가능

### 4. 에러 처리

- **초기화 실패 처리**: 각 단계별 에러 처리 및 복구
- **사용자 친화적 메시지**: 기술적 에러를 사용자에게 친화적으로 변환
- **로깅**: 디버그 모드에서 상세한 로그 출력

## 확장성

### 새로운 프로바이더 추가

```dart
@riverpod
class NewFeatureState extends _$NewFeatureState {
  @override
  NewFeatureStateData build() {
    return const NewFeatureStateData();
  }

  void updateState(NewFeatureData data) {
    state = state.copyWith(data: data);
  }
}
```

### 새로운 상태 속성 추가

```dart
class AppStateData {
  // 기존 속성들...
  final String? newProperty;

  const AppStateData({
    // 기존 매개변수들...
    this.newProperty,
  });

  AppStateData copyWith({
    // 기존 매개변수들...
    String? newProperty,
  }) {
    return AppStateData(
      // 기존 속성들...
      newProperty: newProperty ?? this.newProperty,
    );
  }
}
```

### 새로운 초기화 단계 추가

```dart
Future<void> initialize() async {
  // 기존 단계들...

  // 9. 새로운 초기화 단계
  await _initializeNewFeature();

  state = state.copyWith(isInitialized: true, isLoading: false);
}

Future<void> _initializeNewFeature() async {
  // 새로운 기능 초기화 로직
}
```

---

## 日本語版 / 日本語バージョン

[한국어](#app-providers-module) | [日本語](#app-providers-module-1)

---

## App Providers Module {#app-providers-module-1}

アプリレベルの Riverpod プロバイダーを管理するモジュールです。

### 📋 目次 (Table of Contents)

- [構造概要](#structure-overview)
- [主要構成要素](#key-components)
- [使用方法](#usage)
- [プロバイダー構造](#provider-structure)
- [ベストプラクティス](#best-practices)
- [拡張性](#scalability)

### 構造概要 {#structure-overview}

```txt
lib/app/providers/
├── [README.md](README.md)                                    # このドキュメント
├── [providers.dart](providers.dart)                          # プロバイダーバレルファイル
├── [app_initialization_provider.dart](app_initialization_provider.dart) # アプリ初期化
├── [app_state_provider.dart](app_state_provider.dart)        # アプリグローバル状態管理
└── [router_provider.dart](router_provider.dart)              # ルータープロバイダー
```

### 主要構成要素 {#key-components}

#### 1. App Initialization Provider 日本語版 ([app_initialization_provider.dart](app_initialization_provider.dart))

- **役割**: アプリ起動時に必要な全ての初期化作業を管理
- **初期化段階**:
  1. **基本サービス初期化**: エラーハンドラー、パフォーマンス監視、ユーザー体験、通知サービス
  2. **アプリ設定読み込み**: 環境別設定とユーザー設定
  3. **ユーザー認証状態確認**: Firebase Auth 状態とトークン管理
  4. **オンボーディング完了状態確認**: ユーザーオンボーディング進行状態
  5. **ネットワーク接続確認**: Connectivity Plus による接続状態確認
  6. **アプリバージョン確認**: Package Info Plus によるバージョン情報
  7. **必須データ読み込み**: アプリ実行に必要な基本データ
  8. **リソース初期化**: フォント、画像、ローカルストレージなど

#### 状態データ構造

```dart
class AppInitializationState {
  final bool isInitialized;           // 初期化完了の有無
  final bool isLoading;               // 初期化進行中の有無
  final String? error;                // 初期化エラーメッセージ
  final bool isAuthenticated;         // 認証状態
  final bool isOnboardingCompleted;   // オンボーディング完了状態
  final String appVersion;            // アプリバージョン
  final bool isNetworkConnected;      // ネットワーク接続状態
}
```

#### 2. App State Provider 日本語版 ([app_state_provider.dart](app_state_provider.dart))

- **役割**: アプリのグローバル状態管理
- **主要状態**:
  - **ローディング状態**: `isLoading`
  - **エラー状態**: `error`
  - **現在時刻**: `currentTime` (HH:MM 形式)
  - **オンライン状態**: `isOnline`
  - **アプリバージョン**: `appVersion`
  - **最終同期時刻**: `lastSyncTime`

#### 日本語版 앱 상태 데이터 구조

```dart
class AppStateData {
  final bool isLoading;
  final String? error;
  final String? currentTime;
  final bool isOnline;
  final String appVersion;
  final DateTime? lastSyncTime;

  // 計算された属性
  bool get hasError => error != null;
  bool get isOffline => !isOnline;
  int? get minutesSinceLastSync => /* 計算ロジック */;
}
```

#### 3. Router Provider 日本語版 ([router_provider.dart](router_provider.dart))

- **役割**: GoRouter インスタンスと現在ルート情報提供
- **主要プロバイダー**:
  - **routerProvider**: GoRouter インスタンス
  - **currentRouteProvider**: 現在アクティブなルートパス

### 使用方法 {#usage}

#### アプリ初期化状態購読

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitializationProvider);

    if (initState.isLoading) {
      return const LoadingScreen();
    }

    if (initState.error != null) {
      return ErrorScreen(error: initState.error!);
    }

    if (!initState.isOnboardingCompleted) {
      return const OnboardingScreen();
    }

    if (!initState.isAuthenticated) {
      return const LoginScreen();
    }

    return const HomeContent();
  }
}
```

#### アプリ状態管理

```dart
class AppController {
  final WidgetRef ref;

  AppController(this.ref);

  void updateCurrentTime() {
    ref.read(appStateProvider.notifier).updateCurrentTime();
  }

  void setOnlineStatus(bool isOnline) {
    ref.read(appStateProvider.notifier).setOnlineStatus(isOnline);
  }

  void setError(String? error) {
    ref.read(appStateProvider.notifier).setError(error);
  }
}
```

#### ルーター使用

```dart
class NavigationService {
  final WidgetRef ref;

  NavigationService(this.ref);

  void navigateToHome() {
    final router = ref.read(routerProvider);
    router.go('/home');
  }

  String getCurrentRoute() {
    return ref.read(currentRouteProvider);
  }
}
```

### プロバイダー構造 {#provider-structure}

#### 依存関係

```dart
// アプリ初期化プロバイダー
@riverpod
class AppInitialization extends _$AppInitialization {
  // 他のプロバイダーとの依存関係
  final onboardingRepository = ref.read(onboardingRepositoryProvider);
  final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
}

// アプリ状態プロバイダー
@riverpod
class AppState extends _$AppState {
  // 独立した状態管理
}

// ルータープロバイダー
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter();
});
```

#### 状態更新パターン

```dart
// 状態更新
state = state.copyWith(
  isLoading: false,
  isInitialized: true,
  error: null,
);

// 部分更新
state = state.copyWith(isLoading: false);
```

### ベストプラクティス {#best-practices}

#### 1. 状態管理

- **不変性維持**: copyWith による状態更新
- **単一責任**: 各プロバイダーは一つの主要状態のみ管理
- **エラー処理**: 初期化失敗時の適切なエラー状態設定

#### 2. パフォーマンス最適化

- **選択的購読**: 必要な状態のみ watch
- **自動クリーンアップ**: AutoDisposeNotifier 使用でメモリ管理
- **遅延初期化**: 必要時のみ初期化作業実行

#### 3. テスト可能性

- **依存性注入**: ref による依存性注入でテスト容易
- **状態分離**: 各プロバイダーの状態を独立してテスト
- **Mock サポート**: 他のプロバイダーを Mock で置換可能

#### 4. エラー処理

- **初期化失敗処理**: 各段階別エラー処理と復旧
- **ユーザーフレンドリーなメッセージ**: 技術的エラーをユーザーに親しみやすく変換
- **ログ出力**: デバッグモードでの詳細ログ出力

### 拡張性 {#scalability}

#### 新しいプロバイダー追加

```dart
@riverpod
class NewFeatureState extends _$NewFeatureState {
  @override
  NewFeatureStateData build() {
    return const NewFeatureStateData();
  }

  void updateState(NewFeatureData data) {
    state = state.copyWith(data: data);
  }
}
```

#### 新しい状態属性追加

```dart
class AppStateData {
  // 既存属性...
  final String? newProperty;

  const AppStateData({
    // 既存パラメータ...
    this.newProperty,
  });

  AppStateData copyWith({
    // 既存パラメータ...
    String? newProperty,
  }) {
    return AppStateData(
      // 既存属性...
      newProperty: newProperty ?? this.newProperty,
    );
  }
}
```

#### 新しい初期化段階追加

```dart
Future<void> initialize() async {
  // 既存段階...

  // 9. 新しい初期化段階
  await _initializeNewFeature();

  state = state.copyWith(isInitialized: true, isLoading: false);
}

Future<void> _initializeNewFeature() async {
  // 新しい機能初期化ロジック
}
```
