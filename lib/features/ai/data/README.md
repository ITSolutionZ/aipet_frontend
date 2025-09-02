# AI Feature - Data Layer / AI 機能 - データ層

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [구조 (Structure)](#구조-structure)
- [주요 컴포넌트 (Key Components)](#주요-컴포넌트-key-components)
- [사용 방법 (Usage)](#사용-방법-usage)
- [Mock 데이터 전략 (Mock Data Strategy)](#mock-데이터-전략-mock-data-strategy)
- [API 연동 설정 (API Integration)](#api-연동-설정-api-integration)
- [의존성 (Dependencies)](#의존성-dependencies)

### 개요 (Overview)

AI Feature의 Data Layer는 AI 채팅 시스템의 데이터 관리와 외부 API 통신을
담당합니다. Clean Architecture 원칙에 따라 Domain Layer와 Presentation
Layer 사이의 데이터 흐름을 안전하고 일관성 있게 처리하는 책임, 구성,
사용법을 정의합니다.

**주요 책임:**

- 🔌 **OpenAI API 통신**: GPT 모델과의 안전한 상호작용
- 🛡️ **컨텐츠 필터링**: 펫 관련 외/부적절한 토픽 억제
- 💾 **데이터 관리**: 채팅 히스토리/세션/즐겨찾기 등의 CRUD
- 🔄 **상태 관리**: Riverpod을 통한 의존성 주입과 반응형 제어
- 🧪 **Mock 데이터**: 외부 의존성을 끊은 UI/동작 검증

### 구조 (Structure)

```txt
lib/features/ai/data/
├── data.dart                           # Data Layer 배럴 파일
├── providers/                          # Riverpod 프로바이더
│   ├── ai_providers.dart               # AI 관련 프로바이더 정의
│   └── ai_providers.g.dart             # 생성 코드
├── repositories/                       # 리포지토리 구현
│   └── ai_repository_impl.dart
└── services/                           # 외부 API / 비즈니스 로직
    ├── openai_service.dart             # OpenAI API 통신
    └── pet_content_filter_service.dart # 펫용 컨텐츠 필터
```

### 주요 컴포넌트 (Key Components)

#### 1) **프로바이더 (`providers/ai_providers.dart`)**

```dart
@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  return AiRepositoryImpl(
    openAIService: ref.read(openAIServiceProvider),
    contentFilter: ref.read(petContentFilterServiceProvider),
  );
}

@riverpod
OpenAIService openAIService(OpenAIServiceRef ref) {
  return OpenAIService();
}

@riverpod
PetContentFilterService petContentFilterService(
  PetContentFilterServiceRef ref,
) {
  return PetContentFilterService();
}
```

> 의존성은 Riverpod을 통해 주입하여 테스트 용이성과 느슨한 결합을
> 보장합니다.

#### 2) **리포지토리 구현 (`repositories/ai_repository_impl.dart`)**

```dart
class AiRepositoryImpl implements AiRepository {
  final OpenAIService _openAIService;
  final PetContentFilterService _contentFilter;

  AiRepositoryImpl({
    required OpenAIService openAIService,
    required PetContentFilterService contentFilter,
  })  : _openAIService = openAIService,
        _contentFilter = contentFilter;

  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataService.getMockAiMessages();
  }

  @override
  Future<String> sendMessage(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    // 1) 컨텐츠 검증 (일본어 메시지로 사용자에게 이유 반환)
    final filterResult = await _contentFilter
        .validatePetContent(message);
    if (!filterResult.isValid) {
      throw AiException.invalidContent(
          filterResult.reason ?? '부적절한 내용입니다');
    }

    // 2) OpenAI 호출
    final response = await _openAIService.generateResponse(
      message,
      petContext: petContext,
    );

    return response;
  }
}
```

#### 3) **OpenAI 서비스 (`services/openai_service.dart`)**

```dart
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  // 모델은 환경변수로 교체 권장
  static const String _model = 'gpt-3.5-turbo';

  final Dio _dio = Dio();
  final PetContentFilterService _contentFilter;

  OpenAIService({PetContentFilterService? contentFilter})
      : _contentFilter = contentFilter ?? PetContentFilterService();

  Future<String> generateResponse(
    String message, {
    PetProfileEntity? petContext,
    AiCategoryEntity? category,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(petContext, category);

      final requestData = {
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getApiKey()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      throw AiException.apiError('OpenAI API 호출에 실패했습니다: $e');
    }
  }

  String _buildSystemPrompt(
    PetProfileEntity? petContext,
    AiCategoryEntity? category,
  ) {
    String prompt = '''당신은 펫 전문 AI 어시스턴트입니다.
펫의 건강, 행동, 케어에 관한 실무적인 조언을 일본어로 제공해주세요.''';

    if (petContext != null) {
      prompt += '''

【펫 정보】
・이름: ${petContext.name}
・종류: ${petContext.typeName}
・나이: ${petContext.age}세
・품종: ${petContext.breed}
이를 고려하여 답변해주세요.''';
    }

    if (category != null) {
      prompt += '''

【상담 카테고리】${category.name}
${category.description}''';
    }

    return prompt;
  }

  String _getApiKey() {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      throw AiException.configurationError(
          'OPENAI_API_KEY가 설정되지 않았습니다.');
    }
    return apiKey;
  }
}
```

#### 4) **컨텐츠 필터 (`services/pet_content_filter_service.dart`)**

- 일본어의 **금지 키워드**와 **펫 관련 키워드**를 통한 단순 검출
- 불일치 시 일본어 이유와 함께 `invalidContent` 반환

> 향후 ML/규칙 확장 가능. 우선은 오차를 피하기 위해 보수적으로 운영.

### 사용 방법 (Usage)

#### 기본 사용

```dart
final aiRepository = ref.read(aiRepositoryProvider);

try {
  final response = await aiRepository.sendMessage(
      '강아지가 산책 후 밥을 먹지 않아요');
  print('AI 응답: $response');
} catch (e) {
  print('에러: $e');
}
```

#### 컨텐츠 필터만 사용

```dart
final contentFilter = ref.read(petContentFilterServiceProvider);
final result = await contentFilter.validatePetContent('고양이 훈련');
if (!result.isValid) {
  // 일본어 이유를 UI에 표시
}
```

### Mock 데이터 전략 (Mock Data Strategy)

- 외부 API에 의존하지 않고 **UI/상태 전환**을 고속 검증
- 대표적인 시나리오를 `MockDataService`에 집중하여 재사용

```dart
class MockDataService {
  static List<AiMessageEntity> getMockAiMessages() => [
        AiMessageEntity(
          id: '1',
          content: '안녕하세요. 펫 상담을 도와드리겠습니다.',
          type: MessageType.assistant,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AiMessageEntity(
          id: '2',
          content: '강아지가 자주 짖어요. 어떻게 하면 될까요?',
          type: MessageType.user,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];
}
```

### API 연동 설정 (API Integration)

#### .env 예시

```env
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-3.5-turbo
OPENAI_MAX_TOKENS=1000
OPENAI_TEMPERATURE=0.7
```

> Dart 측에서는 `String.fromEnvironment` 사용. 빌드 시 `--dart-define`으로
> 주입합니다.

#### 에러/예외 처리

```dart
class AiException implements Exception {
  final String message;
  final AiExceptionType type;
  const AiException._(this.message, this.type);

  factory AiException.invalidContent(String reason) =>
      AiException._(reason, AiExceptionType.invalidContent);
  factory AiException.apiError(String reason) =>
      AiException._(reason, AiExceptionType.apiError);
  factory AiException.configurationError(String reason) =>
      AiException._(reason, AiExceptionType.configurationError);

  @override
  String toString() => 'AiException[$type]: $message';
}

enum AiExceptionType { invalidContent, apiError, configurationError }
```

#### 재시도 로직

```dart
Future<String> generateResponseWithRetry(
  String message, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await generateResponse(message);
    } catch (_) {
      if (attempt == maxRetries) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
  throw AiException.apiError('최대 재시도 횟수를 초과했습니다');
}
```

### 의존성 (Dependencies)

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  dio: ^5.4.3+1
  go_router: ^14.6.2
```

- **내부 모듈**: `shared`, `features/ai/domain`, `features/pet_profile` 등
- **네트워크**: Dio를 통한 HTTP 통신

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [構造 (Structure)](#構造-structure)
- [主要コンポーネント (Key Components)](#主要コンポーネント-key-components)
- [使用方法 (Usage)](#使用方法-usage)
- [モックデータ戦略 (Mock Data Strategy)](#モックデータ戦略-mock-data-strategy)
- [API 連携設定 (API Integration)](#api-連携設定-api-integration)
- [依存関係 (Dependencies)](#依存関係-dependencies)

### 概要 (Overview)

AI 機能の Data Layer は、AI チャットシステムのデータ管理と外部 API 通信を
担当します。Clean Architecture の原則に従って Domain Layer と Presentation
Layer の間のデータフローを安全で一貫性のあるものとして扱うための責務、
構成、使用方法を定義します。

**主要な責任:**

- 🔌 **OpenAI API 通信**: GPT モデルとの安全なやり取り
- 🛡️ **コンテンツフィルタリング**: ペット関連以外/不適切トピックの抑止
- 💾 **データ管理**: チャット履歴/セッション/お気に入り等の CRUD
- 🔄 **状態管理**: Riverpod による依存性注入とリアクティブ制御
- 🧪 **モックデータ**: 外部依存を切った UI/振る舞い検証

### 構造 (Structure)

```txt
lib/features/ai/data/
├── data.dart                           # Data 層のバレルファイル
├── providers/                          # Riverpod プロバイダ
│   ├── ai_providers.dart               # AI 関連プロバイダ定義
│   └── ai_providers.g.dart             # 生成コード
├── repositories/                       # リポジトリ実装
│   └── ai_repository_impl.dart
└── services/                           # 外部 API / 業務ロジック
    ├── openai_service.dart             # OpenAI API 通信
    └── pet_content_filter_service.dart # ペット用コンテンツフィルタ
```

### 主要コンポーネント (Key Components)

#### 1) **プロバイダ (`providers/ai_providers.dart`)**

```dart
@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  return AiRepositoryImpl(
    openAIService: ref.read(openAIServiceProvider),
    contentFilter: ref.read(petContentFilterServiceProvider),
  );
}

@riverpod
OpenAIService openAIService(OpenAIServiceRef ref) {
  return OpenAIService();
}

@riverpod
PetContentFilterService petContentFilterService(
  PetContentFilterServiceRef ref,
) {
  return PetContentFilterService();
}
```

> 依存性は Riverpod 経由で注入し、テスト容易性と疎結合を担保します。

#### 2) **リポジトリ実装 (`repositories/ai_repository_impl.dart`)**

```dart
class AiRepositoryImpl implements AiRepository {
  final OpenAIService _openAIService;
  final PetContentFilterService _contentFilter;

  AiRepositoryImpl({
    required OpenAIService openAIService,
    required PetContentFilterService contentFilter,
  })  : _openAIService = openAIService,
        _contentFilter = contentFilter;

  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDataService.getMockAiMessages();
  }

  @override
  Future<String> sendMessage(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    // 1) コンテンツ検証（日本語メッセージでユーザーに理由を返す）
    final filterResult = await _contentFilter
        .validatePetContent(message);
    if (!filterResult.isValid) {
      throw AiException.invalidContent(
          filterResult.reason ?? '不適切な内容です');
    }

    // 2) OpenAI 呼び出し
    final response = await _openAIService.generateResponse(
      message,
      petContext: petContext,
    );

    return response;
  }
}
```

#### 3) **OpenAI サービス (`services/openai_service.dart`)**

```dart
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  // モデルは環境変数で差し替え推奨
  static const String _model = 'gpt-3.5-turbo';

  final Dio _dio = Dio();
  final PetContentFilterService _contentFilter;

  OpenAIService({PetContentFilterService? contentFilter})
      : _contentFilter = contentFilter ?? PetContentFilterService();

  Future<String> generateResponse(
    String message, {
    PetProfileEntity? petContext,
    AiCategoryEntity? category,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(petContext, category);

      final requestData = {
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getApiKey()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      throw AiException.apiError('OpenAI API 呼び出しに失敗しました: $e');
    }
  }

  String _buildSystemPrompt(
    PetProfileEntity? petContext,
    AiCategoryEntity? category,
  ) {
    String prompt = '''あなたはペット専門のAIアシスタントです。
ペットの健康・行動・ケアに関する実務的な助言を、日本語で提供してください。''';

    if (petContext != null) {
      prompt += '''

【ペット情報】
・名前: ${petContext.name}
・種類: ${petContext.typeName}
・年齢: ${petContext.age}歳
・品種: ${petContext.breed}
これらを考慮して回答してください。''';
    }

    if (category != null) {
      prompt += '''

【相談カテゴリ】${category.name}
${category.description}''';
    }

    return prompt;
  }

  String _getApiKey() {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      throw AiException.configurationError(
          'OPENAI_API_KEY が設定されていません。');
    }
    return apiKey;
  }
}
```

#### 4) **コンテンツフィルタ (`services/pet_content_filter_service.dart`)**

- 日本語の **禁止キーワード** と **ペット関連キーワード** による単純検出
- 不一致時は日本語理由付きで `invalidContent` を返却

> 将来的に ML/ルール拡張可能。まずは誤阻害を避けるために保守的に運用。

### 使用方法 (Usage)

#### 基本使用方法

```dart
final aiRepository = ref.read(aiRepositoryProvider);

try {
  final response = await aiRepository.sendMessage(
      '犬が散歩後にご飯を食べません');
  print('AI 応答: $response');
} catch (e) {
  print('エラー: $e');
}
```

#### コンテンツフィルタのみ使用

```dart
final contentFilter = ref.read(petContentFilterServiceProvider);
final result = await contentFilter.validatePetContent('子猫のしつけ');
if (!result.isValid) {
  // 日本語の理由を UI に表示
}
```

### モックデータ戦略 (Mock Data Strategy)

- 外部 API に依存せず **UI/状態遷移** を高速検証
- 代表的シナリオを `MockDataService` に集約し再利用

```dart
class MockDataService {
  static List<AiMessageEntity> getMockAiMessages() => [
        AiMessageEntity(
          id: '1',
          content: 'こんにちは。ペット相談をお手伝いします。',
          type: MessageType.assistant,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AiMessageEntity(
          id: '2',
          content: '子犬がよく吠えます。どうすれば？',
          type: MessageType.user,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];
}
```

### API 連携設定 (API Integration)

#### 環境変数設定例

```env
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-3.5-turbo
OPENAI_MAX_TOKENS=1000
OPENAI_TEMPERATURE=0.7
```

> Dart 側では `String.fromEnvironment` を使用。ビルド時に `--dart-define`
> で注入します。

#### エラー/例外処理

```dart
class AiException implements Exception {
  final String message;
  final AiExceptionType type;
  const AiException._(this.message, this.type);

  factory AiException.invalidContent(String reason) =>
      AiException._(reason, AiExceptionType.invalidContent);
  factory AiException.apiError(String reason) =>
      AiException._(reason, AiExceptionType.apiError);
  factory AiException.configurationError(String reason) =>
      AiException._(reason, AiExceptionType.configurationError);

  @override
  String toString() => 'AiException[$type]: $message';
}

enum AiExceptionType { invalidContent, apiError, configurationError }
```

#### リトライ処理

```dart
Future<String> generateResponseWithRetry(
  String message, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await generateResponse(message);
    } catch (_) {
      if (attempt == maxRetries) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
  throw AiException.apiError('最大リトライ回数を超えました');
}
```

### 依存関係 (Dependencies)

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  dio: ^5.4.3+1
  go_router: ^14.6.2
```

- **社内モジュール**: `shared`, `features/ai/domain`, `features/pet_profile` など
- **ネットワーク**: Dio による HTTP 通信

---

## 📚 추가 리소스 / その他のリソース

- [OpenAI API](https://platform.openai.com/docs)
- [Riverpod](https://riverpod.dev/)
- [Dio](https://pub.dev/packages/dio)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

© 2025 AI Pet. AI 기능 데이터 계층 / AI Feature Data Layer
