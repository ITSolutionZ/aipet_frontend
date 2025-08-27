# App Module Architecture

앱의 핵심 구조와 초기화 로직을 관리하는 모듈입니다.

## 구조 개요

```
lib/app/
├── README.md                           # 이 문서
├── app.dart                           # 모듈 export 파일
├── bootstrap.dart                     # 앱 부트스트랩 및 메인 위젯
├── controllers/                       # 앱 레벨 컨트롤러들
│   ├── controllers.dart               # Export 파일
│   └── base_controller.dart          # 기본 컨트롤러 클래스
├── providers/                        # 앱 레벨 Riverpod 프로바이더들
│   ├── app_initialization_provider.dart  # 앱 초기화 상태 관리
│   ├── app_state_provider.dart       # 글로벌 앱 상태 관리
│   └── router_provider.dart          # 라우터 프로바이더
└── router/                           # 라우팅 시스템
    ├── app_router.dart               # 메인 라우터 클래스
    └── routes/                       # 모듈별 라우트 정의
        ├── routes.dart               # Export 파일
        ├── route_constants.dart      # 라우트 상수들
        ├── splash_shell_routes.dart  # 로고 시퀀스 라우트
        ├── auth_routes.dart          # 인증 관련 라우트
        ├── shell_routes.dart         # 메인 앱 Shell 라우트
        └── standalone_routes.dart    # 독립 전체화면 라우트
```

## 주요 구성 요소

### 1. Bootstrap (`bootstrap.dart`)
- **역할**: 앱의 진입점이자 최상위 위젯 관리
- **기능**:
  - 앱 초기화 트리거
  - 초기화 상태에 따른 UI 분기
  - 메인 MaterialApp.router 설정
  - 테마 및 라우터 설정

### 2. App Initialization Provider (`app_initialization_provider.dart`)
- **역할**: 앱 시작 시 필요한 모든 초기화 작업 관리
- **초기화 단계**:
  1. 기본 서비스 초기화 (에러 핸들러, 성능 모니터링 등)
  2. 앱 설정 로드 (테마, 언어, 알림 설정 등)
  3. 사용자 인증 상태 확인
  4. 온보딩 완료 상태 확인
  5. 네트워크 연결 확인
  6. 앱 버전 확인
  7. 필수 데이터 로드
  8. 리소스 초기화 (폰트, 이미지 등)

### 3. Router System (`router/`)
- **모듈형 라우터 아키텍처**:
  - **SplashShellRoutes**: 로고 시퀀스 → 온보딩 (최우선, 스킵 불가)
  - **AuthRoutes**: 로그인, 회원가입 등 인증 관련
  - **ShellRoutes**: 하단 네비게이션이 있는 메인 앱 화면들
  - **StandaloneRoutes**: 설정, 펫 등록 등 독립 전체화면들

#### 라우터 우선순위
1. **Splash Shell**: `/`, `/splash`, `/onboarding` - 최우선, 스킵 불가
2. **Auth Routes**: `/login`, `/signup`, `/welcome` - 인증 관련
3. **Main Shell**: `/home`, `/scheduling`, `/ai`, `/walk`, `/calendar` - 하단 네비게이션
4. **Standalone**: `/settings/*`, 펫 등록 플로우 등 - 독립 화면

## 개선 사항

### ✅ 완료된 개선사항
1. **모듈형 라우터 구조**: 관심사별로 라우트 분리
2. **Shell Router 활용**: 하단 네비게이션 체계적 관리
3. **초기화 단계 세분화**: 8단계 체계적 초기화 프로세스
4. **에러 핸들링**: 각 초기화 단계별 에러 처리
5. **상태 관리 최적화**: Riverpod를 활용한 반응형 상태 관리

### 🔄 추천 개선사항

#### 1. 환경 설정 관리 강화
```dart
// lib/app/config/
├── app_config.dart          # 환경별 설정
├── dev_config.dart          # 개발 환경
├── staging_config.dart      # 스테이징 환경
└── prod_config.dart         # 프로덕션 환경
```

#### 2. 의존성 주입 시스템
```dart
// lib/app/di/
├── di_container.dart        # DI 컨테이너
├── service_locator.dart     # 서비스 로케이터
└── module_registrar.dart    # 모듈별 의존성 등록
```

#### 3. 미들웨어 시스템
```dart
// lib/app/middleware/
├── auth_middleware.dart     # 인증 미들웨어
├── logging_middleware.dart  # 로깅 미들웨어
└── analytics_middleware.dart # 분석 미들웨어
```

#### 4. 앱 생명주기 관리
```dart
// lib/app/lifecycle/
├── app_lifecycle_observer.dart  # 앱 생명주기 관찰자
└── background_task_manager.dart # 백그라운드 작업 관리
```

## 베스트 프랙티스

### 1. 라우터 사용법
```dart
// 라우트 상수 사용
context.go(RouteConstants.homeRoute);

// 하위 라우트 네비게이션
context.go('/home/pet-profile');

// Shell 내에서의 네비게이션
context.go('/scheduling/feeding-schedule');
```

### 2. 초기화 상태 활용
```dart
// 초기화 상태 구독
final initState = ref.watch(appInitializationProvider);

// 인증 상태 확인
if (initState.isAuthenticated) {
  // 인증된 사용자 로직
}

// 온보딩 상태 확인
if (!initState.isOnboardingCompleted) {
  // 온보딩 필요
}
```

### 3. 에러 처리
```dart
// 초기화 에러 처리
if (initState.error != null) {
  // 에러 UI 표시
  return ErrorWidget(error: initState.error);
}
```

## 확장성 고려사항

1. **모듈 추가**: 새로운 기능 모듈 추가 시 해당 라우트를 적절한 라우트 파일에 추가
2. **미들웨어 확장**: 인증, 로깅, 분석 등 횡단 관심사 처리
3. **환경별 설정**: 개발/스테이징/프로덕션 환경별 설정 분리
4. **성능 최적화**: 라우트별 지연 로딩 및 코드 분할 적용 가능

이 구조는 확장 가능하고 유지보수가 용이하도록 설계되었으며, 팀 개발에 적합한 모듈형 아키텍처를 제공합니다.