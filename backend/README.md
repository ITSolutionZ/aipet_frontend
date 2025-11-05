# 🐾 AIPet Backend API

Node.js + Express + MySQL + Firebase Auth 기반 반려동물 관리 애플리케이션 백엔드

## 📋 목차

- [기술 스택](#기술-스택)
- [시작하기](#시작하기)
- [환경 설정](#환경-설정)
- [API 문서](#api-문서)
- [데이터베이스 구조](#데이터베이스-구조)
- [프로젝트 구조](#프로젝트-구조)

## 🛠️ 기술 스택

- **Runtime**: Node.js 18+
- **Framework**: Express 4.18+
- **Database**: MySQL 8.0+
- **Authentication**: Firebase Admin SDK
- **Validation**: express-validator
- **Security**: Helmet, CORS, Rate Limiting

## 🚀 시작하기

### 1. 의존성 설치

```bash
cd backend
npm install
```

### 2. MySQL 데이터베이스 생성

```sql
CREATE DATABASE aipet_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 환경 변수 설정

`.env` 파일 생성:

```bash
cp .env.example .env
```

`.env` 파일 수정:

```env
# Server
NODE_ENV=development
PORT=3000
API_VERSION=v1

# MySQL
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=aipet_db

# Firebase Admin SDK (Firebase Console에서 가져오기)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project-id.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
```

### 4. 서버 시작

```bash
# 개발 모드 (nodemon)
npm run dev

# 프로덕션 모드
npm start
```

서버가 `http://localhost:3000`에서 실행됩니다.

### 5. Android 에뮬레이터 연결 (선택사항)

```bash
adb reverse tcp:3000 tcp:3000
```

## ⚙️ 환경 설정

### Firebase Admin SDK 설정

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. 프로젝트 설정 → 서비스 계정 → 새 비공개 키 생성
3. 다운로드한 JSON 파일에서 `.env`로 정보 복사

또는 JSON 파일을 직접 사용:

```javascript
// src/config/firebase.js
const serviceAccount = require('./firebase-service-account.json');
```

### MySQL 연결 테스트

```bash
mysql -u root -p
USE aipet_db;
SHOW TABLES;
```

## 📚 API 문서

### Base URL

```
http://localhost:3000/api/v1
```

### 인증

모든 보호된 엔드포인트는 Firebase ID Token이 필요합니다:

```http
Authorization: Bearer <Firebase_ID_Token>
```

### 엔드포인트

#### Health Check

```http
GET /
```

**Response:**

```json
{
  "success": true,
  "message": "AIPet Backend API",
  "version": "v1",
  "status": "running"
}
```

#### 인증 (Auth)

##### 1. 토큰 검증

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
    "email": "user@example.com",
    "name": "User Name"
  }
}
```

##### 2. 사용자 동기화

```http
POST /api/v1/users
Authorization: Bearer <token>
Content-Type: application/json

{
  "uid": "firebase_uid",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoURL": "https://...",
  "provider": "google"
}
```

**Response:**

```json
{
  "success": true,
  "message": "사용자가 생성되었습니다.",
  "data": {
    "id": "firebase_uid",
    "email": "user@example.com",
    "display_name": "User Name"
  }
}
```

##### 3. 현재 사용자 조회

```http
GET /api/v1/auth/me
Authorization: Bearer <token>
```

#### 펫 관리 (Pets)

##### 1. 펫 목록 조회

```http
GET /api/v1/pets
Authorization: Bearer <token>
```

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
      "weight": 8.5,
      "created_at": "2025-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

##### 2. 펫 상세 조회

```http
GET /api/v1/pets/:id
Authorization: Bearer <token>
```

##### 3. 펫 생성

```http
POST /api/v1/pets
Authorization: Bearer <token>
Content-Type: application/json

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

**Response:**

```json
{
  "success": true,
  "message": "펫이 생성되었습니다.",
  "data": {
    "id": "pet_1735891234567_abc123",
    "name": "테스트",
    "type": "dog"
  }
}
```

##### 4. 펫 수정

```http
PUT /api/v1/pets/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "업데이트된 이름",
  "weight": 9.0
}
```

##### 5. 펫 삭제

```http
DELETE /api/v1/pets/:id
Authorization: Bearer <token>
```

##### 6. 펫 통계

```http
GET /api/v1/pets/stats
Authorization: Bearer <token>
```

**Response:**

```json
{
  "success": true,
  "data": {
    "totalPets": 5,
    "byType": [
      { "type": "dog", "count": 3 },
      { "type": "cat", "count": 2 }
    ]
  }
}
```

## 🗄️ 데이터베이스 구조

### ERD

```
users (사용자)
  ├── id (Firebase UID, PK)
  ├── email
  ├── display_name
  ├── photo_url
  ├── provider (google, apple, line)
  └── created_at

pets (반려동물)
  ├── id (PK)
  ├── owner_id (FK → users.id)
  ├── name
  ├── type (dog, cat, bird, etc)
  ├── breed
  ├── birth_date
  ├── gender
  ├── weight
  ├── microchip_number
  └── is_neutered

vaccinations (예방접종)
  ├── id (PK)
  ├── pet_id (FK → pets.id)
  ├── vaccine_name
  ├── vaccination_date
  └── next_due_date

medical_records (의료 기록)
  ├── id (PK)
  ├── pet_id (FK → pets.id)
  ├── visit_date
  ├── diagnosis
  └── treatment

walks (산책 기록)
  ├── id (PK)
  ├── pet_id (FK → pets.id)
  ├── start_time
  ├── duration_minutes
  ├── distance_meters
  └── route_data (JSON)

feedings (급식 기록)
  ├── id (PK)
  ├── pet_id (FK → pets.id)
  ├── feeding_time
  ├── food_type
  └── amount_grams

notifications (알림)
  ├── id (PK)
  ├── user_id (FK → users.id)
  ├── pet_id (FK → pets.id)
  ├── title
  ├── body
  └── scheduled_at
```

### 주요 테이블

#### users

```sql
CREATE TABLE users (
  id VARCHAR(128) PRIMARY KEY COMMENT 'Firebase UID',
  email VARCHAR(255) NOT NULL UNIQUE,
  display_name VARCHAR(100),
  photo_url TEXT,
  provider VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### pets

```sql
CREATE TABLE pets (
  id VARCHAR(128) PRIMARY KEY,
  owner_id VARCHAR(128) NOT NULL,
  name VARCHAR(100) NOT NULL,
  type VARCHAR(50) NOT NULL,
  breed VARCHAR(100),
  birth_date DATE,
  gender ENUM('male', 'female', 'unknown'),
  weight DECIMAL(5,2),
  is_active BOOLEAN DEFAULT true,
  FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## 📁 프로젝트 구조

```
backend/
├── src/
│   ├── config/              # 설정 파일
│   │   ├── database.js      # MySQL 연결 및 초기화
│   │   └── firebase.js      # Firebase Admin SDK
│   ├── controllers/         # 비즈니스 로직
│   │   ├── auth.controller.js
│   │   └── pet.controller.js
│   ├── middlewares/         # 미들웨어
│   │   ├── auth.middleware.js
│   │   ├── error.middleware.js
│   │   └── validation.middleware.js
│   ├── routes/              # API 라우트
│   │   ├── index.js
│   │   ├── auth.routes.js
│   │   └── pet.routes.js
│   └── server.js            # 서버 엔트리 포인트
├── .env                     # 환경 변수 (gitignore)
├── .env.example             # 환경 변수 예제
├── package.json
└── README.md
```

## 🔒 보안

- **Firebase ID Token 검증**: 모든 보호된 엔드포인트는 Firebase Admin SDK로 토큰 검증
- **CORS**: 허용된 origin만 접근 가능
- **Helmet**: HTTP 보안 헤더 설정
- **Rate Limiting**: API 요청 횟수 제한 (15분당 100회)
- **SQL Injection 방지**: Prepared Statements 사용
- **환경 변수**: 민감한 정보는 `.env` 파일로 관리

## 🧪 테스트

```bash
# 단위 테스트
npm test

# 커버리지
npm test -- --coverage
```

## 📝 개발 가이드

### 새 엔드포인트 추가

1. **Controller 생성** (`src/controllers/`)

   ```javascript
   export const newEndpoint = async (req, res) => {
     // 로직 구현
   };
   ```

2. **Route 추가** (`src/routes/`)

   ```javascript
   router.get('/new', authenticateFirebase, newEndpoint);
   ```

3. **Validation 추가**

   ```javascript
   import { body } from 'express-validator';

   router.post('/new', [
     body('field').notEmpty().withMessage('필드는 필수입니다.'),
   ], validate, newEndpoint);
   ```

## 🐛 트러블슈팅

### 1. MySQL 연결 실패

```bash
# MySQL 서비스 확인
mysql --version
mysql -u root -p

# 권한 부여
GRANT ALL PRIVILEGES ON aipet_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Firebase 인증 실패

- `.env` 파일의 Firebase 설정 확인
- FIREBASE_PRIVATE_KEY에 `\n` 이스케이프 확인
- Firebase Console에서 Service Account 재생성

### 3. Android 에뮬레이터 연결 안 됨

```bash
# ADB reverse 재설정
adb reverse --remove tcp:3000
adb reverse tcp:3000 tcp:3000

# 또는 10.0.2.2 사용
# Flutter 앱의 .env 파일:
DEV_API_BASE_URL=http://10.0.2.2:3000
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. 서버 로그 (`console.log` 출력)
2. MySQL 로그
3. Firebase Console 인증 탭
4. 네트워크 요청 (브라우저 개발자 도구)

## 📄 라이센스

MIT

---

**Made with ❤️ by AIPet Team**
