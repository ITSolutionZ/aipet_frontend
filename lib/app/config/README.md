# App Configuration

이 디렉토리는 AI Pet Frontend 앱의 모든 설정을 중앙에서 관리합니다.

## 개요

`AppConfig`는 앱의 환경별 설정값들과 환경 변수를 통합하여 관리하는 추상 클래스입니다. 개발, 스테이징, 프로덕션, 테스트 환경별로 다른 설정을 제공하며, 런타임에 적절한 설정을 제공합니다.

## 주요 기능

### 1. 환경별 설정 관리

- **DevelopmentConfig**: 개발 환경 설정 (디버그 모드 활성화, 상세 로깅)
- **StagingConfig**: 스테이징 환경 설정 (프로덕션과 유사하지만 디버깅 가능)
- **ProductionConfig**: 프로덕션 환경 설정 (최적화된 성능과 보안)
- **TestConfig**: 테스트 환경 설정 (빠른 응답과 테스트용 데이터)

### 2. 환경 변수 통합 관리

- API 키 관리 (Google Maps, OpenAI, Weather, LINE)
- 환경 변수 로드 및 검증
- API 키 설정 상태 모니터링

### 3. 앱 설정 중앙화

- API 타임아웃, 재시도 횟수
- 이미지 캐시 크기, 오프라인 데이터 보존 기간
- 알림, 위치 서비스, 백그라운드 동기화 설정
- 애니메이션 지속 시간, 데이터베이스 버전

## 사용 방법

### 기본 설정 초기화

```dart
import 'package:aipet_frontend/app/config/app_config.dart';

void main() async {
  // 환경 변수 로드
  await AppConfig.current.loadEnv();

  // 환경별 설정 선택
  final config = ProductionConfig(); // 또는 DevelopmentConfig()
  AppConfig.initialize(config);

  runApp(MyApp());
}
```

### 환경별 설정 사용

```dart
// 현재 설정 가져오기
final config = AppConfig.current;

// API URL 사용
final apiUrl = config.apiBaseUrl;

// 환경 변수 확인
if (config.areApiKeysConfigured) {
  // API 키가 모두 설정됨
  final mapsKey = config.googleMapsApiKey;
  final openaiKey = config.openaiApiKey;
}

// API 키 상태 로그 출력
config.logApiKeyStatus();
```

### 환경 변수 관리

```dart
// 환경 변수 로드 확인
if (config.isEnvLoaded) {
  print('환경 변수가 로드되었습니다');
}

// 특정 API 키 유효성 검사
if (config.isGoogleMapsApiKeyValid) {
  print('Google Maps API 키가 유효합니다');
}
```

## 환경 변수 설정

`.env` 파일에 다음 환경 변수를 설정해야 합니다:

```env
# API Keys
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
OPENAI_API_KEY=your_openai_api_key
WEATHER_API_KEY=your_weather_api_key
LINE_CHANNEL_ID=your_line_channel_id
```

## 설정 값 상세

### 개발 환경 (DevelopmentConfig)

- API 타임아웃: 30초
- 이미지 캐시: 100MB
- 오프라인 데이터 보존: 7일
- 로깅: 활성화
- 애니메이션: 300ms

### 스테이징 환경 (StagingConfig)

- API 타임아웃: 20초
- 이미지 캐시: 200MB
- 오프라인 데이터 보존: 14일
- 로깅: 활성화
- 애니메이션: 250ms

### 프로덕션 환경 (ProductionConfig)

- API 타임아웃: 15초
- 이미지 캐시: 500MB
- 오프라인 데이터 보존: 30일
- 로깅: 비활성화
- 애니메이션: 200ms

### 테스트 환경 (TestConfig)

- API 타임아웃: 5초
- 이미지 캐시: 50MB
- 오프라인 데이터 보존: 1일
- 로깅: 활성화
- 애니메이션: 100ms

## 파일 구조

```txt
lib/app/config/
├── README.md           # 이 파일
├── app_config.dart     # 메인 설정 클래스
└── config.dart         # 배럴 파일 (export)
```

## 주의사항

1. **환경 변수 보안**: `.env` 파일은 버전 관리에 포함하지 마세요
2. **프로덕션 설정**: 프로덕션에서는 `ProductionConfig`를 사용하세요
3. **API 키 관리**: API 키는 환경 변수로 관리하고 하드코딩하지 마세요
4. **설정 변경**: 런타임에 설정을 변경하려면 `AppConfig.initialize()`를 사용하세요

## 확장 방법

새로운 환경 설정을 추가하려면:

```dart
class CustomConfig extends AppConfig {
  @override
  String get environment => 'custom';

  // 필요한 설정값들을 오버라이드
  @override
  String get apiBaseUrl => 'https://custom-api.aipet.com';

  // ... 기타 설정
}
```

## 관련 파일

- `lib/shared/services/`: 서비스 관련 설정
- `lib/features/*/`: 기능별 설정
- `lib/app/bootstrap.dart`: 앱 초기화 시 설정 로드

---

## 日本語版 / 日本語バージョン

