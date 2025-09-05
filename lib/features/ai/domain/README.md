# AI Feature - Domain Layer / AI 機能 - ドメイン層

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [구조 (Structure)](#구조-structure)
- [주요 컴포넌트 (Key Components)](#주요-컴포넌트-key-components)
- [비즈니스 로직 (Business Logic)](#비즈니스-로직-business-logic)
- [사용 방법 (Usage)](#사용-방법-usage)
- [확장성 (Extensibility)](#확장성-extensibility)
- [의존성 (Dependencies)](#의존성-dependencies)

### 개요 (Overview)

AI Feature의 Domain Layer는 AI 채팅 시스템의 핵심 비즈니스 로직과 데이터 구조를 정의합니다.
Clean Architecture 원칙에 따라 비즈니스 규칙을 캡슐화하고, 외부 의존성으로부터 독립적인 도메인 모델을 제공합니다.

**주요 책임:**

- 🏗️ **엔티티 정의**: AI 채팅 관련 핵심 데이터 구조
- 📋 **리포지토리 인터페이스**: 데이터 접근 계약 정의
- 🧠 **비즈니스 규칙**: AI 채팅 도메인의 핵심 로직
- 🔒 **도메인 검증**: 데이터 무결성 및 비즈니스 규칙 검증
- 📊 **상태 관리**: AI 채팅 세션 및 메시지 상태 정의

### 구조 (Structure)

```txt
lib/features/ai/domain/
├── domain.dart                              # Domain Layer 배럴 파일
├── entities/                                 # 도메인 엔티티
│   ├── entities.dart                         # entities 배럴 파일
│   ├── ai_message_entity.dart                # AI 메시지 엔티티
│   ├── ai_category_entity.dart               # AI 카테고리 엔티티
│   ├── ai_chat_summary_entity.dart           # AI 채팅 요약 엔티티
│   ├── ai_favorite_entity.dart               # AI 즐겨찾기 엔티티
│   └── ai_favorite_qa_entity.dart            # AI Q&A 즐겨찾기 엔티티
└── repositories/                              # 리포지토리 인터페이스
    ├── repositories.dart                      # repositories 배럴 파일
    └── ai_repository.dart                     # AI 리포지토리 인터페이스
```

**레이어별 역할:**

- **Entities**: AI 채팅 도메인의 핵심 데이터 구조
- **Repositories**: 데이터 접근 추상화 및 계약 정의

### 주요 컴포넌트 (Key Components)

#### 1. **AI Message Entity (`entities/ai_message_entity.dart`)**

**메시지 엔티티 구조:**

```dart
/// AI 채팅 메시지 엔티티
class AiMessageEntity {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? petId;
  final String? categoryId;
  final Map<String, dynamic>? metadata;

  const AiMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.petId,
    this.categoryId,
    this.metadata,
  });

  /// 사용자 메시지 생성
  factory AiMessageEntity.user({
    required String id,
    required String content,
    String? petId,
    String? categoryId,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id,
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      petId: petId,
      categoryId: categoryId,
      metadata: metadata,
    );
  }

  /// AI 응답 메시지 생성
  factory AiMessageEntity.assistant({
    required String id,
    required String content,
    String? petId,
    String? categoryId,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id,
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      petId: petId,
      categoryId: categoryId,
      metadata: metadata,
    );
  }

  /// 시스템 메시지 생성
  factory AiMessageEntity.system({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id,
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  /// 메시지 복사본 생성
  AiMessageEntity copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? petId,
    String? categoryId,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      petId: petId ?? this.petId,
      categoryId: categoryId ?? this.categoryId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'petId': petId,
      'categoryId': categoryId,
      'metadata': metadata,
    };
  }

  /// JSON에서 생성
  factory AiMessageEntity.fromJson(Map<String, dynamic> json) {
    return AiMessageEntity(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      petId: json['petId'] as String?,
      categoryId: json['categoryId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiMessageEntity &&
        other.id == id &&
        other.content == content &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.petId == petId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return Object.hash(id, content, type, timestamp, petId, categoryId);
  }

  @override
  String toString() {
    return 'AiMessageEntity(id: $id, content: $content, type: $type, timestamp: $timestamp, petId: $petId, categoryId: $categoryId)';
  }
}

/// 메시지 타입
enum MessageType {
  user,      // 사용자 메시지
  assistant, // AI 응답 메시지
  system,    // 시스템 메시지
}
```

**주요 특징:**

- **불변성 (Immutability)**: 모든 필드가 final로 선언
- **팩토리 메서드**: 메시지 타입별 생성 메서드 제공
- **JSON 직렬화**: 데이터 저장 및 전송을 위한 변환 메서드
- **복사 메서드**: 상태 변경을 위한 copyWith 메서드
- **동등성 비교**: 올바른 equals 및 hashCode 구현

#### 2. **AI Chat Session Entity (`entities/ai_message_entity.dart`)**

**채팅 세션 엔티티:**

```dart
/// AI 채팅 세션 엔티티
class AiChatSessionEntity {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int messageCount;
  final String? petId;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AiChatSessionEntity({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messageCount,
    this.petId,
    this.categoryId,
    required this.createdAt,
    this.updatedAt,
  });

  /// 새 세션 생성
  factory AiChatSessionEntity.create({
    required String id,
    required String title,
    String? petId,
    String? categoryId,
  }) {
    final now = DateTime.now();
    return AiChatSessionEntity(
      id: id,
      title: title,
      lastMessage: '',
      lastMessageTime: now,
      messageCount: 0,
      petId: petId,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 메시지 추가 시 세션 업데이트
  AiChatSessionEntity addMessage(String message) {
    return copyWith(
      lastMessage: message,
      lastMessageTime: DateTime.now(),
      messageCount: messageCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// 세션 제목 업데이트
  AiChatSessionEntity updateTitle(String newTitle) {
    return copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
  }

  /// 복사본 생성
  AiChatSessionEntity copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? messageCount,
    String? petId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiChatSessionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messageCount: messageCount ?? this.messageCount,
      petId: petId ?? this.petId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'messageCount': messageCount,
      'petId': petId,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory AiChatSessionEntity.fromJson(Map<String, dynamic> json) {
    return AiChatSessionEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      messageCount: json['messageCount'] as int,
      petId: json['petId'] as String?,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
```

#### 3. **AI Category Entity (`entities/ai_category_entity.dart`)**

**AI 상담 카테고리 엔티티:**

```dart
/// AI 상담 카테고리 엔티티
class AiCategoryEntity {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final List<String> exampleQuestions;

  const AiCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.exampleQuestions,
  });

  /// 건강 관리 카테고리
  static const health = AiCategoryEntity(
    id: 'health',
    name: '健康管理',
    description: 'ペットの健康、病気、予防接種について',
    icon: '🏥',
    color: Color(0xFFE57373),
    exampleQuestions: [
      '予防接種のスケジュールは？',
      '病気の症状を見分けるには？',
      '定期健康診断の頻度は？',
    ],
  );

  /// 행동 훈련 카테고리
  static const behavior = AiCategoryEntity(
    id: 'behavior',
    name: '行動・しつけ',
    description: 'ペットの行動問題とトレーニング方法',
    icon: '🎾',
    color: Color(0xFF81C784),
    exampleQuestions: [
      '吠え癖を直すには？',
      'トイレトレーニングの方法は？',
      '分離不安の対処法は？',
    ],
  );

  /// 영양 관리 카테고리
  static const nutrition = AiCategoryEntity(
    id: 'nutrition',
    name: '栄養・食事',
    description: 'ペットの食事と栄養管理について',
    icon: '🍖',
    color: Color(0xFFFFB74D),
    exampleQuestions: [
      '適切な餌の量は？',
      '年齢別の食事内容は？',
      'アレルギー対応食は？',
    ],
  );

  /// 일상 관리 카테고리
  static const daily = AiCategoryEntity(
    id: 'daily',
    name: '日常ケア',
    description: 'グルーミング、散歩、環境整備',
    icon: '🛁',
    color: Color(0xFF64B5F6),
    exampleQuestions: [
      'ブラッシングの頻度は？',
      '適切な散歩時間は？',
      '室内環境の整え方は？',
    ],
  );

  /// 응급 상황 카테고리
  static const emergency = AiCategoryEntity(
    id: 'emergency',
    name: '緊急時対応',
    description: '緊急時の判断と対処法',
    icon: '🚨',
    color: Color(0xFFF06292),
    exampleQuestions: [
      '怪我をした時の対処法は？',
      '中毒症状の見分け方は？',
      '病院に連れて行くタイミングは？',
    ],
  );

  /// 모든 카테고리 목록
  static const List<AiCategoryEntity> allCategories = [
    health,
    behavior,
    nutrition,
    daily,
    emergency,
  ];

  /// ID로 카테고리 찾기
  static AiCategoryEntity? findById(String id) {
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 이름으로 카테고리 찾기
  static AiCategoryEntity? findByName(String name) {
    try {
      return allCategories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color.value,
      'exampleQuestions': exampleQuestions,
    };
  }

  /// JSON에서 생성
  factory AiCategoryEntity.fromJson(Map<String, dynamic> json) {
    return AiCategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: Color(json['color'] as int),
      exampleQuestions: List<String>.from(json['exampleQuestions']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiCategoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AiCategoryEntity(id: $id, name: $name)';
}
```

#### 4. **AI Repository Interface (`repositories/ai_repository.dart`)**

**AI 리포지토리 계약:**

```dart
/// AI 리포지토리 인터페이스
abstract class AiRepository {
  /// 채팅 히스토리 조회
  Future<List<AiMessageEntity>> getChatHistory();

  /// 메시지 전송 및 AI 응답 생성
  Future<String> sendMessage(String message, {PetProfileEntity? petContext});

  /// 채팅 세션 목록 조회
  Future<List<AiChatSessionEntity>> getChatSessions();

  /// 제안 질문 목록 조회
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions();

  /// 메시지 즐겨찾기 토글
  Future<void> toggleFavorite(String messageId);

  /// 즐겨찾기 메시지 목록 조회
  Future<List<AiFavoriteEntity>> getFavoriteMessages();

  /// 즐겨찾기 Q&A 목록 조회
  Future<List<AiFavoriteQaEntity>> getFavoriteQas();

  /// 즐겨찾기 Q&A 추가
  Future<void> addFavoriteQa(AiFavoriteQaEntity favoriteQa);

  /// 즐겨찾기 Q&A 삭제
  Future<void> removeFavoriteQa(String favoriteQaId);

  /// 채팅 요약 생성
  Future<AiChatSummaryEntity> generateChatSummary(String sessionId);

  /// 카테고리별 질문 필터링
  Future<List<AiSuggestedQuestionEntity>> getQuestionsByCategory(String categoryId);
}
```

**주요 메서드:**

- **데이터 조회**: 채팅 히스토리, 세션, 제안 질문 등
- **메시지 처리**: 메시지 전송, AI 응답 생성
- **즐겨찾기 관리**: 즐겨찾기 추가/삭제/조회
- **요약 생성**: 채팅 세션 요약 생성
- **카테고리 관리**: 카테고리별 질문 필터링

### 비즈니스 로직 (Business Logic)

#### 1. **메시지 검증 규칙**

**메시지 유효성 검사:**

```dart
/// 메시지 검증 규칙
class MessageValidationRules {
  /// 최대 메시지 길이
  static const int maxMessageLength = 1000;

  /// 최소 메시지 길이
  static const int minMessageLength = 1;

  /// 금지된 단어 목록
  static const List<String> bannedWords = [
    '政治', '宗教', 'ゲーム', 'ギャンブル', '薬物', '暴力',
    '差別', 'ヘイト', '誹謗中傷', '個人情報', '機密情報',
  ];

  /// 메시지 유효성 검사
  static ValidationResult validateMessage(String message) {
    // 길이 검사
    if (message.length < minMessageLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'メッセージが短すぎます。',
      );
    }

    if (message.length > maxMessageLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'メッセージが長すぎます。最大${maxMessageLength}文字まで。',
      );
    }

    // 금지된 단어 검사
    for (final word in bannedWords) {
      if (message.toLowerCase().contains(word.toLowerCase())) {
        return ValidationResult(
          isValid: false,
          errorMessage: '不適切な内容が含まれています。',
        );
      }
    }

    return ValidationResult(isValid: true);
  }
}

/// 검증 결과
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
```

#### 2. **AI 응답 생성 규칙**

**응답 생성 로직:**

```dart
/// AI 응답 생성 규칙
class AiResponseGenerationRules {
  /// 최대 응답 길이
  static const int maxResponseLength = 2000;

  /// 최소 응답 길이
  static const int minResponseLength = 50;

  /// 응답 품질 기준
  static const double minResponseQuality = 0.7;

  /// 펫 컨텍스트 기반 응답 생성
  static String generateContextualPrompt({
    required String userMessage,
    PetProfileEntity? petContext,
    AiCategoryEntity? category,
  }) {
    String prompt = '''あなたはペット専門のAIアシスタントです。
以下の質問に専門的で実用的なアドバイスを提供してください。
必ず日本語で回答し、具体的で分かりやすい説明を心がけてください。''';

    if (petContext != null) {
      prompt += '''

ペット情報:
・名前: ${petContext.name}
・種類: ${petContext.typeName}
・年齢: ${petContext.age}歳
・品種: ${petContext.breed}
・体重: ${petContext.weight}kg

この情報を考慮して、個別化されたアドバイスを提供してください。''';
    }

    if (category != null) {
      prompt += '''

相談カテゴリ: ${category.name}
${category.description}

このカテゴリに特化した専門的なアドバイスを提供してください。''';
    }

    prompt += '''

ユーザーの質問: $userMessage

上記の情報を踏まえて、具体的で実用的なアドバイスを提供してください。''';

    return prompt;
  }
}
```

#### 3. **즐겨찾기 관리 규칙**

**즐겨찾기 비즈니스 로직:**

```dart
/// 즐겨찾기 관리 규칙
class FavoriteManagementRules {
  /// 최대 즐겨찾기 개수
  static const int maxFavorites = 100;

  /// 즐겨찾기 중복 방지
  static bool isDuplicateFavorite(
    List<AiFavoriteEntity> existingFavorites,
    AiFavoriteEntity newFavorite,
  ) {
    return existingFavorites.any((favorite) =>
        favorite.messageId == newFavorite.messageId &&
        favorite.petId == newFavorite.petId);
  }

  /// 즐겨찾기 정렬 규칙
  static List<AiFavoriteEntity> sortFavorites(
    List<AiFavoriteEntity> favorites,
  ) {
    return List.from(favorites)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 즐겨찾기 그룹화
  static Map<String, List<AiFavoriteEntity>> groupFavoritesByPet(
    List<AiFavoriteEntity> favorites,
  ) {
    final grouped = <String, List<AiFavoriteEntity>>{};

    for (final favorite in favorites) {
      final petId = favorite.petId ?? 'general';
      grouped.putIfAbsent(petId, () => []).add(favorite);
    }

    return grouped;
  }
}
```

### 사용 방법 (Usage)

#### 1. **엔티티 사용**

```dart
import 'package:aipet_frontend/features/ai/domain/domain.dart';

// 메시지 엔티티 생성
final message = AiMessageEntity.user(
  id: 'msg_001',
  content: '강아지가 계속 짖어요',
  petId: 'pet_001',
  categoryId: 'behavior',
);

// 카테고리 엔티티 사용
final healthCategory = AiCategoryEntity.health;
final exampleQuestions = healthCategory.exampleQuestions;

// 채팅 세션 엔티티 생성
final session = AiChatSessionEntity.create(
  id: 'session_001',
  title: '강아지 훈련 상담',
  petId: 'pet_001',
  categoryId: 'behavior',
);
```

#### 2. **리포지토리 인터페이스 사용**

```dart
// 리포지토리 구현체 주입
final aiRepository = ref.read(aiRepositoryProvider);

// 채팅 히스토리 조회
final chatHistory = await aiRepository.getChatHistory();

// 메시지 전송
final aiResponse = await aiRepository.sendMessage(
  '강아지 훈련 방법',
  petContext: selectedPet,
);

// 즐겨찾기 관리
await aiRepository.toggleFavorite('msg_001');
final favorites = await aiRepository.getFavoriteMessages();
```

#### 3. **비즈니스 규칙 적용**

```dart
// 메시지 검증
final validationResult = MessageValidationRules.validateMessage(userInput);
if (!validationResult.isValid) {
  showError(validationResult.errorMessage!);
  return;
}

// AI 응답 프롬프트 생성
final prompt = AiResponseGenerationRules.generateContextualPrompt(
  userMessage: userInput,
  petContext: selectedPet,
  category: selectedCategory,
);

// 즐겨찾기 중복 검사
if (FavoriteManagementRules.isDuplicateFavorite(existingFavorites, newFavorite)) {
  showWarning('이미 즐겨찾기에 추가된 메시지입니다.');
  return;
}
```

### 확장성 (Extensibility)

#### 1. **새로운 메시지 타입 추가**

```dart
// 새로운 메시지 타입 추가
enum MessageType {
  user,      // 사용자 메시지
  assistant, // AI 응답 메시지
  system,    // 시스템 메시지
  image,     // 이미지 메시지 (새로 추가)
  voice,     // 음성 메시지 (새로 추가)
}

// 이미지 메시지 엔티티 확장
class AiImageMessageEntity extends AiMessageEntity {
  final String imageUrl;
  final String? caption;
  final ImageMetadata? metadata;

  const AiImageMessageEntity({
    required super.id,
    required super.content,
    required this.imageUrl,
    this.caption,
    this.metadata,
    super.petId,
    super.categoryId,
    super.metadata: super.metadata,
  }) : super(
          type: MessageType.image,
          timestamp: DateTime.now(),
        );
}
```

#### 2. **새로운 카테고리 추가**

```dart
// 새로운 카테고리 추가
extension AiCategoryEntityExtension on AiCategoryEntity {
  /// 고급 훈련 카테고리
  static const advancedTraining = AiCategoryEntity(
    id: 'advanced_training',
    name: '高度なトレーニング',
    description: '競技会、ドッグスポーツ、専門技能',
    icon: '🏆',
    color: Color(0xFF9C27B0),
    exampleQuestions: [
      'アジリティの基礎は？',
      '服従訓練の進め方は？',
      '競技会への参加方法は？',
    ],
  );
}
```

#### 3. **새로운 검증 규칙 추가**

```dart
// 새로운 검증 규칙 추가
extension MessageValidationRulesExtension on MessageValidationRules {
  /// 이미지 메시지 검증
  static ValidationResult validateImageMessage({
    required String imageUrl,
    String? caption,
  }) {
    // 이미지 URL 유효성 검사
    if (!Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
      return ValidationResult(
        isValid: false,
        errorMessage: '無効な画像URLです。',
      );
    }

    // 캡션 길이 검사
    if (caption != null && caption.length > 200) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'キャプションが長すぎます。最大200文字まで。',
      );
    }

    return ValidationResult(isValid: true);
  }
}
```

### 의존성 (Dependencies)

#### 1. **Flutter 패키지**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
```

#### 2. **프로젝트 내부 의존성**

```dart
// shared 모듈
import 'package:aipet_frontend/shared/shared.dart';

// 다른 feature 모듈
import 'package:aipet_frontend/features/pet_profile/pet_profile.dart';
```

#### 3. **외부 의존성**

- **Flutter Material**: UI 컴포넌트 (Color 등)
- **Dart Core**: 기본 데이터 타입 및 유틸리티

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [構造 (Structure)](#構造-structure)
- [主要コンポーネント (Key Components)](#主要コンポーネント-key-components)
- [ビジネスロジック (Business Logic)](#ビジネスロジック-business-logic)
- [使用方法 (Usage)](#使用方法-usage)
- [拡張性 (Extensibility)](#拡張性-extensibility)
- [依存関係 (Dependencies)](#依存関係-dependencies)

### 概要 (Overview)

AI Feature の Domain Layer は、AI チャットシステムの核心ビジネスロジックとデータ構造を定義します。
Clean Architecture の原則に従ってビジネスルールをカプセル化し、外部依存性から独立したドメインモデルを提供します。

**主要な責任:**

- 🏗️ **エンティティ定義**: AI チャット関連の核心データ構造
- 📋 **リポジトリインターフェース**: データアクセス契約定義
- 🧠 **ビジネスルール**: AI チャットドメインの核心ロジック
- 🔒 **ドメイン検証**: データ整合性とビジネスルール検証
- 📊 **状態管理**: AI チャットセッションとメッセージ状態定義

### 構造 (Structure)

```txt
lib/features/ai/domain/
├── domain.dart                              # Domain Layer バレルファイル
├── entities/                                 # ドメインエンティティ
│   ├── entities.dart                         # entities バレルファイル
│   ├── ai_message_entity.dart                # AI メッセージエンティティ
│   ├── ai_category_entity.dart               # AI カテゴリエンティティ
│   ├── ai_chat_summary_entity.dart           # AI チャットサマリーエンティティ
│   ├── ai_favorite_entity.dart               # AI お気に入りエンティティ
│   └── ai_favorite_qa_entity.dart            # AI Q&A お気に入りエンティティ
└── repositories/                              # リポジトリインターフェース
    ├── repositories.dart                      # repositories バレルファイル
    └── ai_repository.dart                     # AI リポジトリインターフェース
```

**レイヤー別の役割:**

- **Entities**: AI チャットドメインの核心データ構造
- **Repositories**: データアクセス抽象化と契約定義

### 主要コンポーネント (Key Components)

#### 1. **AI メッセージエンティティ (`entities/ai_message_entity.dart`)**

**メッセージエンティティ構造:**

```dart
/// AI チャットメッセージエンティティ
class AiMessageEntity {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? petId;
  final String? categoryId;
  final Map<String, dynamic>? metadata;

  const AiMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.petId,
    this.categoryId,
    this.metadata,
  });

  /// ユーザーメッセージ作成
  factory AiMessageEntity.user({
    required String id,
    required String content,
    String? petId,
    String? categoryId,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id,
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      petId: petId,
      categoryId: categoryId,
      metadata: metadata,
    );
  }

  /// AI 応答メッセージ作成
  factory AiMessageEntity.assistant({
    required String id,
    required String content,
    String? petId,
    String? categoryId,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id,
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      petId: petId,
      categoryId: categoryId,
      metadata: metadata,
    );
  }

  /// システムメッセージ作成
  factory AiMessageEntity.system({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id,
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  /// メッセージコピー作成
  AiMessageEntity copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? petId,
    String? categoryId,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      petId: petId ?? this.petId,
      categoryId: categoryId ?? this.categoryId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON 変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'petId': petId,
      'categoryId': categoryId,
      'metadata': metadata,
    };
  }

  /// JSON から作成
  factory AiMessageEntity.fromJson(Map<String, dynamic> json) {
    return AiMessageEntity(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      petId: json['petId'] as String?,
      categoryId: json['categoryId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiMessageEntity &&
        other.id == id &&
        other.content == content &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.petId == petId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return Object.hash(id, content, type, timestamp, petId, categoryId);
  }

  @override
  String toString() {
    return 'AiMessageEntity(id: $id, content: $content, type: $type, timestamp: $timestamp, petId: $petId, categoryId: $categoryId)';
  }
}

/// メッセージタイプ
enum MessageType {
  user,      // ユーザーメッセージ
  assistant, // AI 応答メッセージ
  system,    // システムメッセージ
}
```

**主要な特徴:**

- **不変性 (Immutability)**: すべてのフィールドが final で宣言
- **ファクトリメソッド**: メッセージタイプ別作成メソッド提供
- **JSON シリアライゼーション**: データ保存と送信のための変換メソッド
- **コピーメソッド**: 状態変更のための copyWith メソッド
- **等価性比較**: 正しい equals と hashCode 実装

#### 2. **AI チャットセッションエンティティ (`entities/ai_message_entity.dart`)**

**チャットセッションエンティティ:**

```dart
/// AI チャットセッションエンティティ
class AiChatSessionEntity {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int messageCount;
  final String? petId;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AiChatSessionEntity({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messageCount,
    this.petId,
    this.categoryId,
    required this.createdAt,
    this.updatedAt,
  });

  /// 新規セッション作成
  factory AiChatSessionEntity.create({
    required String id,
    required String title,
    String? petId,
    String? categoryId,
  }) {
    final now = DateTime.now();
    return AiChatSessionEntity(
      id: id,
      title: title,
      lastMessage: '',
      lastMessageTime: now,
      messageCount: 0,
      petId: petId,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// メッセージ追加時のセッション更新
  AiChatSessionEntity addMessage(String message) {
    return copyWith(
      lastMessage: message,
      lastMessageTime: DateTime.now(),
      messageCount: messageCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// セッションタイトル更新
  AiChatSessionEntity updateTitle(String newTitle) {
    return copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
  }

  /// コピー作成
  AiChatSessionEntity copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? messageCount,
    String? petId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiChatSessionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messageCount: messageCount ?? this.messageCount,
      petId: petId ?? this.petId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON 変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'messageCount': messageCount,
      'petId': petId,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// JSON から作成
  factory AiChatSessionEntity.fromJson(Map<String, dynamic> json) {
    return AiChatSessionEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      messageCount: json['messageCount'] as int,
      petId: json['petId'] as String?,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
```

#### 3. **AI カテゴリエンティティ (`entities/ai_category_entity.dart`)**

**AI 相談カテゴリエンティティ:**

```dart
/// AI 相談カテゴリエンティティ
class AiCategoryEntity {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final List<String> exampleQuestions;

  const AiCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.exampleQuestions,
  });

  /// 健康管理カテゴリ
  static const health = AiCategoryEntity(
    id: 'health',
    name: '健康管理',
    description: 'ペットの健康、病気、予防接種について',
    icon: '🏥',
    color: Color(0xFFE57373),
    exampleQuestions: [
      '予防接種のスケジュールは？',
      '病気の症状を見分けるには？',
      '定期健康診断の頻度は？',
    ],
  );

  /// 行動・しつけカテゴリ
  static const behavior = AiCategoryEntity(
    id: 'behavior',
    name: '行動・しつけ',
    description: 'ペットの行動問題とトレーニング方法',
    icon: '🎾',
    color: Color(0xFF81C784),
    exampleQuestions: [
      '吠え癖を直すには？',
      'トイレトレーニングの方法は？',
      '分離不安の対処法は？',
    ],
  );

  /// 栄養・食事カテゴリ
  static const nutrition = AiCategoryEntity(
    id: 'nutrition',
    name: '栄養・食事',
    description: 'ペットの食事と栄養管理について',
    icon: '🍖',
    color: Color(0xFFFFB74D),
    exampleQuestions: [
      '適切な餌の量は？',
      '年齢別の食事内容は？',
      'アレルギー対応食は？',
    ],
  );

  /// 日常ケアカテゴリ
  static const daily = AiCategoryEntity(
    id: 'daily',
    name: '日常ケア',
    description: 'グルーミング、散歩、環境整備',
    icon: '🛁',
    color: Color(0xFF64B5F6),
    exampleQuestions: [
      'ブラッシングの頻度は？',
      '適切な散歩時間は？',
      '室内環境の整え方は？',
    ],
  );

  /// 緊急時対応カテゴリ
  static const emergency = AiCategoryEntity(
    id: 'emergency',
    name: '緊急時対応',
    description: '緊急時の判断と対処法',
    icon: '🚨',
    color: Color(0xFFF06292),
    exampleQuestions: [
      '怪我をした時の対処法は？',
      '中毒症状の見分け方は？',
      '病院に連れて行くタイミングは？',
    ],
  );

  /// すべてのカテゴリリスト
  static const List<AiCategoryEntity> allCategories = [
    health,
    behavior,
    nutrition,
    daily,
    emergency,
  ];

  /// ID でカテゴリ検索
  static AiCategoryEntity? findById(String id) {
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 名前でカテゴリ検索
  static AiCategoryEntity? findByName(String name) {
    try {
      return allCategories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// JSON 変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color.value,
      'exampleQuestions': exampleQuestions,
    };
  }

  /// JSON から作成
  factory AiCategoryEntity.fromJson(Map<String, dynamic> json) {
    return AiCategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: Color(json['color'] as int),
      exampleQuestions: List<String>.from(json['exampleQuestions']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiCategoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AiCategoryEntity(id: $id, name: $name)';
}
```

#### 4. **AI リポジトリインターフェース (`repositories/ai_repository.dart`)**

**AI リポジトリ契約:**

```dart
/// AI リポジトリインターフェース
abstract class AiRepository {
  /// チャット履歴取得
  Future<List<AiMessageEntity>> getChatHistory();

  /// メッセージ送信とAI 応答生成
  Future<String> sendMessage(String message, {PetProfileEntity? petContext});

  /// チャットセッションリスト取得
  Future<List<AiChatSessionEntity>> getChatSessions();

  /// 提案質問リスト取得
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions();

  /// メッセージお気に入り切り替え
  Future<void> toggleFavorite(String messageId);

  /// お気に入りメッセージリスト取得
  Future<List<AiFavoriteEntity>> getFavoriteMessages();

  /// お気に入りQ&A リスト取得
  Future<List<AiFavoriteQaEntity>> getFavoriteQas();

  /// お気に入りQ&A 追加
  Future<void> addFavoriteQa(AiFavoriteQaEntity favoriteQa);

  /// お気に入りQ&A 削除
  Future<void> removeFavoriteQa(String favoriteQaId);

  /// チャットサマリー生成
  Future<AiChatSummaryEntity> generateChatSummary(String sessionId);

  /// カテゴリ別質問フィルタリング
  Future<List<AiSuggestedQuestionEntity>> getQuestionsByCategory(String categoryId);
}
```

**主要メソッド:**

- **データ取得**: チャット履歴、セッション、提案質問など
- **メッセージ処理**: メッセージ送信、AI 応答生成
- **お気に入り管理**: お気に入り追加/削除/取得
- **サマリー生成**: チャットセッションサマリー生成
- **カテゴリ管理**: カテゴリ別質問フィルタリング

### ビジネスロジック (Business Logic)

#### 1. **メッセージ検証ルール**

**メッセージ有効性検証:**

```dart
/// メッセージ検証ルール
class MessageValidationRules {
  /// 最大メッセージ長
  static const int maxMessageLength = 1000;

  /// 最小メッセージ長
  static const int minMessageLength = 1;

  /// 禁止ワードリスト
  static const List<String> bannedWords = [
    '政治', '宗教', 'ゲーム', 'ギャンブル', '薬物', '暴力',
    '差別', 'ヘイト', '誹謗中傷', '個人情報', '機密情報',
  ];

  /// メッセージ有効性検証
  static ValidationResult validateMessage(String message) {
    // 長さ検証
    if (message.length < minMessageLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'メッセージが短すぎます。',
      );
    }

    if (message.length > maxMessageLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'メッセージが長すぎます。最大${maxMessageLength}文字まで。',
      );
    }

    // 禁止ワード検証
    for (final word in bannedWords) {
      if (message.toLowerCase().contains(word.toLowerCase())) {
        return ValidationResult(
          isValid: false,
          errorMessage: '不適切な内容が含まれています。',
        );
      }
    }

    return ValidationResult(isValid: true);
  }
}

/// 検証結果
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
```

#### 2. **AI 応答生成ルール**

**応答生成ロジック:**

```dart
/// AI 応答生成ルール
class AiResponseGenerationRules {
  /// 最大応答長
  static const int maxResponseLength = 2000;

  /// 最小応答長
  static const int minResponseLength = 50;

  /// 応答品質基準
  static const double minResponseQuality = 0.7;

  /// ペットコンテキストベース応答生成
  static String generateContextualPrompt({
    required String userMessage,
    PetProfileEntity? petContext,
    AiCategoryEntity? category,
  }) {
    String prompt = '''あなたはペット専門のAIアシスタントです。
以下の質問に専門的で実用的なアドバイスを提供してください。
必ず日本語で回答し、具体的で分かりやすい説明を心がけてください。''';

    if (petContext != null) {
      prompt += '''

ペット情報:
・名前: ${petContext.name}
・種類: ${petContext.typeName}
・年齢: ${petContext.age}歳
・品種: ${petContext.breed}
・体重: ${petContext.weight}kg

この情報を考慮して、個別化されたアドバイスを提供してください。''';
    }

    if (category != null) {
      prompt += '''

相談カテゴリ: ${category.name}
${category.description}

このカテゴリに特化した専門的なアドバイスを提供してください。''';
    }

    prompt += '''

ユーザーの質問: $userMessage

上記の情報を踏まえて、具体的で実用的なアドバイスを提供してください。''';

    return prompt;
  }
}
```

#### 3. **お気に入り管理ルール**

**お気に入りビジネスロジック:**

```dart
/// お気に入り管理ルール
class FavoriteManagementRules {
  /// 最大お気に入り数
  static const int maxFavorites = 100;

  /// お気に入り重複防止
  static bool isDuplicateFavorite(
    List<AiFavoriteEntity> existingFavorites,
    AiFavoriteEntity newFavorite,
  ) {
    return existingFavorites.any((favorite) =>
        favorite.messageId == newFavorite.messageId &&
        favorite.petId == newFavorite.petId);
  }

  /// お気に入りソートルール
  static List<AiFavoriteEntity> sortFavorites(
    List<AiFavoriteEntity> favorites,
  ) {
    return List.from(favorites)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// お気に入りグループ化
  static Map<String, List<AiFavoriteEntity>> groupFavoritesByPet(
    List<AiFavoriteEntity> favorites,
  ) {
    final grouped = <String, List<AiFavoriteEntity>>{};

    for (final favorite in favorites) {
      final petId = favorite.petId ?? 'general';
      grouped.putIfAbsent(petId, () => []).add(favorite);
    }

    return grouped;
  }
}
```

### 使用方法 (Usage)

#### 1. **エンティティ使用**

```dart
import 'package:aipet_frontend/features/ai/domain/domain.dart';

// メッセージエンティティ作成
final message = AiMessageEntity.user(
  id: 'msg_001',
  content: '犬が吠え続けます',
  petId: 'pet_001',
  categoryId: 'behavior',
);

// カテゴリエンティティ使用
final healthCategory = AiCategoryEntity.health;
final exampleQuestions = healthCategory.exampleQuestions;

// チャットセッションエンティティ作成
final session = AiChatSessionEntity.create(
  id: 'session_001',
  title: '犬のしつけ相談',
  petId: 'pet_001',
  categoryId: 'behavior',
);
```

#### 2. **リポジトリインターフェース使用**

```dart
// リポジトリ実装体注入
final aiRepository = ref.read(aiRepositoryProvider);

// チャット履歴取得
final chatHistory = await aiRepository.getChatHistory();

// メッセージ送信
final aiResponse = await aiRepository.sendMessage(
  '犬のしつけ方法',
  petContext: selectedPet,
);

// お気に入り管理
await aiRepository.toggleFavorite('msg_001');
final favorites = await aiRepository.getFavoriteMessages();
```

#### 3. **ビジネスルール適用**

```dart
// メッセージ検証
final validationResult = MessageValidationRules.validateMessage(userInput);
if (!validationResult.isValid) {
  showError(validationResult.errorMessage!);
  return;
}

// AI 応答プロンプト生成
final prompt = AiResponseGenerationRules.generateContextualPrompt(
  userMessage: userInput,
  petContext: selectedPet,
  category: selectedCategory,
);

// お気に入り重複検証
if (FavoriteManagementRules.isDuplicateFavorite(existingFavorites, newFavorite)) {
  showWarning('既にお気に入りに追加されたメッセージです。');
  return;
}
```

### 拡張性 (Extensibility)

#### 1. **新しいメッセージタイプ追加**

```dart
// 新しいメッセージタイプ追加
enum MessageType {
  user,      // ユーザーメッセージ
  assistant, // AI 応答メッセージ
  system,    // システムメッセージ
  image,     // 画像メッセージ (新規追加)
  voice,     // 音声メッセージ (新規追加)
}

// 画像メッセージエンティティ拡張
class AiImageMessageEntity extends AiMessageEntity {
  final String imageUrl;
  final String? caption;
  final ImageMetadata? metadata;

  const AiImageMessageEntity({
    required super.id,
    required super.content,
    required this.imageUrl,
    this.caption,
    this.metadata,
    super.petId,
    super.categoryId,
    super.metadata: super.metadata,
  }) : super(
          type: MessageType.image,
          timestamp: DateTime.now(),
        );
}
```

#### 2. **新しいカテゴリ追加**

```dart
// 新しいカテゴリ追加
extension AiCategoryEntityExtension on AiCategoryEntity {
  /// 高度なトレーニングカテゴリ
  static const advancedTraining = AiCategoryEntity(
    id: 'advanced_training',
    name: '高度なトレーニング',
    description: '競技会、ドッグスポーツ、専門技能',
    icon: '🏆',
    color: Color(0xFF9C27B0),
    exampleQuestions: [
      'アジリティの基礎は？',
      '服従訓練の進め方は？',
      '競技会への参加方法は？',
    ],
  );
}
```

#### 3. **新しい検証ルール追加**

```dart
// 新しい検証ルール追加
extension MessageValidationRulesExtension on MessageValidationRules {
  /// 画像メッセージ検証
  static ValidationResult validateImageMessage({
    required String imageUrl,
    String? caption,
  }) {
    // 画像URL 有効性検証
    if (!Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
      return ValidationResult(
        isValid: false,
        errorMessage: '無効な画像URLです。',
      );
    }

    // キャプション長さ検証
    if (caption != null && caption.length > 200) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'キャプションが長すぎます。最大200文字まで。',
      );
    }

    return ValidationResult(isValid: true);
  }
}
```

### 依存関係 (Dependencies)

#### 1. **Flutter パッケージ**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
```

#### 2. **プロジェクト内部依存関係**

```dart
// shared モジュール
import 'package:aipet_frontend/shared/shared.dart';

// 他のfeature モジュール
import 'package:aipet_frontend/features/pet_profile/pet_profile.dart';
```

#### 3. **外部依存関係**

- **Flutter Material**: UI コンポーネント (Color など)
- **Dart Core**: 基本データ型とユーティリティ

---

## 📚 추가 리소스 / その他のリソース

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Flutter Riverpod](https://riverpod.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

© 2025 AI Pet. AI 기능 도메인 계층 / AI Feature Domain Layer
