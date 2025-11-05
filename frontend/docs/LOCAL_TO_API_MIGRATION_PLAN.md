# 🔄 로컬 저장소에서 API 연계로 전환 마이그레이션 플랜

## 📋 프로젝트 현황 분석

### 현재 로컬 저장소 사용 현황

#### 1. **저장소 기술 스택**

- **SharedPreferences**: 설정, 캐시, 간단한 데이터
- **SecureStorage**: 토큰, 민감한 정보
- **Local Mock Services**: 개발용 더미 데이터
- **SQLite/Database**: 복잡한 관계형 데이터 (일부 구현됨)

#### 2. **주요 로컬 저장 영역**

```text
📁 로컬 저장소 맵핑
├── 🔐 인증 & 보안
│   ├── AccessToken/RefreshToken (SecureStorage)
│   ├── Firebase ID Token (SecureStorage)
│   └── 사용자 인증 상태 (SharedPreferences)
├── 🐕 펫 관리
│   ├── 펫 프로필 데이터 (Mock → API 전환 필요)
│   ├── 펫 등록 정보 (Mock → API 전환 필요)
│   └── 펫 이미지 (로컬 캐시 → 클라우드 스토리지)
├── 📅 스케줄링
│   ├── 급식 스케줄 (Mock → API 전환 필요)
│   ├── 급수 스케줄 (Mock → API 전환 필요)
│   └── 예약 정보 (Mock → API 전환 필요)
├── 🚶 활동 추적
│   ├── 산책 기록 (Mock → API 전환 필요)
│   ├── 운동 데이터 (Mock → API 전환 필요)
│   └── GPS 트래킹 (로컬 캐시 → API 동기화)
├── 🏥 건강 관리
│   ├── 의료 기록 (Mock → API 전환 필요)
│   ├── 예방접종 기록 (Mock → API 전환 필요)
│   └── 건강 상태 (Mock → API 전환 필요)
├── 🔔 알림 & 설정
│   ├── 알림 설정 (SharedPreferences → API 동기화)
│   ├── 앱 설정 (SharedPreferences → API 동기화)
│   └── 사용자 선호도 (SharedPreferences → API 동기화)
└── 💾 캐시 & 임시 데이터
    ├── 이미지 캐시 (로컬 유지)
    ├── API 응답 캐시 (로컬 유지)
    └── 임시 작업 데이터 (로컬 유지)
```

---

## 🎯 마이그레이션 전략

### Phase 1: 기반 구조 설정 (Week 1-2)

#### 1.1 API 클라이언트 인프라 구축

```dart
// 목표 구조
lib/shared/core/api/
├── api_client.dart              // Dio 기반 HTTP 클라이언트
├── api_interceptors.dart        // 인증, 로깅, 에러 처리
├── api_constants.dart           // 엔드포인트 상수
├── api_response_models.dart     // 공통 응답 모델
└── api_error_handler.dart       // API 에러 핸들링
```

#### 1.2 환경별 설정 관리

```dart
// lib/app/config/api_config.dart
class ApiConfig {
  static const String devBaseUrl = 'https://dev-api.aipet.com';
  static const String stagingBaseUrl = 'https://staging-api.aipet.com';
  static const String prodBaseUrl = 'https://api.aipet.com';

  static String get baseUrl {
    switch (AppConfig.current.environment) {
      case 'development': return devBaseUrl;
      case 'staging': return stagingBaseUrl;
      case 'production': return prodBaseUrl;
      default: return devBaseUrl;
    }
  }
}
```

#### 1.3 데이터 레이어 아키텍처 정의

```dart
// Repository 패턴 + Data Source 분리
abstract class DataSource {
  // 로컬 데이터 소스
  abstract class LocalDataSource {}

  // 원격 데이터 소스
  abstract class RemoteDataSource {}
}

// Repository 구현체는 둘 다 사용
class RepositoryImpl implements Repository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  // 하이브리드 로직 구현
}
```

### Phase 2: 핵심 도메인 마이그레이션 (Week 3-5)

#### 2.1 우선순위별 마이그레이션 순서

1. **🔐 인증 시스템** (Week 3)

   - 로그인/회원가입 API 연동
   - 토큰 갱신 자동화
   - 오프라인 인증 상태 관리

