import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/entities.dart'; // ✅ 추가
import '../controllers/ai_chat_controller.dart';
import '../widgets/ai_widgets.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  // ✅ WidgetsBindingObserver 제거 (백그라운드 저장 비활성화)
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ✅ Observer 등록 제거
    // WidgetsBinding.instance.addObserver(this);

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatProvider.notifier).initializeChat();
    });
  }

  @override
  void dispose() {
    // ✅ Observer 제거 코드도 삭제
    // WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ 백그라운드 자동 저장 기능 비활성화
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   // 앱이 백그라운드로 갈 때 현재 채팅 저장
  //   if (state == AppLifecycleState.paused) {
  //     _saveCurrentChatBeforeExit();
  //   }
  // }

  // Future<void> _saveCurrentChatBeforeExit() async {
  //   final chatState = ref.read(aiChatProvider);
  //   if (chatState.messages.isNotEmpty) {
  //     try {
  //       await ref
  //           .read(aiChatProvider.notifier)
  //           .saveCurrentChatToHistory(isManualSave: false);
  //     } catch (error) {
  //       // 백그라운드 저장 실패는 로그만 남기고 UI에는 표시하지 않음
  //       LoggerService.debug('백그라운드 채팅 저장 실패: $error');
  //     }
  //   }
  // }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _messageController.clear();

    // 사용자 메시지 전송 후 스크롤
    _scrollToBottom();

    // 노티파이어를 통해 메시지 전송
    await ref.read(aiChatProvider.notifier).sendMessage(content);

    // AI 응답 완료 후 UI 갱신을 위해 여러 번 스크롤 시도
    _scrollToBottom();

    // 추가 딜레이 후 다시 스크롤 (후속 질문 버블이 렌더링될 시간 확보)
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 300));
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

  /// 医療免責事項バナーを構築
  Widget _buildMedicalDisclaimerBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6), // 警告色（オレンジ系の薄い色）
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '重要な注意事項',
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'このAIアシスタントは一般的なペットケアの情報を提供しますが、獣医師の診断や治療の代わりにはなりません。ペットの健康に関する深刻な問題や緊急の症状がある場合は、直ちに獣医師にご相談ください。',
                  style: AppFonts.bodySmall.copyWith(
                    color: const Color(0xFFE65100),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChatHistory() async {
    await ref.read(aiChatProvider.notifier).clearChatHistory();
  }

  Future<void> _saveCurrentChat() async {
    final chatState = ref.read(aiChatProvider);
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
          .read(aiChatProvider.notifier)
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

    // 펫은 선택했지만 카테고리가 아직 선택되지 않은 경우, 카테고리 선택 버블 추가
    if (chatState.hasPetSelected &&
        !chatState.hasCategorySelected &&
        chatState.selectedCategory == null &&
        chatState.messages.isNotEmpty) {
      count += 1; // 카테고리 선택 메시지
    }

    // 카테고리는 선택했지만 서브카테고리가 필요하고 아직 선택되지 않은 경우
    if (chatState.selectedCategory != null &&
        !chatState.hasCategorySelected &&
        !chatState.hasSubCategorySelected &&
        chatState.selectedCategory!.subCategories != null &&
        chatState.selectedCategory!.subCategories!.isNotEmpty) {
      count += 1; // 서브카테고리 선택 메시지
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
            ref.read(aiChatProvider.notifier).selectPet(pet);
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
            // ✅ 즐겨찾기 기능 비활성화
            isFavorite:
                false, // chatState.favoriteMessageIds.contains(message.id),
            onFavoriteToggle: null, // (msg) async {
            //   await ref.read(aiChatProvider.notifier).toggleFavorite(msg);
            // },
          ),
        ],
      );
    }
    currentIndex += chatState.messages.length;

    // 3. 카테고리 선택 버블 (카테고리가 아직 선택되지 않은 경우)
    if (chatState.hasPetSelected &&
        !chatState.hasCategorySelected &&
        chatState.selectedCategory == null &&
        chatState.messages.isNotEmpty) {
      if (index == currentIndex) {
        return AiCategorySelectionBubble(
          selectedCategory: chatState.selectedCategory,
          onCategorySelected: (category) {
            ref.read(aiChatProvider.notifier).selectCategory(category);
          },
          onSkip: () {
            // ✅ 추가: Skip 시 일반 카테고리 선택으로 처리
            const generalCategory = AiCategoryEntity(
              id: 'general',
              name: '一般',
              icon: Icons.help_outline,

              description: '一般的なペット相談',
              color: AppColors.pointBlue,
            );
            ref.read(aiChatProvider.notifier).selectCategory(generalCategory);
          },
        );
      }
      currentIndex++;
    }

    // 3-1. 서브카테고리 선택 버블 (카테고리 선택 직후 표시)
    if (chatState.selectedCategory != null &&
        !chatState.hasCategorySelected &&
        !chatState.hasSubCategorySelected &&
        chatState.selectedCategory!.subCategories != null &&
        chatState.selectedCategory!.subCategories!.isNotEmpty) {
      if (index == currentIndex) {
        return AiSubCategorySelectionBubble(
          selectedCategory: chatState.selectedCategory!,
          selectedSubCategory: chatState.selectedSubCategory,
          onSubCategorySelected: (subCategory) {
            ref.read(aiChatProvider.notifier).selectSubCategory(subCategory);
          },
          onSkip: () {
            // スキップ時は一般的なサブカテゴリとして扱う
            ref.read(aiChatProvider.notifier).skipSubCategorySelection();
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
    final chatState = ref.watch(aiChatProvider);

    // 디버그 로그
    LoggerService.debug('🐾 AI Chat Debug:');
    LoggerService.debug('  - hasPetSelected: ${chatState.hasPetSelected}');
    LoggerService.debug(
      '  - hasCategorySelected: ${chatState.hasCategorySelected}',
    );
    LoggerService.debug(
      '  - hasSubCategorySelected: ${chatState.hasSubCategorySelected}',
    );
    LoggerService.debug('  - messages count: ${chatState.messages.length}');
    LoggerService.debug('  - selectedPet: ${chatState.selectedPet?.name}');
    LoggerService.debug(
      '  - selectedCategory: ${chatState.selectedCategory?.name}',
    );
    LoggerService.debug(
      '  - selectedSubCategory: ${chatState.selectedSubCategory?.name}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pointBrown,
        elevation: 0,
        title: null, // タイトルを削除
        leading: IconButton(
          onPressed: _navigateToChatHistory,
          icon: const Icon(Icons.history, color: AppColors.pointDark),
          tooltip: 'チャット履歴',
        ),
        actions: [
          IconButton(
            onPressed: _navigateToFavoriteMessages,
            icon: const Icon(Icons.star, color: AppColors.pointDark),
            tooltip: 'お気に入り',
          ),
          IconButton(
            onPressed: _saveCurrentChat,
            icon: const Icon(Icons.save, color: AppColors.pointDark),
            tooltip: '会話を保存',
          ),
          IconButton(
            onPressed: _clearChatHistory,
            icon: const Icon(Icons.refresh, color: AppColors.pointDark),
            tooltip: 'チャットをクリア',
          ),
        ],
      ),
      body: GestureDetector(
        // 화면 탭 시 키보드 닫기
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              // 医療免責事項バナー
              _buildMedicalDisclaimerBanner(),

              // 메시지 리스트
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    bottom: AppSpacing.xl * 2, // 하단 여백 증가
                  ),
                  reverse: false,
                  itemCount: _getTotalItemCount(chatState),
                  itemBuilder: (context, index) {
                    return _buildChatItem(context, ref, chatState, index);
                  },
                ),
              ),

              // 메시지 입력 영역 (항상 표시)
              AiMessageInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
                isLoading: chatState.isTyping,
              ),
            ],
          ),
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
