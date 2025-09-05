import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../controllers/ai_chat_controller.dart';
import '../widgets/widgets.dart';
import 'ai_favorite_messages_screen.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatNotifierProvider.notifier).initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _messageController.clear();
    _scrollToBottom();

    // 노티파이어를 통해 메시지 전송
    await ref.read(aiChatNotifierProvider.notifier).sendMessage(content);
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

  void _navigateToFavoriteMessages() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AiFavoriteMessagesScreen()),
    );
  }

  int _getTotalItemCount(AiChatState chatState) {
    int count = 0;

    // 펫 선택이 완료되지 않은 경우 펫 선택 버블 표시
    if (!chatState.hasPetSelected) {
      count += 1;
    }

    // 펫은 선택했지만 카테고리 선택이 완료되지 않은 경우
    if (chatState.hasPetSelected && !chatState.hasCategorySelected) {
      count += 1; // 카테고리 선택 메시지
    }

    // 카테고리가 선택되었지만 메시지가 없는 경우
    if (chatState.hasCategorySelected && chatState.messages.isEmpty) {
      count += 1; // 구체적인 질문 요청 메시지
    }

    // 실제 메시지들
    count += chatState.messages.length;

    // 타이핑 인디케이터
    if (chatState.isTyping) {
      count += 1;
    }

    // 추천 질문들은 AiQuestionRequestBubble에 포함되어 있으므로 별도로 카운트하지 않음

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

    // 2. 카테고리 선택 버블 (펫은 선택했지만 카테고리가 선택되지 않은 경우)
    if (chatState.hasPetSelected && !chatState.hasCategorySelected) {
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

    // 3. 구체적인 질문 요청 버블 (카테고리가 선택되었지만 메시지가 없는 경우)
    if (chatState.hasCategorySelected && chatState.messages.isEmpty) {
      if (index == currentIndex) {
        return AiQuestionRequestBubble(
          selectedPet: chatState.selectedPet,
          selectedCategory: chatState.selectedCategory,
          onQuestionTap: _sendMessage,
        );
      }
      currentIndex++;
    }

    // 4. 실제 메시지들
    if (index >= currentIndex &&
        index < currentIndex + chatState.messages.length) {
      final messageIndex = index - currentIndex;
      final message = chatState.messages[messageIndex];
      return AiMessageBubble(
        message: message,
        isFavorite: chatState.favoriteMessageIds.contains(message.id),
        onFavoriteToggle: (msg) {
          ref.read(aiChatNotifierProvider.notifier).toggleFavorite(msg);
        },
      );
    }
    currentIndex += chatState.messages.length;

    // 5. 추천 질문들은 AiQuestionRequestBubble에 포함되어 있으므로 별도 처리 불필요

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
      appBar: SoftGradientAppBar(
        title: 'AIアシスタント',
        actions: [
          IconButton(
            onPressed: _navigateToFavoriteMessages,
            icon: const Icon(Icons.star),
            tooltip: 'お気に入り',
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
}