2. **🐕 펫 프로필 관리** (Week 3-4)

   - 펫 등록/수정/삭제 API
   - 이미지 업로드 (클라우드 스토리지)
   - 펫 정보 동기화

3. **📅 스케줄링 시스템** (Week 4-5)
   - 급식/급수 스케줄 API
   - 예약 관리 API
   - 실시간 알림 연동

#### 2.2 하이브리드 운영 전략

```dart
// 로컬 우선 + API 동기화 패턴
class HybridRepository implements Repository {
  @override
  Future<Result<T>> getData() async {
    try {
      // 1. 로컬 캐시 확인
      final localData = await _localDataSource.getCachedData();

      if (_isCacheValid(localData)) {
        // 2. 백그라운드 API 호출로 갱신
        _refreshDataInBackground();
        return Success(localData);
      }

      // 3. API 호출 및 로컬 저장
      final apiData = await _remoteDataSource.fetchData();
      await _localDataSource.saveData(apiData);

      return Success(apiData);
    } catch (e) {
      // 4. 오프라인 폴백
      final fallbackData = await _localDataSource.getLastKnownData();
      return fallbackData != null
          ? Success(fallbackData)
          : Failure(OfflineError());
    }
  }
}
```

### Phase 3: 고급 기능 및 최적화 (Week 6-8)

#### 3.1 오프라인 지원 & 동기화

```dart
// 동기화 전략
class SyncManager {
  // 1. 즉시 동기화 (실시간 중요 데이터)
  Future<void> syncImmediately(SyncItem item) async {}

  // 2. 배치 동기화 (성능 최적화)
  Future<void> scheduleBatchSync() async {}

  // 3. 충돌 해결 전략
  Future<void> resolveConflicts() async {}
}
```

#### 3.2 성능 최적화

- **페이지네이션**: 대용량 데이터 분할 로딩
- **Incremental Sync**: 변경된 데이터만 동기화
- **Background Sync**: 백그라운드 동기화
- **Smart Caching**: 지능형 캐시 전략

#### 3.3 모니터링 & 분석

```dart
// API 성능 모니터링
class ApiAnalytics {
  void trackApiCall(String endpoint, Duration responseTime) {}
  void trackCacheHitRate(String dataType, double hitRate) {}
  void trackSyncSuccess(String syncType, bool success) {}
}
```

---

## 🛠️ 구현 가이드라인

### 1. Feature Flag 시스템

```dart
// 단계적 전환을 위한 피처 플래그
class FeatureFlags {
  static bool get useApiForPetData =>
      AppConfig.current.isApiEnabled('pet_data');

  static bool get useApiForScheduling =>
      AppConfig.current.isApiEnabled('scheduling');

  // 환경별/사용자별 A/B 테스트 가능
}
```

### 2. 마이그레이션 체크리스트

#### ✅ API 연동 전 체크포인트

- [ ] API 스펙 문서 확정
- [ ] 인증 방식 합의 (JWT, OAuth 등)
- [ ] 에러 코드 정의
- [ ] Rate Limiting 정책 확인
- [ ] 데이터 스키마 일치성 검증

#### ✅ 개발 단계별 체크리스트

- [x] **설계 단계**

  - [x] API 엔드포인트 설계
  - [x] 데이터 모델 매핑
  - [x] 에러 처리 전략 수립
  - [x] 캐시 전략 설계

- [x] **구현 단계**

  - [x] Remote Data Source 구현
  - [x] Repository 하이브리드 로직 구현
  - [x] 에러 처리 및 재시도 로직
  - [ ] 단위/통합 테스트 작성

- [ ] **테스트 단계**
  - [ ] 네트워크 상태별 테스트
  - [ ] 동시성 처리 테스트
  - [ ] 성능 테스트 (응답시간, 메모리)
  - [ ] 사용자 시나리오 테스트

### 3. 데이터 무결성 보장

```dart
// 데이터 일관성 검증
class DataValidator {
  bool validateDataIntegrity(LocalData local, RemoteData remote) {
    // 체크섬, 타임스탬프 등으로 무결성 검증
    return local.checksum == remote.checksum &&
           local.version <= remote.version;
  }
}
```

---

## 📊 마이그레이션 모니터링

### 1. 성공 지표 (KPI)

