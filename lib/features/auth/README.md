# Auth Feature / 認証機能

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
- [ID Token 데이터 플로우 (ID Token Data Flow)](#id-token-id-token-data-flow)
- [보안 기능 (Security Features)](#security-features)
- [사용 방법 (Usage)](#usage)
- [설정 (Configuration)](#configuration)

### 개요 (Overview)

AI Pet 애플리케이션의 인증 기능을 담당하는 모듈입니다. Firebase Authentication을 기반으로 한 안전하고 확장 가능한 인증 시스템을 제공합니다.

**주요 특징:**

- 🔐 Firebase Authentication 기반
- 🛡️ 보안 토큰 관리 (iOS Keychain, Android Keystore)
- 📱 다중 플랫폼 지원 (iOS, Android, Web)
- 🔄 자동 토큰 갱신
- 🎨 Clean Architecture 패턴 적용

### 아키텍처 (Architecture)

```txt
lib/features/auth/
├── data/               # 데이터 계층
├── domain/             # 도메인 계층 
├── presentation/       # 프레젠테이션 계층
└── utils/              # 유틸리티
```

**Clean Architecture 적용:**

- **Domain Layer**: 비즈니스 로직과 엔티티 정의
- **Data Layer**: Firebase Auth 및 토큰 저장소 구현
- **Presentation Layer**: UI 컨트롤러 및 화면 구성

### 주요 기능 (Key Features)

#### 🔑 인증 방법

- **이메일/비밀번호** 로그인 및 회원가입
- **Google** 소셜 로그인
- **Apple** 소셜 로그인 (iOS 전용)
- **LINE** 소셜 로그인 (예정)

#### 🛡️ 보안 기능

- **Firebase ID Token** 자동 관리
- **Secure Storage** - iOS Keychain/Android Keystore 활용
- **토큰 자동 갱신** - 만료 5분 전 자동 리프레시
- **에러 표준화** - 사용자 친화적 메시지 제공

#### 📊 상태 관리

- **Riverpod** 기반 상태 관리
- **Form 상태** 실시간 검증
- **로딩/에러 상태** 자동 처리

### 디렉토리 구조 (Directory Structure)

```txt
auth/
├── auth.dart                        # 기능 export 파일
├── data/
│   ├── auth_providers.dart          # Riverpod 프로바이더
│   ├── auth_service.dart           # 인증 서비스
│   ├── repositories/
│   │   ├── firebase_auth_repository.dart  # Firebase 구현체
│   │   └── mock_auth_repository.dart     # Mock 구현체
│   └── services/
│       ├── firebase_token_service.dart    # Token 관리
│       └── token_storage_service.dart     # 보안 저장소
├── domain/
│   ├── auth_constants.dart         # 상수 정의
│   ├── auth_error.dart            # 에러 타입
│   ├── auth_form_state.dart       # 폼 상태
│   ├── auth_state.dart            # 인증 상태
│   ├── auth_token.dart            # 토큰 모델
│   ├── repositories/
│   │   └── auth_repository.dart    # 추상 인터페이스
│   └── result.dart                # Result 패턴
├── presentation/
│   ├── controllers/
│   │   └── auth_controller.dart    # UI 컨트롤러
│   ├── screens/
│   │   ├── login_screen.dart       # 로그인 화면
│   │   ├── signup_screen.dart      # 회원가입 화면
│   │   └── welcome_screen.dart     # 웰컴 화면
│   └── widgets/
│       ├── auth_button.dart        # 인증 버튼
│       ├── auth_input_field.dart   # 입력 필드
│       ├── social_login_button.dart # 소셜 로그인 버튼
│       └── ... (기타 위젯)
└── utils/
    └── auth_validator.dart         # 입력 검증
```

### ID Token 데이터 플로우 (ID Token Data Flow)

이 애플리케이션은 Firebase ID Token을 중심으로 한 안전한 인증 데이터 플로우를 구현합니다.

#### 📊 인증 플로우 다이어그램

```txt
[사용자] → [Firebase Auth] → [ID Token] → [백엔드 API] → [JWT Token]
    ↓           ↓              ↓              ↓            ↓
  로그인     Firebase      자동 갱신      토큰 검증    사용자 세션
  요청       인증 완료      + 캐싱        + DB 조회    + 권한 관리
```

#### 🔄 토큰 생명주기 관리

**1단계: Firebase 인증**

```dart
// 이메일/비밀번호 로그인
final credential = await _firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

**2단계: ID Token 획득 및 캐싱**

```dart
// Firebase ID Token 가져오기 (자동 갱신 포함)
final idToken = await FirebaseTokenService.getCurrentIdToken();
if (idToken != null) {
  // iOS Keychain/Android Keystore에 안전하게 저장
  await _cacheIdToken(idToken);
}
```

**3단계: 백엔드 인증 및 JWT 발급**

```dart
// ID Token을 백엔드로 전송
final backendResponse = await HttpClientService.instance.post(
  '/auth/login',
  data: {'idToken': idToken},
);

// 백엔드에서 JWT Access/Refresh Token 발급
final accessToken = backendData['accessToken'];
final refreshToken = backendData['refreshToken'];
```

**4단계: 자동 토큰 관리**

```dart
// 토큰 만료 5분 전 자동 갱신
final shouldRefresh = await _shouldRefreshToken();
if (shouldRefresh) {
  final newToken = await user.getIdToken(true); // 강제 갱신
}
```

#### 🛡️ 보안 계층 구조

**Multi-Layer Security:**

1. **Firebase Security Rules** - 서버측 검증
2. **ID Token Verification** - 백엔드에서 토큰 무결성 확인
3. **JWT Access Control** - API 엔드포인트별 권한 제어
4. **Secure Storage** - 토큰의 안전한 로컬 저장

**토큰 저장 전략:**

- **Firebase ID Token**: Secure Storage (임시 캐싱)
- **JWT Access Token**: HTTP Client 메모리 (자동 헤더 주입)
- **JWT Refresh Token**: Secure Storage (장기간 보관)

#### 📡 HTTP 요청 자동화

```dart
// HTTP Client가 자동으로 Authorization 헤더 추가
options.headers['Authorization'] = 'Bearer ${token.accessToken}';

// 401 에러 시 자동 토큰 갱신 및 재요청
if (error.response?.statusCode == 401) {
  final refreshed = await _handleTokenRefresh(error, handler);
  if (refreshed) {
    // 새 토큰으로 원래 요청 재시도
    final retryResponse = await _dio.fetch(originalRequest);
  }
}
```

### 보안 기능 (Security Features)

#### 1. **토큰 관리**

```dart
// Firebase ID Token 자동 관리
final idToken = await FirebaseTokenService.getCurrentIdToken();

// 강제 토큰 갱신
final refreshedToken = await FirebaseTokenService.refreshIdToken();
```

#### 2. **보안 저장소**

```dart
// iOS Keychain / Android Keystore 활용
await SecureStorageServiceV2.setString('key', 'value');
final value = await SecureStorageServiceV2.getString('key');
```

#### 3. **자동 갱신**

- 토큰 만료 5분 전 자동 리프레시
- 네트워크 실패 시 지수 백오프 재시도
- Auth 상태 변경 시 자동 토큰 정리

### 사용 방법 (Usage)

#### 1. **로그인**

```dart
final authController = AuthController(ref);

// 이메일 로그인
final result = await authController.login();
if (result.isSuccess) {
  // 로그인 성공
} else {
  // 에러 처리
}
```

#### 2. **소셜 로그인**

```dart
// Google 로그인
final repository = ref.read(authRepositoryProvider);
final result = await repository.signInWithGoogle();
```

#### 3. **현재 사용자 확인**

```dart
final authState = ref.watch(authStateNotifierProvider);
if (authState.isAuthenticated) {
  final user = authState.user;
  // 로그인된 사용자 정보 활용
}
```

### 설정 (Configuration)

#### Firebase 설정

1. **iOS**: `ios/Runner/GoogleService-Info.plist`
2. **Android**: `android/app/google-services.json`
3. **Web**: `web/firebase-config.js` (필요시)

#### 의존성

```yaml
dependencies:
  firebase_auth: ^5.7.0
  firebase_core: ^3.15.2
  google_sign_in: ^6.3.0
  flutter_secure_storage: ^9.2.4
  flutter_riverpod: ^2.6.1
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#overview-1)
- [アーキテクチャ (Architecture)](#architecture-1)
- [主要機能 (Key Features)](#key-features-1)
- [ディレクトリ構造 (Directory Structure)](#directory-structure-1)
- [ID Token データフロー (ID Token Data Flow)](#id-token-id-token-data-flow-1)
- [セキュリティ機能 (Security Features)](#security-features-1)
- [使用方法 (Usage)](#usage-1)
- [設定 (Configuration)](#configuration-1)

### 概要 (Overview)

AI Petアプリケーションの認証機能を担当するモジュールです。Firebase Authenticationをベースにした安全で拡張可能な認証システムを提供します。

**主な特徴:**

- 🔐 Firebase Authentication ベース
- 🛡️ セキュアトークン管理 (iOS Keychain, Android Keystore)
- 📱 マルチプラットフォーム対応 (iOS, Android, Web)
- 🔄 自動トークンリフレッシュ
- 🎨 Clean Architecture パターン適用

### アーキテクチャ (Architecture)

```txt
lib/features/auth/
├── data/               # データ層
├── domain/             # ドメイン層 
├── presentation/       # プレゼンテーション層
└── utils/              # ユーティリティ
```

**Clean Architecture適用:**

- **Domain Layer**: ビジネスロジックとエンティティ定義
- **Data Layer**: Firebase Auth およびトークンストレージ実装
- **Presentation Layer**: UI コントローラーと画面構成

### 主要機能 (Key Features)

#### 🔑 認証方法

- **メール/パスワード** ログインおよびサインアップ
- **Google** ソーシャルログイン
- **Apple** ソーシャルログイン (iOS専用)
- **LINE** ソーシャルログイン (予定)

#### 🛡️ セキュリティ機能

- **Firebase ID Token** 自動管理
- **Secure Storage** - iOS Keychain/Android Keystore 活用
- **トークン自動更新** - 期限切れ5分前に自動リフレッシュ
- **エラー標準化** - ユーザーフレンドリーなメッセージ提供

#### 📊 状態管理

- **Riverpod** ベースの状態管理
- **Form状態** リアルタイム検証
- **ローディング/エラー状態** 自動処理

### ディレクトリ構造 (Directory Structure)

```txt
auth/
├── auth.dart                        # 機能 export ファイル
├── data/
│   ├── auth_providers.dart          # Riverpod プロバイダー
│   ├── auth_service.dart           # 認証サービス
│   ├── repositories/
│   │   ├── firebase_auth_repository.dart  # Firebase 実装
│   │   └── mock_auth_repository.dart     # Mock 実装
│   └── services/
│       ├── firebase_token_service.dart    # Token 管理
│       └── token_storage_service.dart     # セキュアストレージ
├── domain/
│   ├── auth_constants.dart         # 定数定義
│   ├── auth_error.dart            # エラータイプ
│   ├── auth_form_state.dart       # フォーム状態
│   ├── auth_state.dart            # 認証状態
│   ├── auth_token.dart            # トークンモデル
│   ├── repositories/
│   │   └── auth_repository.dart    # 抽象インターフェース
│   └── result.dart                # Result パターン
├── presentation/
│   ├── controllers/
│   │   └── auth_controller.dart    # UI コントローラー
│   ├── screens/
│   │   ├── login_screen.dart       # ログイン画面
│   │   ├── signup_screen.dart      # サインアップ画面
│   │   └── welcome_screen.dart     # ウェルカム画面
│   └── widgets/
│       ├── auth_button.dart        # 認証ボタン
│       ├── auth_input_field.dart   # 入力フィールド
│       ├── social_login_button.dart # ソーシャルログインボタン
│       └── ... (その他のウィジェット)
└── utils/
    └── auth_validator.dart         # 入力検証
```

### ID Token データフロー (ID Token Data Flow)

このアプリケーションは Firebase ID Token を中心とした安全な認証データフローを実装しています。

#### 📊 認証フロー図

```txt
[ユーザー] → [Firebase Auth] → [ID Token] → [バックエンド API] → [JWT Token]
     ↓           ↓              ↓              ↓              ↓
   ログイン     Firebase       自動リフレッシュ   トークン検証     ユーザーセッション
    要求        認証完了        + キャッシング    + DB 検索      + 権限管理
```

#### 🔄 トークンライフサイクル管理

**ステップ1: Firebase 認証**

```dart
// メール/パスワードログイン
final credential = await _firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

**ステップ2: ID Token 取得およびキャッシング**

```dart
// Firebase ID Token 取得 (自動リフレッシュ含む)
final idToken = await FirebaseTokenService.getCurrentIdToken();
if (idToken != null) {
  // iOS Keychain/Android Keystore に安全に保存
  await _cacheIdToken(idToken);
}
```

**ステップ3: バックエンド認証および JWT 発行**

```dart
// ID Token をバックエンドに送信
final backendResponse = await HttpClientService.instance.post(
  '/auth/login',
  data: {'idToken': idToken},
);

// バックエンドから JWT Access/Refresh Token 発行
final accessToken = backendData['accessToken'];
final refreshToken = backendData['refreshToken'];
```

**ステップ4: 自動トークン管理**

```dart
// トークン期限切れ5分前に自動リフレッシュ
final shouldRefresh = await _shouldRefreshToken();
if (shouldRefresh) {
  final newToken = await user.getIdToken(true); // 強制リフレッシュ
}
```

### セキュリティ機能 (Security Features)

#### 1. **トークン管理**

```dart
// Firebase ID Token 自動管理
final idToken = await FirebaseTokenService.getCurrentIdToken();

// 強制トークンリフレッシュ
final refreshedToken = await FirebaseTokenService.refreshIdToken();
```

#### 2. **セキュアストレージ**

```dart
// iOS Keychain / Android Keystore 活用
await SecureStorageServiceV2.setString('key', 'value');
final value = await SecureStorageServiceV2.getString('key');
```

#### 3. **自動リフレッシュ**

- トークン期限切れ5分前に自動リフレッシュ
- ネットワーク障害時の指数バックオフ再試行
- Auth状態変更時の自動トークンクリア

### 使用方法 (Usage)

#### 1. **ログイン**

```dart
final authController = AuthController(ref);

// メールログイン
final result = await authController.login();
if (result.isSuccess) {
  // ログイン成功
} else {
  // エラー処理
}
```

#### 2. **ソーシャルログイン**

```dart
// Google ログイン
final repository = ref.read(authRepositoryProvider);
final result = await repository.signInWithGoogle();
```

#### 3. **現在のユーザー確認**

```dart
final authState = ref.watch(authStateNotifierProvider);
if (authState.isAuthenticated) {
  final user = authState.user;
  // ログイン済みユーザー情報を活用
}
```

### 設定 (Configuration)

#### Firebase 設定

1. **iOS**: `ios/Runner/GoogleService-Info.plist`
2. **Android**: `android/app/google-services.json`
3. **Web**: `web/firebase-config.js` (必要に応じて)

#### 依存関係

```yaml
dependencies:
  firebase_auth: ^5.7.0
  firebase_core: ^3.15.2
  google_sign_in: ^6.3.0
  flutter_secure_storage: ^9.2.4
  flutter_riverpod: ^2.6.1
```

---

## 📚 추가 리소스 / その他のリソース

- [Firebase Auth 문서 / Firebase Auth ドキュメント](https://firebase.google.com/docs/auth)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Riverpod 가이드 / Riverpod ガイド](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**© 2024 AI Pet. 프로덕션 레벨 인증 시스템 / Production-ready Authentication System**