[한국어](#app-configuration) | [日本語](#app-configuration-1)

---

## App Configuration {#app-configuration-1}

このディレクトリは、AI Pet Frontend アプリのすべての設定を中央で管理します。

### 📋 目次 (Table of Contents)

- [概要](#overview-1)
- [主要機能](#key-features-1)
- [使用方法](#usage-1)
- [環境変数設定](#environment-variables-1)
- [設定値詳細](#configuration-details-1)
- [ファイル構造](#file-structure-1)
- [注意事項](#precautions-1)
- [拡張方法](#extension-methods-1)
- [関連ファイル](#related-files-1)

### 概要 {#overview-1}

`AppConfig`は、アプリの環境別設定値と環境変数を統合して管理する抽象クラスです。開発、ステージング、プロダクション、テスト環境別に異なる設定を提供し、ランタイムに適切な設定を提供します。

### 主要機能 {#key-features-1}

#### 1. 環境別設定管理

- **DevelopmentConfig**: 開発環境設定（デバッグモード有効化、詳細ログ出力）
- **StagingConfig**: ステージング環境設定（プロダクションと類似だがデバッグ可能）
- **ProductionConfig**: プロダクション環境設定（最適化されたパフォーマンスとセキュリティ）
- **TestConfig**: テスト環境設定（高速応答とテスト用データ）

#### 2. 環境変数統合管理

- API キー管理（Google Maps、OpenAI、Weather、LINE）
- 環境変数の読み込みと検証
- API キー設定状態のモニタリング

#### 3. アプリ設定の中央化

- API タイムアウト、再試行回数
- 画像キャッシュサイズ、オフラインデータ保持期間
- 通知、位置サービス、バックグラウンド同期設定
- アニメーション持続時間、データベースバージョン

### 使用方法 {#usage-1}

#### 基本設定初期化

```dart
import 'package:aipet_frontend/app/config/app_config.dart';

void main() async {
  // 環境変数の読み込み
  await AppConfig.current.loadEnv();

  // 環境別設定の選択
  final config = ProductionConfig(); // またはDevelopmentConfig()
  AppConfig.initialize(config);

  runApp(MyApp());
}
```

#### 環境別設定の使用

```dart
// 現在の設定を取得
final config = AppConfig.current;

// API URLの使用
final apiUrl = config.apiBaseUrl;

// 環境変数の確認
if (config.areApiKeysConfigured) {
  // APIキーがすべて設定されている
  final mapsKey = config.googleMapsApiKey;
  final openaiKey = config.openaiApiKey;
}

// APIキー状態ログの出力
config.logApiKeyStatus();
```

#### 環境変数管理

```dart
// 環境変数読み込み確認
if (config.isEnvLoaded) {
  print('環境変数が読み込まれました');
}

// 特定のAPIキーの有効性確認
if (config.isGoogleMapsApiKeyValid) {
  print('Google Maps APIキーが有効です');
}
```

### 環境変数設定 {#environment-variables-1}

`.env`ファイルに以下の環境変数を設定する必要があります：

```env
# API Keys
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
OPENAI_API_KEY=your_openai_api_key
WEATHER_API_KEY=your_weather_api_key
LINE_CHANNEL_ID=your_line_channel_id
```

### 設定値詳細 {#configuration-details-1}

#### 開発環境（DevelopmentConfig）

- API タイムアウト: 30 秒
- 画像キャッシュ: 100MB
- オフラインデータ保持: 7 日
- ログ出力: 有効
- アニメーション: 300ms

#### ステージング環境（StagingConfig）

- API タイムアウト: 20 秒
- 画像キャッシュ: 200MB
- オフラインデータ保持: 14 日
- ログ出力: 有効
- アニメーション: 250ms

#### プロダクション環境（ProductionConfig）

- API タイムアウト: 15 秒
- 画像キャッシュ: 500MB
- オフラインデータ保持: 30 日
- ログ出力: 無効
- アニメーション: 200ms

#### テスト環境（TestConfig）

- API タイムアウト: 5 秒
- 画像キャッシュ: 50MB
- オフラインデータ保持: 1 日
- ログ出力: 有効
- アニメーション: 100ms

### ファイル構造 {#file-structure-1}

```txt
lib/app/config/
├── README.md           # このファイル
├── app_config.dart     # メイン設定クラス
└── config.dart         # バレルファイル（export）
```

### 注意事項 {#precautions-1}

1. **環境変数のセキュリティ**: `.env`ファイルはバージョン管理に含めないでください
2. **プロダクション設定**: プロダクションでは`ProductionConfig`を使用してください
3. **API キー管理**: API キーは環境変数で管理し、ハードコーディングしないでください
4. **設定変更**: ランタイムに設定を変更するには`AppConfig.initialize()`を使用してください

### 拡張方法 {#extension-methods-1}

新しい環境設定を追加するには：

```dart
class CustomConfig extends AppConfig {
  @override
  String get environment => 'custom';

  // 必要な設定値をオーバーライド
  @override
  String get apiBaseUrl => 'https://custom-api.aipet.com';

  // ... その他の設定
}
```

### 関連ファイル {#related-files-1}

- `lib/shared/services/`: サービス関連設定
- `lib/features/*/`: 機能別設定
- `lib/app/bootstrap.dart`: アプリ初期化時の設定読み込み
