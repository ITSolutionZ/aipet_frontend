# Home Domain Layer / ホームドメイン層

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [구조 (Structure)](#구조-structure)
- [주요 컴포넌트 (Key Components)](#주요-컴포넌트-key-components)
- [비즈니스 로직 (Business Logic)](#비즈니스-로직-business-logic)
- [사용 방법 (Usage)](#사용-방법-usage)
- [확장성 (Extensibility)](#확장성-extensibility)

### 개요 (Overview)

Home Feature의 Domain Layer는 비즈니스 로직의 핵심을 담당합니다.
홈 대시보드의 엔티티 정의, 리포지토리 인터페이스, 유스케이스를 통해
비즈니스 규칙과 데이터 흐름을 관리합니다.

**주요 역할:**

- 🏗️ **엔티티 정의**: 비즈니스 도메인의 핵심 객체 정의
- 📋 **인터페이스 설계**: 데이터 접근 계층의 계약 정의
- ⚡ **비즈니스 로직**: 핵심 비즈니스 규칙 구현
- 🔄 **데이터 흐름**: 계층 간 데이터 전달 규칙 정의
- 🎯 **의존성 역전**: 외부 의존성으로부터 비즈니스 로직 보호

### 구조 (Structure)

```txt
domain/
├── domain.dart                       # Domain Layer 배럴 파일
├── entities/                         # 비즈니스 엔티티
│   ├── entities.dart                 # Entities 배럴 파일
│   └── home_dashboard_entity.dart    # 홈 대시보드 엔티티
├── repositories/                     # 리포지토리 인터페이스
│   ├── repositories.dart             # Repositories 배럴 파일
│   └── home_repository.dart          # 홈 리포지토리 인터페이스
└── usecases/                         # 비즈니스 유스케이스
    ├── usecases.dart                 # Usecases 배럴 파일
    └── get_dashboard_data_usecase.dart # 대시보드 데이터 조회 유스케이스
```

### 주요 컴포넌트 (Key Components)

#### 1. **Entities (비즈니스 엔티티)**

**HomeDashboardEntity**: 홈 대시보드의 핵심 데이터 구조

```dart
class HomeDashboardEntity {
  final String currentTime;                    // 현재 시간
  final WeatherData weather;                   // 날씨 정보
  final List<PetProfileEntity> petProfiles;    // 펫 프로필 목록
  final List<AppointmentSummary> upcomingAppointments; // 예정된 예약
  final HealthSummary petHealthSummary;        // 펫 건강 요약
  final WalkSummary walkSummary;               // 산책 요약
}
```

**AppointmentSummary**: 예약 정보 요약

```dart
class AppointmentSummary {
  final String id;                    // 예약 ID
  final String title;                 // 예약 제목
  final DateTime scheduledTime;       // 예약 시간
  final String type;                  // 예약 유형
  final String petName;               // 펫 이름
}
```

**HealthSummary**: 건강 상태 요약

```dart
class HealthSummary {
  final int totalPets;                // 전체 펫 수
  final int healthyPets;              // 건강한 펫 수
  final int petsNeedingAttention;     // 주의가 필요한 펫 수
  final List<HealthAlert> alerts;     // 건강 알림 목록
}
```

**WalkSummary**: 산책 요약

```dart
class WalkSummary {
  final int todayWalks;               // 오늘 산책 횟수
  final double todayDistance;         // 오늘 산책 거리 (km)
  final Duration todayDuration;       // 오늘 산책 시간
  final double weeklyGoal;            // 주간 목표 (km)
  final double weeklyProgress;        // 주간 진행률 (km)
}
```

**HealthAlert**: 건강 알림

```dart
class HealthAlert {
  final String petName;               // 펫 이름
  final String message;               // 알림 메시지
}
```

#### 2. **Repositories (리포지토리 인터페이스)**

**HomeRepository**: 홈 관련 데이터 접근 계약

```dart
abstract class HomeRepository {
  /// 대시보드 데이터 조회
  Future<HomeDashboardEntity> getDashboardData();

  /// 현재 날씨 정보 조회
  Future<WeatherData?> getCurrentWeather();

  /// 펫 프로필 목록 조회
  Future<List<PetProfileEntity>> getPetProfiles();

  /// 산책 요약 정보 조회
  Future<WalkSummary> getWalkSummary();

  /// 펫 건강 요약 정보 조회
  Future<HealthSummary> getPetHealthSummary();

  /// 예정된 예약 목록 조회
  Future<List<AppointmentSummary>> getUpcomingAppointments();
}
```

#### 3. **Use Cases (비즈니스 유스케이스)**

**GetDashboardDataUseCase**: 대시보드 데이터 조회 비즈니스 로직

```dart
class GetDashboardDataUseCase {
  final HomeRepository repository;

  GetDashboardDataUseCase(this.repository);

  /// 대시보드 데이터 조회 실행
  Future<HomeDashboardEntity> call() async {
    return repository.getDashboardData();
  }
}
```

### 비즈니스 로직 (Business Logic)

#### **데이터 집계 로직**

1. **대시보드 데이터 통합**

   - 날씨 정보 + 펫 프로필 + 요약 정보 통합
   - 실시간 데이터와 캐시된 데이터 조합

2. **펫별 맞춤 데이터**

   - 펫 타입(강아지/고양이)에 따른 다른 데이터 제공
   - 개별 펫의 특성에 맞는 정보 표시

3. **시간 기반 데이터**
   - 현재 시간에 따른 동적 데이터 생성
   - 일일/주간 목표 달성률 계산

#### **데이터 검증 규칙**

1. **날씨 데이터 검증**

   - 온도 범위: -50°C ~ 60°C
   - 습도 범위: 0% ~ 100%
   - UV 지수: 0 ~ 11

2. **펫 데이터 검증**
   - 필수 필드 존재 확인
   - 날짜 유효성 검증
   - 수치 범위 검증

### 사용 방법 (Usage)

#### 1. **Entity 사용**

```dart
// 대시보드 엔티티 생성
final dashboard = HomeDashboardEntity(
  currentTime: '14:30',
  weather: weatherData,
  petProfiles: petList,
  upcomingAppointments: appointments,
  petHealthSummary: healthSummary,
  walkSummary: walkSummary,
);

// 데이터 접근
final currentTime = dashboard.currentTime;
final petCount = dashboard.petProfiles.length;
final hasUpcomingAppointments = dashboard.upcomingAppointments.isNotEmpty;
```

#### 2. **Repository 인터페이스 사용**

```dart
// Repository 구현체 주입
final homeRepository = ref.read(homeRepositoryProvider);

// 데이터 조회
final dashboardData = await homeRepository.getDashboardData();
final weather = await homeRepository.getCurrentWeather();
final pets = await homeRepository.getPetProfiles();
```

#### 3. **Use Case 사용**

```dart
// Use Case 인스턴스 생성
final getDashboardDataUseCase = GetDashboardDataUseCase(homeRepository);

// 비즈니스 로직 실행
final dashboardData = await getDashboardDataUseCase.call();
```

### 확장성 (Extensibility)

#### **새로운 Entity 추가**

```dart
// 새로운 요약 정보 엔티티 추가
class FeedingSummary {
  final int completedMeals;
  final int totalMeals;
  final String nextMeal;
  final DateTime nextMealTime;

  const FeedingSummary({
    required this.completedMeals,
    required this.totalMeals,
    required this.nextMeal,
    required this.nextMealTime,
  });
}

// HomeDashboardEntity에 추가
class HomeDashboardEntity {
  // ... 기존 필드들
  final FeedingSummary feedingSummary;  // 새로 추가된 필드
}
```

#### **새로운 Repository 메서드 추가**

```dart
abstract class HomeRepository {
  // ... 기존 메서드들

  /// 급여 요약 정보 조회
  Future<FeedingSummary> getFeedingSummary();
}
```

#### **새로운 Use Case 추가**

```dart
class GetFeedingSummaryUseCase {
  final HomeRepository repository;

  GetFeedingSummaryUseCase(this.repository);

  Future<FeedingSummary> call() async {
    return repository.getFeedingSummary();
  }
}
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [構造 (Structure)](#構造-structure)
- [主要コンポーネント (Key Components)](#主要コンポーネント-key-components)
- [ビジネスロジック (Business Logic)](#ビジネスロジック-business-logic)
- [使用方法 (Usage)](#使用方法-usage)
- [拡張性 (Extensibility)](#拡張性-extensibility)

### 概要 (Overview)

Home Feature の Domain Layer はビジネスロジックの核心を担当します。
ホームダッシュボードのエンティティ定義、リポジトリインターフェース、ユースケースを通じて
ビジネスルールとデータフローを管理します。

**主な役割:**

- 🏗️ **エンティティ定義**: ビジネスドメインの核心オブジェクト定義
- 📋 **インターフェース設計**: データアクセス層の契約定義
- ⚡ **ビジネスロジック**: 核心ビジネスルール実装
- 🔄 **データフロー**: 層間データ転送ルール定義
- 🎯 **依存性逆転**: 外部依存性からビジネスロジック保護

### 構造 (Structure)

```txt
domain/
├── domain.dart                       # Domain Layer バレルファイル
├── entities/                         # ビジネスエンティティ
│   ├── entities.dart                 # Entities バレルファイル
│   └── home_dashboard_entity.dart    # ホームダッシュボードエンティティ
├── repositories/                     # リポジトリインターフェース
│   ├── repositories.dart             # Repositories バレルファイル
│   └── home_repository.dart          # ホームリポジトリインターフェース
└── usecases/                         # ビジネスユースケース
    ├── usecases.dart                 # Usecases バレルファイル
    └── get_dashboard_data_usecase.dart # ダッシュボードデータ取得ユースケース
```

### 主要コンポーネント (Key Components)

#### 1. **Entities (ビジネスエンティティ)**

**HomeDashboardEntity**: ホームダッシュボードの核心データ構造

```dart
class HomeDashboardEntity {
  final String currentTime;                    // 現在時間
  final WeatherData weather;                   // 天気情報
  final List<PetProfileEntity> petProfiles;    // ペットプロフィールリスト
  final List<AppointmentSummary> upcomingAppointments; // 予定された予約
  final HealthSummary petHealthSummary;        // ペット健康サマリー
  final WalkSummary walkSummary;               // 散歩サマリー
}
```

**AppointmentSummary**: 予約情報サマリー

```dart
class AppointmentSummary {
  final String id;                    // 予約 ID
  final String title;                 // 予約タイトル
  final DateTime scheduledTime;       // 予約時間
  final String type;                  // 予約タイプ
  final String petName;               // ペット名
}
```

**HealthSummary**: 健康状態サマリー

```dart
class HealthSummary {
  final int totalPets;                // 全体ペット数
  final int healthyPets;              // 健康なペット数
  final int petsNeedingAttention;     // 注意が必要なペット数
  final List<HealthAlert> alerts;     // 健康アラートリスト
}
```

**WalkSummary**: 散歩サマリー

```dart
class WalkSummary {
  final int todayWalks;               // 今日の散歩回数
  final double todayDistance;         // 今日の散歩距離 (km)
  final Duration todayDuration;       // 今日の散歩時間
  final double weeklyGoal;            // 週間目標 (km)
  final double weeklyProgress;        // 週間進行率 (km)
}
```

**HealthAlert**: 健康アラート

```dart
class HealthAlert {
  final String petName;               // ペット名
  final String message;               // アラートメッセージ
}
```

#### 2. **Repositories (リポジトリインターフェース)**

**HomeRepository**: ホーム関連データアクセス契約

```dart
abstract class HomeRepository {
  /// ダッシュボードデータ取得
  Future<HomeDashboardEntity> getDashboardData();

  /// 現在天気情報取得
  Future<WeatherData?> getCurrentWeather();

  /// ペットプロフィールリスト取得
  Future<List<PetProfileEntity>> getPetProfiles();

  /// 散歩サマリー情報取得
  Future<WalkSummary> getWalkSummary();

  /// ペット健康サマリー情報取得
  Future<HealthSummary> getPetHealthSummary();

  /// 予定された予約リスト取得
  Future<List<AppointmentSummary>> getUpcomingAppointments();
}
```

#### 3. **Use Cases (ビジネスユースケース)**

**GetDashboardDataUseCase**: ダッシュボードデータ取得ビジネスロジック

```dart
class GetDashboardDataUseCase {
  final HomeRepository repository;

  GetDashboardDataUseCase(this.repository);

  /// ダッシュボードデータ取得実行
  Future<HomeDashboardEntity> call() async {
    return repository.getDashboardData();
  }
}
```

### ビジネスロジック (Business Logic)

#### **データ集約ロジック**

1. **ダッシュボードデータ統合**

   - 天気情報 + ペットプロフィール + サマリー情報統合
   - リアルタイムデータとキャッシュされたデータ組み合わせ

2. **ペット別カスタムデータ**

   - ペットタイプ(犬/猫)による異なるデータ提供
   - 個別ペットの特性に合った情報表示

3. **時間ベースデータ**
   - 現在時間による動的データ生成
   - 日次/週間目標達成率計算

#### **データ検証ルール**

1. **天気データ検証**

   - 気温範囲: -50°C ~ 60°C
   - 湿度範囲: 0% ~ 100%
   - UV 指数: 0 ~ 11

2. **ペットデータ検証**
   - 必須フィールド存在確認
   - 日付有効性検証
   - 数値範囲検証

### 使用方法 (Usage)

#### 1. **Entity 使用**

```dart
// ダッシュボードエンティティ作成
final dashboard = HomeDashboardEntity(
  currentTime: '14:30',
  weather: weatherData,
  petProfiles: petList,
  upcomingAppointments: appointments,
  petHealthSummary: healthSummary,
  walkSummary: walkSummary,
);

// データアクセス
final currentTime = dashboard.currentTime;
final petCount = dashboard.petProfiles.length;
final hasUpcomingAppointments = dashboard.upcomingAppointments.isNotEmpty;
```

#### 2. **Repository インターフェース使用**

```dart
// Repository 実装体注入
final homeRepository = ref.read(homeRepositoryProvider);

// データ取得
final dashboardData = await homeRepository.getDashboardData();
final weather = await homeRepository.getCurrentWeather();
final pets = await homeRepository.getPetProfiles();
```

#### 3. **Use Case 使用**

```dart
// Use Case インスタンス作成
final getDashboardDataUseCase = GetDashboardDataUseCase(homeRepository);

// ビジネスロジック実行
final dashboardData = await getDashboardDataUseCase.call();
```

### 拡張性 (Extensibility)

#### **新しい Entity 追加**

```dart
// 新しいサマリー情報エンティティ追加
class FeedingSummary {
  final int completedMeals;
  final int totalMeals;
  final String nextMeal;
  final DateTime nextMealTime;

  const FeedingSummary({
    required this.completedMeals,
    required this.totalMeals,
    required this.nextMeal,
    required this.nextMealTime,
  });
}

// HomeDashboardEntity に追加
class HomeDashboardEntity {
  // ... 既存フィールド
  final FeedingSummary feedingSummary;  // 新しく追加されたフィールド
}
```

#### **新しい Repository メソッド追加**

```dart
abstract class HomeRepository {
  // ... 既存メソッド

  /// 給餌サマリー情報取得
  Future<FeedingSummary> getFeedingSummary();
}
```

#### **新しい Use Case 追加**

```dart
class GetFeedingSummaryUseCase {
  final HomeRepository repository;

  GetFeedingSummaryUseCase(this.repository);

  Future<FeedingSummary> call() async {
    return repository.getFeedingSummary();
  }
}
```

---

## 📚 추가 리소스 / その他のリソース

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)

---

© 2025 AI Pet. Home Domain Layer / ホームドメイン層
