# 🤖 CLAUDE.md - AI Pet Frontend Development Guide

Claude에게 이 프로젝트에 대한 상세 정보를 제공하여 더 나은 도움을 받을 수 있도록 하는 가이드입니다.

한국어로 대답하고, 코드에서 필요한 주석은 한국어로, ui는 일본어로 표시하며,
커밋 메시지는 일본어로 작성.

## 📋 프로젝트 개요

**프로젝트명**: AIPet Frontend
**설명**: AI 기반 지능형 반려동물 관리 애플리케이션
**프레임워크**: Flutter 3.8.1+
**언어**: Dart
**상태관리**: Riverpod 2.5+
**라우팅**: Go Router 14.6+
**린터에러 해결** : markdownlnt 사용하여 md파일 수정시 적용

## 🏗️ 아키텍처 & 디렉토리 구조

이 프로젝트는 **Clean Architecture** 원칙을 따르며 **Feature-First** 구조로 조직되어 있습니다.

```text
lib/
├── app/                           # 애플리케이션 레이어
│   ├── config/                    # 앱 설정
│   ├── controllers/               # 기본 컨트롤러
│   ├── providers/                 # 글로벌 프로바이더
│   └── router/                    # GoRouter 네비게이션 설정
│       └── routes/                # 라우트 정의
├── features/                      # 기능별 모듈 (Feature-First)
│   ├── ai/                        # AI 어시스턴트 기능
│   ├── auth/                      # 인증 관련
│   ├── facility/                  # 시설 검색
│   ├── home/                      # 홈 대시보드
│   ├── notification/              # 푸시 알림
│   ├── onboarding/               # 온보딩
│   ├── pet_activities/           # 반려동물 활동
│   ├── pet_feeding/              # 급식 관리
│   ├── pet_health/               # 건강 관리
│   ├── pet_profile/              # 프로필 관리
│   ├── pet_registor/             # 반려동물 등록
│   ├── scheduling/               # 스케줄링
│   ├── settings/                 # 설정
│   ├── splash/                   # 스플래시
│   └── walk/                     # 산책 기능
└── shared/                       # 공통 리소스
    ├── branding/                 # 브랜딩 요소
    ├── constants/                # 상수 정의
    ├── design/                   # 디자인 토큰
    ├── mock_data/               # 목업 데이터
    ├── services/                # 공통 서비스
    ├── utils/                   # 유틸리티
    └── widgets/                 # 재사용 가능한 위젯
```

### Clean Architecture 레이어별 구조

각 feature는 다음과 같은 구조를 따릅니다:

```text
feature_name/
├── data/                         # Data Layer
│   ├── models/                   # 데이터 모델
│   ├── repositories/             # Repository 구현체
│   ├── services/                 # 외부 API 서비스
│   └── providers/                # Riverpod 프로바이더
├── domain/                       # Domain Layer
│   ├── entities/                 # 비즈니스 엔티티
│   ├── repositories/             # Repository 인터페이스
│   ├── usecases/                 # 비즈니스 로직
│   └── services/                 # 도메인 서비스
└── presentation/                 # Presentation Layer
    ├── controllers/              # Riverpod 컨트롤러
    ├── screens/                  # 화면 위젯
    ├── widgets/                  # 기능별 위젯
    └── constants/                # UI 상수
```

## 🚀 주요 기능

### 핵심 기능

- **🐕 반려동물 프로필 관리**: 완전한 반려동물 프로필 시스템
- **🏥 건강 관리**: 예방접종, 의료 기록, 건강 추적
- **🚶 활동 추적**: GPS 기반 산책 및 운동 추적
- **🍽️ 급식 관리**: 식사 스케줄과 영양 관리
- **📅 스마트 스케줄링**: 자동 알림 및 일정 관리
- **🤖 AI 수의학 도우미**: AI 기반 건강 상담
- **📍 시설 검색**: 주변 동물병원, 펜션 등 검색
- **🔔 스마트 알림**: 맞춤형 푸시 알림

### 기술적 특징

- **상태 관리**: Riverpod + Code Generation
- **의존성 주입**: Provider 패턴
- **네비게이션**: Declarative routing (GoRouter)
- **로컬 저장소**: SharedPreferences + SecureStorage
- **HTTP 통신**: Dio + Custom Interceptors
- **지도 서비스**: Google Maps
- **애니메이션**: Lottie + Custom animations
- **테스팅**: Unit, Widget, Integration tests

