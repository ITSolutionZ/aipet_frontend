# 📖 Swagger UI 사용 가이드

AIPet Backend API를 Swagger UI에서 테스트하는 방법을 단계별로 설명합니다.

## 🚀 시작하기

### 1. 백엔드 서버 시작

```bash
cd backend
npm start
```

서버가 시작되면 다음 메시지를 확인할 수 있습니다:

```
📖 Swagger UI: http://localhost:3000/api-docs
```

### 2. Swagger UI 접속

브라우저에서 다음 URL에 접속:

```
http://localhost:3000/api-docs
```

## 🔐 인증 설정 (Firebase ID Token)

Pet API는 모두 Firebase 인증이 필요합니다.

### 방법 1: Flutter 앱에서 토큰 획득 (권장)

1. **Flutter 앱 실행 및 로그인**
   - 이메일/비밀번호, Google, Apple 등으로 로그인

2. **Firebase ID Token 출력**

   아무 화면의 `initState()`나 버튼 클릭 이벤트에 다음 코드 추가:

   ```dart
   import 'package:firebase_auth/firebase_auth.dart';

   Future<void> printToken() async {
     final user = FirebaseAuth.instance.currentUser;
     if (user != null) {
       final token = await user.getIdToken();
       print('Firebase ID Token: $token');
     }
   }
   ```

3. **VS Code 디버그 콘솔에서 토큰 복사**

### 방법 2: Firebase Console 사용

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택 → Authentication
3. Users 탭에서 테스트 계정 생성
4. 해당 계정으로 Flutter 앱에서 로그인
5. 위 방법 1로 토큰 획득

### 방법 3: Custom Token 생성 (개발용)

```bash
node scripts/generate-test-token.js my-test-user-id
```

이 방법은 Custom Token을 생성하며, Flutter 앱에서 이 토큰으로 로그인 후 ID Token을 얻어야 합니다.

## 📝 Swagger UI에서 API 테스트하기

### Step 1: 인증 설정

1. Swagger UI 페이지 우측 상단의 **"Authorize"** 버튼 클릭
2. **BearerAuth** 섹션의 **Value** 입력란에 Firebase ID Token 붙여넣기
   ```
   예시: eyJhbGciOiJSUzI1NiIsImtpZCI6IjE4...
   ```
3. **"Authorize"** 버튼 클릭
4. **"Close"** 버튼으로 닫기

✅ 이제 모든 API 호출에 자동으로 `Authorization: Bearer {token}` 헤더가 추가됩니다.

### Step 2: API 테스트 - GET 요청 (펫 목록 조회)

1. **Pets** 섹션 펼치기
2. **GET /api/v1/pets** 클릭
3. **"Try it out"** 버튼 클릭
4. **"Execute"** 버튼 클릭
5. 응답 확인:
   ```json
   {
     "success": true,
     "data": [],
     "count": 0
   }
   ```

### Step 3: API 테스트 - POST 요청 (펫 생성)

1. **POST /api/v1/pets** 클릭
2. **"Try it out"** 버튼 클릭
3. **Request body** 섹션에서 JSON 편집:

   ```json
   {
     "name": "ポチ",
     "type": "dog",
     "breed": "柴犬",
     "birthDate": "2020-01-01",
     "gender": "male",
     "weight": 5.5,
     "color": "茶色",
     "isNeutered": false,
     "notes": "元気な犬です"
   }
   ```

4. **"Execute"** 버튼 클릭
5. 응답 확인 (201 Created):
   ```json
   {
     "success": true,
     "message": "ペットを作成しました",
     "data": {
       "id": "generated-uuid",
       "owner_id": "your-firebase-uid",
       "name": "ポチ",
       ...
     }
   }
   ```

### Step 4: API 테스트 - GET 요청 (특정 펫 조회)

1. **GET /api/v1/pets/{id}** 클릭
2. **"Try it out"** 버튼 클릭
3. **id** 파라미터에 위에서 생성된 펫의 ID 입력
4. **"Execute"** 버튼 클릭
5. 응답 확인

### Step 5: API 테스트 - PUT 요청 (펫 정보 수정)

1. **PUT /api/v1/pets/{id}** 클릭
2. **"Try it out"** 버튼 클릭
3. **id** 파라미터에 펫 ID 입력
4. **Request body**에서 수정할 필드만 입력:
   ```json
   {
     "weight": 6.0,
     "notes": "体重が増えました"
   }
   ```
