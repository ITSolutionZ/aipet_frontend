# 🔐 Firebase Auth 개선사항 (2025-11-11)

## 📋 개요

이 문서는 AIPet Frontend 프로젝트의 Firebase Authentication 구현에 대한 최신 개선사항을 설명합니다.
Firebase Auth 공식 문서(2025년 기준)의 베스트 프랙티스를 적용하여 실시간 인증 상태 관리, 토큰 자동 갱신, 라우팅 가드 등을 개선했습니다.

## ✅ 기존 구현 현황

프로젝트는 이미 다음과 같은 훌륭한 Firebase Auth 구현을 가지고 있었습니다:

### 1. Clean Architecture 완전 준수
- **Domain Layer**: `AuthRepository` 인터페이스, `AuthUser` 엔티티, UseCase 패턴
- **Data Layer**: `FirebaseAuthRealImpl`, `LocalAuthImpl` 구현체
- **Presentation Layer**: `AuthController`, `AuthFormState`

### 2. 다양한 인증 방법 지원
- ✅ 이메일/비밀번호 로그인 및 회원가입
- ✅ Google Sign-In (OAuth 2.0)
- ✅ Apple Sign-In (Sign in with Apple)
- ✅ LINE 로그인 (OAuth 2.0)

### 3. 백엔드 연동
- ✅ Firebase ID Token → 백엔드 JWT 교환
- ✅ 서버 토큰 SecureStorage 저장
- ✅ 토큰 만료 시간 관리

### 4. 보안 기능
- ✅ 비밀번호 재설정
- ✅ 이메일 인증
- ✅ 계정 삭제
- ✅ SecureStorage를 통한 안전한 토큰 저장

## 🚀 새로운 개선사항

### 1. 실시간 인증 상태 스트림 프로바이더 (auth_state_provider.dart)

Firebase Auth의 세 가지 핵심 스트림을 Riverpod 프로바이더로 제공합니다:

#### a. authStateChanges() - 로그인/로그아웃 감지
```dart
@riverpod
Stream<User?> authStateStream(AuthStateStreamRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}
```

**사용 예시:**
```dart
final authState = ref.watch(authStateStreamProvider);
authState.when(
  data: (user) => user != null ? HomeScreen() : LoginScreen(),
  loading: () => LoadingScreen(),
  error: (error, stack) => ErrorScreen(error),
);
```

#### b. idTokenChanges() - 토큰 갱신 감지 (신규 추가!)
```dart
@riverpod
Stream<User?> idTokenStream(IdTokenStreamRef ref) {
  return FirebaseAuth.instance.idTokenChanges();
}
```

**특징:**
- 토큰이 만료되어 자동 갱신될 때 이벤트 발생
- 백엔드 API 호출 시 최신 토큰 보장
- Custom Claims 업데이트 감지

**사용 예시:**
```dart
// 백엔드 API 호출 전 최신 토큰 확인
final tokenState = ref.watch(idTokenStreamProvider);
tokenState.when(
  data: (user) {
    if (user != null) {
      final token = await user.getIdToken(true);
      await callBackendAPI(token);
    }
  },
  // ...
);
```

#### c. userChanges() - 사용자 프로필 변경 감지 (신규 추가!)
```dart
@riverpod
Stream<User?> userChangesStream(UserChangesStreamRef ref) {
  return FirebaseAuth.instance.userChanges();
}
```

**특징:**
- `updateEmail`, `updatePassword`, `updateProfile` 등의 변경사항 감지
- 사용자 프로필 화면에서 실시간 업데이트 반영

**사용 예시:**
```dart
// 프로필 화면에서 실시간 업데이트
final userState = ref.watch(userChangesStreamProvider);
userState.when(
  data: (user) => ProfileView(
    email: user?.email,
    displayName: user?.displayName,
    photoURL: user?.photoURL,
  ),
  // ...
);
```

### 2. 고급 토큰 관리 기능 (firebase_auth_real_impl.dart)