- **API 응답 시간**: 평균 < 500ms
- **캐시 적중률**: > 80%
- **오프라인 복구율**: > 95%
- **데이터 동기화 성공률**: > 99%
- **앱 크래시율**: < 0.1%

### 2. 모니터링 대시보드

```dart
// 실시간 메트릭 수집
class MigrationMetrics {
  static void recordApiLatency(String endpoint, Duration latency) {}
  static void recordCachePerformance(String operation, bool success) {}
  static void recordSyncConflict(String entityType, String resolution) {}
}
```

### 3. 롤백 전략

```dart
// 긴급 롤백 메커니즘
class EmergencyRollback {
  Future<void> rollbackToLocalMode() async {
    FeatureFlags.disableAllApiFeatures();
    await _clearCorruptedCache();
    await _notifyUserOfFallback();
  }
}
```

---

## 🚀 실행 타임라인

### Week 1-2: 인프라 구축

- API 클라이언트 설정
- 환경 설정 및 CI/CD 파이프라인
- 기본 아키텍처 구현

### Week 3-4: 핵심 기능 마이그레이션

- 인증 시스템 API 연동
- 펫 프로필 관리 API 연동
- 기본 CRUD 작업 API 전환

### Week 5-6: 고급 기능 구현

- 스케줄링 시스템 API 연동
- 실시간 동기화 구현
- 오프라인 지원 강화

### Week 7-8: 최적화 및 안정화

- 성능 최적화
- 종합 테스트 및 버그 수정
- 모니터링 시스템 구축

---

## ⚠️ 위험 요소 및 대응책

### 1. 기술적 위험

- **API 응답 지연** → 타임아웃 설정, 재시도 로직
- **네트워크 불안정** → 오프라인 모드, 큐잉 시스템
- **데이터 손실** → 백업 전략, 트랜잭션 관리

### 2. 사용자 경험 위험

- **로딩 시간 증가** → 프리로딩, 스켈레톤 UI
- **오프라인 기능 제한** → 명확한 상태 표시
- **데이터 불일치** → 동기화 상태 UI

### 3. 비즈니스 위험

- **마이그레이션 지연** → 단계적 출시 전략
- **사용자 이탈** → A/B 테스트, 점진적 전환
- **운영 비용 증가** → 비용 최적화 전략

---

## ✅ 진행 상황 업데이트 (2025-10-02)

### 완료된 작업

#### Phase 1: API 클라이언트 인프라 구축 ✅ COMPLETED

- [x] **API 클라이언트 기본 구조** (`shared/core/api/api_client.dart`)

  - Dio 기반 HTTP 클라이언트 with CRUD operations
  - BaseOptions, 타임아웃, 헤더 설정 완료
  - File upload, pagination 지원

- [x] **API 인터셉터 구현** (`shared/core/api/api_interceptors.dart`)

  - **AuthInterceptor**: 자동 토큰 첨부 및 401 에러 시 토큰 갱신
  - **LoggingInterceptor**: 상세한 요청/응답 로깅
  - **ErrorInterceptor**: 포괄적 에러 처리 및 변환
  - **RetryInterceptor**: 네트워크 실패 시 자동 재시도

- [x] **환경별 설정 관리** (`shared/core/api/api_config.dart`)

  - Environment-specific API URLs
  - Timeout configurations
  - Debug settings

- [x] **데이터 레이어 아키텍처** (`shared/core/data/`)
  - **ResultState pattern**: Success/Failure with error handling
  - **BaseRemoteDataSource**: 공통 API 작업 추상화
  - **ApiErrorHandler**: 통합 에러 처리

#### Phase 2: 인증 시스템 API 연동 ✅ COMPLETED

- [x] **인증 API 서비스** (`features/auth/data/services/api_auth_service.dart`)

  - Login, register, logout API endpoints
  - Email verification, password reset
  - Profile management APIs

- [x] **토큰 관리 시스템** (`features/auth/data/services/token_manager_service.dart`)

  - JWT 토큰 생명주기 관리
  - 자동 토큰 갱신 스케줄링
  - 만료 임박 감지 및 백그라운드 갱신

- [x] **오프라인 인증 상태 관리** (`features/auth/data/services/offline_auth_state_manager.dart`)
  - 네트워크 상태 모니터링
  - Online/Offline/Hybrid 모드 자동 전환
  - 캐시된 사용자 정보 관리

