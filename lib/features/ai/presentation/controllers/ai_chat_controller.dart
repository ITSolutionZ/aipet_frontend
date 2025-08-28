import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

part 'ai_chat_controller.g.dart';

/// AI 채팅 상태 데이터
class AiChatState {
  final List<AiMessageEntity> messages;
  final List<AiSuggestedQuestionEntity> suggestedQuestions;
  final bool isTyping;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.suggestedQuestions = const [],
    this.isTyping = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessageEntity>? messages,
    List<AiSuggestedQuestionEntity>? suggestedQuestions,
    bool? isTyping,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
    );
  }
}

/// AI 채팅 상태 프로바이더
@riverpod
class AiChatNotifier extends _$AiChatNotifier {
  @override
  AiChatState build() {
    // 초기 상태는 빈 상태로 시작하고, 실제 데이터는 repository를 통해 로드
    return const AiChatState();
  }

  /// 초기 데이터 로드
  Future<void> initializeChat() async {
    final repository = ref.read(aiRepositoryProvider);
    
    try {
      final messages = await repository.getChatHistory();
      final suggestedQuestions = await repository.getSuggestedQuestions();
      
      state = state.copyWith(
        messages: messages,
        suggestedQuestions: suggestedQuestions,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
      );
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    final repository = ref.read(aiRepositoryProvider);

    // 타이핑 상태 시작
    state = state.copyWith(isTyping: true);

    // 사용자 메시지 추가
    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages);

    try {
      // Repository를 통해 AI 응답 받기
      final aiResponse = await repository.sendMessage(content.trim());
      final finalMessages = List<AiMessageEntity>.from([...state.messages, aiResponse]);
      
      state = state.copyWith(
        messages: finalMessages,
        isTyping: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isTyping: false,
        error: error.toString(),
      );
    }
  }

  /// 채팅 기록 초기화
  Future<void> clearChatHistory() async {
    final repository = ref.read(aiRepositoryProvider);
    
    try {
      await repository.clearChatHistory();
      
      // 초기 메시지로 리셋
      final messages = await repository.getChatHistory();
      state = state.copyWith(
        messages: messages,
        isTyping: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
      );
    }
  }

}

/// AI 채팅 컨트롤러 (BaseController 패턴)
/// 
/// UI와 Logic을 분리하여 UI에서는 이 Controller를 통해서만 데이터에 접근합니다.
class AiChatController extends BaseController {
  AiChatController(super.ref);

  /// 채팅 상태 스트림 제공 (UI에서 구독)
  AiChatState get chatState => ref.read(aiChatNotifierProvider);

  /// 채팅 상태 변경 감지 (UI에서 사용)
  AiChatState watchChatState() {
    return ref.watch(aiChatNotifierProvider);
  }

  /// 초기 데이터 로드
  Future<void> initializeChat() async {
    await safeExecute(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.initializeChat();
      },
      errorMessage: 'チャット初期化に失敗しました',
    );
  }

  /// 메시지 전송
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    await safeExecute(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.sendMessage(content);
      },
      errorMessage: 'メッセージの送信に失敗しました',
    );
  }

  /// 채팅 기록 초기화
  Future<void> clearChatHistory() async {
    await safeExecute(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.clearChatHistory();
      },
      errorMessage: 'チャット履歴のクリアに失敗しました',
    );
  }

  /// 현재 메시지 목록 가져오기
  List<AiMessageEntity> get messages => chatState.messages;

  /// 추천 질문 목록 가져오기  
  List<AiSuggestedQuestionEntity> get suggestedQuestions => chatState.suggestedQuestions;

  /// 타이핑 상태 확인
  bool get isTyping => chatState.isTyping;

  /// 에러 상태 확인
  String? get error => chatState.error;
}