#### a. forceRefresh 파라미터 추가
```dart
Future<String?> getCurrentUserIdToken({bool forceRefresh = false}) async {
  final user = _firebaseAuth.currentUser;
  if (user == null) return null;

  // forceRefresh=true로 최신 토큰 강제 획득
  return await user.getIdToken(forceRefresh);
}
```

**베스트 프랙티스:**
- **일반적인 경우**: `forceRefresh=false` (기본값) → 캐시된 토큰 사용
- **Custom Claims 업데이트 후**: `forceRefresh=true` → 서버에서 새 토큰 획득
- **토큰 만료 의심 시**: `forceRefresh=true` → 강제 갱신

#### b. Custom Claims 관리 (신규 추가!)
```dart
/// Custom Claims 전체 확인
Future<Map<String, dynamic>?> getCustomClaims({bool forceRefresh = false}) async {
  final user = _firebaseAuth.currentUser;
  if (user == null) return null;

  final idTokenResult = await user.getIdTokenResult(forceRefresh);
  return idTokenResult.claims;
}

/// 특정 Custom Claim 값 확인
Future<dynamic> getCustomClaim(String key, {bool forceRefresh = false}) async {
  final claims = await getCustomClaims(forceRefresh: forceRefresh);
  return claims?[key];
}
```

**사용 예시:**
```dart
// 관리자 권한 확인
final isAdmin = await repository.getCustomClaim('admin', forceRefresh: true);
if (isAdmin == true) {
  // 관리자 기능 활성화
}

// 프리미엄 사용자 확인
final isPremium = await repository.getCustomClaim('isPremium');
if (isPremium == true) {
  // 프리미엄 기능 활성화
}
```

**Firebase Admin SDK 연동 (백엔드):**
```javascript
// Node.js 백엔드에서 Custom Claims 설정
const admin = require('firebase-admin');

await admin.auth().setCustomUserClaims(uid, {
  admin: true,
  role: 'premium',
  subscriptionTier: 'gold',
});
```

**중요:** Admin SDK에서 설정한 Custom Claims는 기존 토큰에 즉시 반영되지 않습니다.
프론트엔드에서 `forceRefresh=true`로 호출하여 최신 토큰을 가져와야 합니다.

### 3. 라우팅 가드 시스템 (app/router/guards/auth_guard.dart)

GoRouter와 통합되는 다양한 인증 가드를 제공합니다:

#### a. requireAuth - 로그인 필수
```dart
static String? requireAuth(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return AppRouter.loginRoute; // 로그인 화면으로 리다이렉트
  }

  return null; // 진행 허용
}
```

**사용 예시:**
```dart
GoRoute(
  path: '/home',
  redirect: AuthGuard.requireAuth,
  builder: (context, state) => HomeScreen(),
)
```

#### b. requireGuest - 비로그인 사용자만 접근
```dart
static String? requireGuest(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    return AppRouter.homeRoute; // 이미 로그인됨 → 홈으로
  }

  return null; // 진행 허용
}
```

**사용 예시:**
```dart
GoRoute(
  path: '/login',
  redirect: AuthGuard.requireGuest, // 로그인된 사용자는 접근 불가
  builder: (context, state) => LoginScreen(),
),
GoRoute(
  path: '/signup',
  redirect: AuthGuard.requireGuest,
  builder: (context, state) => SignupScreen(),
)
```

#### c. requireEmailVerified - 이메일 인증 필수
```dart
static String? requireEmailVerified(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return AppRouter.loginRoute;
  }

  if (!user.emailVerified) {
    return AppRouter.emailVerificationRoute; // 인증 안내 화면
  }

  return null;
}
```

**사용 예시:**
```dart
GoRoute(
  path: '/sensitive-data',
  redirect: AuthGuard.requireEmailVerified,
  builder: (context, state) => SensitiveDataScreen(),
)
```

#### d. requireAdmin - 관리자 권한 필수 (신규 추가!)
```dart
static Future<String?> requireAdmin(BuildContext context, GoRouterState state) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return AppRouter.loginRoute;
  }

  // Custom Claims 확인
  final idTokenResult = await user.getIdTokenResult();
  final isAdmin = idTokenResult.claims?['admin'] == true;

  if (!isAdmin) {
    return AppRouter.homeRoute; // 권한 없음 → 홈으로
  }

  return null;
}
```

