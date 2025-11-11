# 🏗️ AIPet 백엔드/프론트엔드 아키텍처 분리 분석

## 📋 개요

이 문서는 AIPet 프로젝트의 백엔드와 프론트엔드 분리 구조를 분석하고,
각 레이어의 역할과 Firebase Auth 통합 방식을 설명합니다.

작성일: 2025-11-11

---

## 🗂️ 프로젝트 구조

```
aipet/
├── frontend/          # Flutter 프론트엔드 애플리케이션
│   ├── lib/
│   │   ├── app/
│   │   ├── features/
│   │   └── shared/
│   ├── android/
│   ├── ios/
│   ├── assets/
│   └── test/
│
├── backend/           # Node.js + Express 백엔드 서버
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middlewares/
│   │   ├── routes/
│   │   └── services/
│   ├── logs/
│   ├── uploads/
│   └── node_modules/
│
└── docs/              # 프로젝트 문서
```

---

## ✅ 백엔드/프론트엔드 분리 확인

### 1. 디렉토리 분리
- ✅ **완전히 분리됨**: `/frontend`와 `/backend`가 독립된 디렉토리
- ✅ **의존성 독립**: 각각 별도의 패키지 관리자 사용
  - 프론트엔드: `pubspec.yaml` (Dart/Flutter)
  - 백엔드: `package.json` (Node.js/NPM)

### 2. 코드베이스 분리
- ✅ **프론트엔드**: Flutter/Dart (`frontend/lib/`)
- ✅ **백엔드**: Node.js/JavaScript (`backend/src/`)
- ✅ **공통 코드 없음**: 각 레이어가 독립적으로 동작

### 3. 실행 환경 분리
- ✅ **프론트엔드**: 모바일 앱 (Android/iOS)
- ✅ **백엔드**: Node.js 서버 (Express)
- ✅ **독립 실행**: 각각 별도로 빌드 및 배포 가능

---

## 🔐 Firebase Auth 통합 방식

### 인증 흐름

```
┌─────────────────────────────────────────────────────────────────┐
│                         사용자                                    │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ 1. 로그인 요청
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                     프론트엔드 (Flutter)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Firebase Auth SDK                                        │  │
│  │ - signInWithEmailAndPassword()                          │  │
│  │ - signInWithGoogle()                                    │  │
│  │ - signInWithApple()                                     │  │
│  └─────────────────────┬────────────────────────────────────┘  │
│                        │                                        │
│                        │ 2. ID Token 발급                        │
│                        ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ SecureStorage                                            │  │
│  │ - Firebase ID Token 저장                                  │  │
│  │ - 서버 JWT Token 저장                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            │ 3. ID Token 전송
                            │    POST /api/v1/auth/verify-token
                            │    Authorization: Bearer <ID Token>
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                     백엔드 (Node.js)                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Auth Middleware                                          │  │
│  │ - Firebase Admin SDK로 ID Token 검증                      │  │
│  │ - admin.auth().verifyIdToken()                          │  │
│  └─────────────────────┬────────────────────────────────────┘  │
│                        │                                        │
│                        │ 4. 토큰 검증 성공                        │
│                        ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ JWT Service                                              │  │
│  │ - 서버 자체 JWT 토큰 발급 (만료: 7일)                         │  │
│  │ - 사용자 정보 포함 (uid, email, role, etc)                  │  │
│  └─────────────────────┬────────────────────────────────────┘  │
│                        │                                        │
│                        │ 5. 서버 JWT 응답                         │
│                        ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ MySQL Database                                           │  │
│  │ - 사용자 정보 저장/업데이트                                   │  │
│  │ - users, pets, activities 등                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬────────────────────────────────────┘
                            │
                            │ 6. 서버 JWT 저장
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                     프론트엔드 (Flutter)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ SecureStorage                                            │  │
│  │ - 서버 JWT 저장 (7일간 유효)                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘


[이후 API 호출 시]

프론트엔드 → 백엔드: Authorization: Bearer <서버 JWT>
백엔드: JWT 검증 → 사용자 인증 → API 처리
```

