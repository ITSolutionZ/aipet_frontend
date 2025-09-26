# Home Presentation Layer / ホームプレゼンテーション層

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [구조 (Structure)](#구조-structure)
- [주요 컴포넌트 (Key Components)](#주요-컴포넌트-key-components)
- [UI 패턴 (UI Patterns)](#ui-패턴-ui-patterns)
- [상태 관리 (State Management)](#상태-관리-state-management)
- [사용 방법 (Usage)](#사용-방법-usage)
- [커스터마이징 (Customization)](#커스터마이징-customization)

### 개요 (Overview)

Home Feature의 Presentation Layer는 사용자 인터페이스와 사용자 상호작용을 담당합니다.
Riverpod을 통한 상태 관리, Clean Architecture 패턴의 컨트롤러,
재사용 가능한 위젯들을 통해 직관적이고 반응적인 UI를 제공합니다.

**주요 역할:**

- 🎨 **UI 렌더링**: 사용자에게 보여지는 화면 구성
- 🎮 **사용자 상호작용**: 터치, 스와이프, 네비게이션 처리
- 🔄 **상태 관리**: Riverpod을 통한 반응형 상태 관리
- 🧠 **비즈니스 로직**: 컨트롤러를 통한 사용자 액션 처리
- 📱 **반응형 디자인**: 다양한 화면 크기와 방향 대응
- ♻️ **재사용성**: 모듈화된 위젯과 컴포넌트

### 구조 (Structure)

```txt
presentation/
├── presentation.dart                  # Presentation Layer 배럴 파일
├── controllers/                       # 비즈니스 로직 컨트롤러
│   ├── controllers.dart               # Controllers 배럴 파일
│   ├── home_dashboard_controller.dart # 홈 대시보드 컨트롤러
│   ├── home_notification_controller.dart # 알림 컨트롤러
│   └── weather_controller.dart       # 날씨 컨트롤러
├── screens/                           # 화면 UI
│   ├── screens.dart                   # Screens 배럴 파일
│   └── home_screen.dart               # 홈 화면
└── widgets/                           # 재사용 가능한 위젯
    ├── widgets.dart                   # Widgets 배럴 파일
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

### 주요 컴포넌트 (Key Components)

#### 1. **Controllers (비즈니스 로직 컨트롤러)**

**HomeDashboardController**: 홈 대시보드의 핵심 비즈니스 로직

```dart
class HomeDashboardController extends BaseController {
  late final HomeRepository _repository = HomeRepositoryImpl();
  late final GetDashboardDataUseCase _getDashboardDataUseCase =
      GetDashboardDataUseCase(_repository);

  /// 홈 화면 초기화
  Future<HomeDashboardResult> initializeHome() async { ... }

  /// 펫 목록 확인
  Future<bool> hasPets() async { ... }

  /// 날씨 정보 로드
  Future<HomeDashboardResult> loadWeatherInfo() async { ... }

  /// 산책 정보 로드
  Future<HomeDashboardResult> loadWalkInfo() async { ... }

  /// 건강 정보 로드
  Future<HomeDashboardResult> loadHealthInfo() async { ... }

  /// 예약 정보 로드
  Future<HomeDashboardResult> loadAppointmentInfo() async { ... }

  /// 프로필 업데이트
  Future<HomeDashboardResult> updateProfile() async { ... }
}
```

**HomeNotificationController**: 알림 관련 비즈니스 로직

```dart
class HomeNotificationController extends BaseController {
  /// 알림 처리
  Future<HomeNotificationResult> handleNotification() async { ... }

  /// 시간 포맷팅 헬퍼 메서드
  String _formatTime(DateTime dateTime) { ... }
}
```

**WeatherController**: 날씨 관련 비즈니스 로직

```dart
class WeatherController extends BaseController {
  final WeatherService _weatherService = WeatherService();
  final OpenAIService _openAIService = OpenAIService();

  /// 현재 날씨 데이터 가져오기
  Future<WeatherResult> getCurrentWeather() async { ... }

  /// 날씨 기반 산책 조언 생성
  Future<WeatherResult> generateWalkingAdvice() async { ... }

  /// 현재 시간이 낮인지 확인
  bool isDayTime() { ... }
}
```

#### 2. **Screens (화면 UI)**

**HomeScreen**: 홈 화면의 메인 UI

```dart
class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeDashboardController _dashboardController;
  late HomeNotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _dashboardController = HomeDashboardController(ref);
    _notificationController = HomeNotificationController(ref);
    _checkPetsAndRedirect();
  }

  /// 펫 목록을 확인하고 홈 화면 초기화
  Future<void> _checkPetsAndRedirect() async { ... }

  /// 홈 화면 초기화
  Future<void> _initializeHomeScreen() async { ... }

  /// 알림 아이콘 탭 처리
  Future<void> _handleNotificationTap() async { ... }
}
```

#### 3. **Widgets (재사용 가능한 위젯)**

**HomeHeader**: 홈 화면 상단 헤더

```dart
class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const HomeHeader({super.key, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 헤더 UI 구성
      child: Row(
        children: [
          _buildMenuButton(context),      // 메뉴 버튼
          const Spacer(),
          _buildTitle(),                  // 제목
          const Spacer(),
          _buildNotificationButton(),     // 알림 버튼
          _buildProfileAvatar(),          // 프로필 아바타
        ],
      ),
    );
  }
}
```

**PetProfileCard**: 펫 프로필 표시 카드

```dart
class PetProfileCard extends ConsumerStatefulWidget {
  final List<String> activities;

  const PetProfileCard({super.key, this.activities = const []});

  @override
  ConsumerState<PetProfileCard> createState() => _PetProfileCardState();
}

class _PetProfileCardState extends ConsumerState<PetProfileCard> {
  late PageController _pageController;

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (petList) => _buildPetProfile(petList),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
    );
  }
}
```

**WeatherCard**: 날씨 정보 표시 카드

```dart
class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({super.key});

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  late WeatherController _controller;
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _walkingAdvice;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(ref);
    _loadWeatherData(forceRefresh: false);
  }

  Future<void> _loadWeatherData({bool forceRefresh = false}) async { ... }

  Future<void> _generateWalkingAdvice() async { ... }
}
```

**HomeSummaryGrid**: 요약 정보 그리드

```dart
class HomeSummaryGrid extends StatelessWidget {
  const HomeSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle(),
        Transform.translate(
          offset: const Offset(0, -32),
          child: _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      children: const [
        WalkSummaryCard(),        // 산책 요약
        FeedingSummaryCard(),     // 급여 요약
        WeightSummaryCard(),      // 체중 요약
        AppointmentSummaryCard(), // 예약 요약
      ],
    );
  }
}
```

### UI 패턴 (UI Patterns)

#### **1. 카드 기반 레이아웃**

- 각 정보 섹션을 카드 형태로 구성
- 그림자와 둥근 모서리로 시각적 계층 구조 생성
- 터치 가능한 카드로 상호작용성 향상

#### **2. 그리드 레이아웃**

- 2x2 그리드로 요약 정보 표시
- 반응형 디자인으로 다양한 화면 크기 대응
- 일관된 간격과 비율로 시각적 균형 유지

#### **3. 스와이프 네비게이션**

- 펫 프로필 간 스와이프로 전환
- PageView를 사용한 부드러운 애니메이션
- 현재 선택된 펫 상태 관리

#### **4. 로딩 상태 처리**

- 스켈레톤 UI로 로딩 상태 표시
- 에러 상태에 대한 친화적인 메시지
- 재시도 옵션 제공

### 상태 관리 (State Management)

#### **Riverpod Provider 구조**

```dart
// 홈 상태 관리
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() => const HomeStateData(selectedIndex: 0, currentTime: '');

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

