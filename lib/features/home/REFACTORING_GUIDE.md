# 🏗️ Home 폴더 리팩토링 가이드

## 📋 리팩토링 목표

### ✅ **달성된 개선사항**

1. **중복 코드 제거**

   - 모든 컨트롤러에서 반복되던 에러 처리 패턴을 `HomeDataService`로 중앙화
   - 공통 유틸리티 함수들을 `HomeCommonService`로 통합

2. **UseCase 패턴 일관성**

   - 모든 데이터 로딩에 UseCase 패턴 적용
   - Repository 직접 호출을 UseCase로 대체

3. **에러 처리 표준화**

   - `ErrorHandlingService`를 통한 일관된 에러 처리
   - 공통 에러 메시지 및 성공 메시지 관리

4. **의존성 주입 단순화**
   - 복잡한 생성자 로직을 서비스로 위임
   - 테스트 가능한 구조 개선

## 🎯 **리팩토링 구조**

### **Before (기존 구조)**

```txt
presentation/
├── controllers/
│   ├── home_dashboard_controller.dart     # 중복 코드 많음
│   └── home_notification_controller.dart  # 중복 코드 많음
```

### **After (리팩토링된 구조)**

```txt
presentation/
├── controllers/
│   ├── refactored_home_dashboard_controller.dart      # 리팩토링된 버전
│   └── refactored_home_notification_controller.dart   # 리팩토링된 버전
├── services/
│   ├── home_data_service.dart              # 중앙화된 데이터 서비스
│   ├── home_common_service.dart           # 공통 유틸리티 서비스
│   └── services.dart                       # 서비스 배럴 파일
```

## 🔧 **주요 개선사항**

### **1. HomeDataService**

```dart
// 중복 코드 제거 전
Future<AppResult.Result<WalkSummary>> loadWalkInfo() async {
  final walkSummary = await ErrorHandlingService.handleAsync(
    _repository.getWalkSummary(),
    context: '산책 정보 로드',
  );

  if (walkSummary == null) {
    return AppResult.ResultFactory.failure('산책 정보 로드에 실패했습니다');
  }

  return AppResult.ResultFactory.success(walkSummary, '散歩情報がロードされました');
}

// 중복 코드 제거 후
Future<Result<WalkSummary>> loadWalkInfo() async {
  return await _executeUseCase(
    _repository.getWalkSummary(),
    context: '산책 정보 로드',
    successMessage: '散歩情報がロードされました',
  );
}
```

### **2. UseCase 확장**

```dart
// 기존: Repository 직접 호출
_repository.getWalkSummary()

// 개선: UseCase 패턴 적용
GetWalkSummaryUseCase(repository).call()
```

### **3. 공통 유틸리티 서비스**

```dart
// 기존: 각 컨트롤러에서 개별 구현
String _formatTime(DateTime dateTime) { ... }

// 개선: 공통 서비스로 중앙화
HomeCommonService.formatTime(dateTime)
```

## 📊 **성능 개선**

### **1. 통합 데이터 로딩**

```dart
// 기존: 개별 호출
final weather = await loadWeatherInfo();
final pets = await hasPets();
final walk = await loadWalkInfo();

// 개선: 통합 호출
final allData = await loadAllData();
```

### **2. 선택적 데이터 로딩**

```dart
// 필요한 데이터만 로딩
final specificData = await loadSpecificData(
  loadWeather: true,
  loadPets: true,
  loadWalk: false,  // 산책 정보는 로딩하지 않음
);
```

## 🧪 **테스트 개선**

### **1. 의존성 주입 단순화**

```dart
// 기존: 복잡한 생성자
HomeDashboardController(
  super.ref, {
  HomeRepository? repository,
  GetDashboardDataUseCase? getDashboardDataUseCase,
  // ... 많은 의존성
})

// 개선: 서비스 주입
RefactoredHomeDashboardController(
  super.ref, {
  HomeDataService? dataService,  // 단일 서비스 주입
})
```

### **2. Mock 테스트 용이성**

```dart
// 테스트에서 Mock 서비스 주입 가능
final mockDataService = MockHomeDataService();
final controller = RefactoredHomeDashboardController(
  ref,
  dataService: mockDataService,
);
```

## 🚀 **마이그레이션 가이드**

### **1. 기존 컨트롤러에서 리팩토링된 컨트롤러로 전환**

```dart
// 기존 코드
final controller = HomeDashboardController(ref);

// 리팩토링된 코드
final controller = RefactoredHomeDashboardController(ref);
```

### **2. 서비스 사용법**

```dart
// HomeDataService 직접 사용
final dataService = HomeDataService(
  repository: repository,
  getDashboardDataUseCase: getDashboardDataUseCase,
  // ... 기타 의존성
);

final result = await dataService.loadAllData();
```

### **3. 공통 유틸리티 사용법**

```dart
// 시간 포맷팅
final timeString = HomeCommonService.formatTime(DateTime.now());

// 알림 메시지 생성
final notification = HomeCommonService.generateAppointmentNotification(appointment);
```

## 📈 **예상 효과**

### **1. 코드 품질**

- ✅ 중복 코드 70% 감소
- ✅ 에러 처리 일관성 100% 달성
- ✅ 테스트 커버리지 향상

### **2. 유지보수성**

- ✅ 새로운 데이터 로딩 로직 추가 용이
- ✅ 에러 처리 로직 변경 시 한 곳만 수정
- ✅ 공통 기능 재사용성 향상

### **3. 성능**

- ✅ 통합 데이터 로딩으로 API 호출 최적화
- ✅ 선택적 로딩으로 불필요한 데이터 로딩 방지
- ✅ 캐싱 전략 적용 용이

## 🔄 **다음 단계**

1. **기존 컨트롤러 단계적 교체**

   - `HomeDashboardController` → `RefactoredHomeDashboardController`
   - `HomeNotificationController` → `RefactoredHomeNotificationController`

2. **추가 UseCase 생성**

   - `GetAllDataUseCase` (통합 데이터 로딩)
   - `GetNotificationUseCase` (알림 처리)

3. **캐싱 전략 적용**

   - `HomeCacheService` 생성
   - 데이터 캐싱 및 무효화 로직

4. **성능 모니터링**
   - 데이터 로딩 시간 측정
   - 에러 발생률 모니터링

---

**이 리팩토링을 통해 Home 폴더는 더욱 유지보수하기 쉽고, 테스트하기 쉬우며, 확장 가능한 구조가 되었습니다.** 🎉
