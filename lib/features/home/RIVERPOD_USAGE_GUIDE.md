# 🚀 Home 폴더 Riverpod 사용 가이드

## 📋 개요

Home 폴더가 Riverpod과 UseCase 패턴을 사용하도록 리팩토링되었습니다. 이 가이드는 새로운 구조를 사용하는 방법을 안내합니다.

## 🎯 **새로운 구조**

### **Riverpod Provider 기반**

- UseCase Provider들로 의존성 주입
- HomeDataService Provider로 중앙화된 데이터 관리
- Riverpod Controller로 상태 관리

## 🔧 **사용 방법**

### **1. 기본 사용법**

#### **HomeDashboardController 사용**

```dart
// Provider로 컨트롤러 접근
final controller = ref.read(riverpodHomeDashboardControllerProvider.notifier);

// 홈 화면 초기화
final result = await controller.initializeHome();

// 날씨 정보 로드
final weather = await controller.loadWeatherInfo(userTriggered: true);

// 통합 데이터 로드
final allData = await controller.loadAllData();
```

#### **HomeNotificationController 사용**

```dart
// Provider로 컨트롤러 접근
final notificationController = ref.read(riverpodHomeNotificationControllerProvider.notifier);

// 알림 처리
final notifications = await notificationController.handleNotification();

// 특정 알림만 처리
final specificNotifications = await notificationController.handleSpecificNotification(
  includeAppointments: true,
  includeHealth: false,
  includeWalk: true,
);
```

### **2. Widget에서 사용**

#### **ConsumerWidget 사용**

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(riverpodHomeDashboardControllerProvider.notifier);
    final notifications = ref.watch(riverpodHomeNotificationControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          // 홈 화면 내용
          ElevatedButton(
            onPressed: () async {
              final result = await controller.initializeHome();
              if (result.isSuccess) {
                // 성공 처리
              }
            },
            child: Text('홈 초기화'),
          ),

          // 알림 표시
          if (notifications.isNotEmpty)
            ...notifications.map((notification) =>
              Text(notification)
            ).toList(),
        ],
      ),
    );
  }
}
```

#### **ConsumerStatefulWidget 사용**

```dart
class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    final controller = ref.read(riverpodHomeDashboardControllerProvider.notifier);
    final result = await controller.initializeHome();

    if (result.isSuccess) {
      // 성공 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(riverpodHomeNotificationControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          // UI 구성
          if (notifications.isNotEmpty)
            ...notifications.map((notification) =>
              Text(notification)
            ).toList(),
        ],
      ),
    );
  }
}
```

### **3. UseCase 직접 사용**

#### **개별 UseCase 사용**

```dart
// 날씨 정보 조회
final weatherUseCase = ref.read(getWeatherDataUseCaseProvider);
final weatherResult = await weatherUseCase.call(userTriggered: true);

// 펫 정보 조회
final petUseCase = ref.read(getPetSummaryUseCaseProvider);
final petResult = await petUseCase.call();
```

#### **HomeDataService 직접 사용**

```dart
// HomeDataService 직접 사용
final dataService = ref.read(homeDataServiceProvider);

// 통합 데이터 로드
final allData = await dataService.loadAllData();

// 선택적 데이터 로드
final specificData = await dataService.loadSpecificData(
  loadWeather: true,
  loadPets: true,
  loadWalk: false,
);
```

## 🧪 **테스트 방법**

### **1. Unit Test**

```dart
void main() {
  group('RiverpodHomeDashboardController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Mock providers
          homeRepositoryProvider.overrideWithValue(MockHomeRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('홈 초기화 테스트', (tester) async {
      final controller = container.read(riverpodHomeDashboardControllerProvider.notifier);
      final result = await controller.initializeHome();

      expect(result.isSuccess, true);
    });
  });
}
```

### **2. Widget Test**

```dart
void main() {
  group('HomeScreen Widget Test', () {
    testWidgets('홈 화면 렌더링 테스트', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock providers
            homeRepositoryProvider.overrideWithValue(MockHomeRepository()),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('홈 초기화'), findsOneWidget);
    });
  });
}
```

## 🔄 **상태 관리**

### **1. 알림 상태 관리**

```dart
// 알림 상태 구독
final notifications = ref.watch(riverpodHomeNotificationControllerProvider);

// 알림 추가
final notificationController = ref.read(riverpodHomeNotificationControllerProvider.notifier);
notificationController.addNotification('새로운 알림');

// 알림 제거
notificationController.removeNotification('제거할 알림');

// 알림 클리어
notificationController.clearNotifications();
```

### **2. 데이터 로딩 상태 관리**

```dart
// 로딩 상태 관리
class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final controller = ref.read(riverpodHomeDashboardControllerProvider.notifier);
      final result = await controller.loadAllData();

      if (result.isSuccess) {
        // 성공 처리
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              ElevatedButton(
                onPressed: _loadData,
                child: Text('데이터 로드'),
              ),
            ],
          ),
    );
  }
}
```

## 🚀 **성능 최적화**

### **1. 선택적 데이터 로딩**

```dart
// 필요한 데이터만 로드
final controller = ref.read(riverpodHomeDashboardControllerProvider.notifier);
final specificData = await controller.loadSpecificData(
  loadWeather: true,    // 날씨 정보만 로드
  loadPets: false,     // 펫 정보는 로드하지 않음
  loadWalk: true,       // 산책 정보는 로드
  loadHealth: false,   // 건강 정보는 로드하지 않음
  loadAppointments: true, // 예약 정보는 로드
);
```

### **2. 캐싱 활용**

```dart
// Provider는 자동으로 캐싱됨
final weather = ref.watch(getWeatherDataUseCaseProvider);
// 같은 요청은 캐시된 결과 반환
```

## 📊 **모니터링**

### **1. 에러 처리**

```dart
final controller = ref.read(riverpodHomeDashboardControllerProvider.notifier);

try {
  final result = await controller.initializeHome();

  if (result.isFailure) {
    // 에러 처리
    print('에러: ${result.errorOrNull}');
  }
} catch (error) {
  // 예외 처리
  print('예외: $error');
}
```

### **2. 로깅**

```dart
// Provider 상태 변경 로깅
ref.listen(riverpodHomeNotificationControllerProvider, (previous, next) {
  print('알림 상태 변경: ${previous?.length} -> ${next.length}');
});
```

## 🔧 **고급 사용법**

### **1. Provider 오버라이드**

```dart
// 테스트용 Mock Provider
final mockHomeRepository = MockHomeRepository();
when(mockHomeRepository.getDashboardData()).thenAnswer((_) async => mockData);

final container = ProviderContainer(
  overrides: [
    homeRepositoryProvider.overrideWithValue(mockHomeRepository),
  ],
);
```

### **2. Provider 조합**

```dart
// 여러 Provider 조합 사용
final combinedProvider = Provider<Map<String, dynamic>>((ref) {
  final weather = ref.watch(getWeatherDataUseCaseProvider);
  final pets = ref.watch(getPetSummaryUseCaseProvider);

  return {
    'weather': weather,
    'pets': pets,
  };
});
```

---

**이제 Home 폴더는 Riverpod과 UseCase 패턴을 사용하는 현대적이고 효율적인 구조가 되었습니다!** 🎉