**사용 예시:**
```dart
GoRoute(
  path: '/admin',
  redirect: AuthGuard.requireAdmin,
  builder: (context, state) => AdminDashboard(),
)
```

#### e. requireBackendAuth - 백엔드 토큰 필수
```dart
static Future<String?> requireBackendAuth(BuildContext context, GoRouterState state) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return AppRouter.loginRoute;
  }

  // TODO: 백엔드 JWT 토큰 확인
  // final serverToken = await getServerToken();
  // if (serverToken == null) {
  //   return AppRouter.loginRoute;
  // }

  return null;
}
```

### 4. 편리한 인증 상태 프로바이더

#### a. 현재 사용자 정보 (AuthUser 엔티티)
```dart
@riverpod
Stream<AuthUser?> currentAuthUser(CurrentAuthUserRef ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield null;
    } else {
      yield AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        // ...
      );
    }
  }
}
```

**사용 예시:**
```dart
final currentUser = ref.watch(currentAuthUserProvider);
currentUser.when(
  data: (user) {
    if (user != null) {
      return Text('안녕하세요, ${user.displayName}님!');
    } else {
      return Text('로그인이 필요합니다.');
    }
  },
  // ...
);
```

#### b. 로그인 상태 확인 (boolean)
```dart
@riverpod
Stream<bool> isUserLoggedIn(IsUserLoggedInRef ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    yield user != null;
  }
}
```

**사용 예시:**
```dart
final isLoggedIn = ref.watch(isUserLoggedInProvider);
isLoggedIn.when(
  data: (loggedIn) {
    if (loggedIn) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  },
  // ...
);
```

#### c. Firebase ID Token 제공
```dart
@riverpod
Future<String?> currentUserIdToken(CurrentUserIdTokenRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  // forceRefresh=true로 항상 최신 토큰 획득
  return await user.getIdToken(true);
}
```

**사용 예시:**
```dart
// 백엔드 API 호출
final idToken = await ref.read(currentUserIdTokenProvider.future);
if (idToken != null) {
  final response = await dio.get('/api/pets',
    options: Options(headers: {'Authorization': 'Bearer $idToken'}),
  );
}
```

#### d. 서버 JWT 토큰 제공
```dart
@riverpod
Future<String?> currentServerToken(CurrentServerTokenRef ref) async {
  final repository = ref.read(authRepositoryProvider);

  // 1. 저장된 서버 토큰 확인
  final storedToken = await repository.getStoredServerToken();
  if (storedToken != null) {
    return storedToken;
  }

  // 2. Firebase ID Token으로 서버 토큰 교환
  final idToken = await ref.read(currentUserIdTokenProvider.future);
  if (idToken == null) return null;

  return await repository.exchangeServerToken(idToken);
}
```

#### e. 완전한 인증 상태 확인
```dart
@riverpod
Future<bool> isFullyAuthenticated(IsFullyAuthenticatedRef ref) async {
  // Firebase + 서버 JWT 모두 유효한지 확인
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final serverToken = await ref.read(currentServerTokenProvider.future);
  if (serverToken == null) return false;

  return true;
}
```

## 📚 Firebase Auth 베스트 프랙티스 (2025년 기준)

### 1. 인증 상태 관리

#### ❌ 잘못된 방법
```dart
// 일회성 체크 - 상태 변화를 감지하지 못함
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  print('로그인됨');
}
```

#### ✅ 올바른 방법
```dart
// 스트림으로 실시간 감지
FirebaseAuth.instance.authStateChanges().listen((user) {
  if (user != null) {
    print('로그인됨: ${user.email}');
  } else {
    print('로그아웃됨');
  }
});

// 또는 Riverpod 프로바이더 사용
final authState = ref.watch(authStateStreamProvider);
```

### 2. 토큰 관리

