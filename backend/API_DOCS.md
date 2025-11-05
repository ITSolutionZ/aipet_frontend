# 📚 AIPet Backend API 문서

## Base URL

```
http://localhost:3000/api/v1
```

## 인증

모든 보호된 엔드포인트는 Firebase ID Token이 필요합니다:

```http
Authorization: Bearer <Firebase_ID_Token>
```

---

## 📑 API 엔드포인트

### 1. 인증 (Auth)

#### POST /auth/verify-token

Firebase ID Token 검증

**Request:**

```http
POST /api/v1/auth/verify-token
Authorization: Bearer <token>
```

**Response:**

```json
{
  "success": true,
  "message": "Token is valid",
  "user": {
    "uid": "firebase_uid",
    "email": "user@example.com"
  }
}
```

#### POST /users

사용자 생성/업데이트 (Firebase UID 동기화)

**Request:**

```json
{
  "uid": "firebase_uid",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoURL": "https://...",
  "provider": "google"
}
```

#### GET /auth/me

현재 로그인한 사용자 정보 조회

---

### 2. 펫 관리 (Pets)

#### GET /pets

모든 펫 조회

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "pet_123",
      "owner_id": "firebase_uid",
      "name": "테스트",
      "type": "dog",
      "breed": "시바견",
      "birth_date": "2020-01-15",
      "gender": "male",
      "weight": 8.5
    }
  ],
  "count": 1
}
```

#### GET /pets/:id

특정 펫 조회

#### POST /pets

새 펫 생성

**Request:**

```json
{
  "name": "테스트",
  "type": "dog",
  "breed": "시바견",
  "birthDate": "2020-01-15",
  "gender": "male",
  "weight": 8.5,
  "color": "brown",
  "isNeutered": true
}
```

#### PUT /pets/:id

펫 정보 업데이트

#### DELETE /pets/:id

펫 삭제 (Soft Delete)

#### GET /pets/stats

펫 통계 조회

---

### 3. 건강 관리 (Health)

#### 예방접종 (Vaccinations)

##### GET /health/pets/:petId/vaccinations

특정 펫의 예방접종 기록 조회

##### POST /health/pets/:petId/vaccinations

예방접종 기록 생성

**Request:**

```json
{
  "vaccineName": "광견병",
  "vaccineType": "필수",
  "vaccinationDate": "2025-01-15",
  "nextDueDate": "2026-01-15",
  "veterinarianName": "김수의사",
  "clinicName": "행복동물병원",
  "notes": "특이사항 없음"
}
```

##### PUT /health/pets/:petId/vaccinations/:vaccinationId

예방접종 기록 업데이트

##### DELETE /health/pets/:petId/vaccinations/:vaccinationId

예방접종 기록 삭제

#### 의료 기록 (Medical Records)

##### GET /health/pets/:petId/medical-records

특정 펫의 의료 기록 조회

##### POST /health/pets/:petId/medical-records

의료 기록 생성

**Request:**

```json
{
  "visitDate": "2025-01-15",
  "visitType": "checkup",
  "diagnosis": "정기 검진",
  "treatment": "건강 상태 양호",
  "prescription": "없음",
  "veterinarianName": "김수의사",
  "clinicName": "행복동물병원",
  "cost": 50000,
  "notes": "다음 방문: 6개월 후"
}
```

##### PUT /health/pets/:petId/medical-records/:recordId

의료 기록 업데이트

##### DELETE /health/pets/:petId/medical-records/:recordId

의료 기록 삭제

#### 체중 기록 (Weight History)

##### GET /health/pets/:petId/weight-history

특정 펫의 체중 기록 조회

##### POST /health/pets/:petId/weight-history

체중 기록 생성

**Request:**

```json
{
  "weight": 8.5,
  "measuredAt": "2025-01-15T10:00:00Z",
  "notes": "정상 체중"
}
```

---

### 4. 활동 관리 (Activity)

#### 산책 (Walks)

##### GET /activity/pets/:petId/walks

특정 펫의 산책 기록 조회

**Query Parameters:**

- `startDate` (optional): 시작 날짜 (ISO 8601)
- `endDate` (optional): 종료 날짜 (ISO 8601)
- `limit` (optional): 조회 개수 (기본값: 50)

##### POST /activity/pets/:petId/walks

산책 기록 생성

**Request:**

```json
{
  "startTime": "2025-01-15T10:00:00Z",
  "endTime": "2025-01-15T10:30:00Z",
  "durationMinutes": 30,
  "distanceMeters": 2000,
  "routeData": [
    { "lat": 37.5665, "lng": 126.9780 },
    { "lat": 37.5670, "lng": 126.9785 }
  ],
  "temperature": 15.5,
  "weather": "맑음",
  "poopCount": 1,
  "peeCount": 2,
  "notes": "공원에서 산책"
}
```

##### PUT /activity/pets/:petId/walks/:walkId

산책 기록 업데이트

##### DELETE /activity/pets/:petId/walks/:walkId

산책 기록 삭제

##### GET /activity/pets/:petId/walks/stats

산책 통계 조회

**Query Parameters:**

- `period` (optional): 조회 기간 (일 단위, 기본값: 7)

**Response:**

```json
{
  "success": true,
  "data": {
    "period": "7일",
    "totalWalks": 15,
    "totalMinutes": 450,
    "totalMeters": 30000,
    "avgMinutes": 30,
    "avgMeters": 2000
  }
}
```

#### 급식 (Feedings)

##### GET /activity/pets/:petId/feedings

특정 펫의 급식 기록 조회

**Query Parameters:**

- `startDate` (optional): 시작 날짜
- `endDate` (optional): 종료 날짜
- `limit` (optional): 조회 개수

##### POST /activity/pets/:petId/feedings

급식 기록 생성

**Request:**

```json
{
  "feedingTime": "2025-01-15T08:00:00Z",
  "foodType": "사료",
  "foodBrand": "로얄캐닌",
  "amountGrams": 150,
  "mealType": "breakfast",
  "notes": "잘 먹음"
}
```

**mealType 옵션:**

- `breakfast`: 아침
- `lunch`: 점심
- `dinner`: 저녁
- `snack`: 간식

##### PUT /activity/pets/:petId/feedings/:feedingId

급식 기록 업데이트

##### DELETE /activity/pets/:petId/feedings/:feedingId

급식 기록 삭제

##### GET /activity/pets/:petId/feedings/stats

급식 통계 조회

**Query Parameters:**

- `period` (optional): 조회 기간 (일 단위, 기본값: 7)

**Response:**

```json
{
  "success": true,
  "data": {
    "period": "7일",
    "byMealType": [
      { "meal_type": "breakfast", "count_by_type": 7, "total_grams": 1050 },
      { "meal_type": "dinner", "count_by_type": 7, "total_grams": 1050 }
    ],
    "totalFeedings": 14,
    "totalGrams": 2100
  }
}
```

#### 기타 활동 (Activities)

##### GET /activity/pets/:petId/activities

특정 펫의 기타 활동 기록 조회

**Query Parameters:**

- `activityType` (optional): 활동 타입 (playing, sleeping, bathing 등)
- `startDate` (optional): 시작 날짜
- `endDate` (optional): 종료 날짜
- `limit` (optional): 조회 개수

##### POST /activity/pets/:petId/activities

기타 활동 기록 생성

**Request:**

```json
{
  "activityType": "playing",
  "startTime": "2025-01-15T14:00:00Z",
  "endTime": "2025-01-15T14:30:00Z",
  "durationMinutes": 30,
  "notes": "장난감으로 놀이"
}
```

**activityType 예시:**

- `playing`: 놀이
- `sleeping`: 수면
- `bathing`: 목욕
- `grooming`: 그루밍

---

### 5. 알림 관리 (Notifications)

#### GET /notifications

알림 목록 조회

**Query Parameters:**

- `isRead` (optional): 읽음 여부 (true/false)
- `notificationType` (optional): 알림 타입
- `limit` (optional): 조회 개수 (기본값: 50)

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "notif_123",
      "user_id": "firebase_uid",
      "pet_id": "pet_123",
      "title": "테스트의 광견병 접종일이 다가왔습니다",
      "body": "다음 접종 예정일: 2025-01-20",
      "notification_type": "vaccination",
      "scheduled_at": "2025-01-15T09:00:00Z",
      "is_read": false,
      "is_sent": true,
      "sent_at": "2025-01-15T09:00:05Z"
    }
  ],
  "count": 1
}
```