// 선택된 펫 관리
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() { ... }

  void selectPet(PetProfileEntity pet) {
    state = pet;
  }
}

// 현재 시간 스트림
@riverpod
Stream<String> homeCurrentTimeStream(Ref ref) async* { ... }
```

#### **Controller와 Provider 조합**

```dart
// Controller에서 상태 업데이트
class HomeDashboardController extends BaseController {
  Future<HomeDashboardResult> initializeHome() async {
    try {
      final dashboardData = await _getDashboardDataUseCase.call();
      return HomeDashboardResult.success('홈 화면이 로드되었습니다', dashboardData);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
```

### 사용 방법 (Usage)

#### **1. 기본 화면 표시**

```dart
import 'package:aipet_frontend/features/home/home.dart';

// 홈 화면으로 이동
context.go('/home');

// 홈 화면 위젯 사용
const HomeScreen()
```

#### **2. Controller 사용**

```dart
final dashboardController = ref.read(homeDashboardControllerProvider.notifier);

// 홈 화면 초기화
final result = await dashboardController.initializeHome();

// 날씨 정보 로드
final weatherResult = await dashboardController.loadWeatherInfo();
```

#### **3. 개별 위젯 사용**

```dart
// 펫 프로필 카드
const PetProfileCard(
  activities: ['산책 완료', '급여 완료'],
);

// 날씨 카드
const WeatherCard();

// 요약 그리드
const HomeSummaryGrid();
```

#### **4. 커스텀 스타일링**

```dart
// 테마 색상 사용
Container(
  color: AppColors.pointBrown.withValues(alpha: 0.8),
  child: Text('ホーム', style: AppFonts.fredoka()),
)

// 간격 상수 사용
const SizedBox(height: AppSpacing.lg);
const EdgeInsets.all(AppSpacing.md);
```

### 커스터마이징 (Customization)

#### **새로운 위젯 추가**

```dart
// 새로운 요약 카드 위젯 생성
class NewSummaryCard extends ConsumerWidget {
  const NewSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // 위젯 UI 구성
    );
  }
}

// widgets.dart에 export 추가
export 'new_summary_card.dart';

// HomeSummaryGrid에 추가
children: const [
  WalkSummaryCard(),
  FeedingSummaryCard(),
  WeightSummaryCard(),
  AppointmentSummaryCard(),
  NewSummaryCard(),  // 새로 추가된 위젯
],
```

#### **새로운 화면 추가**

```dart
// 새로운 화면 생성
class NewScreen extends ConsumerWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('新機能')),
      body: const Center(child: Text('新しい機能')),
    );
  }
}