#### ❌ 잘못된 방법
```dart
// 캐시된 토큰을 계속 사용 - 만료될 수 있음
final token = await user.getIdToken();
```

#### ✅ 올바른 방법
```dart
// 중요한 API 호출 전에는 강제 갱신
final token = await user.getIdToken(true); // forceRefresh=true

// 또는 idTokenChanges()로 토큰 변경 감지
FirebaseAuth.instance.idTokenChanges().listen((user) {
  if (user != null) {
    final token = await user.getIdToken();
    // 최신 토큰 사용
  }
});
```

### 3. Custom Claims 관리

#### ❌ 잘못된 방법
```dart
// Admin SDK에서 Claims 업데이트 후 바로 확인
await admin.auth().setCustomUserClaims(uid, { admin: true });

// 프론트엔드에서 바로 확인 (❌ 이전 토큰 사용)
final idTokenResult = await user.getIdTokenResult();
final isAdmin = idTokenResult.claims?['admin']; // null! (이전 토큰)
```

#### ✅ 올바른 방법
```dart
// Admin SDK에서 Claims 업데이트
await admin.auth().setCustomUserClaims(uid, { admin: true });

// 프론트엔드에서 강제 갱신 후 확인
final idTokenResult = await user.getIdTokenResult(true); // forceRefresh=true
final isAdmin = idTokenResult.claims?['admin']; // true ✅
```

### 4. 에러 처리

#### ✅ Firebase Auth 에러 코드 처리
```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      return '사용자를 찾을 수 없습니다';
    case 'wrong-password':
      return '비밀번호가 틀렸습니다';
    case 'invalid-email':
      return '이메일 형식이 올바르지 않습니다';
    case 'user-disabled':
      return '비활성화된 계정입니다';
    case 'too-many-requests':
      return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요';
    default:
      return '로그인에 실패했습니다: ${e.message}';
  }
}
```

### 5. 보안 고려사항

#### a. 토큰 저장
```dart
// ✅ SecureStorage 사용
final storage = FlutterSecureStorage();
await storage.write(key: 'server_token', value: token);

// ❌ SharedPreferences 사용 (보안 취약)
final prefs = await SharedPreferences.getInstance();
await prefs.setString('server_token', token); // 암호화되지 않음!
```

#### b. 토큰 전송
```dart
// ✅ HTTPS 사용 + Authorization 헤더
final response = await dio.get(
  'https://api.example.com/pets',
  options: Options(
    headers: {'Authorization': 'Bearer $token'},
  ),
);

// ❌ HTTP 사용 또는 URL 파라미터에 토큰 포함
final response = await dio.get('http://api.example.com/pets?token=$token');
```

## 🔗 백엔드 통합

프로젝트는 Node.js + Express 백엔드와 통합되어 있습니다:

### 백엔드 인증 흐름

```
1. 프론트엔드: Firebase Auth 로그인
   ↓
2. Firebase: ID Token 발급
   ↓
3. 프론트엔드 → 백엔드: ID Token 전송
   ↓
4. 백엔드: Firebase Admin SDK로 ID Token 검증
   ↓
5. 백엔드 → 프론트엔드: 서버 JWT 발급
   ↓
6. 프론트엔드: 서버 JWT를 SecureStorage에 저장
   ↓
7. 이후 API 호출: 서버 JWT 사용
```

### 백엔드 미들웨어 예시 (Node.js)

```javascript
// src/middlewares/auth.middleware.js
const admin = require('firebase-admin');

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

    // Firebase Admin SDK로 토큰 검증
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

### API 엔드포인트 보호

```javascript
// src/routes/pet.routes.js
const express = require('express');
const { authenticateFirebase } = require('../middlewares/auth.middleware');
const { getPets, createPet } = require('../controllers/pet.controller');

const router = express.Router();

// 모든 펫 엔드포인트는 인증 필요
router.get('/pets', authenticateFirebase, getPets);
router.post('/pets', authenticateFirebase, createPet);

