# App Controllers Module

## 🌏 언어 선택 / Language Selection

[English](#english-version) | [한국어](#korean-version) | [日本語](#japanese-version)

---

## English Version

### 📋 Overview

The App Controllers module manages application-level controllers that provide
centralized business logic, resource management, and error handling for the
AIPet application.

### 🏗️ Structure

```txt
lib/app/controllers/
├── README.md                    # This documentation
├── controllers.dart             # Controller barrel file
└── base_controller.dart         # Base controller class
```

### 🔧 Key Components

#### 1. BaseController

**Purpose**: Base class for all application controllers

**Key Features**:

- **Memory Leak Prevention**: Automatic cleanup of StreamSubscriptions, Timers, and
  ChangeNotifiers
- **Error Handling**: Centralized error processing with user-friendly messages
- **Safe Async Operations**: Built-in timeout and retry logic
- **Resource Management**: Automatic cleanup in dispose() method

#### Core Methods

```dart
/// Error handling
void handleError(Object error, [StackTrace? stackTrace]);

/// Generate user-friendly error messages
String getUserFriendlyErrorMessage(Object error);

/// Safe async operation execution
Future<T?> safeExecute<T>(Future<T> Function() action);

/// Safe async operation with timeout
Future<T?> safeExecuteWithTimeout<T>(Future<T> Function() action);

/// Safe async operation with retry logic
Future<T?> safeExecuteWithRetry<T>(Future<T> Function() action);
```

#### 2. Resource Management System

##### StreamSubscription Management

```dart
// Automatic StreamSubscription registration
void addSubscription(StreamSubscription subscription);

// Auto-cancel all subscriptions on dispose()
@override
void dispose() {
  for (final subscription in _subscriptions) {
    subscription.cancel();
  }
  _subscriptions.clear();
}
```

##### Timer Management

```dart
// Schedule delayed tasks
Timer scheduleTask(VoidCallback task, Duration delay);

// Schedule periodic tasks
Timer schedulePeriodicTask(VoidCallback task, Duration period);

// Auto-cancel all timers on dispose()
```

##### ChangeNotifier Management

```dart
// Automatic ChangeNotifier registration
void addNotifier(ChangeNotifier notifier);

// Auto-dispose all notifiers on dispose()
```

### 💡 Usage Examples

#### Basic Controller Implementation

```dart
class HomeController extends BaseController {
  HomeController(super.ref, super.context);

  Future<void> loadData() async {
    // Safe async operation execution
    final result = await safeExecute(() async {
      return await _repository.fetchData();
    });

    if (result != null) {
      // Handle success
    }
  }

  @override
  void dispose() {
    // Additional cleanup if needed
    super.dispose();
  }
}
```

#### Error Handling

```dart
class UserController extends BaseController {
  Future<void> updateUser(User user) async {
    try {
      await _repository.updateUser(user);
    } catch (error, stackTrace) {
      // Centralized error handling
      handleError(error, stackTrace);

      // User-friendly message generation
      final message = getUserFriendlyErrorMessage(error);
      // Display message in UI
    }
  }
}
```

### 🎯 Best Practices

1. **Memory Management**

   - Always extend BaseController for all controllers
   - Register all Streams, Timers, and ChangeNotifiers
   - Always call dispose() when controller is no longer needed

2. **Error Handling**

   - Use centralized handleError() method
   - Leverage getUserFriendlyErrorMessage() for UI messages
   - Include stack traces for error logging

3. **Async Operations**

   - Use safeExecute() for safe async operations
   - Set appropriate timeout values
   - Implement retry logic for network errors

---

## Korean Version

### 📋 개요

App Controllers 모듈은 AIPet 애플리케이션의 중앙화된 비즈니스 로직,
리소스 관리 및 오류 처리를 제공하는 애플리케이션 레벨 컨트롤러를
관리합니다.

### 🏗️ 구조

```txt
lib/app/controllers/
├── README.md                    # 이 문서
├── controllers.dart             # 컨트롤러 배럴 파일
└── base_controller.dart         # 기본 컨트롤러 클래스
```

### 🔧 주요 구성 요소

#### 1. BaseController (기본 컨트롤러)

**목적**: 모든 애플리케이션 컨트롤러의 기본 클래스

**주요 기능**:

- **메모리 누수 방지**: StreamSubscription, Timer, ChangeNotifier의 자동 정리
- **오류 처리**: 사용자 친화적 메시지와 함께 중앙화된 오류 처리
- **안전한 비동기 작업**: 내장된 타임아웃 및 재시도 로직
- **리소스 관리**: dispose() 메서드에서 자동 정리

#### 핵심 메서드

```dart
/// 오류 처리
void handleError(Object error, [StackTrace? stackTrace]);

/// 사용자 친화적 오류 메시지 생성
String getUserFriendlyErrorMessage(Object error);

/// 안전한 비동기 작업 실행
Future<T?> safeExecute<T>(Future<T> Function() action);

/// 타임아웃이 있는 안전한 비동기 작업
Future<T?> safeExecuteWithTimeout<T>(Future<T> Function() action);

/// 재시도 로직이 있는 안전한 비동기 작업
Future<T?> safeExecuteWithRetry<T>(Future<T> Function() action);
```

#### 2. 리소스 관리 시스템

##### StreamSubscription 관리

```dart
// StreamSubscription 자동 등록
void addSubscription(StreamSubscription subscription);

// dispose() 시 모든 구독 자동 취소
@override
void dispose() {
  for (final subscription in _subscriptions) {
    subscription.cancel();
  }
  _subscriptions.clear();
}
```

##### Timer 관리

```dart
// 지연된 작업 스케줄링
Timer scheduleTask(VoidCallback task, Duration delay);

// 주기적 작업 스케줄링
Timer schedulePeriodicTask(VoidCallback task, Duration period);

// dispose() 시 모든 타이머 자동 취소
```

##### ChangeNotifier 관리

```dart
// ChangeNotifier 자동 등록
void addNotifier(ChangeNotifier notifier);

// dispose() 시 모든 notifier 자동 해제
```

### 💡 사용 예제

#### 기본 컨트롤러 구현

```dart
class HomeController extends BaseController {
  HomeController(super.ref, super.context);

  Future<void> loadData() async {
    // 안전한 비동기 작업 실행
    final result = await safeExecute(() async {
      return await _repository.fetchData();
    });

    if (result != null) {
      // 성공 처리
    }
  }

  @override
  void dispose() {
    // 필요시 추가 정리
    super.dispose();
  }
}
```

#### 오류 처리

```dart
class UserController extends BaseController {
  Future<void> updateUser(User user) async {
    try {
      await _repository.updateUser(user);
    } catch (error, stackTrace) {
      // 중앙화된 오류 처리
      handleError(error, stackTrace);

      // 사용자 친화적 메시지 생성
      final message = getUserFriendlyErrorMessage(error);
      // UI에 메시지 표시
    }
  }
}
```

### 🎯 모범 사례

1. **메모리 관리**

   - 모든 컨트롤러에 대해 항상 BaseController 상속
   - 모든 Stream, Timer, ChangeNotifier 등록
   - 컨트롤러가 더 이상 필요하지 않을 때 항상 dispose() 호출

2. **오류 처리**

   - 중앙화된 handleError() 메서드 사용
   - UI 메시지에 getUserFriendlyErrorMessage() 활용
   - 오류 로깅을 위한 스택 트레이스 포함

3. **비동기 작업**

   - 안전한 비동기 작업을 위해 safeExecute() 사용
   - 적절한 타임아웃 값 설정
   - 네트워크 오류에 대한 재시도 로직 구현

---

## Japanese Version

### 📋 概要

App Controllers モジュールは、AIPet アプリケーションの中央化された
ビジネスロジック、リソース管理、エラー処理を提供するアプリケーションレベルの
コントローラーを管理します。

### 🏗️ 構造

```txt
lib/app/controllers/
├── README.md                    # このドキュメント
├── controllers.dart             # コントローラーバレルファイル
└── base_controller.dart         # ベースコントローラークラス
```

### 🔧 主要コンポーネント

#### 1. BaseController (ベースコントローラー)

**目的**: すべてのアプリケーションコントローラーのベースクラス

**主要機能**:

- **メモリリーク防止**: StreamSubscription、Timer、ChangeNotifier の自動クリーンアップ
- **エラー処理**: ユーザーフレンドリーなメッセージと共に中央化されたエラー処理
- **安全な非同期操作**: 内蔵タイムアウトとリトライロジック
- **リソース管理**: dispose()メソッドでの自動クリーンアップ

#### コアメソッド

```dart
/// エラー処理
void handleError(Object error, [StackTrace? stackTrace]);

/// ユーザーフレンドリーなエラーメッセージ生成
String getUserFriendlyErrorMessage(Object error);

/// 安全な非同期操作実行
Future<T?> safeExecute<T>(Future<T> Function() action);

/// タイムアウト付き安全な非同期操作
Future<T?> safeExecuteWithTimeout<T>(Future<T> Function() action);

/// リトライロジック付き安全な非同期操作
Future<T?> safeExecuteWithRetry<T>(Future<T> Function() action);
```

#### 2. リソース管理システム

##### StreamSubscription 管理

```dart
// StreamSubscription自動登録
void addSubscription(StreamSubscription subscription);

// dispose()時にすべてのサブスクリプション自動キャンセル
@override
void dispose() {
  for (final subscription in _subscriptions) {
    subscription.cancel();
  }
  _subscriptions.clear();
}
```

##### Timer 管理

```dart
// 遅延タスクのスケジューリング
Timer scheduleTask(VoidCallback task, Duration delay);

// 定期タスクのスケジューリング
Timer schedulePeriodicTask(VoidCallback task, Duration period);

// dispose()時にすべてのタイマー自動キャンセル
```

##### ChangeNotifier 管理

```dart
// ChangeNotifier自動登録
void addNotifier(ChangeNotifier notifier);

// dispose()時にすべてのnotifier自動破棄
```

### 💡 使用例

#### 基本コントローラー実装

```dart
class HomeController extends BaseController {
  HomeController(super.ref, super.context);

  Future<void> loadData() async {
    // 安全な非同期操作実行
    final result = await safeExecute(() async {
      return await _repository.fetchData();
    });

    if (result != null) {
      // 成功処理
    }
  }

  @override
  void dispose() {
    // 必要に応じて追加クリーンアップ
    super.dispose();
  }
}
```

#### エラー処理

```dart
class UserController extends BaseController {
  Future<void> updateUser(User user) async {
    try {
      await _repository.updateUser(user);
    } catch (error, stackTrace) {
      // 中央化されたエラー処理
      handleError(error, stackTrace);

      // ユーザーフレンドリーなメッセージ生成
      final message = getUserFriendlyErrorMessage(error);
      // UIにメッセージ表示
    }
  }
}
```

### 🎯 ベストプラクティス

1. **メモリ管理**

   - すべてのコントローラーで BaseController を常に継承
   - すべての Stream、Timer、ChangeNotifier を登録
   - コントローラーが不要になったら必ず dispose()を呼び出し

2. **エラー処理**

   - 中央化された handleError()メソッドを使用
   - UI メッセージに getUserFriendlyErrorMessage()を活用
   - エラーログ用にスタックトレースを含める

3. **非同期操作**

   - 安全な非同期操作に safeExecute()を使用
   - 適切なタイムアウト値を設定
   - ネットワークエラーに対するリトライロジックを実装

---

## 📚 Additional Information

For more detailed documentation, see the individual controller files and
implementation examples.