// screens.dart에 export 추가
export 'new_screen.dart';
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [構造 (Structure)](#構造-structure)
- [主要コンポーネント (Key Components)](#主要コンポーネント-key-components)
- [UI パターン (UI Patterns)](#ui-パターン-ui-patterns)
- [状態管理 (State Management)](#状態管理-state-management)
- [使用方法 (Usage)](#使用方法-usage)
- [カスタマイズ (Customization)](#カスタマイズ-customization)

### 概要 (Overview)

Home Feature の Presentation Layer はユーザーインターフェースとユーザーインタラクションを担当します。
Riverpod による状態管理、Clean Architecture パターンのコントローラー、
再利用可能なウィジェットを通じて直感的で反応的な UI を提供します。

**主な役割:**

- 🎨 **UI レンダリング**: ユーザーに表示される画面構成
- 🎮 **ユーザーインタラクション**: タッチ、スワイプ、ナビゲーション処理
- 🔄 **状態管理**: Riverpod による反応型状態管理
- 🧠 **ビジネスロジック**: コントローラーによるユーザーアクション処理
- 📱 **反応型デザイン**: 様々な画面サイズと方向対応
- ♻️ **再利用性**: モジュール化されたウィジェットとコンポーネント

### 構造 (Structure)

```txt
presentation/
├── presentation.dart                  # Presentation Layer バレルファイル
├── controllers/                       # ビジネスロジックコントローラー
│   ├── controllers.dart               # Controllers バレルファイル
│   ├── home_dashboard_controller.dart # ホームダッシュボードコントローラー
│   ├── home_notification_controller.dart # 通知コントローラー
│   └── weather_controller.dart       # 天気コントローラー
├── screens/                           # 画面 UI
│   ├── screens.dart                   # Screens バレルファイル
│   └── home_screen.dart               # ホーム画面
└── widgets/                           # 再利用可能なウィジェット
    ├── widgets.dart                   # Widgets バレルファイル
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

### 主要コンポーネント (Key Components)

#### 1. **Controllers (ビジネスロジックコントローラー)**

**HomeDashboardController**: ホームダッシュボードの核心ビジネスロジック

```dart
class HomeDashboardController extends BaseController {
  late final HomeRepository _repository = HomeRepositoryImpl();
  late final GetDashboardDataUseCase _getDashboardDataUseCase =
      GetDashboardDataUseCase(_repository);

  /// ホーム画面初期化
  Future<HomeDashboardResult> initializeHome() async { ... }

  /// ペットリスト確認
  Future<bool> hasPets() async { ... }

  /// 天気情報読み込み
  Future<HomeDashboardResult> loadWeatherInfo() async { ... }

  /// 散歩情報読み込み
  Future<HomeDashboardResult> loadWalkInfo() async { ... }

  /// 健康情報読み込み
  Future<HomeDashboardResult> loadHealthInfo() async { ... }

  /// 予約情報読み込み
  Future<HomeDashboardResult> loadAppointmentInfo() async { ... }

  /// プロフィール更新
  Future<HomeDashboardResult> updateProfile() async { ... }
}
```

**HomeNotificationController**: 通知関連ビジネスロジック

```dart
class HomeNotificationController extends BaseController {
  /// 通知処理
  Future<HomeNotificationResult> handleNotification() async { ... }

  /// 時間フォーマットヘルパーメソッド
  String _formatTime(DateTime dateTime) { ... }
}
```

**WeatherController**: 天気関連ビジネスロジック

```dart
class WeatherController extends BaseController {
  final WeatherService _weatherService = WeatherService();
  final OpenAIService _openAIService = OpenAIService();

  /// 現在天気データ取得
  Future<WeatherResult> getCurrentWeather() async { ... }

  /// 天気ベース散歩アドバイス生成
  Future<WeatherResult> generateWalkingAdvice() async { ... }

  /// 現在時間が昼間か確認
  bool isDayTime() { ... }
}
```

#### 2. **Screens (画面 UI)**

**HomeScreen**: ホーム画面のメイン UI

```dart
class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeDashboardController _dashboardController;
  late HomeNotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _dashboardController = HomeDashboardController(ref);
    _notificationController = HomeNotificationController(ref);
    _checkPetsAndRedirect();
  }

  /// ペットリストを確認してホーム画面初期化
  Future<void> _checkPetsAndRedirect() async { ... }

  /// ホーム画面初期化
  Future<void> _initializeHomeScreen() async { ... }

  /// 通知アイコンタップ処理
  Future<void> _handleNotificationTap() async { ... }
}
```

#### 3. **Widgets (再利用可能なウィジェット)**

**HomeHeader**: ホーム画面上部ヘッダー

```dart
class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const HomeHeader({super.key, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ヘッダー UI 構成
      child: Row(
        children: [
          _buildMenuButton(context),      // メニューボタン
          const Spacer(),
          _buildTitle(),                  // タイトル
          const Spacer(),
          _buildNotificationButton(),     // 通知ボタン
          _buildProfileAvatar(),          // プロフィールアバター
        ],
      ),
    );
  }
}
```

**PetProfileCard**: ペットプロフィール表示カード

```dart
class PetProfileCard extends ConsumerStatefulWidget {
  final List<String> activities;

  const PetProfileCard({super.key, this.activities = const []});

  @override
  ConsumerState<PetProfileCard> createState() => _PetProfileCardState();
}

class _PetProfileCardState extends ConsumerState<PetProfileCard> {
  late PageController _pageController;

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (petList) => _buildPetProfile(petList),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
    );
  }
}
```

**WeatherCard**: 天気情報表示カード

```dart
class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({super.key});

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  late WeatherController _controller;
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _walkingAdvice;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(ref);
    _loadWeatherData(forceRefresh: false);
  }

  Future<void> _loadWeatherData({bool forceRefresh = false}) async { ... }

  Future<void> _generateWalkingAdvice() async { ... }
}
```

**HomeSummaryGrid**: サマリー情報グリッド

```dart
class HomeSummaryGrid extends StatelessWidget {
  const HomeSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle(),
        Transform.translate(
          offset: const Offset(0, -32),
          child: _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      children: const [
        WalkSummaryCard(),        // 散歩サマリー
        FeedingSummaryCard(),     // 給餌サマリー
        WeightSummaryCard(),      // 体重サマリー
        AppointmentSummaryCard(), // 予約サマリー
      ],
    );
  }
}
```

### UI パターン (UI Patterns)

#### **1. カードベースレイアウト**

- 各情報セクションをカード形式で構成
- 影と丸い角で視覚的階層構造作成
- タッチ可能なカードで相互性向上

#### **2. グリッドレイアウト**

- 2x2 グリッドでサマリー情報表示
- 反応型デザインで様々な画面サイズ対応
- 一貫した間隔と比率で視覚的バランス維持

#### **3. スワイプナビゲーション**

- ペットプロフィール間スワイプで切り替え
- PageView を使用した滑らかなアニメーション
- 現在選択されたペット状態管理

#### **4. ローディング状態処理**

- スケルトン UI でローディング状態表示
- エラー状態に対する親しみやすいメッセージ
- 再試行オプション提供

### 状態管理 (State Management)

#### **Riverpod Provider 構造**

```dart
// ホーム状態管理
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() => const HomeStateData(selectedIndex: 0, currentTime: '');

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

