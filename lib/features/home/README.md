# Home Feature / ホーム機能

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [아키텍처 (Architecture)](#아키텍처-architecture)
- [주요 기능 (Key Features)](#주요-기능-key-features)
- [디렉토리 구조 (Directory Structure)](#디렉토리-구조-directory-structure)
- [사용 방법 (Usage)](#사용-방법-usage)
- [의존성 (Dependencies)](#의존성-dependencies)

### 개요 (Overview)

AI Pet 애플리케이션의 홈 화면 및 대시보드 기능을 담당하는 모듈입니다.
사용자의 펫 정보, 날씨, 산책, 건강, 예약 등의 종합적인 정보를 제공합니다.

**주요 특징:**

- 🏠 **통합 대시보드**: 펫 프로필, 날씨, 산책, 건강, 예약 정보 통합 표시
- 🌤️ **실시간 날씨**: OpenWeatherMap API 연동 및 목업 데이터 폴백
- 🐕 **펫 프로필 관리**: 다중 펫 지원 및 스와이프 네비게이션
- 📊 **요약 카드**: 산책, 급여, 체중, 예약 정보를 한눈에 확인
- 🔔 **알림 시스템**: 예약, 건강, 산책 관련 스마트 알림
- 🎯 **Clean Architecture**: 도메인, 데이터, 프레젠테이션 레이어 분리

### 아키텍처 (Architecture)

```txt
lib/features/home/
├── data/               # 데이터 계층
│   ├── models/         # 데이터 모델
│   ├── providers/      # Riverpod 프로바이더
│   ├── repositories/   # 리포지토리 구현
│   └── services/       # 외부 서비스 (날씨 API)
├── domain/             # 도메인 계층
│   ├── entities/       # 비즈니스 엔티티
│   ├── repositories/   # 리포지토리 인터페이스
│   └── usecases/      # 비즈니스 로직
└── presentation/       # 프레젠테이션 계층
    ├── controllers/    # 비즈니스 로직 컨트롤러
    ├── screens/        # 화면 UI
    └── widgets/        # 재사용 가능한 위젯
```

**Clean Architecture 적용:**

- **Domain Layer**: 비즈니스 엔티티, 리포지토리 인터페이스, 유스케이스 정의
- **Data Layer**: API 호출, 로컬 저장소, Mock 데이터 관리
- **Presentation Layer**: UI 컴포넌트, 컨트롤러, 상태 관리

### 주요 기능 (Key Features)

#### 🏠 **홈 대시보드**

- 펫 프로필 카드 (다중 펫 스와이프 지원)
- 실시간 날씨 정보 및 산책 조언
- 요약 그리드 (산책, 급여, 체중, 예약)

#### 🌤️ **날씨 시스템**

- OpenWeatherMap API 연동
- One Call API 3.0 우선 시도
- 기본 API 폴백 지원
- Mock 데이터 자동 전환
- UV 지수, 풍속, 체감온도 제공

#### 🐕 **펫 관리**

- 펫 프로필 표시
- 성별, 나이, 품종 정보
- 활동 기록 표시
- 펫별 맞춤 데이터

#### 📊 **요약 카드**

- **산책 요약**: 오늘 산책 거리, 주간 목표 달성률
- **급여 요약**: 완료된 식사 수, 다음 식사 시간
- **체중 요약**: 현재 체중, 변화량 추적
- **예약 요약**: 예정된 예약 수, 다음 예약 시간

#### 🔔 **알림 시스템**

- 예약 알림 (24시간, 2시간 전)
- 건강 상태 알림
- 산책 목표 달성률 알림
- 스마트 알림 메시지 생성

### 디렉토리 구조 (Directory Structure)

```txt
home/
├── home.dart                              # 기능 export 파일
├── README.md                              # 이 문서
├── data/                                  # Data Layer
│   ├── data.dart                         # data 레이어 배럴
│   ├── models/
│   │   └── weather_model.dart            # 날씨 데이터 모델
│   ├── providers/
│   │   ├── home_providers.dart           # Riverpod 프로바이더
│   │   └── home_providers.g.dart         # 생성된 코드
│   ├── repositories/
│   │   └── home_repository_impl.dart     # 홈 리포지토리 구현
│   └── services/
│       └── weather_service.dart          # 날씨 API 서비스
├── domain/                                # Domain Layer
│   ├── domain.dart                       # domain 레이어 배럴
│   ├── entities/
│   │   ├── entities.dart                 # entities 배럴
│   │   └── home_dashboard_entity.dart    # 홈 대시보드 엔티티
│   ├── repositories/
│   │   ├── repositories.dart             # repositories 배럴
│   │   └── home_repository.dart          # 홈 리포지토리 인터페이스
│   └── usecases/
│       ├── usecases.dart                 # usecases 배럴
│       └── get_dashboard_data_usecase.dart # 대시보드 데이터 조회
└── presentation/                          # Presentation Layer
    ├── presentation.dart                  # presentation 레이어 배럴
    ├── controllers/
    │   ├── controllers.dart               # controllers 배럴
    │   ├── home_dashboard_controller.dart # 홈 대시보드 컨트롤러
    │   ├── home_notification_controller.dart # 알림 컨트롤러
    │   └── weather_controller.dart       # 날씨 컨트롤러
    ├── screens/
    │   ├── screens.dart                  # screens 배럴
    │   └── home_screen.dart              # 홈 화면
    └── widgets/
        ├── widgets.dart                   # widgets 배럴
        ├── home_header.dart               # 홈 헤더
        ├── pet_profile_card.dart          # 펫 프로필 카드
        ├── weather_card.dart              # 날씨 카드
        ├── home_summary_grid.dart         # 요약 그리드
        ├── walk_summary_card.dart         # 산책 요약 카드
        ├── feeding_summary_card.dart      # 급여 요약 카드
        ├── weight_summary_card.dart       # 체중 요약 카드
        ├── appointment_summary_card.dart  # 예약 요약 카드
        └── meteocons_icon.dart           # 날씨 아이콘
```

### 사용 방법 (Usage)

#### 1. **기본 사용**

```dart
import 'package:aipet_frontend/features/home/home.dart';

// 홈 화면으로 이동
context.go('/home');
```

#### 2. **Controller 사용**

```dart
final homeController = ref.read(homeDashboardControllerProvider.notifier);

// 홈 화면 초기화
final result = await homeController.initializeHome();

// 날씨 정보 로드
final weatherResult = await homeController.loadWeatherInfo();
```

#### 3. **Provider 사용**

```dart
// 홈 상태
final homeState = ref.watch(homeStateProvider);

// 선택된 펫
final selectedPet = ref.watch(homeSelectedPetNotifierProvider);

// 현재 시간 스트림
final currentTime = ref.watch(homeCurrentTimeStreamProvider);
```

#### 4. **Repository 사용**

```dart
final homeRepository = ref.read(homeRepositoryProvider);

// 대시보드 데이터 조회
final dashboardData = await homeRepository.getDashboardData();

// 날씨 정보 조회
final weather = await homeRepository.getCurrentWeather();
```

### 의존성 (Dependencies)

#### **내부 의존성**

- `pet_registor`: 펫 프로필 엔티티
- `shared`: 공통 위젯, 디자인 시스템, Mock 데이터

#### **외부 패키지**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.6.2
  http: ^1.1.0
  geolocator: ^10.1.0
  flutter_svg: ^2.0.9
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [アーキテクチャ (Architecture)](#アーキテクチャ-architecture)
- [主要機能 (Key Features)](#主要機能-key-features)
- [ディレクトリ構造 (Directory Structure)](#ディレクトリ構造-directory-structure)
- [ホームダッシュボードフロー (Home Dashboard Flow)](#ホームダッシュボードフロー-home-dashboard-flow)
- [UI 構成 (UI Components)](#ui-構成-ui-components)
- [使用方法 (Usage)](#使用方法-usage)
- [設定 (Configuration)](#設定-configuration)

### 概要 (Overview)

AI Pet アプリケーションのホーム画面とダッシュボード機能を担当するモジュールです。
ユーザーのペット情報、天気、散歩、健康、予約などの総合的な情報を提供します。

**主な特徴:**

- 🏠 **統合ダッシュボード**: ペットプロフィール、天気、散歩、健康、予約情報の統合表示
- 🌤️ **リアルタイム天気**: OpenWeatherMap API 連携とモックデータフォールバック
- 🐕 **ペットプロフィール管理**: 複数ペット対応とスワイプナビゲーション
- 📊 **サマリーカード**: 散歩、給餌、体重、予約情報を一目で確認
- 🔔 **通知システム**: 予約、健康、散歩関連のスマート通知
- 🎯 **Clean Architecture パターン**: 拡張可能で保守しやすい構造

### アーキテクチャ (Architecture)

```txt
lib/features/home/
├── data/               # データ層
│   ├── models/         # データモデル
│   ├── providers/      # Riverpod プロバイダー
│   ├── repositories/   # リポジトリ実装
│   └── services/       # 外部サービス (天気 API)
├── domain/             # ドメイン層
│   ├── entities/       # ビジネスエンティティ
│   ├── repositories/   # リポジトリインターフェース
│   └── usecases/      # ビジネスロジック
└── presentation/       # プレゼンテーション層
    ├── controllers/    # ビジネスロジックコントローラー
    ├── screens/        # 画面 UI
    └── widgets/        # 再利用可能なウィジェット
```

**Clean Architecture 適用:**

- **Domain Layer**: ビジネスエンティティ、リポジトリインターフェース、ユースケース定義
- **Data Layer**: API 呼び出し、ローカルストレージ、Mock データ管理
- **Presentation Layer**: UI コンポーネント、コントローラー、状態管理

### 主要機能 (Key Features)

#### 🏠 **ホームダッシュボード**

- ペットプロフィールカード (複数ペットスワイプ対応)
- リアルタイム天気情報と散歩アドバイス
- サマリーグリッド (散歩、給餌、体重、予約)

#### 🌤️ **天気システム**

- OpenWeatherMap API 連携
- One Call API 3.0 優先試行
- 基本 API フォールバック対応
- Mock データ自動切り替え
- UV 指数、風速、体感温度提供

#### 🐕 **ペット管理**

- ペットプロフィール表示
- 性別、年齢、品種情報
- 活動記録表示
- ペット別カスタムデータ

#### 📊 **サマリーカード**

- **散歩サマリー**: 今日の散歩距離、週間目標達成率
- **給餌サマリー**: 完了した食事数、次の食事時間
- **体重サマリー**: 現在体重、変化量追跡
- **予約サマリー**: 予定された予約数、次の予約時間

#### 🔔 **通知システム**

- 予約通知 (24 時間、2 時間前)
- 健康状態通知
- 散歩目標達成率通知
- スマート通知メッセージ生成

### ディレクトリ構造 (Directory Structure)

```txt
home/
├── home.dart                              # 機能 export ファイル
├── README.md                              # この文書
├── data/                                  # Data Layer
│   ├── data.dart                         # data 層バレル
│   ├── models/
│   │   └── weather_model.dart            # 天気データモデル
│   ├── providers/
│   │   ├── home_providers.dart           # Riverpod プロバイダー
│   │   └── home_providers.g.dart         # 生成されたコード
│   ├── repositories/
│   │   └── home_repository_impl.dart     # ホームリポジトリ実装
│   └── services/
│       └── weather_service.dart          # 天気 API サービス
├── domain/                                # Domain Layer
│   ├── domain.dart                       # domain 層バレル
│   ├── entities/
│   │   ├── entities.dart                 # entities バレル
│   │   └── home_dashboard_entity.dart    # ホームダッシュボードエンティティ
│   ├── repositories/
│   │   ├── repositories.dart             # repositories バレル
│   │   └── home_repository.dart          # ホームリポジトリインターフェース
│   └── usecases/
│       ├── usecases.dart                 # usecases バレル
│       └── get_dashboard_data_usecase.dart # ダッシュボードデータ取得
└── presentation/                          # Presentation Layer
    ├── presentation.dart                  # presentation 層バレル
    ├── controllers/
    │   ├── controllers.dart               # controllers バレル
    │   ├── home_dashboard_controller.dart # ホームダッシュボードコントローラー
    │   ├── home_notification_controller.dart # 通知コントローラー
    │   └── weather_controller.dart       # 天気コントローラー
    ├── screens/
    │   ├── screens.dart                  # screens バレル
    │   └── home_screen.dart              # ホーム画面
    └── widgets/
        ├── widgets.dart                   # widgets バレル
        ├── home_header.dart               # ホームヘッダー
        ├── pet_profile_card.dart          # ペットプロフィールカード
        ├── weather_card.dart              # 天気カード
        ├── home_summary_grid.dart         # サマリーグリッド
        ├── walk_summary_card.dart         # 散歩サマリーカード
        ├── feeding_summary_card.dart      # 給餌サマリーカード
        ├── weight_summary_card.dart       # 体重サマリーカード
        ├── appointment_summary_card.dart  # 予約サマリーカード
        └── meteocons_icon.dart           # 天気アイコン
```

### ホームダッシュボードフロー (Home Dashboard Flow)

#### 📊 **ホームダッシュボードフローダイアグラム**

```txt
[アプリ起動] → [ペット情報確認] → [天気情報取得] → [サマリーデータ統合] → [UI 表示]
    ↓              ↓                    ↓              ↓              ↓
  初期化処理    ペット存在確認         API 呼び出し    データ集約     画面更新
    ↓              ↓                    ↓              ↓              ↓
  リダイレクト   ペット登録画面         Mock データ    状態管理      ユーザー操作
```

#### 🔄 **データ処理フロー**

##### 1 段階: ペット情報確認

```dart
// ペットリスト確認
Future<bool> hasPets() async {
  try {
    final petProfiles = await _repository.getPetProfiles();
    return petProfiles.isNotEmpty;
  } catch (error) {
    handleError(error);
    return false;
  }
}
```

##### 2 段階: 天気情報取得

```dart
// 天気情報取得
Future<WeatherData?> getCurrentWeather() async {
  try {
    // One Call API 3.0 優先試行
    final weather = await _weatherService.getCurrentWeather();
    return weather;
  } catch (e) {
    // API 失敗時 Mock データ使用
    return _getMockWeatherData();
  }
}
```

##### 3 段階: サマリーデータ統合

```dart
// ダッシュボードデータ統合
Future<HomeDashboardEntity> getDashboardData() async {
  final weather = await getCurrentWeather();
  final petProfiles = await getPetProfiles();
  final walkSummary = await getWalkSummary();
  final healthSummary = await getPetHealthSummary();
  final appointments = await getUpcomingAppointments();

  return HomeDashboardEntity(
    currentTime: _getCurrentTime(),
    weather: weather ?? _getMockWeatherData(),
    petProfiles: petProfiles,
    walkSummary: walkSummary,
    petHealthSummary: healthSummary,
    upcomingAppointments: appointments,
  );
}
```

#### 🎨 **UI 状態管理**

**リアルタイム更新:**

```dart
// 現在時間ストリーム
@riverpod
Stream<String> homeCurrentTimeStream(Ref ref) async* {
  late StreamController<String> controller;
  Timer? timer;

  controller = StreamController<String>(
    onListen: () {
      // 即座に現在時間を emit
      final now = DateTime.now();
      final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      controller.add(timeString);

      // 1秒ごとに時間更新
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        if (!controller.isClosed) {
          controller.add(timeString);
        }
      });
    },
  );

  yield* controller.stream;
}
```

**ペット選択管理:**

```dart
// 選択されたペット管理
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() {
    final petsAsync = ref.watch(petsNotifierProvider);
    return petsAsync.when(
      data: (pets) => pets.isNotEmpty ? pets.first : null,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void selectPet(PetProfileEntity pet) {
    state = pet;
  }

  void nextPet() {
    final petsAsync = ref.read(petsNotifierProvider);
    petsAsync.when(
      data: (pets) {
        if (pets.isNotEmpty && state != null) {
          final currentIndex = pets.indexWhere((p) => p.id == state!.id);
          if (currentIndex != -1) {
            final nextIndex = (currentIndex + 1) % pets.length;
            state = pets[nextIndex];
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }
}
```

### UI 構成 (UI Components)

#### 1. **ホーム画面構造**

```dart
Scaffold(
  backgroundColor: AppColors.pointOffWhite,
  drawer: const AppDrawer(),
  body: Column(
    children: [
      HomeHeader(onNotificationTap: _handleNotificationTap),
      _buildMainContent(),
    ],
  ),
)
```

#### 2. **コンポーネント別の役割**

**HomeHeader:**

- メニューボタン、タイトル、通知、プロフィール表示
- 通知タップ処理
- ドロワー開閉

**PetProfileCard:**

- ペットプロフィール表示
- スワイプナビゲーション
- 活動記録表示

**WeatherCard:**

- 現在天気情報表示
- UV 指数、風速、体感温度
- 散歩アドバイス生成

**HomeSummaryGrid:**

- 2x2 グリッドでサマリー情報表示
- 散歩、給餌、体重、予約情報
- タップ可能なカード

### 使用方法 (Usage)

#### 1. **基本使用**

```dart
import 'package:aipet_frontend/features/home/home.dart';

// ホーム画面へ移動
context.go('/home');
```

#### 2. **Controller 使用**

```dart
final homeController = ref.read(homeDashboardControllerProvider.notifier);

// ホーム画面初期化
final result = await homeController.initializeHome();

// 天気情報読み込み
final weatherResult = await homeController.loadWeatherInfo();
```

#### 3. **Provider 使用**

```dart
// ホーム状態
final homeState = ref.watch(homeStateProvider);

// 選択されたペット
final selectedPet = ref.watch(homeSelectedPetNotifierProvider);

// 現在時間ストリーム
final currentTime = ref.watch(homeCurrentTimeStreamProvider);
```

#### 4. **Repository 使用**

```dart
final homeRepository = ref.read(homeRepositoryProvider);

// ダッシュボードデータ取得
final dashboardData = await homeRepository.getDashboardData();

// 天気情報取得
final weather = await homeRepository.getCurrentWeather();
```

### 設定 (Configuration)

#### 天気 API 設定

`.env` ファイルで OpenWeatherMap API キーを設定:

```env
WEATHER_API_KEY=your_openweathermap_api_key_here
```

#### 依存関係

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.6.2
  http: ^1.1.0
  geolocator: ^10.1.0
  flutter_svg: ^2.0.9
```

#### 内部依存関係

- `pet_registor`: ペットプロフィールエンティティ
- `shared`: 共通ウィジェット、デザインシステム、Mock データ

---

## 📚 추가 리소스 / その他のリソース

- [Riverpod 가이드 / Riverpod ガイド](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [OpenWeatherMap API](https://openweathermap.org/api)

---

© 2025 AI Pet. 통합 홈 대시보드 시스템 / 統合ホームダッシュボードシステム