## 🛠️ 개발 환경 설정

### 필수 조건

- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Android Studio / VS Code
- Firebase 프로젝트 (인증, Firestore, FCM)
- Google Maps API 키

### 설정 단계

1. **의존성 설치**:

   ```bash
   flutter pub get
   ```

2. **코드 생성**:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **환경 변수 설정** (.env 파일):

   ```env
   # Firebase & Google Services
   GOOGLE_MAPS_API_KEY=your_api_key

   # API Endpoints
   BASE_API_URL=your_api_url
   ```

### 자동화 스크립트

프로젝트에는 다음 개발 도구들이 포함되어 있습니다:

- **`./scripts/dev_setup.sh`**: 전체 개발 환경 설정
- **`./scripts/build_runner.sh`**: 코드 생성 자동화
- **`./scripts/format_code.sh`**: 코드 포맷팅 및 린팅

## 📝 코딩 규칙 & 컨벤션

### 네이밍 컨벤션

- **파일명**: snake_case (예: `pet_profile_screen.dart`)
- **클래스명**: PascalCase (예: `PetProfileScreen`)
- **변수/함수명**: camelCase (예: `petProfileData`)
- **상수명**: SCREAMING_SNAKE_CASE (예: `API_BASE_URL`)

### 라우트 컨벤션

- 메인 라우트: kebab-case (예: `/home`, `/pet-profile`)
- 하위 라우트: kebab-case (예: `/home/pet-empty`)
- 쿼리 파라미터: camelCase (예: `?petId=123`)

### 코드 품질

- **린팅**: `analysis_options.yaml`에 정의된 엄격한 린트 규칙
- **포맷팅**: `dart format` 사용
- **타입 안정성**: Null Safety 완전 지원
- **테스팅**: 모든 핵심 로직에 대한 테스트 필수

## 🧪 테스팅 전략

### 테스트 구조

```text
test/
├── unit/                         # 단위 테스트
│   ├── features/                 # 기능별 단위 테스트
│   ├── services/                 # 서비스 테스트
│   └── utils/                    # 유틸리티 테스트
├── widget/                       # 위젯 테스트
│   └── features/                 # 기능별 위젯 테스트
└── integration/                  # 통합 테스트
    └── app_test.dart            # 전체 앱 플로우 테스트
```

### 테스트 명령어

```bash
# 전체 테스트 실행
flutter test

# 커버리지 포함
flutter test --coverage

# 특정 테스트만 실행
flutter test test/unit/features/pet_profile/
```

## 🏷️ 의존성 관리

### 주요 의존성

```yaml
dependencies:
  # Core Framework
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.6.2

  # Backend & API
  firebase_core: ^3.15.2
  firebase_auth: ^5.1.4
  dio: ^5.4.3+1

  # UI & Visualization
  google_fonts: ^6.3.0
  fl_chart: ^0.68.0
  lottie: ^3.1.3

  # Maps & Location
  google_maps_flutter: ^2.8.0
  geolocator: ^13.0.1
  location: ^6.0.0

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.2.2

  # Notifications
  flutter_local_notifications: ^17.2.3

dev_dependencies:
  # Code Generation
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.13

  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  test: ^1.25.2

  # Code Quality
  flutter_lints: ^5.0.0
```

## 🔄 상태 관리 패턴

### Riverpod 사용법

