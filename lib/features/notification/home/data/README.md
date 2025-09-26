# Home Data Layer / ホームデータ層

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [구조 (Structure)](#구조-structure)
- [주요 컴포넌트 (Key Components)](#주요-컴포넌트-key-components)
- [사용 방법 (Usage)](#사용-방법-usage)
- [Mock 데이터 전략 (Mock Data Strategy)](#mock-데이터-전략-mock-data-strategy)

### 개요 (Overview)

Home Feature의 Data Layer는 외부 API 호출, 데이터 모델링, 상태 관리를 담당합니다.
OpenWeatherMap API와의 연동, Mock 데이터 관리, Riverpod 프로바이더를 통해
도메인 계층에 필요한 데이터를 제공합니다.

**주요 역할:**

- 🌐 **외부 API 연동**: OpenWeatherMap 날씨 API 호출
- 📊 **데이터 모델링**: 날씨 데이터 구조 정의
- 🔄 **상태 관리**: Riverpod을 통한 앱 상태 관리
- 🎭 **Mock 데이터**: API 연동 전 개발용 데이터 제공
- 💾 **데이터 저장**: 로컬 데이터 캐싱 및 관리

### 구조 (Structure)

```txt
data/
├── data.dart                         # Data Layer 배럴 파일
├── models/                           # 데이터 모델
│   └── weather_model.dart           # 날씨 데이터 모델
├── providers/                        # Riverpod 프로바이더
│   ├── home_providers.dart          # 홈 관련 프로바이더
│   └── home_providers.g.dart        # 생성된 코드
├── repositories/                     # 리포지토리 구현
│   └── home_repository_impl.dart    # 홈 리포지토리 구현체
└── services/                         # 외부 서비스
    └── weather_service.dart         # 날씨 API 서비스
```

### 주요 컴포넌트 (Key Components)

#### 1. **Models (데이터 모델)**

**WeatherData**: 날씨 정보를 담는 데이터 클래스

```dart
class WeatherData {
  final double temperature;      // 온도 (°C)
  final String location;        // 위치명
  final int weatherId;          // 날씨 ID (OpenWeatherMap)
  final String description;     // 날씨 설명
  final double feelsLike;       // 체감온도
  final int humidity;           // 습도 (%)
  final double windSpeed;       // 풍속 (m/s)
  final String iconCode;        // 아이콘 코드
  final double uvIndex;         // UV 지수
  final int visibility;         // 가시거리 (m)
  final double pressure;        // 기압 (hPa)
}
```

**WeatherLocation**: 위치 정보를 담는 데이터 클래스

```dart
class WeatherLocation {
  final double latitude;        // 위도
  final double longitude;       // 경도
  final String name;            // 위치명
}
```

#### 2. **Providers (상태 관리)**

**HomeState**: 홈 화면의 기본 상태 관리

```dart
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() => const HomeStateData(selectedIndex: 0, currentTime: '');

  void setSelectedIndex(int index) { ... }
  void updateCurrentTime(String time) { ... }
}
```

**HomeSelectedPetNotifier**: 현재 선택된 펫 관리

```dart
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() { ... }

  void selectPet(PetProfileEntity pet) { ... }
  void nextPet() { ... }
  void previousPet() { ... }
}
```

**HomeCurrentTimeStream**: 실시간 시간 업데이트 스트림

```dart
@riverpod
Stream<String> homeCurrentTimeStream(Ref ref) async* { ... }
```

#### 3. **Repositories (데이터 접근)**

**HomeRepositoryImpl**: 홈 관련 데이터 접근 구현체

```dart
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeDashboardEntity> getDashboardData() async { ... }

  @override
  Future<WeatherData?> getCurrentWeather() async { ... }

  @override
  Future<List<PetProfileEntity>> getPetProfiles() async { ... }

  @override
  Future<WalkSummary> getWalkSummary() async { ... }

  @override
  Future<HealthSummary> getPetHealthSummary() async { ... }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async { ... }
}
```

#### 4. **Services (외부 서비스)**

**WeatherService**: OpenWeatherMap API 연동 서비스

```dart
class WeatherService {
  // One Call API 3.0 우선 시도
  Future<WeatherData?> getCurrentWeather({WeatherLocation? location}) async { ... }

  // 기본 API 폴백
  Future<WeatherData?> _getCurrentWeatherFallback(WeatherLocation location) async { ... }

  // Mock 데이터 제공
  WeatherData _getMockWeatherData(String locationName) { ... }
}
```

### 사용 방법 (Usage)

#### 1. **Provider 사용**

```dart
// 홈 상태 관리
final homeState = ref.watch(homeStateProvider);
final homeNotifier = ref.read(homeStateProvider.notifier);

// 선택된 펫
final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
final petNotifier = ref.read(homeSelectedPetNotifierProvider.notifier);

// 현재 시간 스트림
final currentTime = ref.watch(homeCurrentTimeStreamProvider);
```

#### 2. **Repository 사용**

```dart
final homeRepository = ref.read(homeRepositoryProvider);

// 대시보드 데이터 조회
final dashboardData = await homeRepository.getDashboardData();

// 날씨 정보 조회
final weather = await homeRepository.getCurrentWeather();

// 펫 프로필 조회
final pets = await homeRepository.getPetProfiles();
```

#### 3. **Service 직접 사용**

```dart
final weatherService = WeatherService();

// 특정 위치의 날씨 조회
final weather = await weatherService.getCurrentWeather(
  location: WeatherLocation(
    latitude: 35.6092,
    longitude: 139.7301,
    name: '東京都品川区',
  ),
);
```

### Mock 데이터 전략 (Mock Data Strategy)

#### **Mock 데이터 사용 시나리오**

1. **API 키 없음**: OpenWeatherMap API 키가 설정되지 않은 경우
2. **API 호출 실패**: 네트워크 오류, API 제한 등
3. **개발 환경**: 로컬 개발 시 API 호출 없이 테스트
4. **테스트**: 단위 테스트 및 위젯 테스트

#### **Mock 데이터 구조**

```dart
// MockDataService에서 중앙화된 데이터 제공
final mockWeatherInfo = MockDataService.getMockWeatherInfo();
final mockPets = MockDataService.getMockPets();
final mockWalkSummary = MockDataService.getMockWalkSummary();
final mockHealthSummary = MockDataService.getPetHealthSummary();
final mockAppointments = MockDataService.getMockAppointments();
```

#### **API 연동 시 제거 방법**

```dart
// 1. MockDataService.isEnabled = false 설정
// 2. 실제 API 호출로 교체
// 3. Mock 데이터 관련 코드 제거
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [構造 (Structure)](#構造-structure)
- [主要コンポーネント (Key Components)](#主要コンポーネント-key-components)
- [使用方法 (Usage)](#使用方法-usage)
- [Mock データ戦略 (Mock Data Strategy)](#mock-データ戦略-mock-data-strategy)

### 概要 (Overview)

Home Feature の Data Layer は外部 API 呼び出し、データモデリング、状態管理を担当します。
OpenWeatherMap API との連携、Mock データ管理、Riverpod プロバイダーを通じて
ドメイン層に必要なデータを提供します。

**主な役割:**

- 🌐 **外部 API 連携**: OpenWeatherMap 天気 API 呼び出し
- 📊 **データモデリング**: 天気データ構造の定義
- 🔄 **状態管理**: Riverpod によるアプリ状態管理
- 🎭 **Mock データ**: API 連携前の開発用データ提供
- 💾 **データ保存**: ローカルデータキャッシュと管理

### 構造 (Structure)

```txt
data/
├── data.dart                         # Data Layer バレルファイル
├── models/                           # データモデル
│   └── weather_model.dart           # 天気データモデル
├── providers/                        # Riverpod プロバイダー
│   ├── home_providers.dart          # ホーム関連プロバイダー
│   └── home_providers.g.dart        # 生成されたコード
├── repositories/                     # リポジトリ実装
│   └── home_repository_impl.dart    # ホームリポジトリ実装体
└── services/                         # 外部サービス
    └── weather_service.dart         # 天気 API サービス
```

### 主要コンポーネント (Key Components)

#### 1. **Models (データモデル)**

**WeatherData**: 天気情報を格納するデータクラス

```dart
class WeatherData {
  final double temperature;      // 気温 (°C)
  final String location;        // 位置名
  final int weatherId;          // 天気 ID (OpenWeatherMap)
  final String description;     // 天気説明
  final double feelsLike;       // 体感温度
  final int humidity;           // 湿度 (%)
  final double windSpeed;       // 風速 (m/s)
  final String iconCode;        // アイコンコード
  final double uvIndex;         // UV 指数
  final int visibility;         // 視程 (m)
  final double pressure;        // 気圧 (hPa)
}
```

**WeatherLocation**: 位置情報を格納するデータクラス

```dart
class WeatherLocation {
  final double latitude;        // 緯度
  final double longitude;       // 経度
  final String name;            // 位置名
}
```

#### 2. **Providers (状態管理)**

**HomeState**: ホーム画面の基本状態管理

```dart
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() => const HomeStateData(selectedIndex: 0, currentTime: '');

  void setSelectedIndex(int index) { ... }
  void updateCurrentTime(String time) { ... }
}
```

**HomeSelectedPetNotifier**: 現在選択されたペット管理

```dart
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() { ... }

  void selectPet(PetProfileEntity pet) { ... }
  void nextPet() { ... }
  void previousPet() { ... }
}
```

**HomeCurrentTimeStream**: リアルタイム時間更新ストリーム

```dart
@riverpod
Stream<String> homeCurrentTimeStream(Ref ref) async* { ... }
```

#### 3. **Repositories (データアクセス)**

**HomeRepositoryImpl**: ホーム関連データアクセス実装体

```dart
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeDashboardEntity> getDashboardData() async { ... }

  @override
  Future<WeatherData?> getCurrentWeather() async { ... }

  @override
  Future<List<PetProfileEntity>> getPetProfiles() async { ... }

  @override
  Future<WalkSummary> getWalkSummary() async { ... }

  @override
  Future<HealthSummary> getPetHealthSummary() async { ... }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async { ... }
}
```

#### 4. **Services (外部サービス)**

**WeatherService**: OpenWeatherMap API 連携サービス

```dart
class WeatherService {
  // One Call API 3.0 優先試行
  Future<WeatherData?> getCurrentWeather({WeatherLocation? location}) async { ... }

  // 基本 API フォールバック
  Future<WeatherData?> _getCurrentWeatherFallback(WeatherLocation location) async { ... }

  // Mock データ提供
  WeatherData _getMockWeatherData(String locationName) { ... }
}
```

### 使用方法 (Usage)

#### 1. **Provider 使用**

```dart
// ホーム状態管理
final homeState = ref.watch(homeStateProvider);
final homeNotifier = ref.read(homeStateProvider.notifier);

// 選択されたペット
final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
final petNotifier = ref.read(homeSelectedPetNotifierProvider.notifier);

// 現在時間ストリーム
final currentTime = ref.watch(homeCurrentTimeStreamProvider);
```

#### 2. **Repository 使用**

```dart
final homeRepository = ref.read(homeRepositoryProvider);

// ダッシュボードデータ取得
final dashboardData = await homeRepository.getDashboardData();

// 天気情報取得
final weather = await homeRepository.getCurrentWeather();

// ペットプロフィール取得
final pets = await homeRepository.getPetProfiles();
```

#### 3. **Service 直接使用**

```dart
final weatherService = WeatherService();

// 特定位置の天気取得
final weather = await weatherService.getCurrentWeather(
  location: WeatherLocation(
    latitude: 35.6092,
    longitude: 139.7301,
    name: '東京都品川区',
  ),
);
```

### Mock データ戦略 (Mock Data Strategy)

#### **Mock データ使用シナリオ**

1. **API キーなし**: OpenWeatherMap API キーが設定されていない場合
2. **API 呼び出し失敗**: ネットワークエラー、API 制限など
3. **開発環境**: ローカル開発時 API 呼び出しなしでテスト
4. **テスト**: 単体テストとウィジェットテスト

#### **Mock データ構造**

```dart
// MockDataService で中央化されたデータ提供
final mockWeatherInfo = MockDataService.getMockWeatherInfo();
final mockPets = MockDataService.getMockPets();
final mockWalkSummary = MockDataService.getMockWalkSummary();
final mockHealthSummary = MockDataService.getPetHealthSummary();
final mockAppointments = MockDataService.getMockAppointments();
```

#### **API 連携時削除方法**

```dart
// 1. MockDataService.isEnabled = false 設定
// 2. 実際の API 呼び出しに置き換え
// 3. Mock データ関連コード削除
```

---

## 📚 추가 리소스 / その他のリソース

- [Riverpod Documentation](https://riverpod.dev/)
- [OpenWeatherMap API](https://openweathermap.org/api)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

© 2025 AI Pet. Home Data Layer / ホームデータ層
