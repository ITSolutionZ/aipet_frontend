# ✅ Backend API Service 생성 완료

프론트엔드에서 백엔드 API를 호출할 수 있는 Service 파일을 생성했습니다.

## 📝 생성된 파일

### 1. Feeding API Service ✅

**파일:** `frontend/lib/features/pet_feeding/data/services/backend_feeding_api_service.dart`

**구현된 메서드:**

```dart
class BackendFeedingApiService {
  // 급식 기록 조회
  static Future<Result<List<FeedingRecordEntity>>> getFeedings({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  })

  // 급식 기록 생성
  static Future<Result<FeedingRecordEntity>> createFeeding({
    required String petId,
    required FeedingRecordEntity feeding,
  })

  // 급식 기록 수정
  static Future<Result<FeedingRecordEntity>> updateFeeding({
    required String petId,
    required FeedingRecordEntity feeding,
  })

  // 급식 기록 삭제
  static Future<Result<void>> deleteFeeding({
    required String petId,
    required String feedingId,
  })

  // 급식 통계 조회
  static Future<Result<FeedingStatistics>> getFeedingStats({
    required String petId,
    int? period,
  })
}
```

**백엔드 API 매핑:**
- `GET /activity/pets/:petId/feedings` → getFeedings()
- `POST /activity/pets/:petId/feedings` → createFeeding()
- `PUT /activity/pets/:petId/feedings/:feedingId` → updateFeeding()
- `DELETE /activity/pets/:petId/feedings/:feedingId` → deleteFeeding()
- `GET /activity/pets/:petId/feedings/stats` → getFeedingStats()

**특징:**
- ✅ Firebase ID Token 자동 주입 (BackendApiClient)
- ✅ 백엔드 응답 자동 매핑 (snake_case → Entity)
- ✅ 에러 핸들링 (Dio Exception 처리)
- ✅ Result 패턴 (성공/실패 통합 처리)
- ✅ 일본어 사용자 메시지

---

### 2. Notification API Service ✅

**파일:** `frontend/lib/features/notification/data/services/backend_notification_api_service.dart`

**구현된 메서드:**

```dart
class BackendNotificationApiService {
  // 알림 목록 조회
  static Future<Result<List<NotificationModel>>> getNotifications({
    bool? isRead,
    String? notificationType,
    int? limit,
  })

  // 알림 생성 (스케줄링)
  static Future<Result<NotificationModel>> createNotification({
    required String title,
    required String body,
    String? petId,
    NotificationType? notificationType,
    DateTime? scheduledAt,
    bool sendImmediately = false,
    String? fcmToken,
  })

  // 알림 읽음 처리
  static Future<Result<NotificationModel>> markAsRead({
    required String notificationId,
  })

  // 모든 알림 읽음 처리
  static Future<Result<void>> markAllAsRead()

  // 알림 삭제
  static Future<Result<void>> deleteNotification({
    required String notificationId,
  })

  // 읽지 않은 알림 개수 조회
  static Future<Result<int>> getUnreadCount()

  // FCM 토큰 저장/업데이트
  static Future<Result<void>> saveFCMToken({
    required String fcmToken,
    String deviceType = 'android',
  })

  // FCM 푸시 알림 전송 (테스트용)
  static Future<Result<void>> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  })
}
```

**백엔드 API 매핑:**
- `GET /notifications` → getNotifications()
- `POST /notifications` → createNotification()
- `PUT /notifications/:id/read` → markAsRead()
- `PUT /notifications/mark-all-read` → markAllAsRead()
- `DELETE /notifications/:id` → deleteNotification()
- `GET /notifications/unread-count` → getUnreadCount()
- `POST /notifications/fcm-token` → saveFCMToken()
- `POST /notifications/push` → sendPushNotification()

**특징:**
- ✅ Firebase ID Token 자동 주입
- ✅ FCM (Firebase Cloud Messaging) 통합
- ✅ 알림 스케줄링 지원
- ✅ 읽음/읽지 않음 상태 관리
- ✅ Result 패턴
- ✅ 일본어 사용자 메시지

---

## 🔄 다음 단계: Repository 연동

### 1. Feeding Repository 수정

**파일:** `frontend/lib/features/pet_feeding/data/repositories/...`

**작업:**
```dart
// Before (로컬 저장소)
class FeedingRepository {
  Future<Result<List<FeedingRecord>>> getFeedings() {
    return PetFeedingLocalStorageService.getFeedings();
  }
}

// After (백엔드 API)
class FeedingRepository {
  Future<Result<List<FeedingRecord>>> getFeedings(String petId) {
    return BackendFeedingApiService.getFeedings(petId: petId);
  }
}
```

### 2. Notification Repository 수정

**파일:** `frontend/lib/features/notification/data/repositories/notification_repository_impl.dart`

**작업:**
```dart
// Before (로컬 저장소)
final localResult = await _localService.getNotifications(...);

// After (백엔드 API)
final backendResult = await BackendNotificationApiService.getNotifications(...);
```

---

## 📊 API 통합 상태 업데이트

### ✅ 완료 (Backend API Service 생성 및 수정됨)

