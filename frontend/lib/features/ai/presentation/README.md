# AI Feature - Presentation Layer / AI 機能 - プレゼンテーション層

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 목차 (Table of Contents)

- [개요 (Overview)](#개요-overview)
- [구조 (Structure)](#구조-structure)
- [주요 컴포넌트 (Key Components)](#주요-컴포넌트-key-components)
- [UI 패턴 (UI Patterns)](#ui-패턴-ui-patterns)
- [상태 관리 (State Management)](#상태-관리-state-management)
- [사용 방법 (Usage)](#사용-방법-usage)
- [커스터마이징 (Customization)](#커스터마이징-customization)
- [의존성 (Dependencies)](#의존성-dependencies)

### 개요 (Overview)

AI Feature의 Presentation Layer는 AI 채팅 시스템의 사용자 인터페이스와 상호작용을 담당합니다.
Clean Architecture 원칙에 따라 UI 로직과 비즈니스 로직을 분리하고, Riverpod을 통한 반응형 상태 관리를 제공합니다.

**주요 책임:**

- 🎨 **UI 렌더링**: AI 채팅 화면 및 컴포넌트 표시
- 🎮 **사용자 상호작용**: 메시지 입력, 버튼 클릭, 제스처 처리
- 📱 **상태 관리**: Riverpod을 통한 UI 상태 및 비즈니스 상태 관리
- 🔄 **데이터 바인딩**: Domain Layer와 UI 간의 데이터 연결
- 🎯 **사용자 경험**: 직관적이고 반응적인 채팅 인터페이스 제공

### 구조 (Structure)

```txt
lib/features/ai/presentation/
├── presentation.dart                         # Presentation Layer 배럴 파일
├── controllers/                              # 컨트롤러 및 상태 관리
│   ├── ai_chat_controller.dart               # AI 채팅 컨트롤러
│   └── ai_chat_controller.g.dart             # 생성된 Riverpod 코드
├── screens/                                  # 화면 컴포넌트
│   ├── ai_chat_screen.dart                   # AI 채팅 메인 화면
│   └── ai_favorite_messages_screen.dart      # 즐겨찾기 메시지 화면
└── widgets/                                  # 재사용 가능한 UI 컴포넌트
    ├── widgets.dart                          # widgets 배럴 파일
    ├── ai_message_bubble.dart                # 메시지 버블 컴포넌트
    ├── ai_message_input.dart                 # 메시지 입력 컴포넌트
    ├── ai_typing_indicator.dart              # 타이핑 인디케이터
    ├── ai_suggested_questions.dart           # 제안 질문 컴포넌트
    ├── ai_category_selection.dart            # 카테고리 선택 컴포넌트
    ├── ai_category_selection_bubble.dart     # 카테고리 선택 버블
    ├── ai_pet_selection.dart                 # 펫 선택 컴포넌트
    ├── ai_pet_selection_bubble.dart          # 펫 선택 버블
    └── ai_question_request_bubble.dart       # 질문 요청 버블
```

**레이어별 역할:**

- **Controllers**: UI 상태 관리 및 비즈니스 로직 조정
- **Screens**: 전체 화면 레이아웃 및 네비게이션
- **Widgets**: 재사용 가능한 UI 컴포넌트

### 주요 컴포넌트 (Key Components)

#### 1. **AI Chat Controller (`controllers/ai_chat_controller.dart`)**

**상태 관리 및 비즈니스 로직:**

```dart
/// AI 채팅 상태
class AiChatState {
  final List<AiMessageEntity> messages;
  final bool isLoading;
  final bool isTyping;
  final PetProfileEntity? selectedPet;
  final AiCategoryEntity? selectedCategory;
  final String? errorMessage;
  final List<AiSuggestedQuestionEntity> suggestedQuestions;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.selectedPet,
    this.selectedCategory,
    this.errorMessage,
    this.suggestedQuestions = const [],
  });

  /// 상태 복사본 생성
  AiChatState copyWith({
    List<AiMessageEntity>? messages,
    bool? isLoading,
    bool? isTyping,
    PetProfileEntity? selectedPet,
    AiCategoryEntity? selectedCategory,
    String? errorMessage,
    List<AiSuggestedQuestionEntity>? suggestedQuestions,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      selectedPet: selectedPet ?? this.selectedPet,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
    );
  }
}

/// AI 채팅 상태 관리 (Riverpod Notifier)
@riverpod
class AiChatNotifier extends _$AiChatNotifier {
  @override
  AiChatState build() => const AiChatState();

  /// 초기 데이터 로드
  Future<void> initializeChat() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(aiRepositoryProvider);

      // 채팅 히스토리 로드
      final messages = await repository.getChatHistory();

      // 제안 질문 로드
      final suggestedQuestions = await repository.getSuggestedQuestions();

      state = state.copyWith(
        messages: messages,
        suggestedQuestions: suggestedQuestions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'チャットの初期化に失敗しました: $e',
        isLoading: false,
      );
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = AiMessageEntity.user(
      id: _generateId(),
      content: message.trim(),
      petId: state.selectedPet?.id,
      categoryId: state.selectedCategory?.id,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    try {
      final repository = ref.read(aiRepositoryProvider);

      // AI 응답 생성
      final aiResponse = await repository.sendMessage(
        message,
        petContext: state.selectedPet,
      );

      // AI 응답 메시지 추가
      final aiMessage = AiMessageEntity.assistant(
        id: _generateId(),
        content: aiResponse,
        petId: state.selectedPet?.id,
        categoryId: state.selectedCategory?.id,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
      );
    } catch (e) {
      // 에러 메시지 추가
      final errorMessage = AiMessageEntity.system(
        id: _generateId(),
        content: '申し訳ございません。エラーが発生しました: $e',
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isTyping: false,
        errorMessage: 'メッセージの送信に失敗しました: $e',
      );
    }
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// 카테고리 선택
  void selectCategory(AiCategoryEntity? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// 메시지 즐겨찾기 토글
  Future<void> toggleFavorite(String messageId) async {
    try {
      final repository = ref.read(aiRepositoryProvider);
      await repository.toggleFavorite(messageId);

      // 메시지 목록 업데이트 (즐겨찾기 상태 반영)
      final updatedMessages = state.messages.map((message) {
        if (message.id == messageId) {
          // 즐겨찾기 상태 토글 (실제로는 메시지에 즐겨찾기 필드가 있어야 함)
          return message;
        }
        return message;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'お気に入りの更新に失敗しました: $e',
      );
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// ID 생성
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// AI 채팅 컨트롤러 (BaseController 패턴)
class AiChatController extends BaseController {
  final Ref ref;
  final BuildContext context;

  AiChatController(this.ref, this.context);

  /// 채팅 초기화
  Future<void> initializeChat() async {
    try {
      await ref.read(aiChatNotifierProvider.notifier).initializeChat();
      showSuccess('チャットが初期化されました');
    } catch (error) {
      handleError(error);
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String message) async {
    try {
      await ref.read(aiChatNotifierProvider.notifier).sendMessage(message);
    } catch (error) {
      handleError(error);
    }
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    ref.read(aiChatNotifierProvider.notifier).selectPet(pet);
    if (pet != null) {
      showInfo('${pet.name}が選択されました');
    }
  }

  /// 카테고리 선택
  void selectCategory(AiCategoryEntity? category) {
    ref.read(aiChatNotifierProvider.notifier).selectCategory(category);
    if (category != null) {
      showInfo('${category.name}カテゴリが選択されました');
    }
  }

  /// 즐겨찾기 화면으로 이동
  void navigateToFavorites() {
    context.push('/ai-favorites');
  }
}
```

**주요 특징:**

- **Riverpod Notifier**: 상태 관리 및 비즈니스 로직
- **BaseController**: 에러 처리 및 사용자 피드백
- **비동기 처리**: 메시지 전송 및 AI 응답 생성
- **상태 업데이트**: UI 상태의 반응형 업데이트

#### 2. **AI Chat Screen (`screens/ai_chat_screen.dart`)**

**메인 채팅 화면:**

```dart
/// AI 채팅 메인 화면
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatControllerProvider.notifier).initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatNotifierProvider);
    final controller = ref.read(aiChatControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI相談'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: controller.navigateToFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          // 펫 및 카테고리 선택
          if (chatState.messages.isEmpty) ...[
            _buildPetSelection(controller),
            _buildCategorySelection(controller),
          ],

          // 메시지 리스트
          Expanded(
            child: _buildMessageList(chatState),
          ),

          // 메시지 입력
          _buildMessageInput(controller, chatState),
        ],
      ),
    );
  }

  /// 펫 선택 위젯
  Widget _buildPetSelection(AiChatController controller) {
    return Consumer(
      builder: (context, ref, child) {
        final pets = ref.watch(petListProvider);

        return pets.when(
          data: (petList) => AiPetSelection(
            pets: petList,
            selectedPet: ref.watch(aiChatNotifierProvider).selectedPet,
            onPetSelected: controller.selectPet,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('エラー: $error'),
        );
      },
    );
  }

  /// 카테고리 선택 위젯
  Widget _buildCategorySelection(AiChatController controller) {
    return AiCategorySelection(
      categories: AiCategoryEntity.allCategories,
      selectedCategory: ref.watch(aiChatNotifierProvider).selectedCategory,
      onCategorySelected: controller.selectCategory,
    );
  }

  /// 메시지 리스트 위젯
  Widget _buildMessageList(AiChatState chatState) {
    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatState.messages.isEmpty) {
      return _buildWelcomeMessage();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isTyping) {
          return const AiTypingIndicator();
        }

        final message = chatState.messages[index];
        return AiMessageBubble(
          message: message,
          onFavoriteToggle: () => _toggleFavorite(message.id),
        );
      },
    );
  }

  /// 환영 메시지 위젯
  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'AI相談を始めましょう',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'ペットについて何でも相談してください',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSuggestedQuestions(),
        ],
      ),
    );
  }

  /// 제안 질문 위젯
  Widget _buildSuggestedQuestions() {
    final chatState = ref.watch(aiChatNotifierProvider);

    if (chatState.suggestedQuestions.isEmpty) return const SizedBox.shrink();

    return AiSuggestedQuestions(
      questions: chatState.suggestedQuestions,
      onQuestionSelected: (question) {
        _messageController.text = question.content;
        _sendMessage();
      },
    );
  }

  /// 메시지 입력 위젯
  Widget _buildMessageInput(AiChatController controller, AiChatState chatState) {
    return AiMessageInput(
      controller: _messageController,
      onSendMessage: _sendMessage,
      isLoading: chatState.isTyping,
    );
  }

  /// 메시지 전송
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    controller.sendMessage(message);
    _messageController.clear();

    // 스크롤을 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 즐겨찾기 토글
  void _toggleFavorite(String messageId) {
    ref.read(aiChatNotifierProvider.notifier).toggleFavorite(messageId);
  }
}
```

#### 3. **AI Message Bubble (`widgets/ai_message_bubble.dart`)**

**메시지 버블 컴포넌트:**

```dart
/// AI 메시지 버블 컴포넌트
class AiMessageBubble extends StatelessWidget {
  final AiMessageEntity message;
  final VoidCallback? onFavoriteToggle;
  final bool showTimestamp;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onFavoriteToggle,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) const Spacer(),
          if (!isUser) _buildAvatar(),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(isUser, isSystem),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 메시지 내용
                  Text(
                    message.content,
                    style: TextStyle(
                      color: _getTextColor(isUser, isSystem),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 하단 정보 (시간, 즐겨찾기)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showTimestamp) ...[
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: _getTextColor(isUser, isSystem).withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      if (message.type == MessageType.assistant && onFavoriteToggle != null)
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 16),
                          onPressed: onFavoriteToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isUser) _buildAvatar(),
          if (!isUser) const Spacer(),
        ],
      ),
    );
  }

  /// 아바타 위젯
  Widget _buildAvatar() {
    final isUser = message.type == MessageType.user;

    return Container(
      width: 32,
      height: 32,
      margin: EdgeInsets.only(
        left: isUser ? 8 : 0,
        right: isUser ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  /// 버블 색상
  Color _getBubbleColor(bool isUser, bool isSystem) {
    if (isSystem) return Colors.orange.shade100;
    if (isUser) return Colors.blue.shade500;
    return Colors.grey.shade100;
  }

  /// 텍스트 색상
  Color _getTextColor(bool isUser, bool isSystem) {
    if (isSystem) return Colors.orange.shade800;
    if (isUser) return Colors.white;
    return Colors.black87;
  }

  /// 시간 포맷팅
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨日 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
```

### UI 패턴 (UI Patterns)

#### 1. **반응형 레이아웃**

**화면 크기별 적응:**

```dart
/// 반응형 레이아웃 빌더
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

#### 2. **로딩 상태 관리**

**로딩 인디케이터:**

```dart
/// 로딩 상태 래퍼
class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }
    return child;
  }
}
```

#### 3. **에러 처리 UI**

**에러 표시 컴포넌트:**

```dart
/// 에러 표시 위젯
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('再試行'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 상태 관리 (State Management)

#### 1. **Riverpod 상태 관리**

**프로바이더 사용:**

```dart
/// AI 채팅 화면에서 상태 사용
class AiChatScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  @override
  Widget build(BuildContext context) {
    // 상태 구독
    final chatState = ref.watch(aiChatNotifierProvider);

    // 컨트롤러 접근
    final controller = ref.read(aiChatControllerProvider.notifier);

    // 특정 상태만 구독
    final isTyping = ref.watch(
      aiChatNotifierProvider.select((state) => state.isTyping),
    );

    return Scaffold(
      body: Column(
        children: [
          // 로딩 상태 표시
          if (chatState.isLoading)
            const LinearProgressIndicator(),

          // 메시지 리스트
          Expanded(
            child: _buildMessageList(chatState),
          ),

          // 타이핑 상태 표시
          if (isTyping)
            const AiTypingIndicator(),

          // 메시지 입력
          AiMessageInput(
            onSendMessage: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}
```

#### 2. **상태 선택적 구독**

**성능 최적화:**

```dart
/// 특정 상태만 구독하여 불필요한 rebuild 방지
class OptimizedMessageList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 메시지 목록만 구독
    final messages = ref.watch(
      aiChatNotifierProvider.select((state) => state.messages),
    );

    // 타이핑 상태만 구독
    final isTyping = ref.watch(
      aiChatNotifierProvider.select((state) => state.isTyping),
    );

    return ListView.builder(
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const AiTypingIndicator();
        }

        final message = messages[index];
        return AiMessageBubble(message: message);
      },
    );
  }
}
```

### 사용 방법 (Usage)

#### 1. **기본 사용**

```dart
import 'package:aipet_frontend/features/ai/ai.dart';

// AI 채팅 화면으로 이동
context.go('/ai-chat');

// 즐겨찾기 화면으로 이동
context.push('/ai-favorites');
```

#### 2. **컨트롤러 사용**

```dart
// AI 채팅 컨트롤러 사용
final aiChatController = ref.read(aiChatControllerProvider.notifier);

// 채팅 초기화
await aiChatController.initializeChat();

// 메시지 전송
await aiChatController.sendMessage('강아지가 계속 짖어요');

// 펫 선택
aiChatController.selectPet(selectedPet);

// 카테고리 선택
aiChatController.selectCategory(selectedCategory);
```

#### 3. **상태 구독**

```dart
// 전체 상태 구독
final chatState = ref.watch(aiChatNotifierProvider);

// 특정 상태만 구독
final messages = ref.watch(
  aiChatNotifierProvider.select((state) => state.messages),
);

final isTyping = ref.watch(
  aiChatNotifierProvider.select((state) => state.isTyping),
);

final selectedPet = ref.watch(
  aiChatNotifierProvider.select((state) => state.selectedPet),
);
```

#### 4. **커스텀 위젯 사용**

```dart
// 메시지 버블
AiMessageBubble(
  message: message,
  onFavoriteToggle: () => _toggleFavorite(message.id),
  showTimestamp: true,
);

// 메시지 입력
AiMessageInput(
  controller: textController,
  onSendMessage: _sendMessage,
  isLoading: isTyping,
);

// 카테고리 선택
AiCategorySelection(
  categories: AiCategoryEntity.allCategories,
  selectedCategory: selectedCategory,
  onCategorySelected: _selectCategory,
);

// 펫 선택
AiPetSelection(
  pets: petList,
  selectedPet: selectedPet,
  onPetSelected: _selectPet,
);
```

### 커스터마이징 (Customization)

#### 1. **테마 커스터마이징**

**커스텀 색상 및 스타일:**

```dart
/// AI 채팅 테마 커스터마이징
class AiChatTheme {
  // 사용자 메시지 스타일
  static const userMessageStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // AI 메시지 스타일
  static const aiMessageStyle = TextStyle(
    color: Colors.black87,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // 시스템 메시지 스타일
  static const systemMessageStyle = TextStyle(
    color: Colors.orange,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 버블 색상
  static const userBubbleColor = Colors.blue;
  static const aiBubbleColor = Colors.grey;
  static const systemBubbleColor = Colors.orange;
}
```

#### 2. **애니메이션 커스터마이징**

**커스텀 애니메이션:**

```dart
/// 메시지 애니메이션
class MessageAnimation extends StatefulWidget {
  final Widget child;
  final int index;

  const MessageAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<MessageAnimation> createState() => _MessageAnimationState();
}

class _MessageAnimationState extends State<MessageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
```

#### 3. **로컬라이제이션 커스터마이징**

**다국어 지원:**

```dart
/// AI 채팅 로컬라이제이션
class AiChatLocalization {
  // 한국어
  static const Map<String, String> ko = {
    'aiConsultation': 'AI 상담',
    'sendMessage': '메시지 전송',
    'typing': '입력 중...',
    'selectPet': '펫 선택',
    'selectCategory': '카테고리 선택',
    'favorites': '즐겨찾기',
    'error': '오류가 발생했습니다',
    'retry': '다시 시도',
  };

  // 일본어
  static const Map<String, String> ja = {
    'aiConsultation': 'AI相談',
    'sendMessage': 'メッセージ送信',
    'typing': '入力中...',
    'selectPet': 'ペット選択',
    'selectCategory': 'カテゴリ選択',
    'favorites': 'お気に入り',
    'error': 'エラーが発生しました',
    'retry': '再試行',
  };

  // 현재 언어에 따른 텍스트 반환
  static String getText(String key, String language) {
    switch (language) {
      case 'ko':
        return ko[key] ?? key;
      case 'ja':
        return ja[key] ?? key;
      default:
        return ja[key] ?? key; // 기본값은 일본어
    }
  }
}
```

### 의존성 (Dependencies)

#### 1. **Flutter 패키지**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.6.2
```

#### 2. **프로젝트 내부 의존성**

```dart
// shared 모듈
import 'package:aipet_frontend/shared/shared.dart';

// domain 모듈
import 'package:aipet_frontend/features/ai/domain/domain.dart';

// 다른 feature 모듈
import 'package:aipet_frontend/features/pet_profile/pet_profile.dart';
```

#### 3. **외부 의존성**

- **Flutter Material**: UI 컴포넌트 및 테마
- **Riverpod**: 상태 관리
- **GoRouter**: 네비게이션

---

## 日本語 (Japanese)

### 📋 目次 (Table of Contents)

- [概要 (Overview)](#概要-overview)
- [構造 (Structure)](#構造-structure)
- [主要コンポーネント (Key Components)](#主要コンポーネント-key-components)
- [UI パターン (UI Patterns)](#ui-パターン-ui-patterns)
- [状態管理 (State Management)](#状態管理-state-management)
- [使用方法 (Usage)](#使用方法-usage)
- [カスタマイズ (Customization)](#カスタマイズ-customization)
- [依存関係 (Dependencies)](#依存関係-dependencies)

### 概要 (Overview)

AI Feature の Presentation Layer は、AI チャットシステムのユーザーインターフェースとインタラクションを担当します。
Clean Architecture の原則に従って UI ロジックとビジネスロジックを分離し、Riverpod による反応型状態管理を提供します。

**主要な責任:**

- 🎨 **UI レンダリング**: AI チャット画面とコンポーネント表示
- 🎮 **ユーザーインタラクション**: メッセージ入力、ボタンクリック、ジェスチャー処理
- 📱 **状態管理**: Riverpod による UI 状態とビジネス状態管理
- 🔄 **データバインディング**: Domain Layer と UI 間のデータ接続
- 🎯 **ユーザーエクスペリエンス**: 直感的で反応的なチャットインターフェース提供

### 構造 (Structure)

```txt
lib/features/ai/presentation/
├── presentation.dart                         # Presentation Layer バレルファイル
├── controllers/                              # コントローラーと状態管理
│   ├── ai_chat_controller.dart               # AI チャットコントローラー
│   └── ai_chat_controller.g.dart             # 生成された Riverpod コード
├── screens/                                  # 画面コンポーネント
│   ├── ai_chat_screen.dart                   # AI チャットメイン画面
│   └── ai_favorite_messages_screen.dart      # お気に入りメッセージ画面
└── widgets/                                  # 再利用可能な UI コンポーネント
    ├── widgets.dart                          # widgets バレルファイル
    ├── ai_message_bubble.dart                # メッセージバブルコンポーネント
    ├── ai_message_input.dart                 # メッセージ入力コンポーネント
    ├── ai_typing_indicator.dart              # タイピングインジケーター
    ├── ai_suggested_questions.dart           # 提案質問コンポーネント
    ├── ai_category_selection.dart            # カテゴリ選択コンポーネント
    ├── ai_category_selection_bubble.dart     # カテゴリ選択バブル
    ├── ai_pet_selection.dart                 # ペット選択コンポーネント
    ├── ai_pet_selection_bubble.dart          # ペット選択バブル
    └── ai_question_request_bubble.dart       # 質問リクエストバブル
```

**レイヤー別の役割:**

- **Controllers**: UI 状態管理とビジネスロジック調整
- **Screens**: 全体画面レイアウトとナビゲーション
- **Widgets**: 再利用可能な UI コンポーネント

### 主要コンポーネント (Key Components)

#### 1. **AI Chat Controller (コントローラー)**

**状態管理とビジネスロジック:**

```dart
/// AI チャット状態
class AiChatState {
  final List<AiMessageEntity> messages;
  final bool isLoading;
  final bool isTyping;
  final PetProfileEntity? selectedPet;
  final AiCategoryEntity? selectedCategory;
  final String? errorMessage;
  final List<AiSuggestedQuestionEntity> suggestedQuestions;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.selectedPet,
    this.selectedCategory,
    this.errorMessage,
    this.suggestedQuestions = const [],
  });

  /// 状態コピー作成
  AiChatState copyWith({
    List<AiMessageEntity>? messages,
    bool? isLoading,
    bool? isTyping,
    PetProfileEntity? selectedPet,
    AiCategoryEntity? selectedCategory,
    String? errorMessage,
    List<AiSuggestedQuestionEntity>? suggestedQuestions,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      selectedPet: selectedPet ?? this.selectedPet,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
    );
  }
}

/// AI チャット状態管理 (Riverpod Notifier)
@riverpod
class AiChatNotifier extends _$AiChatNotifier {
  @override
  AiChatState build() => const AiChatState();

  /// 初期データ読み込み
  Future<void> initializeChat() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(aiRepositoryProvider);

      // チャット履歴読み込み
      final messages = await repository.getChatHistory();

      // 提案質問読み込み
      final suggestedQuestions = await repository.getSuggestedQuestions();

      state = state.copyWith(
        messages: messages,
        suggestedQuestions: suggestedQuestions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'チャットの初期化に失敗しました: $e',
        isLoading: false,
      );
    }
  }

  /// メッセージ送信
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // ユーザーメッセージ追加
    final userMessage = AiMessageEntity.user(
      id: _generateId(),
      content: message.trim(),
      petId: state.selectedPet?.id,
      categoryId: state.selectedCategory?.id,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    try {
      final repository = ref.read(aiRepositoryProvider);

      // AI 応答生成
      final aiResponse = await repository.sendMessage(
        message,
        petContext: state.selectedPet,
      );

      // AI 応答メッセージ追加
      final aiMessage = AiMessageEntity.assistant(
        id: _generateId(),
        content: aiResponse,
        petId: state.selectedPet?.id,
        categoryId: state.selectedCategory?.id,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
      );
    } catch (e) {
      // エラーメッセージ追加
      final errorMessage = AiMessageEntity.system(
        id: _generateId(),
        content: '申し訳ございません。エラーが発生しました: $e',
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isTyping: false,
        errorMessage: 'メッセージの送信に失敗しました: $e',
      );
    }
  }

  /// ペット選択
  void selectPet(PetProfileEntity? pet) {
    state = state.copyWith(selectedPet: pet);
  }

  /// カテゴリ選択
  void selectCategory(AiCategoryEntity? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// メッセージお気に入り切り替え
  Future<void> toggleFavorite(String messageId) async {
    try {
      final repository = ref.read(aiRepositoryProvider);
      await repository.toggleFavorite(messageId);

      // メッセージリスト更新 (お気に入り状態反映)
      final updatedMessages = state.messages.map((message) {
        if (message.id == messageId) {
          // お気に入り状態切り替え (実際にはメッセージにお気に入りフィールドが必要)
          return message;
        }
        return message;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'お気に入りの更新に失敗しました: $e',
      );
    }
  }

  /// エラーメッセージクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// ID 生成
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// AI チャットコントローラー (BaseController パターン)
class AiChatController extends BaseController {
  final Ref ref;
  final BuildContext context;

  AiChatController(this.ref, this.context);

  /// チャット初期化
  Future<void> initializeChat() async {
    try {
      await ref.read(aiChatNotifierProvider.notifier).initializeChat();
      showSuccess('チャットが初期化されました');
    } catch (error) {
      handleError(error);
    }
  }

  /// メッセージ送信
  Future<void> sendMessage(String message) async {
    try {
      await ref.read(aiChatNotifierProvider.notifier).sendMessage(message);
    } catch (error) {
      handleError(error);
    }
  }

  /// ペット選択
  void selectPet(PetProfileEntity? pet) {
    ref.read(aiChatNotifierProvider.notifier).selectPet(pet);
    if (pet != null) {
      showInfo('${pet.name}が選択されました');
    }
  }

  /// カテゴリ選択
  void selectCategory(AiCategoryEntity? category) {
    ref.read(aiChatNotifierProvider.notifier).selectCategory(category);
    if (category != null) {
      showInfo('${category.name}カテゴリが選択されました');
    }
  }

  /// お気に入り画面へ移動
  void navigateToFavorites() {
    context.push('/ai-favorites');
  }
}
```

**主要な特徴:**

- **Riverpod Notifier**: 状態管理とビジネスロジック
- **BaseController**: エラー処理とユーザーフィードバック
- **非同期処理**: メッセージ送信と AI 応答生成
- **状態更新**: UI 状態の反応型更新

#### 2. **AI Chat Screen (チャット画面)**

**メインチャット画面:**

```dart
/// AI チャットメイン画面
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初期データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatControllerProvider.notifier).initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatNotifierProvider);
    final controller = ref.read(aiChatControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI相談'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: controller.navigateToFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          // ペットとカテゴリ選択
          if (chatState.messages.isEmpty) ...[
            _buildPetSelection(controller),
            _buildCategorySelection(controller),
          ],

          // メッセージリスト
          Expanded(
            child: _buildMessageList(chatState),
          ),

          // メッセージ入力
          _buildMessageInput(controller, chatState),
        ],
      ),
    );
  }

  /// ペット選択ウィジェット
  Widget _buildPetSelection(AiChatController controller) {
    return Consumer(
      builder: (context, ref, child) {
        final pets = ref.watch(petListProvider);

        return pets.when(
          data: (petList) => AiPetSelection(
            pets: petList,
            selectedPet: ref.watch(aiChatNotifierProvider).selectedPet,
            onPetSelected: controller.selectPet,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('エラー: $error'),
        );
      },
    );
  }

  /// カテゴリ選択ウィジェット
  Widget _buildCategorySelection(AiChatController controller) {
    return AiCategorySelection(
      categories: AiCategoryEntity.allCategories,
      selectedCategory: ref.watch(aiChatNotifierProvider).selectedCategory,
      onCategorySelected: controller.selectCategory,
    );
  }

  /// メッセージリストウィジェット
  Widget _buildMessageList(AiChatState chatState) {
    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatState.messages.isEmpty) {
      return _buildWelcomeMessage();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isTyping) {
          return const AiTypingIndicator();
        }

        final message = chatState.messages[index];
        return AiMessageBubble(
          message: message,
          onFavoriteToggle: () => _toggleFavorite(message.id),
        );
      },
    );
  }

  /// 歓迎メッセージウィジェット
  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'AI相談を始めましょう',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'ペットについて何でも相談してください',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSuggestedQuestions(),
        ],
      ),
    );
  }

  /// 提案質問ウィジェット
  Widget _buildSuggestedQuestions() {
    final chatState = ref.watch(aiChatNotifierProvider);

    if (chatState.suggestedQuestions.isEmpty) return const SizedBox.shrink();

    return AiSuggestedQuestions(
      questions: chatState.suggestedQuestions,
      onQuestionSelected: (question) {
        _messageController.text = question.content;
        _sendMessage();
      },
    );
  }

  /// メッセージ入力ウィジェット
  Widget _buildMessageInput(AiChatController controller, AiChatState chatState) {
    return AiMessageInput(
      controller: _messageController,
      onSendMessage: _sendMessage,
      isLoading: chatState.isTyping,
    );
  }

  /// メッセージ送信
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    controller.sendMessage(message);
    _messageController.clear();

    // スクロールを一番下へ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// お気に入り切り替え
  void _toggleFavorite(String messageId) {
    ref.read(aiChatNotifierProvider.notifier).toggleFavorite(messageId);
  }
}
```

#### 3. **AI Message Bubble (メッセージバブル)**

**メッセージバブルコンポーネント:**

```dart
/// AI メッセージバブルコンポーネント
class AiMessageBubble extends StatelessWidget {
  final AiMessageEntity message;
  final VoidCallback? onFavoriteToggle;
  final bool showTimestamp;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onFavoriteToggle,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) const Spacer(),
          if (!isUser) _buildAvatar(),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(isUser, isSystem),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // メッセージ内容
                  Text(
                    message.content,
                    style: TextStyle(
                      color: _getTextColor(isUser, isSystem),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 下部情報 (時間、お気に入り)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showTimestamp) ...[
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: _getTextColor(isUser, isSystem).withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      if (message.type == MessageType.assistant && onFavoriteToggle != null)
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 16),
                          onPressed: onFavoriteToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isUser) _buildAvatar(),
          if (!isUser) const Spacer(),
        ],
      ),
    );
  }

  /// アバターウィジェット
  Widget _buildAvatar() {
    final isUser = message.type == MessageType.user;

    return Container(
      width: 32,
      height: 32,
      margin: EdgeInsets.only(
        left: isUser ? 8 : 0,
        right: isUser ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  /// バブル色
  Color _getBubbleColor(bool isUser, bool isSystem) {
    if (isSystem) return Colors.orange.shade100;
    if (isUser) return Colors.blue.shade500;
    return Colors.grey.shade100;
  }

  /// テキスト色
  Color _getTextColor(bool isUser, bool isSystem) {
    if (isSystem) return Colors.orange.shade800;
    if (isUser) return Colors.white;
    return Colors.black87;
  }

  /// 時間フォーマット
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨日 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
```

### UI パターン (UI Patterns)

#### 1. **反応型レイアウト**

**画面サイズ別適応:**

```dart
/// 反応型レイアウトビルダー
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

#### 2. **ローディング状態管理**

**ローディングインジケーター:**

```dart
/// ローディング状態ラッパー
class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }
    return child;
  }
}
```

#### 3. **エラー処理 UI**

**エラー表示コンポーネント:**

```dart
/// エラー表示ウィジェット
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('再試行'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 状態管理 (State Management)

#### 1. **Riverpod 状態管理**

**プロバイダー使用:**

```dart
/// AI チャット画面で状態使用
class AiChatScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  @override
  Widget build(BuildContext context) {
    // 状態購読
    final chatState = ref.watch(aiChatNotifierProvider);

    // コントローラーアクセス
    final controller = ref.read(aiChatControllerProvider.notifier);

    // 特定状態のみ購読
    final isTyping = ref.watch(
      aiChatNotifierProvider.select((state) => state.isTyping),
    );

    return Scaffold(
      body: Column(
        children: [
          // ローディング状態表示
          if (chatState.isLoading)
            const LinearProgressIndicator(),

          // メッセージリスト
          Expanded(
            child: _buildMessageList(chatState),
          ),

          // タイピング状態表示
          if (isTyping)
            const AiTypingIndicator(),

          // メッセージ入力
          AiMessageInput(
            onSendMessage: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}
```

#### 2. **状態選択的購読**

**パフォーマンス最適化:**

```dart
/// 特定状態のみ購読して不要な rebuild 防止
class OptimizedMessageList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // メッセージリストのみ購読
    final messages = ref.watch(
      aiChatNotifierProvider.select((state) => state.messages),
    );

    // タイピング状態のみ購読
    final isTyping = ref.watch(
      aiChatNotifierProvider.select((state) => state.isTyping),
    );

    return ListView.builder(
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const AiTypingIndicator();
        }

        final message = messages[index];
        return AiMessageBubble(message: message);
      },
    );
  }
}
```

### 使用方法 (Usage)

#### 1. **基本使用**

```dart
import 'package:aipet_frontend/features/ai/ai.dart';

// AI チャット画面へ移動
context.go('/ai-chat');

// お気に入り画面へ移動
context.push('/ai-favorites');
```

#### 2. **コントローラー使用**

```dart
// AI チャットコントローラー使用
final aiChatController = ref.read(aiChatControllerProvider.notifier);

// チャット初期化
await aiChatController.initializeChat();

// メッセージ送信
await aiChatController.sendMessage('犬が吠え続けます');

// ペット選択
aiChatController.selectPet(selectedPet);

// カテゴリ選択
aiChatController.selectCategory(selectedCategory);
```

#### 3. **状態購読**

```dart
// 全体状態購読
final chatState = ref.watch(aiChatNotifierProvider);

// 特定状態のみ購読
final messages = ref.watch(
  aiChatNotifierProvider.select((state) => state.messages),
);

final isTyping = ref.watch(
  aiChatNotifierProvider.select((state) => state.isTyping),
);

final selectedPet = ref.watch(
  aiChatNotifierProvider.select((state) => state.selectedPet),
);
```

#### 4. **カスタムウィジェット使用**

```dart
// メッセージバブル
AiMessageBubble(
  message: message,
  onFavoriteToggle: () => _toggleFavorite(message.id),
  showTimestamp: true,
);

// メッセージ入力
AiMessageInput(
  controller: textController,
  onSendMessage: _sendMessage,
  isLoading: isTyping,
);

// カテゴリ選択
AiCategorySelection(
  categories: AiCategoryEntity.allCategories,
  selectedCategory: selectedCategory,
  onCategorySelected: _selectCategory,
);

// ペット選択
AiPetSelection(
  pets: petList,
  selectedPet: selectedPet,
  onPetSelected: _selectPet,
);
```

### カスタマイズ (Customization)

#### 1. **テーマカスタマイズ**

**カスタム色とスタイル:**

```dart
/// AI チャットテーマカスタマイズ
class AiChatTheme {
  // ユーザーメッセージスタイル
  static const userMessageStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // AI メッセージスタイル
  static const aiMessageStyle = TextStyle(
    color: Colors.black87,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // システムメッセージスタイル
  static const systemMessageStyle = TextStyle(
    color: Colors.orange,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // バブル色
  static const userBubbleColor = Colors.blue;
  static const aiBubbleColor = Colors.grey;
  static const systemBubbleColor = Colors.orange;
}
```

#### 2. **アニメーションカスタマイズ**

**カスタムアニメーション:**

```dart
/// メッセージアニメーション
class MessageAnimation extends StatefulWidget {
  final Widget child;
  final int index;

  const MessageAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<MessageAnimation> createState() => _MessageAnimationState();
}

class _MessageAnimationState extends State<MessageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
```

#### 3. **ローカライゼーションカスタマイズ**

**多言語対応:**

```dart
/// AI チャットローカライゼーション
class AiChatLocalization {
  // 韓国語
  static const Map<String, String> ko = {
    'aiConsultation': 'AI 상담',
    'sendMessage': '메시지 전송',
    'typing': '입력 중...',
    'selectPet': '펫 선택',
    'selectCategory': '카테고리 선택',
    'favorites': '즐겨찾기',
    'error': '오류가 발생했습니다',
    'retry': '다시 시도',
  };

  // 日本語
  static const Map<String, String> ja = {
    'aiConsultation': 'AI相談',
    'sendMessage': 'メッセージ送信',
    'typing': '入力中...',
    'selectPet': 'ペット選択',
    'selectCategory': 'カテゴリ選択',
    'favorites': 'お気に入り',
    'error': 'エラーが発生しました',
    'retry': '再試行',
  };

  // 現在言語によるテキスト返却
  static String getText(String key, String language) {
    switch (language) {
      case 'ko':
        return ko[key] ?? key;
      case 'ja':
        return ja[key] ?? key;
      default:
        return ja[key] ?? key; // デフォルトは日本語
    }
  }
}
```

### 依存関係 (Dependencies)

#### 1. **Flutter パッケージ**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.6.2
```

#### 2. **プロジェクト内部依存関係**

```dart
// shared モジュール
import 'package:aipet_frontend/shared/shared.dart';

// domain モジュール
import 'package:aipet_frontend/features/ai/domain/domain.dart';

// 他のfeature モジュール
import 'package:aipet_frontend/features/pet_profile/pet_profile.dart';
```

#### 3. **外部依存関係**

- **Flutter Material**: UI コンポーネントとテーマ
- **Riverpod**: 状態管理
- **GoRouter**: ナビゲーション

---

## 📚 추가 리소스 / その他のリソース

- [Flutter Widgets](https://docs.flutter.dev/development/ui/widgets)
- [Flutter Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Material Design](https://material.io/design)

---

© 2025 AI Pet. AI 기능 프레젠테이션 계층 / AI Feature Presentation Layer