#### POST /notifications

알림 생성 (스케줄링)

**Request:**

```json
{
  "title": "급식 시간입니다",
  "body": "테스트에게 사료를 챙겨주세요",
  "petId": "pet_123",
  "notificationType": "feeding",
  "scheduledAt": "2025-01-15T18:00:00Z",
  "sendImmediately": false,
  "fcmToken": "device_fcm_token"
}
```

**notificationType 옵션:**

- `vaccination`: 예방접종
- `feeding`: 급식
- `walk`: 산책
- `medical`: 의료
- `general`: 일반

#### GET /notifications/unread-count

읽지 않은 알림 개수 조회

**Response:**

```json
{
  "success": true,
  "data": {
    "unreadCount": 5
  }
}
```

#### PUT /notifications/:notificationId/read

알림 읽음 처리

#### PUT /notifications/mark-all-read

모든 알림 읽음 처리

#### DELETE /notifications/:notificationId

알림 삭제

#### POST /notifications/push

FCM 푸시 알림 직접 전송 (테스트용)

**Request:**

```json
{
  "fcmToken": "device_fcm_token",
  "title": "테스트 알림",
  "body": "푸시 알림 테스트입니다",
  "data": {
    "custom_key": "custom_value"
  }
}
```

#### POST /notifications/fcm-token