---

## 📦 프론트엔드 아키텍처 (Flutter)

### Clean Architecture + Feature-First

```
frontend/lib/
├── app/                           # 애플리케이션 레이어
│   ├── config/                    # 앱 설정
│   ├── providers/                 # 글로벌 프로바이더
│   └── router/                    # GoRouter 네비게이션
│       └── guards/                # 🆕 라우팅 가드
│           └── auth_guard.dart    # Firebase Auth 기반 가드
│
├── features/                      # 기능별 모듈 (Feature-First)
│   ├── auth/                      # 🔐 인증 기능
│   │   ├── domain/                # Domain Layer
│   │   │   ├── entities/          # AuthUser 엔티티
│   │   │   ├── repositories/      # AuthRepository 인터페이스
│   │   │   └── usecases/          # 비즈니스 로직
│   │   ├── data/                  # Data Layer
│   │   │   ├── repositories/      # Firebase Auth 구현체
│   │   │   │   ├── firebase_auth_real_impl.dart
│   │   │   │   └── local_auth_impl.dart (개발용)
│   │   │   ├── providers/         # 🆕 실시간 인증 상태 프로바이더
│   │   │   │   └── auth_state_provider.dart
│   │   │   └── services/          # 토큰 관리 서비스
│   │   └── presentation/          # Presentation Layer
│   │       ├── controllers/       # AuthController
│   │       ├── screens/           # 로그인, 회원가입 화면
│   │       └── widgets/           # 인증 관련 위젯
│   │
│   ├── pet_profile/               # 펫 프로필 관리
│   ├── walk/                      # 산책 기능
│   └── ...                        # 기타 기능들
│
└── shared/                        # 공통 리소스
    ├── services/                  # 공통 서비스
    │   ├── logger_service.dart
    │   └── secure_storage_service.dart
    └── core/
        └── services/
            └── backend_token_service.dart  # 백엔드 JWT 관리
```

### 주요 파일 역할

#### 1. Firebase Auth 구현체
**`frontend/lib/features/auth/data/repositories/firebase_auth_real_impl.dart`**

```dart
class FirebaseAuthRealImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ✅ Firebase Auth 기능
  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async { ... }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async { ... }

  @override
  Future<Result<AuthUser>> signInWithApple() async { ... }

  // ✅ 토큰 관리
  @override
  Future<String?> getCurrentUserIdToken({bool forceRefresh = false}) async { ... }

  @override
  Future<String> exchangeServerToken(String idToken) async {
    // 백엔드 API 호출: POST /auth/exchange-token
    final response = await http.post(
      Uri.parse('${AppConfig.current.apiBaseUrl}/auth/exchange-token'),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    // 서버 JWT 저장
    await saveServerToken(serverToken);
  }

  // ✅ Custom Claims 관리 (신규)
  Future<Map<String, dynamic>?> getCustomClaims({bool forceRefresh = false}) async { ... }
}
```

**특징:**
- Firebase Auth SDK 직접 사용
- 백엔드와 HTTP 통신 (토큰 교환)
- SecureStorage에 토큰 저장
- ❌ 백엔드 코드 포함 없음 (완전 분리)

#### 2. 실시간 인증 상태 프로바이더
**`frontend/lib/features/auth/data/providers/auth_state_provider.dart`**

```dart
// 🆕 Firebase Auth 상태 스트림
@riverpod
Stream<User?> authStateStream(AuthStateStreamRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

// 🆕 ID Token 변경 스트림
@riverpod
Stream<User?> idTokenStream(IdTokenStreamRef ref) {
  return FirebaseAuth.instance.idTokenChanges();
}

// 🆕 사용자 프로필 변경 스트림
@riverpod
Stream<User?> userChangesStream(UserChangesStreamRef ref) {
  return FirebaseAuth.instance.userChanges();
}

// 🆕 완전한 인증 상태 확인 (Firebase + 서버 JWT)
@riverpod
Future<bool> isFullyAuthenticated(IsFullyAuthenticatedRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final serverToken = await ref.read(currentServerTokenProvider.future);
  if (serverToken == null) return false;

  return true;
}
```