// 選択されたペット管理
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() { ... }

  void selectPet(PetProfileEntity pet) {
    state = pet;
  }
}

// 現在時間ストリーム
@riverpod
Stream<String> homeCurrentTimeStream(Ref ref) async* { ... }
```

#### **Controller と Provider 組み合わせ**

```dart
// Controller で状態更新
class HomeDashboardController extends BaseController {
  Future<HomeDashboardResult> initializeHome() async {
    try {
      final dashboardData = await _getDashboardDataUseCase.call();
      return HomeDashboardResult.success('ホーム画面が読み込まれました', dashboardData);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
```

### 使用方法 (Usage)

#### **1. 基本画面表示**

```dart
import 'package:aipet_frontend/features/home/home.dart';

// ホーム画面へ移動
context.go('/home');

// ホーム画面ウィジェット使用
const HomeScreen()
```

#### **2. Controller 使用**

```dart
final dashboardController = ref.read(homeDashboardControllerProvider.notifier);

// ホーム画面初期化
final result = await dashboardController.initializeHome();

// 天気情報読み込み
final weatherResult = await dashboardController.loadWeatherInfo();
```

#### **3. 個別ウィジェット使用**

```dart
// ペットプロフィールカード
const PetProfileCard(
  activities: ['散歩完了', '給餌完了'],
);

// 天気カード
const WeatherCard();

// サマリーグリッド
const HomeSummaryGrid();
```

#### **4. カスタムスタイリング**

```dart
// テーマ色使用
Container(
  color: AppColors.pointBrown.withValues(alpha: 0.8),
  child: Text('ホーム', style: AppFonts.fredoka()),
)

// 間隔定数使用
const SizedBox(height: AppSpacing.lg);
const EdgeInsets.all(AppSpacing.md);
```

### カスタマイズ (Customization)

#### **新しいウィジェット追加**

```dart
// 新しいサマリーカードウィジェット作成
class NewSummaryCard extends ConsumerWidget {
  const NewSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // ウィジェット UI 構成
    );
  }
}

// widgets.dart に export 追加
export 'new_summary_card.dart';

// HomeSummaryGrid に追加
children: const [
  WalkSummaryCard(),
  FeedingSummaryCard(),
  WeightSummaryCard(),
  AppointmentSummaryCard(),
  NewSummaryCard(),  // 新しく追加されたウィジェット
],
```

#### **新しい画面追加**

```dart
// 新しい画面作成
class NewScreen extends ConsumerWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('新機能')),
      body: const Center(child: Text('新しい機能')),
    );
  }
}

// screens.dart に export 追加
export 'new_screen.dart';
```

---

## 📚 추가 리소스 / その他のリソース

- [Flutter Widgets](https://docs.flutter.dev/development/ui/widgets)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design](https://material.io/design)
- [Flutter Layouts](https://docs.flutter.dev/development/ui/layout)

---

© 2025 AI Pet. Home Presentation Layer / ホームプレゼンテーション層
