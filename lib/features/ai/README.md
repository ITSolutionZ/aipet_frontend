# AI Feature - AI 챗봇 기능

## 📋 개요

AI 챗봇 기능은 사용자가 펫 관련 질문을 하고 AI로부터 답변을 받을 수 있는 기능입니다.

## 🏗️ 아키텍처

### Clean Architecture 구조

```
lib/features/ai/
├── data/                           # Data Layer
│   ├── providers/                  # Riverpod Providers
│   │   ├── ai_providers.dart      # AI 관련 Provider들
│   │   └── ai_providers.g.dart    # 자동 생성된 Provider 코드
│   ├── repositories/               # Repository 구현체
│   │   ├── ai_repository.dart     # Repository 인터페이스
│   │   └── ai_repository_impl.dart # Repository 구현체
│   └── services/                   # 외부 서비스 연동
│       ├── openai_service.dart     # OpenAI API 연동
│       └── pet_content_filter_service.dart # 펫 콘텐츠 필터링
├── domain/                         # Domain Layer
│   ├── entities/                   # 비즈니스 엔티티
│   │   ├── ai_category_entity.dart # AI 카테고리 엔티티
│   │   ├── ai_favorite_qa_entity.dart # 즐겨찾기 QA 엔티티
│   │   ├── ai_message_entity.dart  # AI 메시지 엔티티
│   │   └── ai_suggested_question_entity.dart # 추천 질문 엔티티
│   ├── repositories/               # Repository 인터페이스
│   │   └── ai_repository.dart     # AI Repository 인터페이스
│   └── usecases/                   # 비즈니스 로직
│       └── ai_chat_usecase.dart   # AI 채팅 Use Case
└── presentation/                    # Presentation Layer
    ├── controllers/                 # 상태 관리 컨트롤러
    │   └── ai_chat_controller.dart # AI 채팅 컨트롤러
    ├── screens/                     # 화면
    │   ├── ai_chat_screen.dart     # AI 채팅 화면
    │   ├── ai_favorite_messages_screen.dart # 즐겨찾기 메시지 화면
    │   └── ai_suggested_questions_screen.dart # 추천 질문 화면
    └── widgets/                     # UI 컴포넌트
        ├── ai_chat_bubble.dart     # AI 채팅 버블
        ├── ai_favorite_qa_card.dart # 즐겨찾기 QA 카드
        ├── ai_message_bubble.dart   # AI 메시지 버블
        ├── ai_pet_selection.dart    # 펫 선택 위젯
        ├── ai_pet_selection_bubble.dart # 펫 선택 버블
        ├── ai_question_request_bubble.dart # 질문 요청 버블
        └── ai_suggested_questions.dart # 추천 질문 위젯
```

## 🔧 코드 분리 및 의존성 관리

### 1. Mock 데이터 의존성 분리

**이전 구조 (문제점)**:

```dart
// ❌ Repository에서 직접 Mock 데이터 호출
class AiRepositoryImpl {
  Future<List<AiMessageEntity>> getChatHistory() async {
    final mockData = AiMockDataService.getChatHistoryMockData(); // 직접 의존
    return mockData.map((json) => AiMessageEntity(...)).toList();
  }
}
```

**새로운 구조 (해결책)**:

```dart
// ✅ MockDataService 인터페이스를 통한 의존성 주입
class AiRepositoryImpl {
  final MockDataService _mockDataService;

  Future<List<AiMessageEntity>> getChatHistory() async {
    return await _mockDataService.getChatHistory(); // 인터페이스 통한 호출
  }
}
```

### 2. 정적 데이터 서비스 분리

**이전 구조 (문제점)**:

```dart
// ❌ 엔티티 내부에 정적 데이터 하드코딩
class AiCategoryEntity {
  static const List<AiCategoryEntity> defaultCategories = [
    AiCategoryEntity(id: 'health', name: '健康', ...),
    // ... 8개 카테고리
  ];
}
```

**새로운 구조 (해결책)**:

```dart
// ✅ 별도 서비스로 데이터 관리
class AiCategoryService {
  static List<AiCategoryEntity> getDefaultCategories() {
    return [
      const AiCategoryEntity(id: 'health', name: '健康', ...),
      // ... 8개 카테고리
    ];
  }
}
```

### 3. 환경별 설정 분리

**새로운 구조**:

```dart
// ✅ 환경별 설정 서비스
class AiConfigService {
  static bool get isMockMode => AppConfig.current.isMockMode;

  static Future<List<AiCategoryEntity>> getCategories() async {
    if (isMockMode) {
      return _getMockCategories();
    } else {
      return await _loadCategoriesFromApi();
    }
  }
}
```

## 📁 새로운 서비스 구조

### Shared Services

```
lib/shared/services/
├── ai_category_service.dart         # AI 카테고리 데이터 관리
├── ai_config_service.dart           # AI 환경별 설정 관리
├── ai_keyword_service.dart          # AI 키워드 데이터 관리
├── ai_mock_data_service_impl.dart   # AI Mock 데이터 구현체
└── mock_data_service.dart           # Mock 데이터 서비스 인터페이스
```

### Mock Data Service Interface

```dart
abstract class MockDataService {
  Future<void> simulateApiDelay({int seconds = 1});
  Future<List<AiMessageEntity>> getChatHistory();
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions();
  Future<List<AiFavoriteQaEntity>> getFavoriteQAs();
  Future<List<AiChatSessionEntity>> getChatSessions();
  Future<Map<String, dynamic>> generateAiResponse(String userMessage);
  Future<Map<String, dynamic>> createChatSession(String title, {String? petId});
}
```

## 🚀 Provider 설정

### AI Repository Provider

```dart
@riverpod
AiRepository aiRepository(Ref ref) {
  return AiRepositoryImpl(
    openAIService: OpenAIService(),
    mockDataService: AiMockDataService(), // Mock 데이터 서비스 주입
    ref: ref,
  );
}
```

## 🔄 API 연동 준비

### Mock 모드에서 실제 API 모드로 전환

1. **Mock 모드 (현재)**:

   ```dart
   // AiConfigService.isMockMode = true
   return await _mockDataService.getChatHistory();
   ```

2. **실제 API 모드 (향후)**:
   ```dart
   // AiConfigService.isMockMode = false
   final response = await _httpClient.get('/api/ai/chat/history');
   return response.data.map((json) => AiMessageEntity.fromJson(json)).toList();
   ```

## 📝 주요 개선사항

### 1. 의존성 분리

- ✅ Repository에서 Mock 데이터 직접 호출 제거
- ✅ MockDataService 인터페이스를 통한 의존성 주입
- ✅ 테스트 용이성 향상

### 2. 데이터 관리 개선

- ✅ 정적 데이터를 별도 서비스로 분리
- ✅ 엔티티의 단일 책임 원칙 준수
- ✅ 확장성 향상

### 3. 환경별 설정

- ✅ Mock 모드와 실제 API 모드 구분
- ✅ 환경별 배포 용이성 향상
- ✅ 설정 중앙화

### 4. 코드 품질 향상

- ✅ DRY 원칙 준수
- ✅ 단일 책임 원칙 준수
- ✅ 의존성 역전 원칙 준수

## 🧪 테스트

### Mock 데이터 서비스 테스트

```dart
void main() {
  late MockDataService mockDataService;

  setUp(() {
    mockDataService = MockMockDataService();
  });

  test('getChatHistory returns empty list', () async {
    when(mockDataService.getChatHistory())
        .thenAnswer((_) async => []);

    final result = await mockDataService.getChatHistory();
    expect(result, isEmpty);
  });
}
```

## 🔮 향후 계획

1. **API 연동**: 실제 OpenAI API와의 연동 구현
2. **데이터베이스**: 카테고리 및 키워드 데이터베이스 저장
3. **캐싱**: AI 응답 캐싱 시스템 구현
4. **성능 최적화**: 응답 시간 개선 및 사용자 경험 향상

## 📚 참고 자료

- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/about_riverpod)
- [Flutter Testing](https://docs.flutter.dev/testing)