```dart
// Provider 정의 (Code Generation)
@riverpod
class PetProfileController extends _$PetProfileController {
  @override
  FutureOr<PetProfile?> build() {
    return _fetchPetProfile();
  }

  Future<void> updateProfile(PetProfile profile) async {
    // 비즈니스 로직
  }
}

// 화면에서 사용
class PetProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petProfile = ref.watch(petProfileControllerProvider);

    return petProfile.when(
      data: (profile) => ProfileView(profile: profile),
      loading: () => LoadingWidget(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

## 🔧 문제 해결 가이드

### 자주 발생하는 문제들

1. **코드 생성 문제**:

   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **의존성 충돌**:

   ```bash
   flutter clean
   flutter pub get
   ```

3. **iOS 빌드 문제**:

   ```bash
   cd ios && pod install
   cd .. && flutter clean && flutter run
   ```

### 로그 및 디버깅

- Firebase Console에서 실시간 로그 확인
- Flutter Inspector 활용
- Dio Interceptor로 네트워크 요청 로깅

### 현재 알려진 제한사항 및 TODO

#### Pet Registration 기능

- **데이터 영속성**: 현재 Mock 데이터 사용, 실제 SQLite/Firebase 연동 필요
- **임시 데이터 저장**: SharedPreferences 구현 미완료
- **이미지 업로드**: 실제 이미지 저장소 연동 필요
- **테스트 커버리지**: 9개 스크린 중 1개만 위젯 테스트 존재

#### Pet Profile 기능 현황

- **아키텍처**: ✅ Clean Architecture 완전 준수 (Domain/Data/Presentation)
- **상태관리**: ✅ Riverpod + Code Generation 패턴 적용
- **UI/Logic 분리**: ⚠️ 1,641라인 메가 클래스 - 위젯 분리 필요
- **테스트 커버리지**: ✅ Controller 단위 테스트 완료, ⚠️ Repository/Screen 테스트 부족
- **코드 재사용성**: ⚠️ 하드코딩된 UI 컴포넌트, 공통 위젯 분리 필요
- **DRY 원칙**: ❌ 중복 코드 다수 (카드 위젯, 편집 필드 등)

**주요 위반사항:**

1. `PetProfileScreen` 1,641라인 - 단일 책임 원칙 위반
2. UI 컴포넌트 하드코딩 - 재사용성 부족
3. 편집 로직이 Screen에 직접 구현 - 관심사 분리 미흡
4. 배럴 파일 의존성 - `pet_registor` Entity 재사용

#### 개발 우선순위

1. **Critical**: Pet Profile 코드 리팩토링 (UI/Logic 분리, 위젯 분할)
2. **Critical**: 데이터 영속성 구현 (`PetRepositoryImpl`)
3. **High**: 테스트 커버리지 확대 (95% 목표)
4. **High**: 공통 위젯 추출 및 재사용성 개선
5. **Medium**: 이미지 관리 시스템 구축
6. **Low**: UI/UX 개선 (로딩 상태, 에러 핸들링)

## 🚀 배포 가이드

### Android

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### 코드 사인 및 배포

- Android: Google Play Console
- iOS: App Store Connect
- Firebase App Distribution (내부 테스팅)

## 📚 추가 리소스

- **Firebase Console**: 백엔드 서비스 관리
- **Google Cloud Console**: Maps API 관리
- **Flutter Documentation**: <https://docs.flutter.dev>
- **Riverpod Documentation**: <https://riverpod.dev>

---

## 🤖 Claude 개발 지원 명령어

다음은 Claude가 이 프로젝트에서 자주 사용할 수 있는 명령어들입니다:

### 코드 품질 관리

```bash
# 린팅 및 분석
flutter analyze

# 코드 포맷팅
dart format lib/ test/

# 자동 import 정리
dart fix --apply

# 마크다운 린팅
npx markdownlint "**/*.md" --fix
```

### 배너 이미지 관리

```bash
# 홈 배너 이미지 목록 자동 업데이트
./scripts/update_banner_assets.sh

# 새로운 배너 이미지 추가 후 실행 필요
# assets/images/home_banner/banners/ 폴더에 새 이미지 추가 후:
./scripts/update_banner_assets.sh
```

### 코드 생성

```bash
# Riverpod + JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs

# 정리 후 재생성
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### 테스팅

```bash
# 전체 테스트
flutter test

# 특정 기능 테스트
flutter test test/unit/features/pet_profile/

# 위젯 테스트만
flutter test test/widget/

# 커버리지 리포트 생성
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Mock 데이터 및 개발 도구

```bash
# Mock 데이터로 개발 환경 실행
flutter run --flavor dev

# 프로덕션 빌드 (실제 API 연동)
flutter run --flavor prod

# JSON 모델 코드 생성 (데이터 모델 변경 시)
flutter packages pub run build_runner build --delete-conflicting-outputs --verbose
```

---

이 문서는 Claude가 AIPet Frontend 프로젝트를 효과적으로 이해하고 개발을 지원할 수 있도록 작성되었습니다.
질문이나 추가 정보가 필요한 경우 언제든지 문의하세요!
