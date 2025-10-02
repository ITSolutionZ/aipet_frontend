# Mock API Server

개발 및 테스트 환경에서 실제 API 서버 없이 동작하도록 Mock 응답을 제공하는 서버입니다.

## 📂 구조

```text
lib/shared/testing/mock_server/
├── mock_api_interceptor.dart  # Dio Interceptor (API 요청 가로채기)
├── walk_mock_server.dart      # Walk API Mock 서버
└── mock_server.dart           # Barrel file
```

## 🚀 사용 방법

### 1. 개발 환경에서 활성화

```dart
// lib/shared/core/api/api_client.dart
final apiClient = ApiClient(useMockServer: true); // Mock 서버 활성화
```

### 2. Provider 설정

```dart
// lib/shared/core/api/api_client.dart
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    useMockServer: kDebugMode, // 디버그 모드에서만 Mock 사용
  );
  ref.onDispose(() => client.dispose());
  return client;
});
```

### 3. 테스트에서 사용

```dart
test('API 호출 테스트', () async {
  // Arrange
  WalkMockServer.instance.initialize();
  final apiClient = ApiClient(useMockServer: true);
  final walkApiService = WalkApiService(apiClient);

  // Act
  final result = await walkApiService.getAllWalkRecords();

  // Assert
  expect(result.isSuccess, true);
});
```

## 📡 지원되는 API

### Walk API

| Method | Endpoint              | 설명                |
| ------ | --------------------- | ------------------- |
| GET    | `/walks`              | 전체 산책 기록 조회 |
| GET    | `/walks/:id`          | 특정 산책 기록 조회 |
| GET    | `/walks?petId=:petId` | 펫별 산책 기록 조회 |
| GET    | `/walks/current`      | 현재 진행 중인 산책 |
| GET    | `/walks/statistics`   | 산책 통계           |
| POST   | `/walks`              | 산책 시작           |
| PUT    | `/walks/:id`          | 산책 기록 업데이트  |
| DELETE | `/walks/:id`          | 산책 기록 삭제      |

## 🔧 커스터마이징

### Mock 데이터 추가

```dart
// WalkMockServer 초기화 시 데이터 추가
final mockServer = WalkMockServer.instance;
mockServer.initialize();

// 커스텀 데이터 추가
mockServer._walkRecords.add({
  'id': 'custom-1',
  'petId': 'pet-1',
  'petName': 'Custom Pet',
  'startTime': DateTime.now().toIso8601String(),
  'status': 'completed',
  // ...
});
```

### 지연 시뮬레이션

Mock 서버는 200-500ms 랜덤 지연을 시뮬레이션하여
실제 네트워크 환경과 유사한 경험을 제공합니다.

## ⚠️ 주의사항

1. **프로덕션 빌드에서 제거**

   - Mock 서버 코드는 프로덕션 빌드에 포함되지 않도록 주의
   - `kDebugMode` 또는 환경 변수로 제어

2. **데이터 초기화**

   - 테스트 간 데이터 격리를 위해 `reset()` 메서드 사용
   - `setUp()`에서 초기화 권장

3. **제한사항**
   - 인메모리 저장소 사용 (앱 재시작 시 초기화)
   - 복잡한 비즈니스 로직 시뮬레이션 제한

## 🎯 향후 확장

- [ ] Auth Mock 서버 추가
- [ ] Pet Profile Mock 서버 추가
- [ ] Feeding Mock 서버 추가
- [ ] WebSocket Mock 지원
- [ ] 에러 시나리오 시뮬레이션 (네트워크 오류, 타임아웃 등)
