import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/ai/presentation/controllers/ai_chat_controller.dart';
import 'package:aipet_frontend/features/ai/presentation/widgets/ai_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatNotifierProvider.notifier).initializeChat();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 백그라운드로 갈 때 현재 채팅 저장
    if (state == AppLifecycleState.paused) {
      _saveCurrentChatBeforeExit();
    }
  }

  Future<void> _saveCurrentChatBeforeExit() async {
    final chatState = ref.read(aiChatNotifierProvider);
    if (chatState.messages.isNotEmpty) {
      try {
        await ref
            .read(aiChatNotifierProvider.notifier)
            .saveCurrentChatToHistory(isManualSave: false);
      } catch (error) {
        // 백그라운드 저장 실패는 로그만 남기고 UI에는 표시하지 않음
        debugPrint('백그라운드 채팅 저장 실패: $error');
      }
    }
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _messageController.clear();

    // 사용자 메시지 전송 후 스크롤
    _scrollToBottom();

    // 노티파이어를 통해 메시지 전송
    await ref.read(aiChatNotifierProvider.notifier).sendMessage(content);

    // AI 응답 완료 후 다시 스크롤
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  Future<void> _clearChatHistory() async {
    await ref.read(aiChatNotifierProvider.notifier).clearChatHistory();
  }

  Future<void> _saveCurrentChat() async {
    final chatState = ref.read(aiChatNotifierProvider);
    if (chatState.messages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存する会話がありません')));
      }
      return;
    }

    try {
      await ref
          .read(aiChatNotifierProvider.notifier)
          .saveCurrentChatToHistory(isManualSave: true);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('会話を保存しました')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $error')));
      }
    }
  }

  void _navigateToFavoriteMessages() {
    context.push(AppRouter.aiFavoriteMessagesRoute);
  }

  void _navigateToChatHistory() {
    context.push(AppRouter.aiChatHistoryRoute);
  }

  Widget _buildDateSeparator(DateTime date) {
    return DateSeparatorWidget(date: date);
  }

  int _getTotalItemCount(AiChatState chatState) {
    int count = 0;

    // 펫 선택이 완료되지 않은 경우 펫 선택 버블 표시
    if (!chatState.hasPetSelected) {
      count += 1;
    }

    // 실제 메시지들
    count += chatState.messages.length;

    // 펫은 선택했지만 카테고리 선택이 완료되지 않은 경우, 메시지 뒤에 카테고리 선택 버블 추가
    if (chatState.hasPetSelected &&
        !chatState.hasCategorySelected &&
        chatState.messages.isNotEmpty) {
      count += 1; // 카테고리 선택 메시지
    }

    // 구체적인 질문 요청 버블 (카테고리 선택 완료 후, 실제 질문 전 단계)
    if (chatState.hasCategorySelected &&
        chatState.messages.length >=
            4 && // 펫선택(사용자) + AI응답 + 카테고리선택(사용자) + AI응답 = 4개
        !_hasUserQuestionAfterCategorySelection(chatState)) {
      count += 1; // 구체적인 질문 요청 메시지
    }

    // 후속 질문 제안 버블 (사용자 커스텀 질문에 대한 AI 답변 완료 후)
    if (_shouldShowFollowUpQuestions(chatState)) {
      count += 1;
    }

    // 타이핑 인디케이터
    if (chatState.isTyping) {
      count += 1;
    }

    return count;
  }

  Widget _buildChatItem(
    BuildContext context,
    WidgetRef ref,
    AiChatState chatState,
    int index,
  ) {
    int currentIndex = 0;

    // 1. 펫 선택 버블 (펫이 선택되지 않은 경우 첫 번째로 표시)
    if (!chatState.hasPetSelected) {
      if (index == currentIndex) {
        return AiPetSelectionBubble(
          selectedPet: chatState.selectedPet,
          onPetSelected: (pet) {
            ref.read(aiChatNotifierProvider.notifier).selectPet(pet);
          },
        );
      }
      currentIndex++;
    }

    // 2. 실제 메시지들 (날짜 구분선 포함)
    if (index >= currentIndex &&
        index < currentIndex + chatState.messages.length) {
      final messageIndex = index - currentIndex;
      final message = chatState.messages[messageIndex];

      // 날짜 구분선 표시 (첫 메시지이거나 이전 메시지와 날짜가 다른 경우)
      bool showDateSeparator = false;
      if (messageIndex == 0) {
        showDateSeparator = true;
      } else {
        final previousMessage = chatState.messages[messageIndex - 1];
        final currentDate = DateTime(
          message.timestamp.year,
          message.timestamp.month,
          message.timestamp.day,
        );
        final previousDate = DateTime(
          previousMessage.timestamp.year,
          previousMessage.timestamp.month,
          previousMessage.timestamp.day,
        );
        showDateSeparator = !currentDate.isAtSameMomentAs(previousDate);
      }

      return Column(
        children: [
          if (showDateSeparator) _buildDateSeparator(message.timestamp),
          AiMessageBubble(
            message: message,
            isFavorite: chatState.favoriteMessageIds.contains(message.id),
            onFavoriteToggle: (msg) async {
              await ref
                  .read(aiChatNotifierProvider.notifier)
                  .toggleFavorite(msg);
            },
          ),
        ],
      );
    }
    currentIndex += chatState.messages.length;

    // 3. 카테고리 선택 버블 (메시지들 뒤에 표시)
    if (chatState.hasPetSelected &&
        !chatState.hasCategorySelected &&
        chatState.messages.isNotEmpty) {
      if (index == currentIndex) {
        return AiCategorySelectionBubble(
          selectedCategory: chatState.selectedCategory,
          onCategorySelected: (category) {
            ref.read(aiChatNotifierProvider.notifier).selectCategory(category);
          },
        );
      }
      currentIndex++;
    }

    // 4. 구체적인 질문 요청 버블 (카테고리 선택 완료 후, 실제 질문 전 단계)
    if (chatState.hasCategorySelected &&
        chatState.messages.length >=
            4 && // 펫선택(사용자) + AI응답 + 카테고리선택(사용자) + AI응답 = 4개
        !_hasUserQuestionAfterCategorySelection(chatState)) {
      if (index == currentIndex) {
        return AiQuestionRequestBubble(
          selectedPet: chatState.selectedPet,
          selectedCategory: chatState.selectedCategory,
          onQuestionTap: _sendMessage,
        );
      }
      currentIndex++;
    }

    // 5. 후속 질문 제안 버블 (사용자 커스텀 질문에 대한 AI 답변 완료 후)
    if (_shouldShowFollowUpQuestions(chatState)) {
      if (index == currentIndex) {
        return AiFollowUpQuestionsBubble(
          selectedPet: chatState.selectedPet,
          selectedCategory: chatState.selectedCategory,
          onQuestionTap: _sendMessage,
        );
      }
      currentIndex++;
    }

    // 6. 타이핑 인디케이터
    if (chatState.isTyping && index == currentIndex) {
      return const AiTypingIndicator();
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // UI에서 직접 Provider 상태 감지
    final chatState = ref.watch(aiChatNotifierProvider);

    // 디버그 로그
    debugPrint('🐾 AI Chat Debug:');
    debugPrint('  - hasPetSelected: ${chatState.hasPetSelected}');
    debugPrint('  - hasCategorySelected: ${chatState.hasCategorySelected}');
    debugPrint('  - messages count: ${chatState.messages.length}');
    debugPrint('  - selectedPet: ${chatState.selectedPet?.name}');
    debugPrint('  - selectedCategory: ${chatState.selectedCategory?.name}');

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: 'AIアシスタント',
        leading: IconButton(
          onPressed: _navigateToChatHistory,
          icon: const Icon(Icons.history),
          tooltip: 'チャット履歴',
        ),
        actions: [
          IconButton(
            onPressed: _navigateToFavoriteMessages,
            icon: const Icon(Icons.star),
            tooltip: 'お気に入り',
          ),
          IconButton(
            onPressed: _saveCurrentChat,
            icon: const Icon(Icons.save),
            tooltip: '会話を保存',
          ),
          IconButton(
            onPressed: _clearChatHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'チャットをクリア',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 메시지 리스트
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _getTotalItemCount(chatState),
                itemBuilder: (context, index) {
                  return _buildChatItem(context, ref, chatState, index);
                },
              ),
            ),

            // 메시지 입력 영역 (카테고리까지 선택된 후에만 표시)
            if (chatState.hasCategorySelected)
              AiMessageInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
                isLoading: chatState.isTyping,
              ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 선택 후 사용자가 실제 질문을 했는지 확인
  bool _hasUserQuestionAfterCategorySelection(AiChatState chatState) {
    if (chatState.messages.length <= 4) return false;

    // 5번째 메시지부터 사용자 메시지가 있는지 확인 (카테고리 선택 이후 실제 질문)
    for (int i = 4; i < chatState.messages.length; i++) {
      if (chatState.messages[i].isUser) {
        return true;
      }
    }
    return false;
  }

  /// 후속 질문 제안 버블을 보여줄지 결정
  bool _shouldShowFollowUpQuestions(AiChatState chatState) {
    // 기본 조건: 펫과 카테고리가 선택되어야 함
    if (!chatState.hasPetSelected || !chatState.hasCategorySelected) {
      return false;
    }

    // 타이핑 중이면 후속 질문 버블 숨김
    if (chatState.isTyping) {
      return false;
    }

    // 메시지가 6개 이상 있어야 함 (펫선택 + AI응답 + 카테고리선택 + AI응답 + 사용자질문 + AI응답 = 6개)
    if (chatState.messages.length < 6) {
      return false;
    }

    // 마지막 메시지가 AI 메시지이고, 그 이전에 사용자 질문이 있는 경우
    final lastMessage = chatState.messages.last;
    if (lastMessage.isUser) {
      return false; // 마지막이 사용자 메시지면 아직 AI가 답변하지 않음
    }

    // 카테고리 선택 이후 실제 사용자 질문이 있는 경우에만 후속 질문 제안
    return _hasUserQuestionAfterCategorySelection(chatState);
  }
}
