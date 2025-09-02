# AI Feature / AI 機能

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [아키텍처 (Architecture)](#아키텍처-architecture)
- [주요 기능 (Key Features)](#주요-기능-key-features)
- [디렉토리 구조 (Directory Structure)](#디렉토리-구조-directory-structure)
- [AI 채팅 플로우 (AI Chat Flow)](#ai-채팅-플로우-ai-chat-flow)
- [UI 구성 (UI Components)](#ui-구성-ui-components)
- [사용 방법 (Usage)](#사용-방법-usage)
- [설정 (Configuration)](#설정-configuration)

### 개요 (Overview)

AI Pet 애플리케이션의 AI 채팅 및 상담 기능을 담당하는 모듈입니다.
OpenAI GPT API를 활용하여 펫 전문 AI 어시스턴트 서비스를 제공합니다.

**주요 특징:**

- 🤖 **OpenAI GPT 기반**: GPT-3.5-turbo 모델을 사용한 고품질 응답
- 🔍 **펫 관련 콘텐츠 필터링**: 비관련 질문 자동 차단 및 안전한 응답
- 💬 **실시간 채팅 인터페이스**: 직관적이고 반응적인 채팅 UI
- ⭐ **즐겨찾기 및 카테고리**: 중요 응답 저장 및 분류 시스템
- 🐕 **펫 프로필 기반 맞춤 상담**: 개별 펫 정보를 활용한 개인화된 조언
- 🛡️ **일본어 기반 안전한 응답**: 사용자 친화적인 일본어 인터페이스
- 🎯 **Clean Architecture 패턴**: 확장 가능하고 유지보수하기 쉬운 구조

### 아키텍처 (Architecture)

```txt
lib/features/ai/
├── data/               # 데이터 계층
│   ├── providers/      # Riverpod 프로바이더
│   ├── repositories/   # AI 리포지토리 구현
│   └── services/       # OpenAI API 및 콘텐츠 필터링
├── domain/             # 도메인 계층
│   ├── entities/       # AI 채팅 관련 엔티티
│   └── repositories/   # AI 리포지토리 인터페이스
└── presentation/       # 프레젠테이션 계층
    ├── controllers/    # AI 채팅 컨트롤러
    ├── screens/        # 채팅 화면 및 즐겨찾기 화면
    └── widgets/        # 채팅 관련 UI 컴포넌트
```

**Clean Architecture 적용:**

- **Domain Layer**: AI 엔티티, 리포지토리 인터페이스 정의
- **Data Layer**: OpenAI API 통신, 콘텐츠 필터링 서비스
- **Presentation Layer**: 채팅 UI 및 컨트롤러

### 주요 기능 (Key Features)

#### 🤖 **AI 채팅 시스템**

- **OpenAI GPT-3.5-turbo** 기반 응답 생성
- **펫 전문 시스템 프롬프트** - 펫 관련 질문에만 응답
- **실시간 타이핑 인디케이터** 및 응답 처리
- **일본어 기반 응답** - 사용자 친화적 인터페이스

#### 🔍 **콘텐츠 필터링**

- **펫 관련 콘텐츠 검증** - 비관련 질문 자동 차단
- **안전한 응답 시스템** - 부적절한 내용 필터링
- **맞춤형 거부 메시지** - 일본어 안내 메시지

#### 💬 **채팅 인터페이스**

- **실시간 메시지 교환**
- **메시지 즐겨찾기** 기능
- **카테고리별 분류** 시스템
- **제안 질문** 제공

#### 🐕 **펫 컨텍스트 지원**

- **펫 프로필 기반 상담** - 개별화된 조언
- **연령/품종별 맞춤 응답**
- **펫 정보 활용한 전문 상담**

### 디렉토리 구조 (Directory Structure)

```txt
ai/
├── ai.dart                              # 기능 export 파일
├── README.md                            # 이 문서
├── data/                                # Data Layer
│   ├── data.dart                        # data 레이어 배럴
│   ├── providers/
│   │   ├── ai_providers.dart            # Riverpod 프로바이더
│   │   └── ai_providers.g.dart          # 생성된 코드
│   ├── repositories/
│   │   └── ai_repository_impl.dart      # AI 리포지토리 구현
│   └── services/
│       ├── openai_service.dart          # OpenAI API 서비스
│       └── pet_content_filter_service.dart # 콘텐츠 필터링
├── domain/                              # Domain Layer
│   ├── domain.dart                      # domain 레이어 배럴
│   ├── entities/
│   │   ├── entities.dart                # entities 배럴
│   │   ├── ai_message_entity.dart       # 메시지 엔티티
│   │   ├── ai_category_entity.dart      # 카테고리 엔티티
│   │   ├── ai_chat_summary_entity.dart  # 채팅 요약 엔티티
│   │   ├── ai_favorite_entity.dart      # 즐겨찾기 엔티티
│   │   └── ai_favorite_qa_entity.dart   # Q&A 즐겨찾기
│   └── repositories/
│       ├── repositories.dart             # repositories 배럴
│       └── ai_repository.dart           # AI 리포지토리 인터페이스
└── presentation/                        # Presentation Layer
    ├── presentation.dart                 # presentation 레이어 배럴
    ├── controllers/
    │   ├── ai_chat_controller.dart      # 채팅 컨트롤러
    │   └── ai_chat_controller.g.dart    # 생성된 코드
    ├── screens/
    │   ├── ai_chat_screen.dart          # 채팅 화면
    │   └── ai_favorite_messages_screen.dart # 즐겨찾기 화면
    └── widgets/
        ├── widgets.dart                  # widgets 배럴
        ├── ai_message_bubble.dart        # 메시지 버블
        ├── ai_message_input.dart         # 메시지 입력
        ├── ai_typing_indicator.dart      # 타이핑 인디케이터
        ├── ai_suggested_questions.dart   # 제안 질문
        ├── ai_category_selection.dart    # 카테고리 선택
        ├── ai_category_selection_bubble.dart
        ├── ai_pet_selection.dart         # 펫 선택
        ├── ai_pet_selection_bubble.dart
        └── ai_question_request_bubble.dart
```

### AI 채팅 플로우 (AI Chat Flow)

#### 📊 **AI 채팅 플로우 다이어그램**

```txt
[질문 입력] → [콘텐츠 필터링] → [OpenAI API 호출] → [응답 표시]
    ↓              ↓                    ↓              ↓
  사용자 입력   펫 관련 검증         GPT 응답 생성    UI 업데이트
    ↓              ↓                    ↓              ↓
  유효성 확인   부적절시 거부         일본어 응답     메시지 저장
```

#### 🔄 **메시지 처리 플로우**

##### 1단계: 메시지 입력 및 검증

```dart
// 사용자 메시지 검증
Future<void> sendMessage(String message) async {
  // 콘텐츠 필터링
  final filterResult = await _contentFilter.validatePetContent(message);

  if (!filterResult.isValid) {
    // 거부 메시지 표시
    _showRejectionMessage(filterResult.reason);
    return;
  }

  // 메시지 처리 계속
  _processMessage(message);
}
```

##### 2단계: OpenAI API 호출

```dart
// OpenAI API 호출
Future<String> _generateResponse(String message) async {
  final response = await _openAIService.generateResponse(
    message,
    petContext: selectedPet, // 선택된 펫 정보
  );
  return response;
}
```

##### 3단계: 응답 처리 및 표시

```dart
// 응답 메시지 추가
void _addAIResponse(String response) {
  final aiMessage = AiMessageEntity(
    id: _generateId(),
    content: response,
    type: MessageType.assistant,
    timestamp: DateTime.now(),
  );

  state = [...state, aiMessage];
}
```

#### 🎨 **UI 상태 관리**

**실시간 채팅 업데이트:**

```dart
// 메시지 리스트 관리
class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() => const AiChatState();

  void addMessage(AiMessageEntity message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  void setTyping(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);
  }
}
```

**펫 컨텍스트 기반 상담:**

```dart
// 펫 정보를 포함한 시스템 프롬프트 생성
String _buildSystemPrompt(PetProfileEntity? petContext) {
  if (petContext != null) {
    return '''ペット情報:
・名前: ${petContext.name}
・種類: ${petContext.typeName}
・年齢: ${petContext.age}歳
この情報を考慮してアドバイスしてください。''';
  }
  return 'ペット専門のAIアシスタントです。';
}
```

### UI 구성 (UI Components)

#### 1. **채팅 화면 구조**

```dart
Scaffold(
  appBar: AppBar(title: Text('AI相談')),
  body: Column(
    children: [
      // 메시지 리스트
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) => AiMessageBubble(...),
        ),
      ),
      // 메시지 입력
      AiMessageInput(onSendMessage: _sendMessage),
    ],
  ),
)
```

#### 2. **컴포넌트별 역할**

**AiMessageBubble:**

- 사용자/AI 메시지 표시
- 즐겨찾기 기능
- 시간 표시

**AiMessageInput:**

- 메시지 입력 필드
- 전송 버튼
- 음성 입력 지원

**AiTypingIndicator:**

- AI 응답 대기 중 표시
- 애니메이션 효과

**AiSuggestedQuestions:**

- 추천 질문 버튼
- 카테고리별 질문 제공

### 사용 방법 (Usage)

#### 1. **기본 사용**

```dart
import 'package:aipet_frontend/features/ai/ai.dart';

// AI 채팅 화면으로 이동
context.go('/ai-chat');
```

#### 2. **Controller 사용**

```dart
final aiChatController = ref.read(aiChatControllerProvider.notifier);

// 메시지 전송
await aiChatController.sendMessage('강아지가 계속 짖어요');

// 메시지 즐겨찾기 추가
aiChatController.toggleFavorite(messageId);
```

#### 3. **Provider 사용**

```dart
// 채팅 메시지 목록
final messages = ref.watch(aiChatNotifierProvider);

// 타이핑 상태
final isTyping = ref.watch(aiChatNotifierProvider.select((state) => state.isTyping));

// 선택된 펫
final selectedPet = ref.watch(aiChatNotifierProvider.select((state) => state.selectedPet));
```

#### 4. **펫 컨텍스트 설정**

```dart
// 특정 펫을 선택하여 맞춤 상담
ref.read(aiChatNotifierProvider.notifier).selectPet(petProfile);

// 카테고리 선택
ref.read(aiChatNotifierProvider.notifier).selectCategory(AiCategoryEntity.health);
```

### 설정 (Configuration)

#### OpenAI API 설정

`.env` 파일에서 OpenAI API 키를 설정:

```env
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-3.5-turbo
```

#### 콘텐츠 필터링 설정

`lib/features/ai/data/services/pet_content_filter_service.dart`에서 필터링 규칙 수정:

```dart
class PetContentFilterService {
  // 펫 관련 키워드
  static const List<String> petKeywords = [
    '강아지', '고양이', '펫', 'ペット', '犬', '猫'
  ];

  // 금지 키워드
  static const List<String> bannedKeywords = [
    '정치', '종교', 'ゲーム'
  ];
}
```

#### 의존성

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  dio: ^5.4.3+1
  go_router: ^14.6.2
```

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [アーキテクチャ (Architecture)](#アーキテクチャ-architecture)
- [主要機能 (Key Features)](#主要機能-key-features)
- [ディレクトリ構造 (Directory Structure)](#ディレクトリ構造-directory-structure)
- [AI チャットフロー (AI Chat Flow)](#ai-チャットフロー-ai-chat-flow)
- [UI 構成 (UI Components)](#ui-構成-ui-components)
- [使用方法 (Usage)](#使用方法-usage)
- [設定 (Configuration)](#設定-configuration)

### 概要 (Overview)

AI Pet アプリケーションの AI チャットと相談機能を担当するモジュールです。
OpenAI GPT API を活用してペット専門 AI アシスタントサービスを提供します。

**主な特徴:**

- 🤖 **OpenAI GPT ベース**: GPT-3.5-turbo モデルを使用した高品質応答
- 🔍 **ペット関連コンテンツフィルタリング**: 非関連質問の自動ブロックと安全な応答
- 💬 **リアルタイムチャットインターフェース**: 直感的で反応的なチャット UI
- ⭐ **お気に入りとカテゴリ**: 重要応答の保存と分類システム
- 🐕 **ペットプロフィールベースのカスタム相談**: 個別ペット情報を活用した個別化されたアドバイス
- 🛡️ **日本語ベースの安全な応答**: ユーザーフレンドリーな日本語インターフェース
- 🎯 **Clean Architecture パターン**: 拡張可能で保守しやすい構造

### アーキテクチャ (Architecture)

```txt
lib/features/ai/
├── data/               # データ層
│   ├── providers/      # Riverpod プロバイダー
│   ├── repositories/   # AI リポジトリ実装
│   └── services/       # OpenAI API とコンテンツフィルタリング
├── domain/             # ドメイン層
│   ├── entities/       # AI チャット関連エンティティ
│   └── repositories/   # AI リポジトリインターフェース
└── presentation/       # プレゼンテーション層
    ├── controllers/    # AI チャットコントローラー
    ├── screens/        # チャット画面とお気に入り画面
    └── widgets/        # チャット関連 UI コンポーネント
```

**Clean Architecture 適用:**

- **Domain Layer**: AI エンティティ、リポジトリインターフェース定義
- **Data Layer**: OpenAI API 通信、コンテンツフィルタリングサービス
- **Presentation Layer**: チャット UI とコントローラー

### 主要機能 (Key Features)

#### 🤖 **AI チャットシステム**

- **OpenAI GPT-3.5-turbo** ベースの応答生成
- **ペット専門システムプロンプト** - ペット関連質問にのみ応答
- **リアルタイムタイピングインジケーター** と応答処理
- **日本語ベースの応答** - ユーザーフレンドリーなインターフェース

#### 🔍 **コンテンツフィルタリング**

- **ペット関連コンテンツ検証** - 非関連質問の自動ブロック
- **安全な応答システム** - 不適切な内容のフィルタリング
- **カスタム拒否メッセージ** - 日本語案内メッセージ

#### 💬 **チャットインターフェース**

- **リアルタイムメッセージ交換**
- **メッセージお気に入り** 機能
- **カテゴリ別分類** システム
- **提案質問** 提供

#### 🐕 **ペットコンテキスト対応**

- **ペットプロフィールベースの相談** - 個別化されたアドバイス
- **年齢/品種別のカスタム応答**
- **ペット情報を活用した専門相談**

### ディレクトリ構造 (Directory Structure)

```txt
ai/
├── ai.dart                              # 機能 export ファイル
├── README.md                            # この文書
├── data/                                # Data Layer
│   ├── data.dart                        # data 層バレル
│   ├── providers/
│   │   ├── ai_providers.dart            # Riverpod プロバイダー
│   │   └── ai_providers.g.dart          # 生成されたコード
│   ├── repositories/
│   │   └── ai_repository_impl.dart      # AI リポジトリ実装
│   └── services/
│       ├── openai_service.dart          # OpenAI API サービス
│       └── pet_content_filter_service.dart # コンテンツフィルタリング
├── domain/                              # Domain Layer
│   ├── domain.dart                      # domain 層バレル
│   ├── entities/
│   │   ├── entities.dart                # entities バレル
│   │   ├── ai_message_entity.dart       # メッセージエンティティ
│   │   ├── ai_category_entity.dart      # カテゴリエンティティ
│   │   ├── ai_chat_summary_entity.dart  # チャットサマリーエンティティ
│   │   ├── ai_favorite_entity.dart      # お気に入りエンティティ
│   │   └── ai_favorite_qa_entity.dart   # Q&A お気に入り
│   └── repositories/
│       ├── repositories.dart             # repositories バレル
│       └── ai_repository.dart           # AI リポジトリインターフェース
└── presentation/                        # Presentation Layer
    ├── presentation.dart                 # presentation 層バレル
    ├── controllers/
    │   ├── ai_chat_controller.dart      # チャットコントローラー
    │   └── ai_chat_controller.g.dart    # 生成されたコード
    ├── screens/
    │   ├── ai_chat_screen.dart          # チャット画面
    │   └── ai_favorite_messages_screen.dart # お気に入り画面
    └── widgets/
        ├── widgets.dart                  # widgets バレル
        ├── ai_message_bubble.dart        # メッセージバブル
        ├── ai_message_input.dart         # メッセージ入力
        ├── ai_typing_indicator.dart      # タイピングインジケーター
        ├── ai_suggested_questions.dart   # 提案質問
        ├── ai_category_selection.dart    # カテゴリ選択
        ├── ai_category_selection_bubble.dart
        ├── ai_pet_selection.dart         # ペット選択
        ├── ai_pet_selection_bubble.dart
        └── ai_question_request_bubble.dart
```

### AI チャットフロー (AI Chat Flow)

#### 📊 **AI チャットフローダイアグラム**

```txt
[質問入力] → [コンテンツフィルタリング] → [OpenAI API 呼び出し] → [応答表示]
    ↓              ↓                    ↓              ↓
  ユーザー入力   ペット関連検証         GPT 応答生成    UI 更新
    ↓              ↓                    ↓              ↓
  有効性確認     不適切時拒否          日本語応答     メッセージ保存
```

#### 🔄 **メッセージ処理フロー**

##### 1 段階: メッセージ入力と検証

```dart
// ユーザーメッセージ検証
Future<void> sendMessage(String message) async {
  // コンテンツフィルタリング
  final filterResult = await _contentFilter.validatePetContent(message);

  if (!filterResult.isValid) {
    // 拒否メッセージ表示
    _showRejectionMessage(filterResult.reason);
    return;
  }

  // メッセージ処理継続
  _processMessage(message);
}
```

##### 2 段階: OpenAI API 呼び出し

```dart
// OpenAI API 呼び出し
Future<String> _generateResponse(String message) async {
  final response = await _openAIService.generateResponse(
    message,
    petContext: selectedPet, // 選択されたペット情報
  );
  return response;
}
```

##### 3 段階: 応答処理と表示

```dart
// 応答メッセージ追加
void _addAIResponse(String response) {
  final aiMessage = AiMessageEntity(
    id: _generateId(),
    content: response,
    type: MessageType.assistant,
    timestamp: DateTime.now(),
  );

  state = [...state, aiMessage];
}
```

#### 🎨 **UI 状態管理**

**リアルタイムチャット更新:**

```dart
// メッセージリスト管理
class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() => const AiChatState();

  void addMessage(AiMessageEntity message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  void setTyping(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);
  }
}
```

**ペットコンテキストベースの相談:**

```dart
// ペット情報を含むシステムプロンプト生成
String _buildSystemPrompt(PetProfileEntity? petContext) {
  if (petContext != null) {
    return '''ペット情報:
・名前: ${petContext.name}
・種類: ${petContext.typeName}
・年齢: ${petContext.age}歳
この情報を考慮してアドバイスしてください。''';
  }
  return 'ペット専門のAIアシスタントです。';
}
```

### UI 構成 (UI Components)

#### 1. **チャット画面構造**

```dart
Scaffold(
  appBar: AppBar(title: Text('AI相談')),
  body: Column(
    children: [
      // メッセージリスト
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) => AiMessageBubble(...),
        ),
      ),
      // メッセージ入力
      AiMessageInput(onSendMessage: _sendMessage),
    ],
  ),
)
```

#### 2. **コンポーネント別の役割**

**AiMessageBubble:**

- ユーザー/AI メッセージ表示
- お気に入り機能
- 時間表示

**AiMessageInput:**

- メッセージ入力フィールド
- 送信ボタン
- 音声入力対応

**AiTypingIndicator:**

- AI 応答待機中表示
- アニメーション効果

**AiSuggestedQuestions:**

- 推奨質問ボタン
- カテゴリ別質問提供

### 使用方法 (Usage)

#### 1. **基本使用**

```dart
import 'package:aipet_frontend/features/ai/ai.dart';

// AI チャット画面へ移動
context.go('/ai-chat');
```

#### 2. **Controller 使用**

```dart
final aiChatController = ref.read(aiChatControllerProvider.notifier);

// メッセージ送信
await aiChatController.sendMessage('犬が吠え続けます');

// メッセージお気に入り追加
aiChatController.toggleFavorite(messageId);
```

#### 3. **Provider 使用**

```dart
// チャットメッセージリスト
final messages = ref.watch(aiChatNotifierProvider);

// タイピング状態
final isTyping = ref.watch(aiChatNotifierProvider.select((state) => state.isTyping));

// 選択されたペット
final selectedPet = ref.watch(aiChatNotifierProvider.select((state) => state.selectedPet));
```

#### 4. **ペットコンテキスト設定**

```dart
// 特定のペットを選択してカスタム相談
ref.read(aiChatNotifierProvider.notifier).selectPet(petProfile);

// カテゴリ選択
ref.read(aiChatNotifierProvider.notifier).selectCategory(AiCategoryEntity.health);
```

### 設定 (Configuration)

#### OpenAI API 設定

`.env` ファイルで OpenAI API キーを設定:

```env
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-3.5-turbo
```

#### コンテンツフィルタリング設定

`lib/features/ai/data/services/pet_content_filter_service.dart` でフィルタリングルール修正:

```dart
class PetContentFilterService {
  // ペット関連キーワード
  static const List<String> petKeywords = [
    '犬', '猫', 'ペット', '강아지', '고양이'
  ];

  // 禁止キーワード
  static const List<String> bannedKeywords = [
    '政治', '宗教', 'ゲーム'
  ];
}
```

#### 依存関係

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  dio: ^5.4.3+1
  go_router: ^14.6.2
```

---

## 📚 추가 리소스 / その他のリソース

- [OpenAI API 문서 / OpenAI API ドキュメント](https://platform.openai.com/docs)
- [Riverpod 가이드 / Riverpod ガイド](https://riverpod.dev/)
- [Dio HTTP 클라이언트 / Dio HTTP クライアント](https://pub.dev/packages/dio)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

© 2025 AI Pet. 프로덕션 레벨 AI 채팅 시스템 / Production-ready AI Chat System