module.exports = router;
```

## 📝 사용 예시

### 1. 로그인 화면에서 실시간 인증 상태 처리

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실시간 인증 상태 감지
    final authState = ref.watch(authStateStreamProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // 로그인됨 → 홈 화면 표시
          return HomeContent();
        } else {
          // 로그아웃됨 → 로그인 화면 표시
          return LoginScreen();
        }
      },
      loading: () => LoadingScreen(),
      error: (error, stack) => ErrorScreen(error: error),
    );
  }
}
```

### 2. 백엔드 API 호출 시 최신 토큰 사용

```dart
class PetRepository {
  final Dio _dio;
  final Ref _ref;

  Future<List<Pet>> getPets() async {
    // 최신 Firebase ID Token 획득
    final idToken = await _ref.read(currentUserIdTokenProvider.future);

    if (idToken == null) {
      throw Exception('로그인이 필요합니다');
    }

    // 백엔드 API 호출
    final response = await _dio.get(
      '/api/v1/pets',
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );

    return (response.data['data'] as List)
        .map((json) => Pet.fromJson(json))
        .toList();
  }
}
```

### 3. Custom Claims 기반 UI 제어

```dart
class AdminPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(authRepositoryProvider);

    return FutureBuilder<bool>(
      future: repository.getCustomClaim('admin', forceRefresh: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          // 관리자 기능 표시
          return AdminDashboard();
        } else {
          // 권한 없음
          return Text('관리자 권한이 필요합니다');
        }
      },
    );
  }
}
```

### 4. 라우팅 가드 적용

```dart
// app/router/app_router.dart
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        // 인증 필요 (로그인 필수)
        GoRoute(
          path: '/home',
          redirect: AuthGuard.requireAuth,
          builder: (context, state) => HomeScreen(),
        ),

        // 비로그인 사용자만 접근 가능
        GoRoute(
          path: '/login',
          redirect: AuthGuard.requireGuest,
          builder: (context, state) => LoginScreen(),
        ),

        // 관리자만 접근 가능
        GoRoute(
          path: '/admin',
          redirect: AuthGuard.requireAdmin,
          builder: (context, state) => AdminDashboard(),
        ),
      ],
    );
  }
}
```

## 🧪 테스트 가이드

### 1. 인증 상태 스트림 테스트

```dart
void main() {
  group('AuthStateStream Tests', () {
    late MockFirebaseAuth mockAuth;
    late StreamController<User?> authStateController;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authStateController = StreamController<User?>();

      when(mockAuth.authStateChanges())
          .thenAnswer((_) => authStateController.stream);
    });

    test('로그인 시 사용자 정보 emit', () async {
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');

      // 로그인 이벤트 발생
      authStateController.add(mockUser);

      // 스트림 검증
      await expectLater(
        mockAuth.authStateChanges(),
        emits(mockUser),
      );
    });

    test('로그아웃 시 null emit', () async {
      // 로그아웃 이벤트 발생
      authStateController.add(null);

      // 스트림 검증
      await expectLater(
        mockAuth.authStateChanges(),
        emits(null),
      );
    });
  });
}
```

### 2. Custom Claims 테스트

```dart
void main() {
  group('Custom Claims Tests', () {
    late FirebaseAuthRealImpl repository;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      repository = FirebaseAuthRealImpl();

      when(mockAuth.currentUser).thenReturn(mockUser);
    });

    test('관리자 권한 확인', () async {
      // Custom Claims 설정
      final mockIdTokenResult = MockIdTokenResult();
      when(mockIdTokenResult.claims).thenReturn({
        'admin': true,
        'role': 'super_admin',
      });

      when(mockUser.getIdTokenResult(any))
          .thenAnswer((_) async => mockIdTokenResult);

      // 테스트
      final isAdmin = await repository.getCustomClaim('admin');
      expect(isAdmin, true);

      final role = await repository.getCustomClaim('role');
      expect(role, 'super_admin');
    });
  });
}
```

## 🔧 추가 개선 제안

### 1. 이메일 인증 화면 구현
현재 `AuthGuard.requireEmailVerified`는 TODO 상태입니다.
이메일 인증 안내 화면을 구현하면 더 완성도 높은 인증 플로우를 제공할 수 있습니다.

