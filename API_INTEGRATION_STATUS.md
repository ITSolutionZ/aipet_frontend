# 🔄 API 통합 상태 분석

프론트엔드(Flutter)와 백엔드(Node.js) API 통합 상태를 분석합니다.

## 📊 현재 상태

### ✅ 백엔드 API (구현 완료)

| 기능 | 라우트 | 컨트롤러 | 상태 |
|------|--------|----------|------|
| 인증 | auth.routes.js | auth.controller.js | ✅ 구현됨 |
| 펫 관리 | pet.routes.js | pet.controller.js | ✅ 구현됨 + Swagger |
| 건강 관리 | health.routes.js | health.controller.js | ✅ 구현됨 |
| 활동 관리 | activity.routes.js | activity.controller.js | ✅ 구현됨 |
| 알림 | notification.routes.js | notification.controller.js | ✅ 구현됨 |

### 📱 프론트엔드 Backend API 서비스 (구현 완료)

| 기능 | 파일 | 백엔드 연동 |
|------|------|------------|
| Pet | backend_pet_api_service.dart | ✅ /api/v1/pets |
| Health | backend_health_api_service.dart | ✅ /api/v1/health |
| Schedule | backend_schedule_api_service.dart | ⚠️ 미확인 |
| Walk | backend_walk_api_service.dart | ✅ /api/v1/activity |

### ⚠️ 프론트엔드 로컬 서비스 (API 전환 필요)

| 기능 | 로컬 서비스 파일 | 백엔드 API | 우선순위 |
|------|------------------|-----------|---------|
| **Pet Profile** | pet_local_storage_service.dart | ✅ pets API 있음 | 🔴 HIGH (이미 연동됨) |
| **Pet Health** | pet_health_local_storage_service.dart | ✅ health API 있음 | 🟡 MEDIUM |
| **Pet Feeding** | pet_feeding_local_storage_service.dart | ❌ API 없음 | 🔴 HIGH |
| **Walk** | local_walk_storage_service.dart | ✅ activity API 있음 | 🟡 MEDIUM |
| **Scheduling** | feeding_local_storage_service.dart | ❌ API 없음 | 🔴 HIGH |
| **Scheduling** | local_schedule_service.dart | ❌ API 없음 | 🔴 HIGH |
| **Notification** | notification_local_storage_service.dart | ✅ notification API 있음 | 🟡 MEDIUM |
| **Facility** | facility_local_storage_service.dart | ❌ API 없음 | 🟢 LOW |
| **AI** | ai_local_storage_service.dart | ❌ API 없음 | 🟢 LOW |
| **Settings** | local_user_service.dart | ⚠️ auth/users API 확인 필요 | 🟡 MEDIUM |
| **Daily** | reservation_local_storage_service.dart | ❌ API 없음 | 🟢 LOW |

## 🔍 상세 분석

### 1. Pet Profile (펫 프로필) - ✅ 완료

**상태:** 백엔드 API 완전 연동됨

**프론트엔드:**
- `BackendPetRepository` 사용
- `BackendPetApiService` 구현됨
- `petProfileRepositoryProvider` → BackendPetRepository

**백엔드:**
- ✅ GET /api/v1/pets - 펫 목록
- ✅ GET /api/v1/pets/:id - 펫 상세
- ✅ POST /api/v1/pets - 펫 생성
- ✅ PUT /api/v1/pets/:id - 펫 수정
- ✅ DELETE /api/v1/pets/:id - 펫 삭제
- ✅ GET /api/v1/pets/stats - 펫 통계

**다음 단계:** ✅ 완료 (Swagger 문서화 포함)

---

### 2. Pet Health (건강 관리) - ⚠️ 부분 구현

**상태:** 백엔드 API는 있으나 프론트엔드 Repository 연동 미확인

**프론트엔드:**
- ✅ `backend_health_api_service.dart` 있음
- ❌ Repository가 Backend API 사용하는지 확인 필요

**백엔드:**
- health.routes.js / health.controller.js 있음
- 엔드포인트 확인 필요

**다음 단계:**
1. 백엔드 health API 엔드포인트 확인
2. 프론트엔드 repository 연동 확인
3. 로컬 서비스 → 백엔드 API 전환

---

### 3. Pet Feeding (급식 관리) - ❌ 백엔드 API 없음

**상태:** 로컬 저장소만 사용

**프론트엔드:**
- `pet_feeding_local_storage_service.dart`
- `feeding_local_storage_service.dart`

**백엔드:**
- ❌ feeding 관련 API 없음
- 필요한 엔드포인트:
  - GET /api/v1/feeding - 급식 기록 목록
  - POST /api/v1/feeding - 급식 기록 추가
  - PUT /api/v1/feeding/:id - 급식 기록 수정
  - DELETE /api/v1/feeding/:id - 급식 기록 삭제
  - GET /api/v1/feeding/schedules - 급식 스케줄
  - POST /api/v1/feeding/schedules - 스케줄 생성

**다음 단계:**
1. 백엔드 feeding API 구현
2. 프론트엔드 backend_feeding_api_service.dart 생성
3. Repository 연동

---

### 4. Walk (산책) - ⚠️ 부분 구현

**상태:** 백엔드 activity API 있음, 프론트엔드 연동 확인 필요