**특징:**
- Firebase Auth 스트림을 Riverpod 프로바이더로 제공
- 실시간 인증 상태 감지
- ❌ 백엔드 의존성 없음

#### 3. 라우팅 가드
**`frontend/lib/app/router/guards/auth_guard.dart`**

```dart
class AuthGuard {
  // 로그인 필수
  static String? requireAuth(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppRouter.loginRoute;
    }
    return null;
  }

  // 관리자 권한 필수
  static Future<String?> requireAdmin(
    BuildContext context,
    GoRouterState state,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return AppRouter.loginRoute;

    // Custom Claims 확인
    final idTokenResult = await user.getIdTokenResult();
    final isAdmin = idTokenResult.claims?['admin'] == true;

    if (!isAdmin) return AppRouter.homeRoute;
    return null;
  }
}
```

**특징:**
- GoRouter와 통합
- Firebase Auth 상태로 라우팅 제어
- ❌ 백엔드 API 호출 없음 (클라이언트 사이드 가드)

---

## 🖥️ 백엔드 아키텍처 (Node.js + Express)

### MVC 패턴 + Middleware

```
backend/
├── src/
│   ├── config/                    # 설정
│   │   ├── database.js            # MySQL 연결
│   │   └── firebase.js            # 🔐 Firebase Admin SDK 초기화
│   │
│   ├── middlewares/               # 미들웨어
│   │   ├── auth.middleware.js     # 🔐 Firebase ID Token 검증
│   │   ├── validation.middleware.js
│   │   └── error.middleware.js
│   │
│   ├── controllers/               # 컨트롤러
│   │   ├── auth.controller.js     # 인증 관련 비즈니스 로직
│   │   ├── pet.controller.js
│   │   └── ...
│   │
│   ├── routes/                    # 라우트
│   │   ├── auth.routes.js
│   │   ├── pet.routes.js
│   │   └── index.js
│   │
│   ├── services/                  # 서비스
│   │   └── notification.scheduler.js
│   │
│   └── server.js                  # 서버 엔트리 포인트
│
├── logs/                          # 로그 파일
├── uploads/                       # 업로드 파일
├── firebase-service-account.json  # 🔐 Firebase Admin SDK 키
├── package.json                   # Node.js 의존성
└── .env                           # 환경 변수
```

### 주요 파일 역할

#### 1. Firebase Admin SDK 초기화
**`backend/src/config/firebase.js`**

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('../../firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
```

**특징:**
- Firebase Admin SDK 사용 (프론트엔드의 Firebase Auth SDK와 다름)
- 서비스 계정 키로 인증
- ID Token 검증 권한 보유

#### 2. 인증 미들웨어
**`backend/src/middlewares/auth.middleware.js`**

```javascript
const admin = require('../config/firebase');

const authenticateFirebase = async (req, res, next) => {
  try {
    // Authorization 헤더에서 토큰 추출
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: '인증 토큰이 필요합니다'
      });
    }

    const idToken = authHeader.substring(7);

    // 🔐 Firebase Admin SDK로 ID Token 검증
    const decodedToken = await admin.auth().verifyIdToken(idToken);

    // 사용자 정보를 req.user에 저장
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name,
      claims: decodedToken, // Custom Claims 포함
    };

    next();
  } catch (error) {
    console.error('토큰 검증 실패:', error);
    return res.status(401).json({
      success: false,
      message: '유효하지 않은 토큰입니다'
    });
  }
};

