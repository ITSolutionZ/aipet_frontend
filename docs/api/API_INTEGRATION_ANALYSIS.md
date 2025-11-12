# 🔄 백엔드-프론트엔드 API 통합 분석 보고서

## 📊 요약

프론트엔드(Flutter)에서 로컬 저장소로 구현된 기능들과 백엔드 API 현황을 분석한 결과, **백엔드 API는 이미 대부분 구현되어 있으며**, 프론트엔드에서 백엔드 API Service만 생성하면 바로 연동 가능합니다.

---

## ✅ 백엔드 API 현황 (완전 구현됨)

### 1. Pet API (`/api/v1/pets`)

| 메서드 | 엔드포인트 | 설명 | Swagger |
|--------|-----------|------|---------|
| GET | `/api/v1/pets` | 펫 목록 조회 | ✅ |
| GET | `/api/v1/pets/:id` | 펫 상세 조회 | ✅ |
| POST | `/api/v1/pets` | 펫 생성 | ✅ |
| PUT | `/api/v1/pets/:id` | 펫 수정 | ✅ |
| DELETE | `/api/v1/pets/:id` | 펫 삭제 | ✅ |
| GET | `/api/v1/pets/stats` | 펫 통계 | ✅ |

### 2. Health API (`/api/v1/health`)

#### 예방접종 (Vaccinations)
| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/health/pets/:petId/vaccinations` | 예방접종 기록 조회 |
| POST | `/api/v1/health/pets/:petId/vaccinations` | 예방접종 기록 생성 |
| PUT | `/api/v1/health/pets/:petId/vaccinations/:vaccinationId` | 예방접종 기록 수정 |
| DELETE | `/api/v1/health/pets/:petId/vaccinations/:vaccinationId` | 예방접종 기록 삭제 |

#### 의료 기록 (Medical Records)
| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/health/pets/:petId/medical-records` | 의료 기록 조회 |
| POST | `/api/v1/health/pets/:petId/medical-records` | 의료 기록 생성 |
| PUT | `/api/v1/health/pets/:petId/medical-records/:recordId` | 의료 기록 수정 |
| DELETE | `/api/v1/health/pets/:petId/medical-records/:recordId` | 의료 기록 삭제 |

#### 체중 기록 (Weight History)
| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/health/pets/:petId/weight-history` | 체중 기록 조회 |
| POST | `/api/v1/health/pets/:petId/weight-history` | 체중 기록 생성 |

### 3. Activity API (`/api/v1/activity`)

#### 산책 (Walks)
| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/activity/pets/:petId/walks` | 산책 기록 조회 |
| POST | `/api/v1/activity/pets/:petId/walks` | 산책 기록 생성 |
| PUT | `/api/v1/activity/pets/:petId/walks/:walkId` | 산책 기록 수정 |
| DELETE | `/api/v1/activity/pets/:petId/walks/:walkId` | 산책 기록 삭제 |
| GET | `/api/v1/activity/pets/:petId/walks/stats` | 산책 통계 |

#### 급식 (Feedings) **⭐ 이미 구현됨!**
| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/activity/pets/:petId/feedings` | 급식 기록 조회 |
| POST | `/api/v1/activity/pets/:petId/feedings` | 급식 기록 생성 |
| PUT | `/api/v1/activity/pets/:petId/feedings/:feedingId` | 급식 기록 수정 |
| DELETE | `/api/v1/activity/pets/:petId/feedings/:feedingId` | 급식 기록 삭제 |
| GET | `/api/v1/activity/pets/:petId/feedings/stats` | 급식 통계 |

#### 기타 활동 (Activities)
| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/activity/pets/:petId/activities` | 활동 기록 조회 |
| POST | `/api/v1/activity/pets/:petId/activities` | 활동 기록 생성 |

### 4. Notification API (`/api/v1/notifications`)

| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| GET | `/api/v1/notifications` | 알림 목록 조회 |
| POST | `/api/v1/notifications` | 알림 생성 (스케줄링) |
| GET | `/api/v1/notifications/unread-count` | 읽지 않은 알림 개수 |
| PUT | `/api/v1/notifications/mark-all-read` | 모든 알림 읽음 처리 |
| PUT | `/api/v1/notifications/:notificationId/read` | 알림 읽음 처리 |
| DELETE | `/api/v1/notifications/:notificationId` | 알림 삭제 |
| POST | `/api/v1/notifications/push` | FCM 푸시 알림 전송 |
| POST | `/api/v1/notifications/fcm-token` | FCM 토큰 저장 |

### 5. Auth API (`/api/v1/auth`, `/api/v1/users`)

| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| POST | `/api/v1/auth/verify-token` | Firebase ID Token 검증 |
| GET | `/api/v1/auth/me` | 현재 사용자 정보 조회 |
| POST | `/api/v1/users` | 사용자 생성/동기화 |
| POST | `/api/v1/auth/logout` | 로그아웃 |

---

## 📱 프론트엔드 현황 분석

### ✅ 백엔드 API Service 구현 완료

| 기능 | 파일 | 백엔드 연동 | 상태 |
|------|------|-----------|------|
| Pet | `backend_pet_api_service.dart` | `/api/v1/pets` | ✅ 완전 연동 |
| Health | `backend_health_api_service.dart` | `/api/v1/health` | ⚠️ 확인 필요 |
| Schedule | `backend_schedule_api_service.dart` | 미확인 | ⚠️ 확인 필요 |
| Walk | `backend_walk_api_service.dart` | `/api/v1/activity/walks` | ⚠️ 확인 필요 |

### ❌ 백엔드 API Service 미생성 (생성 필요)

| 기능 | 로컬 서비스 | 백엔드 API | 생성할 파일 | 우선순위 |
|------|------------|-----------|-----------|---------|
| **Feeding** | `pet_feeding_local_storage_service.dart` | ✅ `/api/v1/activity/feedings` | `backend_feeding_api_service.dart` | 🔴 HIGH |
| **Notification** | `notification_local_storage_service.dart` | ✅ `/api/v1/notifications` | `backend_notification_api_service.dart` | 🔴 HIGH |
| **Activity** | (기타 활동) | ✅ `/api/v1/activity/activities` | 기존 Walk 서비스에 통합 | 🟡 MEDIUM |
| **Settings/User** | `local_user_service.dart` | ✅ `/api/v1/auth`, `/api/v1/users` | `backend_user_api_service.dart` | 🟡 MEDIUM |

### 🟢 백엔드 API 불필요 (외부 API 사용)

| 기능 | 로컬 서비스 | 이유 |
|------|------------|------|
| Facility | `facility_local_storage_service.dart` | Google Maps/Kakao API 직접 사용 |
| AI | `ai_local_storage_service.dart` | OpenAI API 직접 사용 |
| Daily/Reservation | `reservation_local_storage_service.dart` | Schedule/Activity API로 커버 가능 |

---

## 🎯 작업 계획

### Phase 1: 즉시 구현 (HIGH Priority) 🔴

#### 1. Feeding API 연동

**백엔드:** ✅ 이미 구현됨 (`activity.routes.js`, `activity.controller.js`)

**프론트엔드 작업:**
```dart
// 1. Backend API Service 생성
frontend/lib/features/pet_feeding/data/services/
└── backend_feeding_api_service.dart  ← NEW

// 2. Repository 수정
frontend/lib/features/pet_feeding/data/repositories/
└── feeding_repository.dart           ← 백엔드 API 사용하도록 수정

// 3. Provider 연동
frontend/lib/features/pet_feeding/data/providers/
└── feeding_providers.dart            ← BackendFeedingApiService 사용
```

**엔드포인트:**
- `GET /api/v1/activity/pets/:petId/feedings`
- `POST /api/v1/activity/pets/:petId/feedings`
- `PUT /api/v1/activity/pets/:petId/feedings/:feedingId`
- `DELETE /api/v1/activity/pets/:petId/feedings/:feedingId`
- `GET /api/v1/activity/pets/:petId/feedings/stats`

#### 2. Notification API 연동

**백엔드:** ✅ 이미 구현됨 (`notification.routes.js`, `notification.controller.js`)

**프론트엔드 작업:**
```dart
// 1. Backend API Service 생성
frontend/lib/features/notification/data/services/
└── backend_notification_api_service.dart  ← NEW

// 2. Repository 수정
frontend/lib/features/notification/data/repositories/
└── notification_repository.dart           ← 백엔드 API 사용하도록 수정
```

#### 3. Health API 연동 확인 및 완료

**백엔드:** ✅ 이미 구현됨

**프론트엔드 작업:**
```dart
// 1. 기존 backend_health_api_service.dart 확인
// 2. Repository가 Backend API 사용하는지 확인
// 3. 필요시 수정
```

### Phase 2: 단계적 구현 (MEDIUM Priority) 🟡

#### 4. Walk API 연동 완료

```dart
// 기존 backend_walk_api_service.dart 확인 및 보완
// Repository 연동 확인
```

#### 5. Schedule API 확인

```dart
// backend_schedule_api_service.dart가 어떤 API를 사용하는지 확인
// 필요시 Activity API 또는 별도 API 사용
```

#### 6. User/Settings API 연동

```dart
// backend_user_api_service.dart 생성
// Auth API와 Users API 통합
```

---

## 📋 생성 필요한 프론트엔드 파일 목록

### 🔴 즉시 생성 필요 (HIGH)

