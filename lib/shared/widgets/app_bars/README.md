# 다이나믹 스크롤 앱 바 (Dynamic Scroll App Bar)

스크롤 위치에 따라 배경색과 블러 효과가 동적으로 변화하는 앱 바 컴포넌트입니다.

## 주요 특징

- **스크롤 반응형**: 스크롤 위치에 따른 실시간 변화
- **세 가지 상태**: 색상 배경 → 블러 효과 → 화이트 배경
- **다양한 테마**: 브라운, 그린, 블루 프리셋 제공
- **완전 커스터마이징**: 모든 파라미터 조정 가능
- **접근성 지원**: 텍스트 색상 자동 조정

## 사용법

### 1. 기본 사용법

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: '내 화면',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController, // 중요: 같은 컨트롤러 사용
        slivers: [
          // 여기에 스크롤 가능한 콘텐츠 추가
        ],
      ),
    );
  }
}
```

### 2. 프리셋 스타일 사용

```dart
// 브라운 테마
DynamicAppBarStyles.brown(
  scrollController: _scrollController,
  title: '브라운 테마',
)

// 그린 테마
DynamicAppBarStyles.green(
  scrollController: _scrollController,
  title: '그린 테마',
)

// 블루 테마
DynamicAppBarStyles.blue(
  scrollController: _scrollController,
  title: '블루 테마',
)
```

### 3. 커스텀 설정

```dart
DynamicScrollAppBar(
  scrollController: _scrollController,
  title: '커스텀 앱 바',
  baseColor: Colors.purple,
  blurStartOffset: 100.0,    // 블러 시작 지점
  whiteStartOffset: 200.0,   // 화이트 전환 시작 지점
  maxBlurSigma: 15.0,        // 최대 블러 강도
  leading: IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () {},
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)
```

## 스크롤 진행에 따른 변화

| 스크롤 진행률 | 배경 상태 | 블러 효과 | 텍스트 색상 |
|-------------|----------|----------|----------|
| 0% | 기본 색상 (baseColor) | 없음 | 흰색 |
| 0-50% | 색상 → 화이트 전환 시작 | 점진적 증가 | 흰색 → 다크 전환 |
| 50-100% | 화이트로 완전 전환 | 최대 블러 | 다크 |

## 파라미터 설명

### DynamicScrollAppBar

| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|--------|------|
| `scrollController` | `ScrollController` | 필수 | 스크롤 상태를 추적할 컨트롤러 |
| `title` | `String?` | null | 앱 바 제목 |
| `leading` | `Widget?` | null | 왼쪽 위젯 (뒤로가기 등) |
| `actions` | `List<Widget>?` | null | 오른쪽 액션 버튼들 |
| `baseColor` | `Color?` | AppColors.pointBrown | 기본 배경색 |
| `blurStartOffset` | `double` | 50.0 | 블러 시작 스크롤 위치 |
| `whiteStartOffset` | `double` | 100.0 | 화이트 전환 시작 위치 |
| `maxBlurSigma` | `double` | 10.0 | 최대 블러 강도 |

## 주의사항

1. **ScrollController 필수**: 반드시 동일한 ScrollController를 앱바와 스크롤 뷰에 전달해야 합니다.

2. **CustomScrollView 권장**: 최적의 성능을 위해 CustomScrollView 사용을 권장합니다.

3. **메모리 관리**: ScrollController의 dispose()를 잊지 마세요.

4. **접근성**: 텍스트 색상이 자동으로 조정되므로 별도 설정이 불필요합니다.

## 예제

전체 예제는 `lib/shared/examples/dynamic_app_bar_demo_screen.dart`를 참고하세요.

## 성능 고려사항

- AnimatedBuilder를 사용하여 효율적인 리빌드
- 색상 계산 최적화로 60fps 유지
- 블러 효과는 적절한 임계값에서만 적용

## 호환성

- Flutter 3.8.1+
- 모든 플랫폼 지원 (iOS, Android, Web, Desktop)
- Riverpod과 호환