FCM 토큰 저장/업데이트

**Request:**

```json
{
  "fcmToken": "device_fcm_token",
  "deviceType": "android"
}
```

**deviceType 옵션:**

- `android`: Android
- `ios`: iOS

---

## 에러 응답

모든 에러는 다음 형식으로 반환됩니다:

```json
{
  "success": false,
  "error": "에러 메시지",
  "message": "상세 에러 정보"
}
```

### HTTP 상태 코드

- `200 OK`: 성공
- `201 Created`: 리소스 생성 성공
- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `404 Not Found`: 리소스를 찾을 수 없음
- `500 Internal Server Error`: 서버 내부 오류

---

## 페이지네이션

대부분의 조회 엔드포인트는 `limit` 파라미터를 지원합니다:

```http
GET /api/v1/pets?limit=20
```

---

## 날짜 형식

모든 날짜는 ISO 8601 형식을 사용합니다:

```
2025-01-15T10:00:00Z
```

---

## 테스트 예제

### cURL 예제

```bash
# 1. 토큰 검증
curl -X POST http://localhost:3000/api/v1/auth/verify-token \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"

# 2. 펫 목록 조회
curl -X GET http://localhost:3000/api/v1/pets \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"

# 3. 펫 생성
curl -X POST http://localhost:3000/api/v1/pets \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "테스트",
    "type": "dog",
    "breed": "시바견",
    "birthDate": "2020-01-15",
    "gender": "male",
    "weight": 8.5
  }'

# 4. 산책 기록 생성
curl -X POST http://localhost:3000/api/v1/activity/pets/pet_123/walks \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "startTime": "2025-01-15T10:00:00Z",
    "endTime": "2025-01-15T10:30:00Z",
    "durationMinutes": 30,
    "distanceMeters": 2000
  }'
```

---

## Postman Collection

Postman Collection을 제공하여 쉽게 API를 테스트할 수 있습니다.

[Postman Collection 다운로드] (준비 중)

---

**문서 버전:** v1.0.0
**최종 업데이트:** 2025-01-15
