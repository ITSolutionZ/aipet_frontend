# 🔗 백엔드 API 연동 가이드

## 📋 목차
1. [개요](#개요)
2. [API 설정](#api-설정)
3. [인증 방식](#인증-방식)
4. [동작 흐름](#동작-흐름)
5. [테스트 방법](#테스트-방법)

---

## 개요

Flutter 앱이 Express 백엔드와 Firebase ID Token으로 인증하여 통신합니다.

### 핵심 기능
- ✅ Firebase Auth로 로그인
- ✅ Firebase ID Token 자동 획득
- ✅ 모든 API 호출에 `Authorization: Bearer <token>` 자동 추가
- ✅ 401 에러 시 자동 토큰 갱신
- ✅ 백엔드 없이도 앱 동작 가능 (로컬 모드)

---

## API 설정

### Base URL 설정

```dart
// lib/shared/core/config/api_config.dart
static String get fullApiUrl => '$baseUrl/api/$apiVersion';

// 결과:
// Development: http://localhost:3000/api/v1
// Staging: https://staging-api.aipet.com/api/v1
// Production: https://api.aipet.com/api/v1
```

### Android 에뮬레이터 주의사항

Android 에뮬레이터에서는 `localhost`가 **에뮬레이터 자체**를 가리킵니다.

```bash
# 해결 방법: ADB Reverse 사용
adb reverse tcp:3000 tcp:3000

# 또는 .env 파일에서 직접 설정
DEV_API_BASE_URL=http://10.0.2.2:3000
```

---

## 인증 방식

### Firebase ID Token 기반 인증

```http
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6...
Content-Type: application/json
Accept: application/json
```

### 프론트엔드 → 백엔드 인증 흐름

```mermaid
sequenceDiagram
    participant User
    participant Flutter
    participant Firebase
    participant Backend

    User->>Flutter: Google/Apple/LINE 로그인
    Flutter->>Firebase: 소셜 인증 요청
    Firebase-->>Flutter: 인증 성공 + ID Token
    Flutter->>Flutter: SecureStorage에 토큰 저장
    
    Flutter->>Backend: GET / (연결 테스트)
    Backend-->>Flutter: 200 OK
    
    Flutter->>Backend: POST /auth/verify-token
    Note right of Backend: Firebase Admin SDK로<br/>토큰 검증
    Backend-->>Flutter: 200 OK
    
    Flutter->>Backend: POST /users {uid, email}
    Backend-->>Flutter: 201 Created
    
    Note over Flutter,Backend: 이후 모든 API 호출
    
    Flutter->>Backend: GET /pets<br/>Authorization: Bearer <token>
    Backend->>Backend: 토큰 검증 & ownerId 추출
    Backend-->>Flutter: 200 OK + 펫 목록
```

---

## 동작 흐름

### 1. 로그인 시 (AuthController)

```dart
// Google 로그인
await authController.loginWithGoogle();

// 내부 동작:
1. Firebase Auth 로그인
2. Firebase ID Token 획득
3. SecureStorage에 저장
4. BackendTokenService.authenticateWithBackend() 호출
   - GET / (연결 테스트)
   - POST /auth/verify-token (토큰 검증)
   - POST /users (사용자 동기화)
5. 로그인 완료
```

### 2. API 호출 시 (FirebaseTokenInterceptor)

```dart
// 펫 목록 조회
final result = await BackendPetApiService.getAllPets();

// 내부 동작:
1. BackendApiClient.get('/pets') 호출
2. FirebaseTokenInterceptor.onRequest 실행
   - Firebase ID Token 자동 획득
   - Authorization 헤더 추가: "Bearer <token>"
3. 백엔드로 요청 전송
4. 백엔드에서 토큰 검증
5. 응답 받아서 PetProfileEntity로 변환
```

### 3. 401 에러 시 (자동 토큰 갱신)

```dart
// API 호출 중 401 Unauthorized 발생

// 내부 동작:
1. FirebaseTokenInterceptor.onError 실행
2. Firebase ID Token 갱신 (forceRefresh: true)
3. SecureStorage 업데이트
4. 같은 요청 자동 재시도
5. 성공 또는 최종 실패
```

---

## 테스트 방법

### 1. 백엔드 서버 준비

```bash
cd aipet_backend
npm run dev  # 또는 npm start
# 백엔드가 http://localhost:3000에서 실행되어야 함
```

### 2. Android 에뮬레이터 포트 포워딩

```bash
adb reverse tcp:3000 tcp:3000
echo "✅ ADB reverse 설정 완료"
```

### 3. Flutter 앱 실행

```bash
cd aipet_frontend
flutter run -d R3CN815LCAB  # Android
# 또는
flutter run -d 4C0DA192-9E69-4869-BDA9-4BF2719D815B  # iOS
```

### 4. 테스트 시나리오

#### ✅ 로그인 테스트
1. Google 로그인 버튼 클릭
2. 로그 확인:
   ```
   🔑 Firebase ID Token 헤더 추가: eyJhbGciOiJSUzI1NiI...
   📡 [API Request] POST http://localhost:3000/api/v1/auth/verify-token
   ✅ [API Response] 200
   ✅ 백엔드 인증 완료
   ```

#### ✅ 펫 조회 테스트
1. 펫 목록 화면 이동
2. 로그 확인:
   ```
   📡 [PetAPI] GET /pets
   🔑 Firebase ID Token 헤더 추가: eyJhbGciOiJSUzI1NiI...
   📡 [API Request] GET http://localhost:3000/api/v1/pets
   ✅ [API Response] 200
   ✅ 펫 목록 조회 성공: 3마리
   ```

#### ✅ 펫 생성 테스트
1. 펫 등록 화면에서 새 펫 생성
2. 로그 확인:
   ```
   📡 [PetAPI] POST /pets
   🔑 Firebase ID Token 헤더 추가: eyJhbGciOiJSUzI1NiI...
   📡 [API Request] POST http://localhost:3000/api/v1/pets
   ✅ [API Response] 201
   ✅ 펫 생성 성공: テスト (pet_123456)
   ```

#### ✅ 401 에러 테스트 (토큰 만료)
1. 토큰 만료 대기 (1시간)
2. 펫 목록 조회
3. 로그 확인:
   ```
   📡 [API Request] GET http://localhost:3000/api/v1/pets
   ❌ [API Error] 401
   🔄 401 에러 - Firebase ID Token 갱신 시도
   ✅ 토큰 갱신 후 요청 재시도 성공
   ✅ [API Response] 200
   ```

---

## 파일 구조

```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_providers.dart  ✅ Firebase Auth 사용
│   │   └── presentation/
│   │       └── controllers/
│   │           └── auth_controller.dart  ✅ 토큰 전송 로직 추가
│   │
│   └── pet_profile/
│       └── data/
│           ├── services/
│           │   └── backend_pet_api_service.dart  ✅ 펫 API 호출
│           ├── repositories/
│           │   └── backend_pet_repository.dart   ✅ 백엔드 사용
│           └── providers/
│               └── pet_profile_providers.dart    ✅ Backend Repository 사용
│
└── shared/
    └── core/
        ├── api/
        │   ├── backend_api_client.dart         ✅ HTTP 클라이언트 + 인터셉터
        │   └── backend_api_usage_example.dart  ✅ 사용 예제
        ├── services/
        │   ├── firebase_token_service.dart     ✅ 토큰 관리
        │   └── backend_token_service.dart      ✅ 백엔드 인증
        ├── config/
        │   └── api_config.dart                 ✅ API 설정
        └── constants/
            └── environment_constants.dart      ✅ 환경 변수
```

---

## 백엔드 개발자 체크리스트

### 필수 구현

- [ ] Firebase Admin SDK 설정
  ```javascript
  import admin from 'firebase-admin';
  const serviceAccount = require('./firebase-service-account.json');
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  ```

- [ ] Firebase 토큰 검증 미들웨어
  ```javascript
  const firebaseAuthMiddleware = async (req, res, next) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = { uid: decodedToken.uid, email: decodedToken.email };
    next();
  };
  ```

- [ ] 필수 엔드포인트 구현
  ```
  GET  /                        - 연결 테스트
  POST /auth/verify-token       - 토큰 검증 (선택)
  POST /users                   - 사용자 등록 (선택)
  GET  /auth/me                 - 현재 사용자 조회
  GET  /pets                    - 펫 목록 조회
  GET  /pets/:id                - 펫 상세 조회
  POST /pets                    - 펫 생성
  PUT  /pets/:id                - 펫 수정
  DELETE /pets/:id              - 펫 삭제
  ```

- [ ] CORS 설정
  ```javascript
  app.use(cors({
    origin: ['http://localhost:*', 'http://10.0.2.2:*'],
    credentials: true
  }));
  ```

---

## 트러블슈팅

### 문제 1: "Connection refused"
```bash
# 해결: 백엔드 서버 실행 확인
cd aipet_backend
npm run dev

# 서버가 http://localhost:3000에서 실행 중이어야 함
```

### 문제 2: Android 에뮬레이터에서 연결 안 됨
```bash
# 해결: ADB reverse 설정
adb reverse tcp:3000 tcp:3000

# 또는 .env 파일 수정
DEV_API_BASE_URL=http://10.0.2.2:3000
```

### 문제 3: "401 Unauthorized"
```
# 원인: Firebase Admin SDK 미설정
# 해결: 백엔드에 firebase-service-account.json 추가
```

### 문제 4: "404 Not Found - /auth/verify-token"
```
# 정상: 이 엔드포인트는 선택사항
# 토큰은 이미 저장되어 다른 API 호출 시 사용됨
```

---

## 현재 설정 확인

```dart
// Flutter 앱에서 현재 설정 출력
ApiConfig.printCurrentConfig();

// 출력:
// 🔧 API Configuration:
//    Environment: development
//    Base URL: http://localhost:3000
//    Full API URL: http://localhost:3000/api/v1
//    Timeout: 60s
//    Max Retries: 5
//    Retry Delay: 2000ms
//    Logging: true
```

---

## 디버깅 도구

### Firebase 토큰 디버그
```dart
await FirebaseTokenService.debugTokenInfo();

// 출력:
// 🔍 [Token Debug] ================
//    사용자 UID: abc123
//    이메일: user@example.com
//    토큰 길이: 1024
//    발급 시간: 2025-10-31 12:00:00
//    만료 시간: 2025-10-31 13:00:00
//    서명 제공자: google.com
// ================================
```

### 백엔드 연결 테스트
```dart
final isConnected = await BackendTokenService.testBackendConnection();
print('백엔드 연결: ${isConnected ? "성공" : "실패"}');
```

---

## 주요 클래스

### 1. FirebaseTokenService
```dart
// Firebase ID Token 관리
await FirebaseTokenService.getIdToken()           // 토큰 획득
await FirebaseTokenService.saveTokenToStorage()   // 토큰 저장
await FirebaseTokenService.refreshAndSaveToken()  // 토큰 갱신
await FirebaseTokenService.isTokenValid()         // 유효성 검증
await FirebaseTokenService.clearToken()           // 로그아웃
```

### 2. BackendApiClient
```dart
// HTTP 클라이언트 (토큰 자동 추가)
final client = BackendApiClient.instance;
await client.get('/pets')                         // GET
await client.post('/pets', data: {...})           // POST
await client.put('/pets/:id', data: {...})        // PUT
await client.delete('/pets/:id')                  // DELETE
```

### 3. BackendTokenService
```dart
// 백엔드 인증 서비스
await BackendTokenService.authenticateWithBackend()  // 전체 인증
await BackendTokenService.sendTokenToBackend()       // 토큰 전송
await BackendTokenService.syncUserToBackend()        // 사용자 동기화
await BackendTokenService.testBackendConnection()    // 연결 테스트
```

### 4. BackendPetApiService
```dart
// 펫 API 서비스
await BackendPetApiService.getAllPets()           // GET /pets
await BackendPetApiService.getPetById(id)         // GET /pets/:id
await BackendPetApiService.createPet(pet)         // POST /pets
await BackendPetApiService.updatePet(pet)         // PUT /pets/:id
await BackendPetApiService.deletePet(id)          // DELETE /pets/:id
```

---

## 예제 코드

### 로그인 후 펫 조회
```dart
// 1. Google 로그인
final authController = ref.read(authControllerProvider.notifier);
final loginResult = await authController.loginWithGoogle();

if (loginResult.isSuccess) {
  print('✅ 로그인 성공');
  
  // 2. 펫 목록 조회 (토큰 자동 추가!)
  final petsResult = await BackendPetApiService.getAllPets();
  
  if (petsResult.isSuccess) {
    final pets = petsResult.dataOrNull ?? [];
    print('✅ 펫 ${pets.length}마리 조회 성공');
  }
}
```

### 새 펫 생성
```dart
final newPet = PetProfileEntity(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'テスト',
  type: 'dog',
  breed: '柴犬',
  birthDate: DateTime(2020, 1, 15),
  gender: 'male',
  weight: 8.5,
  ownerId: '', // 백엔드에서 토큰으로 자동 설정
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final result = await BackendPetApiService.createPet(newPet);

if (result.isSuccess) {
  print('✅ 펫 생성 성공: ${result.dataOrNull?.name}');
}
```

---

## 환경별 설정

### .env 파일 설정

```bash
# .env (루트 디렉토리)
DEV_API_BASE_URL=http://localhost:3000
# Android 에뮬레이터용: http://10.0.2.2:3000

STAGING_API_BASE_URL=https://staging-api.aipet.com
PROD_API_BASE_URL=https://api.aipet.com
```

---

## 보안 고려사항

### ✅ 안전한 것
- Firebase ID Token은 HTTP 요청 헤더로만 전송
- SecureStorage에 암호화 저장
- 1시간마다 자동 만료 (Firebase 기본값)
- 401 에러 시 자동 갱신

### ⚠️ 주의사항
- Firebase Service Account Key는 **절대** 프론트엔드에 포함하지 말 것
- 백엔드에서만 사용
- `.gitignore`에 추가 필수

---

**프론트엔드 구현 완료!** 🎉  
**백엔드만 구현하면 바로 사용 가능합니다!** 🚀