**프론트엔드:**
- ✅ `backend_walk_api_service.dart` 있음
- `local_walk_storage_service.dart` (로컬)

**백엔드:**
- activity.routes.js / activity.controller.js 있음
- Walk 데이터가 activity에 포함되는지 확인 필요

**다음 단계:**
1. 백엔드 activity API 엔드포인트 확인
2. Walk 데이터 포함 여부 확인
3. 프론트엔드 Repository 연동

---

### 5. Scheduling (스케줄링) - ⚠️ 부분 구현

**상태:** Schedule API 서비스는 있으나 백엔드 엔드포인트 미확인

**프론트엔드:**
- ✅ `backend_schedule_api_service.dart` 있음
- `local_schedule_service.dart` (로컬)

**백엔드:**
- 별도 schedule API 없음
- activity 또는 다른 API에 포함되어있는지 확인 필요

**다음 단계:**
1. 백엔드에 schedule API 필요한지 확인
2. 또는 기존 API로 커버 가능한지 확인

---

### 6. Notification (알림) - ⚠️ 부분 구현

**상태:** 백엔드 API 있음, 프론트엔드 연동 확인 필요

**프론트엔드:**
- `notification_local_storage_service.dart` (로컬)
- backend 서비스 파일 없음

**백엔드:**
- ✅ notification.routes.js / notification.controller.js 있음

**다음 단계:**
1. 백엔드 notification API 엔드포인트 확인
2. 프론트엔드 backend_notification_api_service.dart 생성
3. Repository 연동

---

### 7. Facility (시설 검색) - ❌ 백엔드 API 없음

**상태:** 로컬 저장소만 사용 (외부 API 사용 가능)

**프론트엔드:**
- `facility_local_storage_service.dart`
- `local_facility_service.dart`

**백엔드:**
- ❌ facility API 없음
- 외부 지도 API (Google Maps, Kakao 등) 사용 가능

**다음 단계:**
- 우선순위 낮음 (외부 API 직접 사용 가능)

---

### 8. AI Assistant - ❌ 백엔드 API 없음

**상태:** 로컬 서비스만 사용

**프론트엔드:**
- `ai_local_storage_service.dart`
- `local_ai_service.dart`

**백엔드:**
- ❌ AI API 없음
- OpenAI API 직접 호출 또는 백엔드 프록시 필요

**다음 단계:**
- 우선순위 낮음 (OpenAI API 직접 사용 또는 별도 구현)

---

## 🎯 우선순위별 작업 계획

### 🔴 HIGH Priority (즉시 구현 필요)

1. **Pet Feeding API**
   - 백엔드: feeding.routes.js, feeding.controller.js 생성
   - 프론트엔드: backend_feeding_api_service.dart 생성
   - Repository 연동

2. **Pet Health 연동 완료**
   - 기존 health API 확인
   - Repository 연동 확인 및 수정

### 🟡 MEDIUM Priority (단계적 구현)

3. **Walk (Activity) 연동 완료**
   - activity API 엔드포인트 확인
   - Repository 연동

4. **Notification 연동 완료**
   - notification API 엔드포인트 확인
   - backend_notification_api_service.dart 생성
   - Repository 연동

5. **Scheduling 연동**
   - 기존 API로 커버 가능한지 확인
   - 필요시 schedule API 구현

### 🟢 LOW Priority (나중에)

6. **Settings (User) 연동**
   - auth/users API 확인
   - local_user_service → backend 전환

7. **Facility, AI, Daily**
   - 외부 API 사용 또는 별도 구현

## 📝 부족한 백엔드 API 파일

### 즉시 생성 필요:

```
backend/src/
├── routes/
│   └── feeding.routes.js         ❌ NEW
├── controllers/
│   └── feeding.controller.js     ❌ NEW
└── models/ (선택사항)
    └── feeding.model.js
```

### 확인 및 보완 필요:

```
backend/src/
├── routes/
│   ├── health.routes.js          ✅ 확인 필요
│   ├── activity.routes.js        ✅ 확인 필요 (Walk 포함?)
│   ├── notification.routes.js    ✅ 확인 필요
│   └── schedule.routes.js        ❓ 필요성 확인
└── controllers/
    ├── health.controller.js      ✅ 확인 필요
    ├── activity.controller.js    ✅ 확인 필요
    ├── notification.controller.js ✅ 확인 필요
    └── schedule.controller.js    ❓ 필요성 확인
```

## 🔄 다음 단계

1. **백엔드 API 엔드포인트 상세 확인**
   - health, activity, notification API 엔드포인트 리스트 작성
   - 프론트엔드 요구사항과 매칭

2. **Feeding API 구현** (최우선)
   - 테이블 스키마 설계
   - CRUD API 구현
   - Swagger 문서화

3. **프론트엔드 Backend API Service 생성**
   - backend_feeding_api_service.dart
   - backend_notification_api_service.dart
   - 필요시 다른 서비스들

4. **Repository 연동**
   - 각 feature의 repository가 backend API 사용하도록 수정
   - 로컬 저장소는 캐시/오프라인 용도로만 사용

5. **통합 테스트**
   - 각 API 엔드포인트 테스트
   - 프론트엔드-백엔드 연동 테스트
   - Swagger UI로 검증

---

**작성일:** 2025-11-11
**마지막 업데이트:** Pet CRUD API + Swagger 완료