- [x] **하이브리드 인증 리포지토리** (`features/auth/data/repositories/hybrid_auth_repository.dart`)
  - **Firebase Auth 호환**: 기존 AuthRepository 인터페이스 완전 구현
  - **API Auth 통합**: 새로운 API 인증 시스템과 연동
  - **오프라인 지원**: 네트워크 없이도 캐시된 인증 정보로 작동
  - **자동 폴백**: API → Firebase → 오프라인 순서로 시도

#### Phase 3: 펫 프로필 API 연동 ✅ COMPLETED

- [x] **펫 프로필 데이터 모델** (`features/pet_profile/data/models/pet_profile_api_model.dart`)

  - Freezed 기반 불변 데이터 모델
  - JSON serialization/deserialization
  - Domain entity 변환 로직

- [x] **펫 API 서비스** (`features/pet_profile/data/services/pet_api_service.dart`)

  - CRUD operations: getAllPets, getPetById, createPet, updatePet, deletePet
  - Image upload integration
  - Family sharing and permission management
  - Bulk operations and search functionality

- [x] **이미지 업로드 시스템** (`features/pet_profile/data/services/pet_image_upload_service.dart`)

  - 다중 품질 옵션 (low, medium, high, original)
  - 자동 이미지 압축 및 리사이징
  - 로컬 캐시 및 메타데이터 추출
  - 파일 검증 및 형식 지원

- [x] **펫 데이터 동기화 시스템** (`features/pet_profile/data/services/pet_sync_service.dart`)

  - **양방향 동기화**: Local ↔ Remote with conflict resolution
  - **네트워크 감지**: 자동 연결 상태 모니터링 및 동기화 트리거
  - **오프라인 지원**: Pending changes queue for offline operations
  - **충돌 해결**: Last modified wins, remote wins, local wins 전략

- [x] **하이브리드 리포지토리** (`features/pet_profile/data/repositories/hybrid_pet_profile_repository.dart`)
  - **Seamless fallback**: API → Cache → Local mock data
  - **Network resilience**: 네트워크 상태에 따른 자동 전환
  - **기존 인터페이스 호환**: PetProfileRepository 완전 구현
  - **확장 기능**: Sync monitoring, manual sync triggers

### 구현된 핵심 기능

#### 🔄 지능형 동기화 시스템

```dart
// 자동 네트워크 감지 및 동기화
final syncStatus = hybridRepo.syncStatusStream;
final needsSync = await hybridRepo.needsSync();
await hybridRepo.forceSyncAllData();
```

#### 🔀 하이브리드 데이터 전략

```dart
// API 우선 → 캐시 폴백 → 로컬 모크 순서
final pets = await hybridRepo.getAllPets(); // 네트워크 상태 자동 감지
```

#### 🏃‍♂️ 오프라인 우선 아키텍처

- 네트워크 없이도 모든 CRUD 작업 지원
- 연결 복구 시 자동 동기화
- 지능형 충돌 해결

### 다음 단계 (Phase 4)

- [ ] 스케줄링 시스템 API 연동
- [ ] 활동 추적 시스템 API 연동
- [ ] 건강 관리 시스템 API 연동
- [ ] 종합 테스트 및 성능 최적화

---

## 🎯 성공을 위한 권장사항

### 1. 점진적 마이그레이션

- 한 번에 모든 기능을 전환하지 말고 단계적으로 진행
- Feature Flag를 활용한 안전한 롤아웃
- 사용자 피드백을 반영한 개선

### 2. 철저한 테스트

- 다양한 네트워크 환경에서의 테스트
- 경계 조건 및 에러 시나리오 테스트
- 실제 사용자 환경과 유사한 조건에서의 부하 테스트

### 3. 사용자 중심 설계

- 네트워크 상태에 대한 명확한 피드백
- 오프라인에서도 핵심 기능 사용 가능
- 데이터 동기화 과정의 투명성

---

이 플랜을 통해 안정적이고 효율적인 로컬-API 전환을 실현할 수 있습니다.
각 단계별로 충분한 테스트와 검증을 거쳐 사용자 경험을 최우선으로
고려하면서 진행하시기 바랍니다.
