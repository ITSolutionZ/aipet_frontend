# 산책 기능 개선 및 API 마이그레이션 가이드

## 📋 목차

1. [현재 상태 분석](#현재-상태-분석)
2. [발견된 문제점](#발견된-문제점)
3. [개선 사항](#개선-사항)
4. [API 마이그레이션 계획](#api-마이그레이션-계획)
5. [구현 우선순위](#구현-우선순위)

---

## 현재 상태 분석

### 📂 아키텍처 구조

```text
lib/features/walk/
├── domain/              # 도메인 레이어
│   ├── entities/       # WalkRecordEntity, WalkStatistics, WalkLocation
│   ├── repositories/   # WalkRepository 인터페이스
│   ├── usecases/       # StartWalkUseCase, EndWalkUseCase 등
│   └── services/       # WalkRouteService, WalkRecommendationService
├── data/               # 데이터 레이어
│   ├── repositories/   # WalkRepositoryImpl, WalkRepositoryMockitoImpl
│   ├── services/       # WalkRouteServiceImpl
│   └── providers/      # Riverpod providers
└── presentation/       # 프레젠테이션 레이어
    ├── screens/        # WalkListScreen, WalkDetailScreen, WalkCalendarScreen
    ├── widgets/        # MapWidget, WalkRecordCard 등
    └── controllers/    # WalkController
```

### 🗄️ 데이터 저장 현황

#### 1. 로컬 스토리지 (SharedPreferences)

- **위치**: `lib/shared/services/local_walk_storage_service.dart`
- **저장 방식**: JSON 직렬화
- **저장 항목**:
  - `walk_records`: 전체 산책 기록 목록
  - `current_walk`: 현재 진행 중인 산책

#### 2. Mock 데이터

- **위치**: `lib/shared/testing/mock_data/features/walk/walk_mock_service.dart`
- **용도**: API 연동 전 개발 및 테스트

#### 3. 현재 데이터 흐름

```text
Controller
   ↓ (직접 호출)
LocalWalkStorageService
   ↓
SharedPreferences

Repository (Mock 데이터만 반환)
   ↓
WalkMockService
```

**문제점**: Controller가 Repository를 우회하여
LocalStorageService를 직접 호출 → Clean Architecture 위반

---

## 발견된 문제점

### 🔴 1. Repository 구현 불완전

#### 문제

`WalkRepositoryImpl`의 핵심 메서드들이 빈 구현이거나 Mock 데이터만 반환:

```dart
// ❌ 현재 구현
@override
Future<List<WalkRecordEntity>> getAllWalkRecords() async {
  await Future.delayed(const Duration(milliseconds: 300));
  final mockData = WalkMockService.getMockWalkRecords();
  return mockData.map((data) => WalkRecordEntity.fromJson(data)).toList();
  // 로컬 저장소 데이터 무시!
}

@override
Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // 실제 저장 로직 없음!
}

@override
Future<void> updateWalkRecord(WalkRecordEntity walkRecord) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // 실제 업데이트 로직 없음!
}

@override
Future<void> deleteWalkRecord(String id) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // 실제 삭제 로직 없음!
}
```

#### 영향

- Controller가 Repository 대신 LocalWalkStorageService를 직접 호출
- 데이터 흐름의 일관성 부족
- 추후 API 연동 시 수정 범위 증가

### 🔴 2. Hybrid Repository 패턴 미적용

#### 비교: Auth & Pet Profile vs Walk

Auth/Pet Profile (적용됨)

```dart
class HybridAuthRepository {
  Future<User> login() async {
    try {
      // 1. API 시도
      final apiResult = await _apiAuthService.login(...);
      if (apiResult.isSuccess) {
        // 2. 로컬 캐시
        await _cacheUser(apiResult.data);
        return apiResult.data;
      }
    } catch (e) {
      // 3. Fallback: 로컬 캐시 확인
      final cachedUser = await _loadCachedUser();
      if (cachedUser != null) return cachedUser;
    }
  }
}
```

Walk (미적용)

```dart
class WalkRepositoryImpl {
  // Mock 데이터만 반환, 로컬 저장소 무시
  Future<List<WalkRecordEntity>>
   getAllWalkRecords() async {
    final mockData = WalkMockService.getMockWalkRecords();
    return mockData.map(...).toList();
  }
}
```

### 🔴 3. Controller의 책임 과다

```dart
class WalkController {
  Future<Result<List<WalkRecordEntity>>> getAll() async {
    // ❌ Repository를 우회하고 직접 로컬 스토리지 호출
    final localWalkRecords = await LocalWalkStorageService.loadWalkRecords();

    if (localWalkRecords.isNotEmpty) {
      ref.read(walkRecordsNotifierProvider.notifier).setWalkRecords(localWalkRecords);
      return Result.success(...);
    }

    // Repository는 나중에 호출
    final walkRecords = await _getAllWalkRecordsUseCase();
  }
}
```

**문제점**:

- Controller가 데이터 소스 선택 로직 포함 (Repository의 역할)
- 테스트 어려움
- 코드 중복 (여러 메서드에서 반복)

### 🔴 4. 위치 추적 최적화 부족

```dart
class MapWidget {
  Future<void> getCurrentLocation() async {
    // ✅ 최근 개선: LocationCacheService 적용
    final cachedPosition = _locationCache.getCachedPosition();
    if (cachedPosition != null) {
      state = state.copyWith(currentPosition: cachedPosition);
      return;
    }
    // GPS 호출
  }
}
```

**현재 상태**:

- ✅ 위치 캐싱 구현 완료 (30초 TTL)
- ✅ 반복적인 GPS 호출 방지
- ⚠️ 산책 경로 추적 시 배터리 최적화 추가 검토 필요

### 🔴 5. UI 일관성 문제

#### 최근 개선 사항 (✅ 완료)

1. **산책 수정 미반영 문제**

   - 원인: `LocalWalkStorageService.updateWalkRecord()` 미호출
   - 해결: Controller에서 업데이트 후 로컬 저장소 동기화

2. **메모 필드 오버플로우**

   - 원인: 활동 JSON 데이터가 메모 필드에 표시
   - 해결: JSON 파싱 후 사용자 메모만 표시, 활동은 맵 마커로 표시

3. **Bottom Sheet 사라짐**

   - 원인: `DraggableScrollableSheet` 위치 설정 오류
   - 해결: `AnimatedContainer` + `GestureDetector` 조합으로 변경

4. **달성률 표시 추가**
   - 원인: 통계 섹션에 달성률 미표시
   - 해결: 펫별 권장 산책 시간 기준 달성률 계산 및 표시

---

## 개선 사항

### ✅ 1. 최근 완료된 개선

#### 1.1 산책 기록 수정 반영

```dart
// WalkController.updateWalkRecord()
Future<WalkResult> updateWalkRecord(WalkRecordEntity walkRecord) async {
  final result = await safeExecuteWithRetry(() async {
    await _updateWalkRecordUseCase(walkRecord);

    // Provider 상태 업데이트
    ref.read(walkRecordsNotifierProvider.notifier).updateWalkRecord(walkRecord);

    // ✅ 로컬 저장소 동기화 추가
    await LocalWalkStorageService.updateWalkRecord(walkRecord);

    return walkRecord;
  });
}
```

#### 1.2 위치 캐싱 전략

```dart
// LocationCacheService
class LocationCacheService {
  void cachePosition(Position position) {
    _cacheService.setMemoryCache<Position>(
      _cacheKey,
      position,
      ttl: CacheTTL.location, // 30초
    );
  }

  Position? getCachedPosition() {
    return _cacheService.getMemoryCache<Position>(_cacheKey);
  }
}
```

**효과**:

- GPS 호출 빈도 감소 → 배터리 수명 향상
- 지도 렌더링 속도 개선

#### 1.3 산책 기록 삭제 기능

```dart
// WalkCalendarScreen._cleanOldRecords()
Future<void> _cleanOldRecords() async {
  try {
    final walkRecords = ref.read(walkRecordsNotifierProvider);
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

    final recentRecords = walkRecords.where((record) {
      return record.startTime.isAfter(sixMonthsAgo);
    }).toList();

    if (recentRecords.length < walkRecords.length) {
      // 1. 로컬 스토리지에서 삭제
      await LocalWalkStorageService.saveWalkRecords(recentRecords);

      // 2. 상태 업데이트
      ref.read(walkRecordsNotifierProvider.notifier).setWalkRecords(recentRecords);

      // 3. 사용자 피드백
      final deletedCount = walkRecords.length - recentRecords.length;
      showSnackBar('古い記録を${deletedCount}件削除');
    }
  } catch (e) {
    handleError(e);
  }
}
```

#### 1.4 메모 및 활동 분리

```dart
// WalkEditForm
Map<String, String?> _separateNotesAndActivities(String? notes) {
  if (notes == null || notes.isEmpty) {
    return {'userNotes': '', 'activitiesJson': null};
  }

  // JSON 형식인지 확인
  if (notes.trimLeft().startsWith('[')) {
    try {
      final decoded = jsonDecode(notes);
      if (decoded is List) {
        return {'userNotes': '', 'activitiesJson': notes};
      }
    } catch (_) {}
  }

  return {'userNotes': notes, 'activitiesJson': null};
}
```

**효과**:

- 사용자 메모와 활동 데이터 명확히 분리
- 메모 필드 오버플로우 방지
- 활동 데이터는 지도 마커로 시각화

#### 1.5 달성률 계산

```dart
// WalkCalendarScreen
double _calculateAchievementRate(List<WalkRecordEntity> records, String petId) {
  if (records.isEmpty) return 0.0;

  // 펫별 권장 산책 시간 (분)
  final pet = pets.firstWhere((p) => p.id == petId);
  final recommendedMinutes = pet.recommendedWalkMinutes ?? 30;

  // 실제 산책 시간
  final totalMinutes = records.fold<int>(0, (sum, record) {
    return sum + (record.duration?.inMinutes ?? 0);
  });

  // 달성률 계산
  final achievementRate = (totalMinutes / recommendedMinutes) * 100;
  return achievementRate.clamp(0.0, 200.0); // 최대 200%
}
```

### 🚧 2. 필요한 개선 사항

#### 2.1 Hybrid Repository 패턴 적용

**목표**: Auth/Pet Profile과 동일한 패턴 적용

```dart
// 제안: HybridWalkRepository
class HybridWalkRepository implements WalkRepository {
  final WalkApiService _apiService;
  final LocalWalkStorageService _localStorage;
  final WalkMockService _mockService;

  @override
  Future<List<WalkRecordEntity>> getAllWalkRecords() async {
    try {
      // 1차: API 호출
      final apiResult = await _apiService.getAllWalkRecords();
      if (apiResult.isSuccess) {
        // 로컬 캐시 동기화
        await _localStorage.saveWalkRecords(apiResult.data);
        return apiResult.data;
      }
    } catch (e) {
      debugPrint('⚠️ API 호출 실패, 로컬 데이터 사용: $e');
    }

    // 2차: 로컬 저장소
    final localRecords = await _localStorage.loadWalkRecords();
    if (localRecords.isNotEmpty) {
      return localRecords;
    }

    // 3차: Mock 데이터 (Fallback)
    debugPrint('⚠️ 로컬 데이터 없음, Mock 데이터 사용');
    final mockData = _mockService.getMockWalkRecords();
    return mockData.map((data) => WalkRecordEntity.fromJson(data)).toList();
  }

  @override
  Future<void> saveWalkRecord(WalkRecordEntity walkRecord) async {
    try {
      // 1. 로컬 먼저 저장 (빠른 UI 반영)
      await _localStorage.addWalkRecord(walkRecord);

      // 2. API 동기화 (백그라운드)
      unawaited(_apiService.saveWalkRecord(walkRecord));
    } catch (e) {
      debugPrint('❌ 산책 기록 저장 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateWalkRecord(WalkRecordEntity walkRecord) async {
    try {
      // 로컬 업데이트
      await _localStorage.updateWalkRecord(walkRecord);

      // API 동기화
      try {
        await _apiService.updateWalkRecord(walkRecord);
      } catch (e) {
        debugPrint('⚠️ API 업데이트 실패, 나중에 재시도 필요: $e');
        // TODO: 동기화 큐에 추가
      }
    } catch (e) {
      debugPrint('❌ 산책 기록 업데이트 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteWalkRecord(String id) async {
    try {
      // 로컬 삭제
      await _localStorage.deleteWalkRecord(id);

      // API 동기화
      try {
        await _apiService.deleteWalkRecord(id);
      } catch (e) {
        debugPrint('⚠️ API 삭제 실패, 나중에 재시도 필요: $e');
        // TODO: 동기화 큐에 추가
      }
    } catch (e) {
      debugPrint('❌ 산책 기록 삭제 실패: $e');
      rethrow;
    }
  }
}
```

**이점**:

- API 오프라인 시 로컬 데이터로 Fallback
- 로컬 우선 저장으로 빠른 UI 반응
- 백그라운드 동기화로 사용자 경험 개선

#### 2.2 WalkApiService 구현

```dart
// lib/features/walk/data/services/walk_api_service.dart
class WalkApiService {
  final ApiClient _apiClient;

  WalkApiService(this._apiClient);

  /// 모든 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getAllWalkRecords() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.walks);

      if (response.isSuccess) {
        final List<dynamic> data = response.data['walks'];
        final records = data.map((json) => WalkRecordEntity.fromJson(json)).toList();
        return Result.success('산책 기록을 가져왔습니다', records);
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// 산책 시작
  Future<Result<WalkRecordEntity>> startWalk(WalkRecordEntity walkRecord) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.walks,
        data: walkRecord.toJson(),
      );

      if (response.isSuccess) {
        final record = WalkRecordEntity.fromJson(response.data);
        return Result.success('산책이 시작되었습니다', record);
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('산책 시작 실패: ${e.toString()}');
    }
  }

  /// 산책 종료
  Future<Result<WalkRecordEntity>> endWalk(
    String walkId, {
    double? distance,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.walkById(walkId),
        data: {
          'status': 'completed',
          'distance': distance,
          'notes': notes,
          'endTime': DateTime.now().toIso8601String(),
        },
      );

      if (response.isSuccess) {
        final record = WalkRecordEntity.fromJson(response.data);
        return Result.success('산책이 종료되었습니다', record);
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('산책 종료 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 업데이트
  Future<Result<WalkRecordEntity>> updateWalkRecord(
    WalkRecordEntity walkRecord,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.walkById(walkRecord.id),
        data: walkRecord.toJson(),
      );

      if (response.isSuccess) {
        final record = WalkRecordEntity.fromJson(response.data);
        return Result.success('산책 기록이 업데이트되었습니다', record);
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('산책 기록 업데이트 실패: ${e.toString()}');
    }
  }

  /// 산책 기록 삭제
  Future<Result<void>> deleteWalkRecord(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.walkById(id));

      if (response.isSuccess) {
        return Result.success('산책 기록이 삭제되었습니다');
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('산책 기록 삭제 실패: ${e.toString()}');
    }
  }

  /// 펫별 산책 기록 조회
  Future<Result<List<WalkRecordEntity>>> getWalkRecordsByPetId(
    String petId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.walks,
        queryParameters: {'petId': petId},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data['walks'];
        final records = data.map((json) => WalkRecordEntity.fromJson(json)).toList();
        return Result.success('펫 산책 기록을 가져왔습니다', records);
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('펫 산책 기록 조회 실패: ${e.toString()}');
    }
  }

  /// 산책 통계 조회
  Future<Result<WalkStatistics>> getWalkStatistics({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (petId != null) queryParams['petId'] = petId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '${ApiEndpoints.walks}/statistics',
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        final stats = WalkStatistics.fromJson(response.data);
        return Result.success('산책 통계를 가져왔습니다', stats);
      }

      return Result.failure(response.message ?? 'API 호출 실패');
    } catch (e) {
      return Result.failure('산책 통계 조회 실패: ${e.toString()}');
    }
  }
}
```

#### 2.3 배터리 최적화

```dart
// lib/features/walk/domain/services/walk_tracking_optimizer.dart (기존 개선)
class WalkTrackingOptimizer {
  // 배터리 절약 모드 설정
  static LocationSettings get batteryOptimizedSettings => const LocationSettings(
    accuracy: LocationAccuracy.medium,  // GPS 정확도 중간 (배터리 절약)
    distanceFilter: 10,                 // 10m 이동 시에만 업데이트
    timeLimit: Duration(seconds: 30),   // 30초 타임아웃
  );

  // 고정밀 모드 설정 (짧은 산책)
  static LocationSettings get highAccuracySettings => const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    timeLimit: Duration(seconds: 10),
  );

  // 적응형 설정: 속도에 따라 자동 조정
  static LocationSettings getAdaptiveSettings(double currentSpeed) {
    if (currentSpeed > 5.0) {
      // 빠른 속도 (달리기): 더 자주 업데이트
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    } else if (currentSpeed > 1.5) {
      // 중간 속도 (빠른 걸음): 표준 업데이트
      return const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      );
    } else {
      // 느린 속도 (천천히 걷기): 배터리 절약
      return const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 15,
      );
    }
  }
}
```

**사용 예시**:

```dart
// WalkController
void _startLocationTracking() {
  final settings = WalkTrackingOptimizer.batteryOptimizedSettings;

  Geolocator.getPositionStream(locationSettings: settings).listen((position) {
    final location = WalkLocation.fromPosition(position);
    addLocationToCurrentWalk(location);
  });
}
```

#### 2.4 동기화 큐 구현

```dart
// lib/shared/services/sync_queue_service.dart
class SyncQueueService {
  static const String _queueKey = 'pending_sync_operations';

  /// 동기화 대기 작업 추가
  Future<void> addToQueue(SyncOperation operation) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    queue.add(operation.toJson());
    await prefs.setString(_queueKey, jsonEncode(queue));

    debugPrint('📥 동기화 큐에 추가: ${operation.type} - ${operation.id}');
  }

  /// 동기화 처리
  Future<void> processPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null || queueJson == '[]') return;

    final List<dynamic> queue = jsonDecode(queueJson);
    final failedOperations = <Map<String, dynamic>>[];

    for (final operationJson in queue) {
      final operation = SyncOperation.fromJson(operationJson);

      try {
        await _executeOperation(operation);
        debugPrint('✅ 동기화 완료: ${operation.type} - ${operation.id}');
      } catch (e) {
        debugPrint('❌ 동기화 실패: ${operation.type} - ${operation.id}: $e');
        failedOperations.add(operationJson);
      }
    }

    // 실패한 작업만 큐에 다시 저장
    await prefs.setString(_queueKey, jsonEncode(failedOperations));
  }

  Future<void> _executeOperation(SyncOperation operation) async {
    switch (operation.type) {
      case 'create':
        await _apiService.saveWalkRecord(operation.data);
        break;
      case 'update':
        await _apiService.updateWalkRecord(operation.data);
        break;
      case 'delete':
        await _apiService.deleteWalkRecord(operation.id);
        break;
    }
  }
}

class SyncOperation {
  final String id;
  final String type; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'],
    type: json['type'],
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
```

---

## API 마이그레이션 계획

### 📡 API 엔드포인트

#### 기존 정의 (ApiConstants)

```dart
// ✅ 이미 정의됨
static const String walks = '/walks';
static String walkById(String id) => '$walks/$id';
static const String walkHistory = '$walks/history';
```

#### 추가 필요 엔드포인트

```dart
// 추가 제안
static const String walkStatistics = '$walks/statistics';
static const String walkByPet = '$walks/pet';
static String walkByPetId(String petId) => '$walkByPet/$petId';
static const String currentWalk = '$walks/current';
```

### 🗄️ API 요청/응답 모델

#### WalkRecordApiModel

```dart
// lib/features/walk/data/models/walk_record_api_model.dart
@freezed
class WalkRecordApiModel with _$WalkRecordApiModel {
  const factory WalkRecordApiModel({
    required String id,
    required String petId,
    required String petName,
    required String startTime,
    String? endTime,
    int? durationSeconds,
    double? distance,
    List<WalkLocationApiModel>? route,
    String? notes,
    required String status,
    required String createdAt,
    required String updatedAt,
  }) = _WalkRecordApiModel;

  const WalkRecordApiModel._();

  factory WalkRecordApiModel.fromJson(Map<String, dynamic> json) =>
      _$WalkRecordApiModelFromJson(json);

  // Entity 변환
  WalkRecordEntity toEntity() {
    return WalkRecordEntity(
      id: id,
      petId: petId,
      petName: petName,
      startTime: DateTime.parse(startTime),
      endTime: endTime != null ? DateTime.parse(endTime!) : null,
      duration: durationSeconds != null ? Duration(seconds: durationSeconds!) : null,
      distance: distance,
      route: route?.map((r) => r.toEntity()).toList() ?? [],
      notes: notes,
      status: WalkStatus.values.firstWhere(
        (s) => s.toString().split('.').last == status,
        orElse: () => WalkStatus.completed,
      ),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory WalkRecordApiModel.fromEntity(WalkRecordEntity entity) {
    return WalkRecordApiModel(
      id: entity.id,
      petId: entity.petId,
      petName: entity.petName,
      startTime: entity.startTime.toIso8601String(),
      endTime: entity.endTime?.toIso8601String(),
      durationSeconds: entity.duration?.inSeconds,
      distance: entity.distance,
      route: entity.route.map((l) => WalkLocationApiModel.fromEntity(l)).toList(),
      notes: entity.notes,
      status: entity.status.toString().split('.').last,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
```

### 🔄 마이그레이션 단계

#### Phase 1: 준비 단계 (완료 ✅)

- [x] `WalkApiService` 구현 ✅
- [x] `WalkRecordApiModel` 생성 (Entity 직접 사용) ✅
- [x] `HybridWalkRepository` 구현 ✅
- [x] 단위 테스트 작성 ✅
- [x] API Mock 서버 설정 ✅

#### Phase 2: 통합 단계 (완료 ✅)

- [x] `WalkController`에서 `HybridWalkRepository` 사용 ✅
- [x] 로컬 저장소 직접 호출 제거 ✅
- [x] 동기화 큐 서비스 통합 ✅
- [ ] 통합 테스트 작성

#### Phase 3: 테스트 단계 (1주)

#### Phase 4: 배포 단계

- [ ] Staging 환경 배포
- [ ] 베타 테스트 (일부 사용자)
- [ ] 피드백 수집 및 개선
- [ ] Production 배포

---

## 구현 우선순위

### 🔥 High Priority (즉시 필요)

1. **HybridWalkRepository 구현**

   - 현재: Controller가 직접 LocalStorage 호출
   - 목표: Repository 패턴 준수, API 준비

2. **WalkApiService 구현**

   - API 연동 준비
   - Result 패턴 적용
   - 에러 핸들링 표준화

3. **동기화 큐 서비스**
   - 오프라인 작업 저장
   - 온라인 복귀 시 자동 동기화
   - 충돌 해결 전략

### ⚠️ Medium Priority (다음 스프린트)

1. **배터리 최적화**

   - 적응형 위치 추적 설정
   - 백그라운드 위치 추적 최적화
   - 배터리 사용량 모니터링

2. **경로 최적화**
   - 불필요한 포인트 제거
   - Polyline 압축
   - 메모리 사용량 최적화

### 📌 Low Priority (향후 개선)

1. **실시간 동기화**

   - WebSocket 연동
   - 실시간 산책 공유 기능
   - 다중 기기 동기화

2. **분석 기능 강화**
   - ML 기반 산책 패턴 분석
   - 건강 지표 연동
   - 맞춤형 산책 추천

---

## 📝 참고 자료

### 관련 문서

- [API 마이그레이션 계획](./LOCAL_TO_API_MIGRATION_PLAN.md)
- [Clean Architecture 가이드](../CODEBASE_ANALYSIS.md)
- [에러 처리 전략](../lib/shared/foundation/error_handler/README.md)

### 관련 파일

- **Repository**: `lib/features/walk/data/repositories/walk_repository_impl.dart`
- **Controller**: `lib/features/walk/presentation/controllers/walk_controller.dart`
- **Local Storage**: `lib/shared/services/local_walk_storage_service.dart`
- **API Constants**: `lib/shared/core/api/api_constants.dart`

### 유사 구현 참고

- **Auth Hybrid Repository**: `lib/features/auth/data/repositories/hybrid_auth_repository.dart`
- **Pet Profile Hybrid Repository**:
  `lib/features/pet_profile/data/repositories/hybrid_pet_profile_repository.dart`

---

## ✅ 체크리스트

### 코드 품질

- [x] 로컬 저장소 동기화 구현
- [x] 위치 캐싱 전략 적용
- [x] 산책 기록 삭제 기능
- [x] 메모/활동 분리
- [x] 달성률 계산
- [x] **Hybrid Repository 패턴 적용** ✅ **NEW!**
- [x] **API Service 구현** ✅ **NEW!**
- [x] **WalkController 리팩토링** ✅ **NEW!**
- [x] **동기화 큐 구현** ✅ **NEW!**
- [x] **단위 테스트 작성 (30개)** ✅ **NEW!**
- [x] **API Mock 서버 설정** ✅ **NEW!**
- [ ] 통합 테스트 작성

### 성능 최적화

- [x] 위치 캐싱 (30초 TTL)
- [ ] 배터리 최적화 설정
- [ ] 경로 데이터 압축
- [ ] 메모리 사용량 모니터링

### 사용자 경험

- [x] 오프라인 모드 기본 지원
- [x] 빠른 UI 반응 (로컬 우선)
- [ ] 백그라운드 동기화
- [ ] 에러 복구 전략
- [ ] 사용자 피드백 개선

---

---

## 🎉 최근 구현 완료 (2025-10-02)

### ✅ Hybrid Repository 패턴 적용

**구현 파일**: `lib/features/walk/data/repositories/hybrid_walk_repository.dart`

#### 주요 기능

1. **3단계 Fallback 전략**

   ```dart
   // 1차: API 호출 (온라인 시)
   final apiResult = await _apiService.getAllWalkRecords();

   // 2차: 로컬 저장소 (오프라인/API 실패 시)
   final localRecords = await LocalWalkStorageService.loadWalkRecords();

   // 3차: Mock 데이터 (개발/테스트 시)
   final mockData = WalkMockService.getMockWalkRecords();
   ```

2. **로컬 우선 저장**

   - 빠른 UI 반응을 위해 로컬 먼저 저장
   - 백그라운드에서 API 동기화

3. **자동 캐싱**
   - API 성공 시 로컬 저장소 자동 동기화

### ✅ WalkApiService 구현

**구현 파일**: `lib/features/walk/data/services/walk_api_service.dart`

#### 구현된 API 메서드

- `getAllWalkRecords()` - 전체 산책 기록 조회
- `getWalkRecordById()` - ID로 산책 기록 조회
- `getWalkRecordsByPetId()` - 펫별 산책 기록 조회
- `startWalk()` - 산책 시작
- `endWalk()` - 산책 종료
- `updateWalkRecord()` - 산책 기록 업데이트
- `deleteWalkRecord()` - 산책 기록 삭제
- `getWalkStatistics()` - 산책 통계 조회
- `getCurrentWalk()` - 현재 진행 중인 산책 조회

### ✅ WalkController 리팩토링

**수정 파일**: `lib/features/walk/presentation/controllers/walk_controller.dart`

#### 주요 변경사항

**Before:**

```dart
// ❌ 로컬 저장소 직접 호출
final localWalkRecords = await LocalWalkStorageService.loadWalkRecords();
```

**After:**

```dart
// ✅ Repository를 통한 통합 접근
final walkRecords = await _getAllWalkRecordsUseCase();
// Repository가 자동으로 API, 로컬, Mock 순서로 시도
```

#### 효과

- Clean Architecture 준수
- 로컬 저장소 직접 호출 제거
- 모든 데이터 접근이 Repository를 통해 이루어짐
- API 활성화 시 코드 변경 최소화

### ✅ SyncQueueService 구현

**구현 파일**: `lib/shared/services/sync_queue_service.dart`

#### 핵심 기능

1. **오프라인 작업 큐잉**

   - API 동기화 실패 시 자동으로 큐에 저장
   - 작업 타입: Create, Update, Delete

2. **자동 재시도**

   - 최대 3회 재시도
   - 지수 백오프 방식 지연 (2초 × 재시도 횟수)

3. **중복 방지**

   - 같은 ID/타입 작업은 최신 것으로 교체

4. **통계 조회**
   - 대기 중인 작업 수
   - 타입별/엔티티별 분류
   - 가장 오래된 작업 시간

#### 사용 예시

```dart
// HybridWalkRepository에서 자동 사용
try {
  await _apiService.updateWalkRecord(walkRecord);
} catch (e) {
  // API 실패 시 큐에 자동 추가
  await _addToSyncQueue(
    SyncOperation(
      id: walkRecord.id,
      type: SyncOperationType.update,
      entityType: 'walk',
      data: walkRecord.toJson(),
      timestamp: DateTime.now(),
    ),
  );
}

// 온라인 복귀 시 수동 호출
await repository.processPendingSync();
```

### 🚀 API 활성화 방법

API 서버가 준비되면 단 한 줄만 변경:

```dart
// lib/features/walk/data/providers/walk_api_providers.dart
final hybridWalkRepositoryProvider = Provider<WalkRepository>((ref) {
  final apiService = ref.watch(walkApiServiceProvider);
  return HybridWalkRepository(
    apiService: apiService,
    useApi: true, // ✅ false → true로 변경!
  );
});
```

온라인 복귀 시 자동 동기화:

```dart
// 네트워크 상태 변경 감지
connectivity.onConnectivityChanged.listen((result) {
  if (result != ConnectivityResult.none) {
    // 온라인 복귀 시 대기 중인 작업 처리
    final repository = ref.read(hybridWalkRepositoryProvider);
    if (repository is HybridWalkRepository) {
      repository.processPendingSync();
    }
  }
});
```

### ✅ 단위 테스트 작성

**테스트 파일**:

1. `test/features/walk/data/services/walk_api_service_test.dart` (10개 테스트)
2. `test/features/walk/data/repositories/hybrid_walk_repository_test.dart` (12개 테스트)
3. `test/shared/services/sync_queue_service_test.dart` (8개 테스트)

**총 30개 테스트 - 100% 통과** ✅

#### 테스트 범위

- **WalkApiService**: 모든 API 메서드 (GET, POST, PUT, DELETE)
- **HybridWalkRepository**: API 활성화/비활성화 모드, Fallback 전략
- **SyncQueueService**: 큐 추가, 처리, 재시도, 통계

#### 실행 결과

```bash
flutter test test/features/walk/... test/shared/services/...
# All tests passed! ✅
```

### ✅ API Mock 서버 설정

**구현 파일**:

- `lib/shared/testing/mock_server/walk_mock_server.dart`
- `lib/shared/testing/mock_server/mock_api_interceptor.dart`

#### Mock 서버 특징

1. **Dio Interceptor 기반**: 실제 API 요청을 가로채서 Mock 응답 반환
2. **인메모리 저장소**: 세션 동안 데이터 유지
3. **실제 API와 동일한 응답 형식**
4. **네트워크 지연 시뮬레이션**: 200-500ms 랜덤 지연

#### 활성화 방법

```dart
// 개발 환경에서 활성화
final apiClient = ApiClient(useMockServer: kDebugMode);

// Mock 서버 초기화
WalkMockServer.instance.initialize();
```

---

**최종 업데이트**: 2025-10-02 (Phase 1-2 완료 + 테스트)
**작성자**: AI Pet Development Team
**버전**: 2.1.0
