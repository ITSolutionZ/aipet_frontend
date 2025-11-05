# 🚀 AIPet Backend 설치 가이드

## 📋 사전 요구사항

- Node.js 18+ 설치
- MySQL 8.0+ 설치
- Firebase 프로젝트 생성
- Git

---

## 1️⃣ MySQL 데이터베이스 설정

### macOS (Homebrew)

```bash
# MySQL 설치
brew install mysql

# MySQL 시작
brew services start mysql

# MySQL 접속
mysql -u root -p
```

### 데이터베이스 생성

```sql
CREATE DATABASE aipet_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 (선택사항)
CREATE USER 'aipet_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON aipet_db.* TO 'aipet_user'@'localhost';
FLUSH PRIVILEGES;

-- 확인
SHOW DATABASES;
USE aipet_db;
```

---

## 2️⃣ Firebase 설정

### Firebase Console에서 설정

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. 프로젝트 생성 (이미 있으면 선택)
3. **프로젝트 설정** → **서비스 계정** 이동
4. **새 비공개 키 생성** 클릭
5. JSON 파일 다운로드

### 환경 변수에 Firebase 정보 추가

다운로드한 JSON 파일에서 정보를 복사하여 `.env` 파일에 추가:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project-id.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk...
```

⚠️ **주의:** FIREBASE_PRIVATE_KEY는 개행 문자(`\n`)를 그대로 유지해야 합니다!

---

## 3️⃣ 백엔드 설치

```bash
# 프로젝트 디렉토리로 이동
cd /Users/apple/Documents/Github/aipet/backend

# 의존성 설치
npm install

# 환경 변수 파일 생성
cp .env.example .env

# .env 파일 수정 (위의 Firebase 정보 입력)
nano .env
```

### .env 파일 예시

```env
# Server
NODE_ENV=development
PORT=3000
API_VERSION=v1

# MySQL
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=aipet_db

# Firebase (위에서 복사한 정보)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@...
FIREBASE_CLIENT_ID=your-client-id

# CORS
CORS_ORIGIN=http://localhost:*,http://10.0.2.2:*

# Security
JWT_SECRET=your-jwt-secret-key
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

## 4️⃣ 서버 시작

```bash
# 개발 모드 (nodemon - 자동 재시작)
npm run dev

# 프로덕션 모드
npm start
```

### 성공 시 출력

```
🚀 AIPet Backend 서버 시작 중...

📱 Firebase Admin SDK 초기화 중...
✅ Firebase Admin SDK 초기화 성공
🗄️  데이터베이스 연결 확인 중...
✅ MySQL 데이터베이스 연결 성공
📊 데이터베이스 테이블 초기화 중...
✅ 데이터베이스 테이블 초기화 완료

✅ 서버 시작 완료!

====================================
🌐 서버 주소: http://localhost:3000
📡 API 엔드포인트: http://localhost:3000/api/v1
🔧 환경: development
====================================
```

---

## 5️⃣ API 테스트

### 헬스 체크

```bash
curl http://localhost:3000/

# 응답:
# {
#   "success": true,
#   "message": "AIPet Backend API",
#   "status": "running"
# }
```

### 데이터베이스 확인

```bash
mysql -u root -p

USE aipet_db;
SHOW TABLES;

# 출력:
# +--------------------+
# | Tables_in_aipet_db |
# +--------------------+
# | users              |
# | pets               |
# | vaccinations       |
# | medical_records    |
# | weight_history     |
# | walks              |
# | feedings           |
# | notifications      |
# | activities         |
# +--------------------+
```

---

## 6️⃣ Android 에뮬레이터 연결 (Flutter 앱용)

Android 에뮬레이터에서는 `localhost`가 에뮬레이터 자체를 가리킵니다.

### ADB Reverse 사용 (권장)

```bash
# 포트 포워딩
adb reverse tcp:3000 tcp:3000

# 확인
adb reverse --list
```

### 또는 10.0.2.2 사용

Flutter 앱의 `.env` 파일에서:

```env
DEV_API_BASE_URL=http://10.0.2.2:3000
```

---

## 🐛 트러블슈팅

### 문제 1: MySQL 연결 실패

```bash
# MySQL 실행 확인
brew services list

# MySQL 재시작
brew services restart mysql

# 권한 확인
mysql -u root -p
GRANT ALL PRIVILEGES ON aipet_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

### 문제 2: Firebase 인증 실패

```
❌ Firebase Admin SDK 초기화 실패
```

**해결 방법:**

1. `.env` 파일의 Firebase 정보가 올바른지 확인
2. FIREBASE_PRIVATE_KEY에 `\n` 이스케이프가 있는지 확인
3. Firebase Console에서 Service Account JSON 파일 재다운로드

### 문제 3: 포트 충돌

```
Error: listen EADDRINUSE: address already in use :::3000
```

**해결 방법:**

```bash
# 3000 포트 사용 프로세스 확인
lsof -i :3000

# 프로세스 종료
kill -9 <PID>

# 또는 .env에서 다른 포트 사용
PORT=3001
```

### 문제 4: 의존성 설치 오류

```bash
# npm 캐시 삭제
npm cache clean --force

# node_modules 삭제 후 재설치
rm -rf node_modules package-lock.json
npm install
```

---

## 📚 다음 단계

1. **API 문서 확인**: `API_DOCS.md` 참고
2. **Flutter 앱 연결**: 프론트엔드 설정
3. **테스트**: Postman이나 cURL로 API 테스트

---

## 🔒 보안 체크리스트

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는지 확인
- [ ] Firebase Service Account JSON 파일을 Git에 커밋하지 않았는지 확인
- [ ] MySQL 비밀번호가 강력한지 확인
- [ ] CORS 설정이 프로덕션에 맞게 설정되어 있는지 확인

---

**설치 완료!** 🎉

문제가 발생하면 README.md의 트러블슈팅 섹션을 참고하세요.