```
frontend/lib/features/
├── pet_feeding/data/services/
│   └── backend_feeding_api_service.dart        ❌ NEW
├── notification/data/services/
│   └── backend_notification_api_service.dart   ❌ NEW
```

### 🟡 확인 후 수정 (MEDIUM)

```
frontend/lib/features/
├── pet_health/data/services/
│   └── backend_health_api_service.dart         ⚠️ VERIFY
├── walk/data/services/
│   └── backend_walk_api_service.dart           ⚠️ VERIFY
├── scheduling/data/services/
│   └── backend_schedule_api_service.dart       ⚠️ VERIFY
├── settings/data/services/
│   └── backend_user_api_service.dart           ❌ NEW (선택)
```

---

## 🚀 구현 순서

### Step 1: Feeding API Service 생성

```dart
// frontend/lib/features/pet_feeding/data/services/backend_feeding_api_service.dart

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';

class BackendFeedingApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 급식 기록 조회
  static Future<Result<List<FeedingEntity>>> getFeedings(String petId) async {
    try {
      final response = await _apiClient.get('/activity/pets/$petId/feedings');
      // ... 구현
    } catch (e) {
      return Result.failure('급식 기록 조회 실패');
    }
  }

  /// 급식 기록 생성
  static Future<Result<FeedingEntity>> createFeeding(
    String petId,
    FeedingEntity feeding,
  ) async {
    // ... 구현
  }

  // ... CRUD 메서드들
}
```

### Step 2: Repository 연동

```dart
// frontend/lib/features/pet_feeding/data/repositories/feeding_repository.dart

class FeedingRepository {
  // 로컬 서비스 대신 Backend API Service 사용
  Future<Result<List<FeedingEntity>>> getFeedings(String petId) async {
    return BackendFeedingApiService.getFeedings(petId);
  }
}
```

### Step 3: Provider 설정

```dart
// frontend/lib/features/pet_feeding/data/providers/feeding_providers.dart

@riverpod
FeedingRepository feedingRepository(Ref ref) {
  // BackendFeedingApiService를 사용하는 Repository 반환
  return FeedingRepository();
}
```

### Step 4: 테스트

1. Swagger UI에서 API 테스트
2. Flutter 앱에서 연동 테스트
3. 오프라인 모드 확인 (로컬 캐시)

---

## 🎯 예상 효과

### Before (현재)
```
[Flutter App] → [Local Storage] → [SharedPreferences/Hive]
```
- ❌ 데이터 동기화 불가
- ❌ 다른 기기에서 접근 불가
- ❌ 백업 불가

### After (백엔드 API 연동)
```
[Flutter App] → [Backend API Service] → [Node.js API] → [MySQL]
                     ↓ (캐시)
              [Local Storage]
```
- ✅ 실시간 데이터 동기화
- ✅ 다중 기기 지원
- ✅ 자동 백업
- ✅ 데이터 분석 가능
- ✅ 오프라인 모드 (로컬 캐시)

---

## 📊 현재 상태 요약

### ✅ 백엔드 API: 95% 완료
- Pet CRUD ✅
- Health (Vaccinations, Medical Records, Weight) ✅
- Activity (Walks, Feedings, Activities) ✅
- Notification ✅
- Auth/Users ✅

### ⚠️ 프론트엔드 연동: 30% 완료
- Pet: ✅ 완전 연동 (Swagger 문서화 포함)
- Health: ⚠️ 확인 필요
- Feeding: ❌ Backend Service 생성 필요
- Walk: ⚠️ 확인 필요
- Notification: ❌ Backend Service 생성 필요
- Schedule: ⚠️ 확인 필요

---

## 🎯 최종 권장사항

### 즉시 시작 (이번 주)

1. **Feeding Backend API Service 생성** (2-3시간)
   - `backend_feeding_api_service.dart`
   - Repository 연동
   - 테스트

2. **Notification Backend API Service 생성** (2-3시간)
   - `backend_notification_api_service.dart`
   - FCM 연동
   - 테스트

### 다음 단계 (다음 주)

3. **Health, Walk, Schedule API 연동 확인 및 수정** (1일)
4. **통합 테스트 및 버그 수정** (1일)
5. **오프라인 모드 구현** (로컬 캐시) (1일)

### 추가 개선 (선택사항)

6. Swagger 문서 확장 (Health, Activity, Notification)
7. 에러 핸들링 강화
8. 재시도 로직 구현
9. 성능 최적화 (페이지네이션, 캐싱)

---

**작성일:** 2025-11-11
**분석 대상:** `/Users/apple/Documents/Github/aipet`
**백엔드:** Node.js + Express + MySQL
**프론트엔드:** Flutter + Riverpod
**인증:** Firebase Auth