### 2. 리프레시 토큰 자동 갱신
`idTokenChanges()` 스트림을 활용하여 토큰이 자동 갱신될 때 백엔드 서버 토큰도 함께 갱신하는 로직을 추가할 수 있습니다.

```dart
@riverpod
class TokenRefreshService extends _$TokenRefreshService {
  @override
  FutureOr<void> build() async {
    // idTokenChanges 구독
    final subscription = FirebaseAuth.instance.idTokenChanges().listen((user) async {
      if (user != null) {
        // Firebase 토큰이 갱신되면 서버 토큰도 갱신
        final newIdToken = await user.getIdToken(true);
        final repository = ref.read(authRepositoryProvider);
        await repository.exchangeServerToken(newIdToken);
      }
    });

    // Provider가 dispose될 때 구독 취소
    ref.onDispose(() {
      subscription.cancel();
    });
  }
}
```

### 3. 오프라인 지원 강화
현재는 온라인 상태를 가정하고 있습니다.
오프라인 상태에서도 저장된 토큰으로 제한적인 기능을 제공하거나,
온라인 복귀 시 자동으로 토큰을 갱신하는 로직을 추가할 수 있습니다.

### 4. 멀티 플랫폼 지원
웹 플랫폼에서는 Persistence 설정이 필요합니다:

```dart
// Web 플랫폼에서 Persistence 설정
if (kIsWeb) {
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
}
```

## 📚 참고 자료

- [Firebase Auth Flutter 공식 문서](https://firebase.google.com/docs/auth/flutter/start)
- [FlutterFire Auth 사용법](https://firebase.flutter.dev/docs/auth/usage/)
- [Firebase Admin SDK 문서](https://firebase.google.com/docs/admin/setup)
- [Riverpod 공식 문서](https://riverpod.dev)
- [GoRouter 공식 문서](https://pub.dev/packages/go_router)

## 📄 변경 이력

### 2025-11-11
- ✅ 실시간 인증 상태 스트림 프로바이더 추가
- ✅ `idTokenChanges()`, `userChanges()` 스트림 지원
- ✅ Custom Claims 관리 기능 추가
- ✅ `forceRefresh` 파라미터 추가
- ✅ 라우팅 가드 시스템 구현
- ✅ 백엔드 통합 문서화
- ✅ 베스트 프랙티스 가이드 작성

## 🙋 FAQ

### Q: authStateChanges와 idTokenChanges의 차이는 무엇인가요?
**A:**
- `authStateChanges()`: 로그인/로그아웃 시에만 이벤트 발생
- `idTokenChanges()`: 로그인/로그아웃 + 토큰 갱신/만료 시에도 이벤트 발생
- 백엔드 API 호출이 많은 경우 `idTokenChanges()`를 사용하여 항상 최신 토큰을 유지하세요.

### Q: Custom Claims는 언제 사용하나요?
**A:** 사용자 역할(admin, moderator), 구독 상태(premium, free), 권한 등 커스텀 메타데이터를 저장할 때 사용합니다.
Firebase Admin SDK에서만 설정할 수 있으며, 프론트엔드에서는 읽기만 가능합니다.

### Q: forceRefresh는 언제 사용하나요?
**A:**
1. Custom Claims 업데이트 직후
2. 401 Unauthorized 에러 발생 시 (토큰 만료 의심)
3. 중요한 API 호출 전 (결제, 개인정보 수정 등)

일반적인 경우에는 `forceRefresh=false`(기본값)를 사용하여 캐시된 토큰을 활용하세요.

### Q: 백엔드 서버 토큰은 왜 필요한가요?
**A:** Firebase ID Token은 1시간마다 만료되며, Firebase Admin SDK로만 검증 가능합니다.
백엔드에서 자체 JWT를 발급하면:
- 만료 시간을 자유롭게 설정 (예: 7일)
- Firebase에 의존하지 않는 독립적인 인증
- 추가 사용자 정보 저장 가능

---

**Made with ❤️ by AIPet Team**