| 기능 | 백엔드 API | 프론트엔드 Service | 상태 |
|------|----------|-----------------|------|
| **Pet** | /api/v1/pets | backend_pet_api_service.dart | ✅ 완료 + Swagger |
| **Health** | /api/v1/health/pets/:petId/... | backend_health_api_service.dart | ✅ 수정 완료 (UPDATED) |
| **Walk** | /api/v1/activity/pets/:petId/walks | backend_walk_api_service.dart | ✅ 수정 완료 (UPDATED) |
| **Feeding** | /api/v1/activity/pets/:petId/feedings | backend_feeding_api_service.dart | ✅ 완료 (NEW) |
| **Notification** | /api/v1/notifications | backend_notification_api_service.dart | ✅ 완료 (NEW) |
| **Schedule** | ❌ 백엔드 미구현 | backend_schedule_api_service.dart | ⚠️ 백엔드 API 없음 |

### ⚠️ Schedule API 주의사항

**문제**: `backend_schedule_api_service.dart`가 `/api/schedules` 엔드포인트를 호출하지만, 백엔드에 해당 API가 구현되지 않았습니다.

**현재 상황**:
- 백엔드는 Notification API를 통해 스케줄링을 수행 (`scheduledAt` 필드 사용)
- 프론트엔드 Schedule Service는 존재하지 않는 엔드포인트를 호출

**해결 방안**:
1. **옵션 A**: 백엔드에 `/api/v1/schedules` 엔드포인트 구현
2. **옵션 B**: 프론트엔드를 Notification API 사용하도록 리팩토링

### ⏳ 다음 작업 필요

1. **Repository 연동** (3-4시간)
   - Health Repository → Backend Health API Service 사용
   - Walk Repository → Backend Walk API Service 사용
   - Feeding Repository → Backend Feeding API Service 사용
   - Notification Repository → Backend Notification API Service 사용

2. **Schedule API 결정** (1-2시간)
   - 백엔드에 Schedule API 구현 OR
   - 프론트엔드를 Notification API 사용하도록 리팩토링

3. **테스트** (2-3시간)
   - 각 API Service 단위 테스트
   - Repository 통합 테스트
   - 실제 앱에서 동작 확인

---

## 🎯 사용 예시

### Feeding API 사용

```dart
// Controller나 UseCase에서
final result = await BackendFeedingApiService.getFeedings(
  petId: 'pet-123',
  startDate: DateTime.now().subtract(Duration(days: 7)),
  limit: 20,
);

if (result.isSuccess) {
  final feedings = result.dataOrNull!;
  print('급식 기록 ${feedings.length}개 조회');
} else {
  print('에러: ${result.error}');
}
```

### Notification API 사용

```dart
// 알림 생성
final result = await BackendNotificationApiService.createNotification(
  title: '급식 시간',
  body: '포치에게 저녁 식사를 줄 시간입니다',
  petId: 'pet-123',
  notificationType: NotificationType.feeding,
  scheduledAt: DateTime.now().add(Duration(hours: 1)),
);

// 읽지 않은 알림 개수
final countResult = await BackendNotificationApiService.getUnreadCount();
final unreadCount = countResult.dataOrNull ?? 0;

// FCM 토큰 저장
await BackendNotificationApiService.saveFCMToken(
  fcmToken: 'device-fcm-token',
  deviceType: 'android',
);
```

---

## 🔐 인증

모든 API 호출은 자동으로 Firebase ID Token이 포함됩니다:

```
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE4...
```

`BackendApiClient`의 `FirebaseTokenInterceptor`가 자동으로 처리합니다.

---

## 📚 관련 문서

- [API 통합 분석 보고서](API_INTEGRATION_ANALYSIS.md)
- [API 통합 상태](API_INTEGRATION_STATUS.md)
- [Swagger 가이드](backend/SWAGGER_GUIDE.md)

---

## 🔧 최근 업데이트 (2025-11-11)

### Health API Service 수정

**문제**: 기존 코드가 잘못된 엔드포인트 사용
- ❌ OLD: `/health`, `/pets/:petId/health`
- ✅ NEW: `/health/pets/:petId/vaccinations`, `/health/pets/:petId/medical-records`, `/health/pets/:petId/weight-history`

**수정 내용**:
- 예방접종 (Vaccinations): 4개 메서드 (GET, POST, PUT, DELETE)
- 의료 기록 (Medical Records): 4개 메서드 (GET, POST, PUT, DELETE)
- 체중 기록 (Weight History): 2개 메서드 (GET, POST)

### Walk API Service 수정

**문제**: 기존 코드가 잘못된 엔드포인트 사용
- ❌ OLD: `/walks`, `/pets/:petId/walks`, `/walks/:walkId`
- ✅ NEW: `/activity/pets/:petId/walks`, `/activity/pets/:petId/walks/:walkId`

**수정 내용**:
- 산책 기록: 5개 메서드 (GET, POST, PUT, DELETE, GET stats)
- 모든 메서드에 `petId` 필수 파라미터 추가
- 백엔드 필드명 매칭 (`startTime`, `durationMinutes`, `distanceMeters` 등)

### Schedule API Service 확인

**발견**: 백엔드에 `/api/schedules` 엔드포인트가 구현되지 않음
- 백엔드는 Notification API의 `scheduledAt` 필드로 스케줄링 처리
- 프론트엔드 Service에 경고 주석 추가

**향후 결정 필요**:
- 백엔드에 Schedule API 구현 OR
- 프론트엔드를 Notification API 사용하도록 리팩토링

---

**작성일:** 2025-11-11
**최종 업데이트:** 2025-11-11
**작성자:** Claude Code
**상태:** 5개 Service 완료 (2개 생성 + 2개 수정 + 1개 확인), Repository 연동 대기
