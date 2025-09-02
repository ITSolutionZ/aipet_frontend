# Constants

이 디렉토리는 AI Pet Frontend 앱에서 사용되는 모든 상수들을 중앙에서 관리합니다.

## 개요

Constants 모듈은 앱 전체에서 공통으로 사용되는 상수, 에러 코드, 메시지 등을 정의합니다.
일관성 있는 값 사용과 유지보수를 위해 중앙에서 관리됩니다.

## 주요 구성 요소

### ErrorCodes

- 앱 전체에서 사용하는 표준화된 에러 코드와 메시지
- 네트워크, HTTP, Firebase Auth, 인증, 유효성 검사 등 카테고리별 분류
- 사용자 친화적인 에러 메시지 제공
- Firebase Auth 에러를 앱 에러 코드로 변환하는 유틸리티

## 사용 방법

```dart
import 'package:aipet_frontend/shared/constants/error_codes.dart';

// 에러 코드 사용
if (errorCode == ErrorCodes.networkConnectionError) {
  // 네트워크 연결 에러 처리
}

// 사용자 친화적인 에러 메시지 가져오기
final userMessage = ErrorCodes.getErrorMessage(ErrorCodes.httpUnauthorized);

// Firebase Auth 에러를 앱 에러 코드로 변환
final appErrorCode = ErrorCodes.mapFirebaseAuthError('user-not-found');

// HTTP 상태 코드를 앱 에러 코드로 변환
final appErrorCode = ErrorCodes.mapHttpStatusError(401);
```

## 에러 코드 카테고리

### 네트워크 관련 에러

- `NETWORK_CONNECTION_TIMEOUT`: 연결 시간 초과
- `NETWORK_RECEIVE_TIMEOUT`: 응답 시간 초과
- `NETWORK_SEND_TIMEOUT`: 요청 전송 시간 초과
- `NETWORK_CONNECTION_ERROR`: 네트워크 연결 실패
- `NETWORK_UNKNOWN_ERROR`: 알 수 없는 네트워크 오류

### HTTP 상태 코드 관련 에러

- `HTTP_400_BAD_REQUEST`: 잘못된 요청
- `HTTP_401_UNAUTHORIZED`: 인증 필요
- `HTTP_403_FORBIDDEN`: 접근 권한 없음
- `HTTP_404_NOT_FOUND`: 요청한 데이터 없음
- `HTTP_500_INTERNAL_SERVER_ERROR`: 서버 내부 오류

### Firebase Auth 관련 에러

- `FIREBASE_USER_NOT_FOUND`: 등록되지 않은 이메일
- `FIREBASE_WRONG_PASSWORD`: 잘못된 비밀번호
- `FIREBASE_EMAIL_ALREADY_IN_USE`: 이미 사용 중인 이메일
- `FIREBASE_WEAK_PASSWORD`: 약한 비밀번호

### 인증 관련 에러

- `AUTH_TOKEN_EXPIRED`: 토큰 만료
- `AUTH_TOKEN_INVALID`: 유효하지 않은 토큰
- `AUTH_LOGIN_REQUIRED`: 로그인 필요

### 유효성 검사 관련 에러

- `VALIDATION_EMAIL_INVALID`: 잘못된 이메일 형식
- `VALIDATION_PASSWORD_TOO_SHORT`: 비밀번호 너무 짧음
- `VALIDATION_FIELD_REQUIRED`: 필수 입력 항목

## 파일 구조

```text
lib/shared/constants/
├── README.md           # 이 파일
└── error_codes.dart    # 에러 코드 및 메시지
```

## 확장 방법

새로운 상수를 추가하려면:

1. 적절한 카테고리에 상수 추가
2. `getErrorMessage` 메서드에 해당 케이스 추가
3. 필요시 변환 메서드 추가
4. 이 README.md에 문서화

## 관련 파일

- `lib/shared/services/`: 에러 처리 서비스
- `lib/shared/utils/`: 유틸리티 함수
- `lib/app/controllers/`: 에러 처리를 위한 컨트롤러

---

## 日本語版 / 日本語バージョン

