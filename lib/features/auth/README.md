# Auth Feature - 인증 기능

## 📋 개요

Auth 기능은 AI Pet 앱의 사용자 인증을 담당합니다. Firebase Auth를 기반으로 하며, 개발 중에는 간단한 검증만 수행하여 빠른 개발이 가능합니다.

## 🏗️ 아키텍처

### Clean Architecture 구조

```txt
lib/features/auth/
├── domain/                    # 도메인 레이어
│   ├── entities/             # 엔티티 (AuthUser, AuthResult)
│   ├── repositories/         # 리포지토리 인터페이스
│   └── result.dart          # Result 패턴 (Railway-oriented programming)
├── data/                     # 데이터 레이어
│   ├── repositories/         # 리포지토리 구현체
│   ├── services/            # 인증 관련 서비스
│   └── auth_providers.dart  # Riverpod 프로바이더
└── presentation/             # 프레젠테이션 레이어
    ├── screens/             # 인증 화면들
    ├── widgets/             # 인증 관련 위젯들
    └── controllers/         # 인증 컨트롤러
```

## 🔐 인증 방식

### 1. 이메일/비밀번호 로그인

- **개발 모드**: 1문자 이상 입력 시 성공
- **프로덕션 모드**: Firebase Auth 실제 검증

### 2. 소셜 로그인

- **Google**: Google Sign-In SDK 연동
- **Apple**: Apple Sign-In SDK 연동
- **LINE**: LINE Login SDK 연동

### 3. 회원가입

- **개발 모드**: 1문자 이상 입력 시 성공
- **프로덕션 모드**: Firebase Auth 실제 회원가입

## 🚀 주요 기능

### 로그인/회원가입

```dart
// AuthRepository를 통한 인증
final authRepository = ref.read(authRepositoryProvider);
final result = await authRepository.signInWithEmailAndPassword(email, password);

if (result.isSuccess) {
  // 로그인 성공
  final user = result.user;
  // 토큰 자동 저장
} else {
  // 로그인 실패
  final errorMessage = result.message;
}
```

### 토큰 관리

- **자동 저장**: 로그인 성공 시 토큰 자동 저장
- **자동 삭제**: 로그아웃 시 토큰 자동 삭제
- **보안 저장**: SecureStorage를 통한 암호화 저장

### Remember Me

- **이메일 저장**: 사용자가 체크한 경우 이메일만 저장
- **보안**: 패스워드는 저장하지 않음
- **자동 로드**: 앱 재시작 시 저장된 이메일 자동 로드

## 🔧 개발 모드 vs 프로덕션 모드

### 개발 모드 (현재)

```dart
// 간단한 검증만 수행
if (email.isEmpty || password.isEmpty) {
  return AuthResult.failure('メールアドレスとパスワードを入力してください');
}

// Mock 사용자 생성
final mockUser = AuthUser(
  uid: 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
  email: email,
  displayName: email.split('@')[0],
  // ... 기타 필드
);
```

### 프로덕션 모드 (향후)

```dart
// 실제 Firebase Auth 호출
final credential = await _auth.signInWithEmailAndPassword(email, password);
final user = credential.user;

// 백엔드 API 호출
final backendResponse = await HttpClientService.instance.post('/auth/login', {
  'idToken': await FirebaseTokenService.getCurrentIdToken()
});
```

## 📱 UI 컴포넌트

### AuthFormState

```dart
class AuthFormState {
  final String email;
  final String password;
  final String username;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool rememberMe;
  final bool isLoading;
  final String? error;
}
```

### 상태 관리

```dart
@riverpod
class AuthFormStateNotifier extends _$AuthFormStateNotifier {
  void updateEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  Future<void> login() async {
    // AuthRepository를 통한 로그인 처리
  }
}
```

## 🔄 의존성 주입

### Repository 설정

```dart
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    firebaseRepository: FirebaseAuthRepositoryImpl(),
    mockRepository: MockAuthRepositoryImpl(),
    ref: ref,
  );
}
```

### 서비스 주입

- **SecureStorageServiceV2**: 토큰 보안 저장
- **AuthConfigService**: 환경별 설정 관리
- **AuthMockDataService**: Mock 데이터 관리

## 🧪 테스트

### Mock Repository

```dart
class MockAuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email, String password,
  ) async {
    // Mock 데이터를 통한 테스트
    final mockDataService = AuthMockDataServiceImpl();
    return await mockDataService.mockLogin(email, password);
  }
}
```

### 테스트 실행

```bash
# Auth 관련 테스트만 실행
flutter test lib/features/auth/

# 전체 테스트 실행
flutter test
```

## 🚀 향후 계획

### 1단계: 개발 모드 완성 ✅

- [x] 간단한 검증 로직
- [x] Mock 사용자 생성
- [x] 토큰 자동 저장/삭제

### 2단계: Firebase Auth 연동

- [ ] 실제 Firebase Auth 호출
- [ ] ID Token 관리
- [ ] 백엔드 API 연동

### 3단계: 보안 강화

- [ ] 토큰 갱신 로직
- [ ] 에러 처리 개선
- [ ] 로깅 및 모니터링

## 📚 관련 문서

- [Firebase Auth 문서](https://firebase.flutter.dev/docs/auth/overview/)
- [Riverpod 문서](https://riverpod.dev/)
- [Clean Architecture 가이드](../README.md)

## 🐛 문제 해결

### 빌드 에러

```bash
# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 린트 검사
flutter analyze lib/features/auth/
```

### 토큰 저장 실패

- SecureStorage 권한 확인
- 디바이스 보안 설정 확인
- 로그 확인: `debugPrint('토큰 저장 실패: $e')`

---

**Auth 기능은 Firebase Auth를 기반으로 하며, 개발 중에는 빠른 개발을 위한 Mock 모드를 지원합니다.**