5. **"Execute"** 버튼 클릭

### Step 6: API 테스트 - DELETE 요청 (펫 삭제)

1. **DELETE /api/v1/pets/{id}** 클릭
2. **"Try it out"** 버튼 클릭
3. **id** 파라미터에 펫 ID 입력
4. **"Execute"** 버튼 클릭
5. 응답 확인 (200 OK):
   ```json
   {
     "success": true,
     "message": "ペットを削除しました"
   }
   ```

## 📊 응답 코드 이해하기

| 코드 | 의미 | 설명 |
|------|------|------|
| 200 | OK | 요청 성공 (GET, PUT, DELETE) |
| 201 | Created | 리소스 생성 성공 (POST) |
| 400 | Bad Request | 요청 데이터 검증 실패 |
| 401 | Unauthorized | 인증 토큰 없음 또는 만료됨 |
| 403 | Forbidden | 권한 없음 (다른 사용자의 펫 접근 시도) |
| 404 | Not Found | 리소스를 찾을 수 없음 |
| 500 | Server Error | 서버 내부 오류 |

## 🔧 문제 해결

### 401 Unauthorized 에러

**원인:**
- Firebase ID Token이 설정되지 않았거나 만료됨 (1시간 유효)

**해결:**
1. 새로운 Firebase ID Token 획득
2. Swagger UI의 **"Authorize"** 버튼 클릭
3. 새 토큰으로 다시 인증

### 403 Forbidden 에러

**원인:**
- 다른 사용자가 소유한 펫에 접근 시도

**해결:**
- 자신이 생성한 펫의 ID만 사용
- `GET /api/v1/pets`로 자신의 펫 목록 확인

### 400 Validation Error

**원인:**
- 필수 필드 누락 (name, type)
- 잘못된 데이터 타입 (예: weight에 문자열)
- 잘못된 enum 값 (예: gender에 "other" 입력)

**해결:**
- 응답의 `errors` 배열에서 어떤 필드가 문제인지 확인
- Schema 정의 참고하여 올바른 값 입력

### CORS 에러

**원인:**
- 브라우저에서 직접 API 호출 시 CORS 정책 위반

**해결:**
- Swagger UI 사용 (자체 프록시 제공)
- 또는 백엔드의 CORS 설정 확인

## 💡 유용한 팁

### 1. 스키마 참고

각 API의 **Schema** 탭을 클릭하면:
- 요청 본문 구조
- 응답 본문 구조
- 필수/선택 필드
- 데이터 타입 및 제약사항

을 확인할 수 있습니다.

### 2. 예시 값 사용

Request body 섹션의 예시를 그대로 사용하거나 수정하여 빠르게 테스트할 수 있습니다.

### 3. cURL 명령어 복사

각 API 실행 후 **"curl"** 탭을 클릭하면 동일한 요청을 cURL 명령어로 복사할 수 있습니다.

터미널에서 직접 실행 가능:
```bash
curl -X 'GET' \
  'http://localhost:3000/api/v1/pets' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN'
```

### 4. 토큰 만료 주의

Firebase ID Token은 **1시간**마다 만료됩니다.
401 에러 발생 시 새로운 토큰으로 재인증하세요.

### 5. Swagger JSON 다운로드

API 스펙을 파일로 저장하려면:
```
http://localhost:3000/api-docs.json
```
접속하여 JSON 다운로드

## 📚 추가 리소스

- [Swagger UI 공식 문서](https://swagger.io/tools/swagger-ui/)
- [OpenAPI 3.0 Specification](https://swagger.io/specification/)
- [Firebase ID Token 가이드](https://firebase.google.com/docs/auth/admin/verify-id-tokens)

## 🎯 다음 단계

1. **프론트엔드 연동 테스트**
   - Flutter 앱에서 BackendPetApiService 호출
   - Swagger UI에서 확인한 것과 동일한 응답 확인

2. **통합 테스트 작성**
   - `backend/test/integration/pet.test.js` 참고
   - 실제 API 호출 흐름 테스트

3. **다른 API 문서화**
   - Auth API
   - User API
   - Notification API

---

**질문이나 문제가 있으면 개발팀에 문의하세요!** 🚀