[한국어](#constants) | [日本語](#constants-1)

---

## Constants {#constants-1}

このディレクトリは、AI Pet Frontend アプリで使用されるすべての定数を中央で管理します。

### 📋 目次 (Table of Contents)

- [概要](#overview-1)
- [主要構成要素](#key-components-1)
- [使用方法](#usage-1)
- [エラーコードカテゴリ](#error-code-categories-1)
- [ファイル構造](#file-structure-1)
- [拡張方法](#extension-methods-1)
- [関連ファイル](#related-files-1)

### 概要 {#overview-1}

Constants モジュールは、アプリ全体で共通して使用される定数、エラーコード、メッセージなどを定義します。一貫性のある値の使用と保守性を向上させるために中央で管理されます。

### 主要構成要素 {#key-components-1}

#### ErrorCodes {#error-codes-1}

- アプリ全体で使用する標準化されたエラーコードとメッセージ
- ネットワーク、HTTP、Firebase Auth、認証、バリデーションなどのカテゴリ別分類
- ユーザーフレンドリーなエラーメッセージの提供
- Firebase Auth エラーをアプリエラーコードに変換するユーティリティ

### 使用方法 {#usage-1}

```dart
import 'package:aipet_frontend/shared/constants/error_codes.dart';

// エラーコードの使用
if (errorCode == ErrorCodes.networkConnectionError) {
  // ネットワーク接続エラーの処理
}

// ユーザーフレンドリーなエラーメッセージの取得
final userMessage = ErrorCodes.getErrorMessage(ErrorCodes.httpUnauthorized);

// Firebase Authエラーをアプリエラーコードに変換
final appErrorCode = ErrorCodes.mapFirebaseAuthError('user-not-found');

// HTTPステータスコードをアプリエラーコードに変換
final appErrorCode = ErrorCodes.mapHttpStatusError(401);
```

### エラーコードカテゴリ {#error-code-categories-1}

#### ネットワーク関連エラー

- `NETWORK_CONNECTION_TIMEOUT`: 接続タイムアウト
- `NETWORK_RECEIVE_TIMEOUT`: 応答タイムアウト
- `NETWORK_SEND_TIMEOUT`: リクエスト送信タイムアウト
- `NETWORK_CONNECTION_ERROR`: ネットワーク接続失敗
- `NETWORK_UNKNOWN_ERROR`: 不明なネットワークエラー

#### HTTP ステータスコード関連エラー

- `HTTP_400_BAD_REQUEST`: 不正なリクエスト
- `HTTP_401_UNAUTHORIZED`: 認証が必要
- `HTTP_403_FORBIDDEN`: アクセス権限なし
- `HTTP_404_NOT_FOUND`: 要求されたデータが見つかりません
- `HTTP_500_INTERNAL_SERVER_ERROR`: サーバー内部エラー

#### Firebase Auth 関連エラー

- `FIREBASE_USER_NOT_FOUND`: 登録されていないメール
- `FIREBASE_WRONG_PASSWORD`: 間違ったパスワード
- `FIREBASE_EMAIL_ALREADY_IN_USE`: 既に使用中のメール
- `FIREBASE_WEAK_PASSWORD`: 弱いパスワード

#### 認証関連エラー

- `AUTH_TOKEN_EXPIRED`: トークン期限切れ
- `AUTH_TOKEN_INVALID`: 無効なトークン
- `AUTH_LOGIN_REQUIRED`: ログインが必要

#### バリデーション関連エラー

- `VALIDATION_EMAIL_INVALID`: 不正なメール形式
- `VALIDATION_PASSWORD_TOO_SHORT`: パスワードが短すぎる
- `VALIDATION_FIELD_REQUIRED`: 必須入力項目

### ファイル構造 {#file-structure-1}

```text
lib/shared/constants/
├── README.md           # このファイル
└── error_codes.dart    # エラーコードとメッセージ
```

### 拡張方法 {#extension-methods-1}

新しい定数を追加するには：

1. 適切なカテゴリに定数を追加
2. `getErrorMessage`メソッドに該当ケースを追加
3. 必要に応じて変換メソッドを追加
4. この README.md に文書化

### 関連ファイル {#related-files-1}

- `lib/shared/services/`: エラー処理サービス
- `lib/shared/utils/`: ユーティリティ関数
- `lib/app/controllers/`: エラー処理のためのコントローラー
