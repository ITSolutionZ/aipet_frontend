# Services

이 디렉토리는 AI Pet Frontend 앱의 모든 서비스 로직을 중앙에서 관리합니다.

## 개요

Services 모듈은 앱의 비즈니스 로직, 외부 API 통신, 데이터 처리, 에러 처리 등을
담당하는 서비스 클래스들을 포함합니다. Clean Architecture 원칙에 따라 도메인 로직과
분리되어 관리됩니다.

## 주요 구성 요소

### API Service

- **ApiService**: HTTP 통신을 담당하는 중앙 서비스
- GET, POST, PUT, DELETE 요청 처리
- Mock 데이터와 실제 API 호출 간 전환
- 타임아웃 및 에러 처리

### Error Handling Services

- **ErrorHandlerService**: 전역 에러 처리 및 모니터링
- **ErrorService**: 애플리케이션 레벨 에러 관리
- 에러 심각도별 처리 및 로깅

### Security Services

- **EncryptionService**: 데이터 암호화/복호화
- **SecureStorageService**: 민감한 데이터 안전 저장
- **SecureStorageServiceV2**: 개선된 보안 저장소

### Performance Services

- **PerformanceMonitorService**: 앱 성능 모니터링
- **PerformanceOptimizerService**: 성능 최적화

### Notification Services

- **NotificationService**: 푸시 알림 관리
- **NotificationSchedulerService**: 알림 스케줄링
- **NotificationTemplateService**: 알림 템플릿 관리
- **NotificationAnalyticsService**: 알림 분석

### Utility Services

- **HttpClientService**: HTTP 클라이언트 설정
- **ImageCacheService**: 이미지 캐싱 및 최적화
- **LinkRegistrationService**: 링크 등록 처리
- **UiService**: UI 관련 서비스
- **UserExperienceService**: 사용자 경험 최적화

## 사용 방법

### API Service 사용

````dartdart
import 'package:aipet_frontend/shared/core/services/api_service.dart';

// GET 요청
final response = await ApiService.get('/users');
if (response.isSuccess) {
  final users = response.data;
}

// POST 요청
final createResponse = await ApiService.post(
  '/users',
  body: {'name': 'John', 'email': 'john@example.com'},
);
```dart

### Error Handling 사용

```dartdart
import 'package:aipet_frontend/shared/core/services/error_handler_service.dart';

// 에러 처리 서비스 초기화
await ErrorHandlerService().initialize();

// 에러 처리
ErrorHandlerService().handleError(
  error,
  severity: ErrorSeverity.medium,
  type: ErrorType.network,
);
```dart

### Encryption Service 사용

```dartdart
import 'package:aipet_frontend/shared/core/services/encryption_service.dart';

// 데이터 암호화하여 저장
await EncryptionService.encryptAndSave('user_token', token, prefs);

// 암호화된 데이터 복호화
final decryptedToken = await EncryptionService.decryptAndLoad('user_token', prefs);
```dart

### Notification Service 사용

```dartdart
import 'package:aipet_frontend/shared/core/services/notification_service.dart';

// 알림 서비스 초기화
await NotificationService().initialize();