module.exports = { authenticateFirebase };
```

**특징:**
- Firebase Admin SDK의 `verifyIdToken()` 사용
- 프론트엔드에서 전송한 ID Token 검증
- 검증 성공 시 `req.user`에 사용자 정보 저장
- ❌ 프론트엔드 코드 포함 없음 (완전 분리)

#### 3. 인증 컨트롤러
**`backend/src/controllers/auth.controller.js`**

```javascript
const admin = require('../config/firebase');
const jwt = require('jsonwebtoken');

// 토큰 검증 엔드포인트
const verifyToken = async (req, res) => {
  try {
    // authenticateFirebase 미들웨어를 거친 후
    // req.user에 사용자 정보가 이미 있음
    res.json({
      success: true,
      message: 'Token is valid',
      user: req.user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Token verification failed',
    });
  }
};

// 서버 JWT 발급
const exchangeToken = async (req, res) => {
  try {
    const { uid, email } = req.user;

    // 서버 자체 JWT 발급 (7일 만료)
    const serverToken = jwt.sign(
      { uid, email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      serverToken,
      expiresInHours: 168, // 7일 = 168시간
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Token exchange failed',
    });
  }
};

module.exports = {
  verifyToken,
  exchangeToken,
};
```

**특징:**
- Firebase Admin SDK로 검증된 사용자 정보 사용
- 서버 자체 JWT 발급 (만료 기간 자유롭게 설정 가능)
- MySQL에 사용자 정보 저장/업데이트
- ❌ 프론트엔드 로직 포함 없음

#### 4. 라우트 설정
**`backend/src/routes/auth.routes.js`**

```javascript
const express = require('express');
const { authenticateFirebase } = require('../middlewares/auth.middleware');
const { verifyToken, exchangeToken } = require('../controllers/auth.controller');

const router = express.Router();

// 🔐 Firebase ID Token 검증 (미들웨어 적용)
router.post('/verify-token', authenticateFirebase, verifyToken);

// 🔐 서버 JWT 토큰 교환 (미들웨어 적용)
router.post('/exchange-token', authenticateFirebase, exchangeToken);

// 🔐 현재 사용자 정보 조회 (미들웨어 적용)
router.get('/me', authenticateFirebase, (req, res) => {
  res.json({
    success: true,
    user: req.user,
  });
});

module.exports = router;
```

**특징:**
- 모든 인증 엔드포인트에 `authenticateFirebase` 미들웨어 적용
- Firebase ID Token 검증 필수
- ❌ 프론트엔드 의존성 없음

#### 5. 펫 관리 라우트 (보호된 엔드포인트)
**`backend/src/routes/pet.routes.js`**

```javascript
const express = require('express');
const { authenticateFirebase } = require('../middlewares/auth.middleware');
const { getPets, createPet, updatePet, deletePet } = require('../controllers/pet.controller');

const router = express.Router();

// 🔐 모든 펫 엔드포인트는 인증 필요
router.get('/pets', authenticateFirebase, getPets);
router.post('/pets', authenticateFirebase, createPet);
router.put('/pets/:id', authenticateFirebase, updatePet);
router.delete('/pets/:id', authenticateFirebase, deletePet);

