import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../controllers/ai_chat_controller.dart';
import '../widgets/widgets.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late AiChatController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AiChatController(ref);
    
    // 초기 데이터 로드 (Controller를 통해서만 접근)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _messageController.clear();
    _scrollToBottom();

    // 컨트롤러를 통해 메시지 전송
    await _controller.sendMessage(content);
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
    await _controller.clearChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    // UI와 Logic 분리: Controller를 통해서만 상태 접근
    _controller.watchChatState(); // Provider 변화 감지를 위해 호출
    
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AIアシスタント',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_controller.isTyping)
                  Text(
                    '入力中...',
                    style: AppFonts.bodySmall.copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearChatHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 리스트
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _controller.messages.length + (_controller.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _controller.messages.length) {
                  return AiMessageBubble(message: _controller.messages[index]);
                } else {
                  return const AiTypingIndicator();
                }
              },
            ),
          ),

          // 추천 질문 (메시지가 적을 때만 표시)
          if (_controller.messages.length <= 2)
            AiSuggestedQuestions(
              questions: _controller.suggestedQuestions,
              onQuestionTap: _sendMessage,
            ),

          // 메시지 입력 영역
          AiMessageInput(
            controller: _messageController,
            onSendMessage: _sendMessage,
            isLoading: _controller.isTyping,
          ),
        ],
      ),
    );
  }
}