// 로컬 알림 생성
await NotificationService().showLocalNotification(
  title: '산책 시간',
  body: '펫과 함께 산책할 시간입니다!',
);
```dart

## Mock 데이터 지원

대부분의 서비스는 Mock 데이터를 지원하여 API 연계 전까지 개발 및 테스트가 가능합니다:

```dartdart
// Mock 데이터 활성화/비활성화
static const bool isEnabled = true; // false로 설정하면 실제 API 호출
```dart

## 파일 구조

```darttext
lib/shared/core/services/
├── README.md                           # 이 파일
├── api_service.dart                    # API 통신 서비스
├── encryption_service.dart             # 암호화 서비스
├── error_handler_service.dart          # 전역 에러 처리
├── error_service.dart                  # 에러 관리 서비스
├── http_client_service.dart            # HTTP 클라이언트
├── image_cache_service.dart            # 이미지 캐싱
├── link_registration_service.dart      # 링크 등록
├── notification_analytics_service.dart # 알림 분석
├── notification_scheduler_service.dart # 알림 스케줄링
├── notification_service.dart           # 알림 관리
├── notification_template_service.dart  # 알림 템플릿
├── performance_monitor_service.dart    # 성능 모니터링
├── performance_optimizer_service.dart  # 성능 최적화
├── secure_storage_service.dart         # 보안 저장소
├── secure_storage_service_v2.dart     # 보안 저장소 v2
├── ui_service.dart                     # UI 서비스
└── user_experience_service.dart        # 사용자 경험
```dart

## 서비스 초기화

앱 시작 시 필요한 서비스들을 초기화해야 합니다:

```dartdart
void main() async {
  // 에러 처리 서비스 초기화
  await ErrorHandlerService().initialize();

  // 알림 서비스 초기화
  await NotificationService().initialize();

  // 기타 서비스 초기화...

  runApp(MyApp());
}
```dart

## 확장 방법

새로운 서비스를 추가하려면:

1. 서비스 클래스 생성
2. 필요한 인터페이스 및 구현체 정의
3. 의존성 주입 설정 (필요시)
4. 이 README.md에 문서화
5. 관련 테스트 작성

## 관련 파일

- `lib/features/*/`: 기능별 서비스 사용
- `lib/app/controllers/`: 컨트롤러에서 서비스 호출
- `lib/app/providers/`: 서비스 프로바이더 설정

---

## 日本語版 / 日本語バージョン

[한국어](#services) | [日本語](#services-1)

---

## Services {#services-1}

このディレクトリは、AI Pet Frontend アプリのすべてのサービスロジックを中央で管理します。

### 📋 目次 (Table of Contents)

- [概要](#overview-1)
- [主要構成要素](#key-components-1)
- [使用方法](#usage-1)
- [Mock データサポート](#mock-data-support-1)
- [ファイル構造](#file-structure-1)
- [サービス初期化](#service-initialization-1)
- [拡張方法](#extension-methods-1)
- [関連ファイル](#related-files-1)

### 概要 {#overview-1}

Services モジュールは、アプリのビジネスロジック、外部 API 通信、データ処理、
エラー処理などを担当するサービスクラスを含みます。Clean Architecture の原則に従って
ドメインロジックと分離されて管理されます。

### 主要構成要素 {#key-components-1}

#### API Service

- **ApiService**: HTTP 通信を担当する中央サービス
- GET、POST、PUT、DELETE リクエスト処理
- Mock データと実際の API 呼び出し間の切り替え
- タイムアウトとエラー処理

#### Error Handling Services

- **ErrorHandlerService**: グローバルエラー処理とモニタリング
- **ErrorService**: アプリケーションレベルエラー管理
- エラーの深刻度別処理とログ出力

#### Security Services

- **EncryptionService**: データの暗号化/復号化
- **SecureStorageService**: 機密データの安全な保存
- **SecureStorageServiceV2**: 改良されたセキュリティストレージ

#### Performance Services

- **PerformanceMonitorService**: アプリのパフォーマンスモニタリング
- **PerformanceOptimizerService**: パフォーマンス最適化

#### Notification Services

- **NotificationService**: プッシュ通知管理
- **NotificationSchedulerService**: 通知スケジューリング
- **NotificationTemplateService**: 通知テンプレート管理
- **NotificationAnalyticsService**: 通知分析

#### Utility Services

- **HttpClientService**: HTTP クライアント設定
- **ImageCacheService**: 画像キャッシングと最適化
- **LinkRegistrationService**: リンク登録処理
- **UiService**: UI 関連サービス
- **UserExperienceService**: ユーザーエクスペリエンス最適化

### 使用方法 {#usage-1}

#### API Service の使用

```dartdart
import 'package:aipet_frontend/shared/core/services/api_service.dart';

// GETリクエスト
final response = await ApiService.get('/users');
if (response.isSuccess) {
  final users = response.data;
}

// POSTリクエスト
final createResponse = await ApiService.post(
  '/users',
  body: {'name': 'John', 'email': 'john@example.com'},
);
```dart

#### Error Handling の使用

```dartdart
import 'package:aipet_frontend/shared/core/services/error_handler_service.dart';

// エラー処理サービスの初期化
await ErrorHandlerService().initialize();

// エラー処理
ErrorHandlerService().handleError(
  error,
  severity: ErrorSeverity.medium,
  type: ErrorType.network,
);
```dart

#### Encryption Service の使用

```dartdart
import 'package:aipet_frontend/shared/core/services/encryption_service.dart';

// データを暗号化して保存
await EncryptionService.encryptAndSave('user_token', token, prefs);

// 暗号化されたデータを復号化
final decryptedToken = await EncryptionService.decryptAndLoad('user_token', prefs);
```dart

#### Notification Service の使用

```dartdart
import 'package:aipet_frontend/shared/core/services/notification_service.dart';

// 通知サービスの初期化
await NotificationService().initialize();

// ローカル通知の作成
await NotificationService().showLocalNotification(
  title: '散歩時間',
  body: 'ペットと一緒に散歩する時間です！',
);
```dart

### Mock データサポート {#mock-data-support-1}

ほとんどのサービスは Mock データをサポートし、API 連携前まで開発とテストが可能です：

```dartdart
// Mockデータの有効化/無効化
static const bool isEnabled = true; // falseに設定すると実際のAPI呼び出し
```dart

### ファイル構造 {#file-structure-1}

```darttext
lib/shared/core/services/
├── README.md                           # このファイル
├── api_service.dart                    # API通信サービス
├── encryption_service.dart             # 暗号化サービス
├── error_handler_service.dart          # グローバルエラー処理
├── error_service.dart                  # エラー管理サービス
├── http_client_service.dart            # HTTPクライアント
├── image_cache_service.dart            # 画像キャッシング
├── link_registration_service.dart      # リンク登録
├── notification_analytics_service.dart # 通知分析
├── notification_scheduler_service.dart # 通知スケジューリング
├── notification_service.dart           # 通知管理
├── notification_template_service.dart  # 通知テンプレート
├── performance_monitor_service.dart    # パフォーマンスモニタリング
├── performance_optimizer_service.dart  # パフォーマンス最適化
├── secure_storage_service.dart         # セキュリティストレージ
├── secure_storage_service_v2.dart     # セキュリティストレージv2
├── ui_service.dart                     # UIサービス
└── user_experience_service.dart        # ユーザーエクスペリエンス
```dart

### サービス初期化 {#service-initialization-1}

アプリ開始時に必要なサービスを初期化する必要があります：

```dartdart
void main() async {
  // エラー処理サービスの初期化
  await ErrorHandlerService().initialize();

  // 通知サービスの初期化
  await NotificationService().initialize();

  // その他のサービス初期化...

  runApp(MyApp());
}
```dart

### 拡張方法 {#extension-methods-1}

新しいサービスを追加するには：

1. サービスクラスを作成
2. 必要なインターフェースと実装体を定義
3. 依存性注入設定（必要に応じて）
4. この README.md に文書化
5. 関連テストを作成

### 関連ファイル {#related-files-1}

- `lib/shared/mock_data/`: Mock データサービス
- `lib/features/*/`: 機能別サービスの使用
- `lib/app/controllers/`: コントローラーからのサービス呼び出し
- `lib/app/providers/`: サービスプロバイダー設定
````
