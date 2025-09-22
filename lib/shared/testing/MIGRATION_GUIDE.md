# 🚀 Mock Data 마이그레이션 가이드

이 문서는 개발 중 Mock 데이터에서 실제 API/Database 연동으로 전환하는 체계적인 방법을 제공합니다.

## 📋 목차

1. [시스템 개요](#시스템-개요)
2. [환경별 설정](#환경별-설정)
3. [마이그레이션 단계](#마이그레이션-단계)
4. [Repository 구현체 교체](#repository-구현체-교체)
5. [테스트 전략](#테스트-전략)
6. [배포 체크리스트](#배포-체크리스트)

## 🔧 시스템 개요

### 핵심 컴포넌트

```
lib/shared/testing/
├── mock_config.dart              # 환경별 Mock 사용 설정
├── centralized_mock_manager.dart # 중앙집중 Mock 데이터 관리
├── repository_factory.dart      # Mock/Real Repository 팩토리
└── MIGRATION_GUIDE.md           # 이 가이드

test/
├── shared_mockito_mocks.dart     # Mockito Mock 클래스 정의
├── shared_mockito_mocks.mocks.dart # 생성된 Mock 클래스
└── shared_advanced_mockito_setup.dart # 고급 Mock 설정
```

### 작동 원리

1. **MockConfig**: 환경 변수와 앱 상태를 기반으로 Mock 사용 여부 결정
2. **CentralizedMockManager**: 모든 Mock 데이터와 시나리오 중앙 관리
3. **RepositoryFactory**: 환경에 따라 Mock/Real Repository 자동 선택
4. **AdvancedMockitoSetup**: 테스트용 시나리오별 Mock 설정

## ⚙️ 환경별 설정

### 개발 환경 (Development)
```dart
// MockConfig가 자동으로 감지
- shouldUseMock: true
- simulateNetworkDelay: true
- simulateErrors: true
- enableMockLogging: true
```

### 테스트 환경 (Testing)
```dart
// MockConfig가 자동으로 감지
- shouldUseMock: true
- simulateNetworkDelay: false (빠른 테스트)
- simulateErrors: true
- enableMockLogging: true
```

### 스테이징 환경 (Staging)
```dart
// 실제 API 테스트
- shouldUseMock: false
- 실제 백엔드 서버 연결
```

### 프로덕션 환경 (Production)
```dart
// 실제 API만 사용
- shouldUseMock: false
- 모든 Mock 관련 코드 비활성화
```

## 🔄 마이그레이션 단계

### Phase 1: 기반 인프라 준비 ✅
- [x] MockConfig 환경 감지 시스템
- [x] CentralizedMockManager 구축
- [x] Mockito 통합 및 Mock 생성
- [x] RepositoryFactory 패턴 구현

### Phase 2: Repository 구현체 개발
각 기능별로 Real Repository 구현:

#### 2.1 AI Repository
```dart
// 현재: lib/features/ai/data/repositories/ai_repository_mockito_impl.dart
// TODO: lib/features/ai/data/repositories/ai_repository_impl.dart

class AiRepositoryImpl implements AiRepository {
  final HttpClientService _httpClient;
  final OpenAIService _openAIService;

  AiRepositoryImpl({
    required HttpClientService httpClient,
    required OpenAIService openAIService,
  }) : _httpClient = httpClient, _openAIService = openAIService;

  @override
  Future<Result<AiMessageEntity>> sendMessage(String message) async {
    // 실제 API 호출 구현
  }
}
```

#### 2.2 Auth Repository
```dart
// 현재: Mock 구현체 없음 (Firebase만 존재)
// TODO: 완전한 Firebase Auth 연동

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final HttpClientService _httpClient;

  // 실제 Firebase Auth + 백엔드 JWT 교환 구현
}
```

#### 2.3 Home Repository
```dart
// TODO: lib/features/home/data/repositories/home_repository_impl.dart
class HomeRepositoryImpl implements HomeRepository {
  final HttpClientService _httpClient;
  final WeatherService _weatherService;

  // 실제 대시보드 API 호출 구현
}
```

### Phase 3: RepositoryFactory 완성
```dart
// lib/shared/testing/repository_factory.dart에서
AiRepository createAiRepository() {
  if (MockConfig.shouldUseMock) {
    return AiRepositoryMockitoImpl(
      openAIService: container.read(openAIServiceProvider),
      ref: container,
    );
  } else {
    return AiRepositoryImpl(
      httpClient: container.read(httpClientServiceProvider),
      openAIService: container.read(openAIServiceProvider),
    );
  }
}
```

### Phase 4: Provider 통합
```dart
// 각 feature의 providers에서
@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  return RepositoryFactory().createAiRepository();
}
```

## 🔧 Repository 구현체 교체

### 1. Mock → Real 전환 체크리스트

#### AI Repository
- [ ] OpenAI API 키 설정
- [ ] Real AiRepositoryImpl 구현
- [ ] API 엔드포인트 설정
- [ ] 에러 핸들링 구현
- [ ] 레이트 리밋 처리
- [ ] 로깅 및 모니터링

#### Auth Repository
- [ ] Firebase 프로젝트 설정
- [ ] 백엔드 JWT 엔드포인트 연동
- [ ] 토큰 리프레시 로직
- [ ] 소셜 로그인 연동 (Google, Apple, LINE)
- [ ] 보안 스토리지 연동

#### Home Repository
- [ ] 대시보드 API 엔드포인트
- [ ] 날씨 API 연동
- [ ] 펫 정보 API 연동
- [ ] 캐싱 전략 구현

#### Pet Repository
- [ ] 펫 CRUD API 연동
- [ ] 이미지 업로드 서비스
- [ ] 임시 데이터 영속화

### 2. 환경별 테스트 전략

```bash
# 개발 환경 (Mock 사용)
FLUTTER_ENV=development flutter run

# 스테이징 환경 (Real API)
FLUTTER_ENV=staging flutter run

# 프로덕션 빌드
FLUTTER_ENV=production flutter build apk
```

### 3. 점진적 마이그레이션

#### 단계별 전환
1. **개발환경**: Mock 계속 사용하면서 Real 구현체 개발
2. **스테이징**: 기능별로 하나씩 Real API로 전환
3. **테스트**: Real API 통합 테스트 실행
4. **프로덕션**: 전체 Real API 배포

#### 기능별 우선순위
1. **Auth** (가장 중요) - 사용자 인증이 모든 기능의 기반
2. **Pet Profile** - 핵심 도메인 기능
3. **AI Chat** - 차별화 기능
4. **Home Dashboard** - 사용자 경험
5. **기타 기능들**

## 🧪 테스트 전략

### Unit Tests
```dart
// test/unit/에서 Mock 사용
void main() {
  late MockAiRepository mockAiRepository;

  setUp(() {
    MockConfig.setEnvironment(MockEnvironment.testing);
    mockAiRepository = MockAiRepository();
  });
}
```

### Integration Tests
```dart
// test/integration/에서 실제 API 사용
void main() {
  setUp(() {
    MockConfig.setEnvironment(MockEnvironment.staging);
    MockConfig.setUseMock(false);
  });
}
```

### E2E Tests
```bash
# 실제 환경에서 E2E 테스트
FLUTTER_ENV=staging flutter drive --target=test_driver/app.dart
```

## ✅ 배포 체크리스트

### Pre-deployment
- [ ] 모든 Mock → Real 마이그레이션 완료
- [ ] 환경별 설정 검증
- [ ] API 엔드포인트 확인
- [ ] 인증 토큰 설정
- [ ] 에러 핸들링 테스트
- [ ] 성능 테스트
- [ ] 보안 점검

### Deployment
- [ ] 스테이징 환경 배포
- [ ] 통합 테스트 실행
- [ ] 사용자 수용 테스트
- [ ] 성능 모니터링
- [ ] 로그 확인
- [ ] 프로덕션 배포
- [ ] 사후 모니터링

### Post-deployment
- [ ] Mock 관련 코드 정리
- [ ] 미사용 의존성 제거
- [ ] 문서 업데이트
- [ ] 팀 지식 공유

## 🚨 주의사항

### 보안
- Mock 환경에서는 실제 API 키 사용 금지
- 프로덕션에서 디버그 로그 비활성화
- 사용자 데이터 보호

### 성능
- Real API 응답 시간 고려한 UX 설계
- 적절한 로딩 상태 및 에러 처리
- 캐싱 전략 수립

### 유지보수
- Mock과 Real 구현체 간 인터페이스 일관성 유지
- 테스트 커버리지 확보
- 문서화 지속 업데이트

## 📞 지원

질문이나 문제가 있으면 다음을 참고하세요:

1. **MockConfig 설정**: `lib/shared/testing/mock_config.dart`
2. **Factory 패턴**: `lib/shared/testing/repository_factory.dart`
3. **테스트 설정**: `test/shared_advanced_mockito_setup.dart`
4. **이 가이드**: 정기적으로 업데이트됩니다

---

**⚡ 성공적인 마이그레이션을 위해 단계별로 천천히 진행하세요!**