module.exports = router;
```

**특징:**
- 모든 API 엔드포인트에 인증 미들웨어 적용
- `req.user`에서 인증된 사용자 정보 사용
- MySQL에서 사용자의 펫 데이터 CRUD

---

## 🔍 분리 검증 체크리스트

### ✅ 완전히 분리된 항목

| 항목 | 프론트엔드 | 백엔드 | 분리 여부 |
|------|-----------|--------|----------|
| **언어/프레임워크** | Dart/Flutter | JavaScript/Node.js | ✅ 완전 분리 |
| **패키지 관리** | pubspec.yaml | package.json | ✅ 완전 분리 |
| **Firebase SDK** | Firebase Auth SDK | Firebase Admin SDK | ✅ 완전 분리 |
| **데이터베이스** | SQLite (로컬) | MySQL (서버) | ✅ 완전 분리 |
| **인증 방식** | Firebase Auth 로그인 | Firebase ID Token 검증 | ✅ 완전 분리 |
| **토큰 저장** | SecureStorage | JWT (자체 발급) | ✅ 완전 분리 |
| **API 통신** | HTTP Client (Dio) | Express 서버 | ✅ 완전 분리 |
| **라우팅** | GoRouter (클라이언트) | Express Router (서버) | ✅ 완전 분리 |
| **상태 관리** | Riverpod | - | ✅ 프론트엔드 전용 |
| **데이터 검증** | Validation Utils | express-validator | ✅ 완전 분리 |
| **에러 처리** | Result 패턴 | Error Middleware | ✅ 완전 분리 |
| **로깅** | LoggerService | winston/morgan | ✅ 완전 분리 |

### ✅ 통신 방식

| 통신 유형 | 프로토콜 | 인증 방식 | 상태 |
|----------|---------|----------|------|
| 로그인 | REST API | Firebase ID Token | ✅ |
| 토큰 교환 | REST API | Firebase ID Token | ✅ |
| 펫 관리 | REST API | 서버 JWT | ✅ |
| 산책 기록 | REST API | 서버 JWT | ✅ |
| 알림 | REST API | 서버 JWT | ✅ |

---

## 🎯 핵심 요점

### 1. 완전한 분리
- ✅ **디렉토리**: `/frontend`와 `/backend` 완전 독립
- ✅ **코드베이스**: Dart vs JavaScript, 공통 코드 없음
- ✅ **의존성**: 각각 별도의 패키지 관리자
- ✅ **실행 환경**: 모바일 앱 vs 서버 애플리케이션

### 2. Firebase Auth 역할 분담
- **프론트엔드 (Firebase Auth SDK)**:
  - 사용자 로그인/회원가입 처리
  - Firebase ID Token 발급
  - 실시간 인증 상태 감지
  - 토큰 SecureStorage 저장

- **백엔드 (Firebase Admin SDK)**:
  - Firebase ID Token 검증
  - 사용자 정보 MySQL 저장
  - 서버 JWT 발급 (7일 만료)
  - Custom Claims 확인

### 3. 통신 프로토콜
- **인증 시**: Firebase ID Token (HTTP Bearer 헤더)
- **API 호출 시**: 서버 JWT (HTTP Bearer 헤더)
- **프로토콜**: REST API (JSON)
- **보안**: HTTPS + SecureStorage

### 4. 장점
- ✅ **확장성**: 각 레이어 독립적으로 스케일링 가능
- ✅ **유지보수성**: 백엔드/프론트엔드 팀이 독립적으로 개발 가능
- ✅ **보안**: 서버 사이드에서 Firebase ID Token 검증
- ✅ **유연성**: 서버 JWT 만료 기간 자유롭게 설정
- ✅ **테스트 용이성**: 각 레이어 독립적으로 테스트 가능

---

## 📝 결론

**AIPet 프로젝트는 백엔드와 프론트엔드가 완전히 분리된 구조입니다.**

- ✅ 디렉토리 구조: 완전 분리
- ✅ 코드베이스: 완전 분리 (Dart vs JavaScript)
- ✅ Firebase Auth: 역할 분담 명확 (Auth SDK vs Admin SDK)
- ✅ API 통신: REST API로 통신 (HTTP/JSON)
- ✅ 보안: 서버 사이드 토큰 검증
- ✅ 독립 실행: 각각 별도로 빌드/배포 가능

**권장사항:**
1. 현재 구조 유지 (이미 모범 사례 준수)
2. API 문서화 강화 (OpenAPI/Swagger)
3. E2E 테스트 추가 (프론트엔드 ↔ 백엔드 통합 테스트)
4. Docker Compose로 로컬 개발 환경 구성

---

**작성자**: Claude (Anthropic)
**작성일**: 2025-11-11
**문서 버전**: 1.0
