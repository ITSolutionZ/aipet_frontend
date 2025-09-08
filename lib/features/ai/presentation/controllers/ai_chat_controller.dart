import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
import '../../../pet_registor/pet_registor.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

part 'ai_chat_controller.g.dart';

/// AI 채팅 상태 데이터
class AiChatState {
  final List<AiMessageEntity> messages;
  final List<AiSuggestedQuestionEntity> suggestedQuestions;
  final bool isTyping;
  final String? error;
  final PetProfileEntity? selectedPet;
  final bool hasPetSelected;
  final AiCategoryEntity? selectedCategory;
  final bool hasCategorySelected;
  final List<String> favoriteMessageIds;
  final List<AiFavoriteQaEntity> favoriteQAs;

  const AiChatState({
    this.messages = const [],
    this.suggestedQuestions = const [],
    this.isTyping = false,
    this.error,
    this.selectedPet,
    this.hasPetSelected = false,
    this.selectedCategory,
    this.hasCategorySelected = false,
    this.favoriteMessageIds = const [],
    this.favoriteQAs = const [],
  });

  AiChatState copyWith({
    List<AiMessageEntity>? messages,
    List<AiSuggestedQuestionEntity>? suggestedQuestions,
    bool? isTyping,
    String? error,
    PetProfileEntity? selectedPet,
    bool? hasPetSelected,
    AiCategoryEntity? selectedCategory,
    bool? hasCategorySelected,
    List<String>? favoriteMessageIds,
    List<AiFavoriteQaEntity>? favoriteQAs,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
      selectedPet: selectedPet ?? this.selectedPet,
      hasPetSelected: hasPetSelected ?? this.hasPetSelected,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      hasCategorySelected: hasCategorySelected ?? this.hasCategorySelected,
      favoriteMessageIds: favoriteMessageIds ?? this.favoriteMessageIds,
      favoriteQAs: favoriteQAs ?? this.favoriteQAs,
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

  /// 초기 데이터 로드 (깨끗한 상태로 시작)
  Future<void> initializeChat() async {
    final repository = ref.read(aiRepositoryProvider);

    try {
      final suggestedQuestions = await repository.getSuggestedQuestions();

      // 빈 채팅으로 시작 - 펫 선택부터 시작
      state = state.copyWith(
        messages: <AiMessageEntity>[], // 빈 메시지 리스트
        suggestedQuestions: suggestedQuestions,
        favoriteQAs: <AiFavoriteQaEntity>[], // 빈 즐겨찾기 리스트
        favoriteMessageIds: <String>[], // 빈 즐겨찾기 ID 리스트
        // 초기 상태: 아무것도 선택되지 않음
        selectedPet: null,
        hasPetSelected: false,
        selectedCategory: null,
        hasCategorySelected: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    if (pet != null) {
      // 펫 선택을 사용자 메시지로 추가
      final userMessage = AiMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '${pet.name}について相談したいです',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      // AI 응답 메시지 추가
      final aiMessage = AiMessageEntity(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: '${pet.name}についてですね！🐕\n\nどのような内容でお困りですか？カテゴリを選択してください：\n\n• 健康 - 病気、怪我、健康管理\n• 食事 - フード、栄養、給餌\n• 行動 - しつけ、問題行動\n• グルーミング - お手入れ、毛づくろい\n• その他',
        type: MessageType.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
      );

      final updatedMessages = [...state.messages, userMessage, aiMessage];
      
      state = state.copyWith(
        selectedPet: pet,
        hasPetSelected: true,
        messages: updatedMessages,
      );
    } else {
      state = state.copyWith(selectedPet: pet, hasPetSelected: true);
    }
  }

  /// 카테고리 선택
  Future<void> selectCategory(AiCategoryEntity category) async {
    // 카테고리 선택을 사용자 메시지로 추가
    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '${category.name}について相談したいです',
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    // AI 응답 메시지 추가
    final petName = state.selectedPet?.name ?? 'ペット';
    final aiMessage = AiMessageEntity(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: '${petName}の${category.name}について、どのような症状や心配事がありますか？\n\n${petName}の状況を詳しく教えてください。症状、期間、食欲の変化なども含めて説明していただけると、より正確なアドバイスができます。',
      type: MessageType.assistant,
      timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
    );

    final updatedMessages = [...state.messages, userMessage, aiMessage];

    state = state.copyWith(
      selectedCategory: category,
      hasCategorySelected: true,
      messages: updatedMessages,
    );

    // 카테고리별 맞춤 추천 질문 업데이트
    try {
      final repository = ref.read(aiRepositoryProvider);
      final personalizedQuestions = await repository.getPersonalizedSuggestedQuestions(
        category: category.id,
        pet: state.selectedPet,
      );

      state = state.copyWith(
        suggestedQuestions: personalizedQuestions,
      );
    } catch (e) {
      // 에러 발생 시 기본 추천 질문 유지
      AiLogger.logApiError(e);
    }
  }

  /// 즐겨찾기 토글
  void toggleFavorite(AiMessageEntity message) {
    final favoriteIds = List<String>.from(state.favoriteMessageIds);
    final favoriteQAs = List<AiFavoriteQaEntity>.from(state.favoriteQAs);

    if (favoriteIds.contains(message.id)) {
      // 즐겨찾기에서 제거
      favoriteIds.remove(message.id);
      favoriteQAs.removeWhere((qa) => qa.id == message.id);
    } else {
      // 즐겨찾기에 추가
      favoriteIds.add(message.id);

      // 해당 메시지와 연관된 질문 찾기 (바로 이전 사용자 메시지)
      String userQuestion = '질문을 찾을 수 없습니다';
      final messageIndex = state.messages.indexWhere((m) => m.id == message.id);
      if (messageIndex > 0) {
        final previousMessage = state.messages[messageIndex - 1];
        if (previousMessage.type == MessageType.user) {
          userQuestion = previousMessage.content;
        }
      }

      // AiFavoriteQaEntity 생성
      final favoriteQA = AiFavoriteQaEntity(
        id: message.id,
        question: userQuestion,
        answer: message.content,
        pet: state.selectedPet,
        categoryId: state.selectedCategory?.id,
        categoryName: state.selectedCategory?.name,
        createdAt: DateTime.now(),
        originalTimestamp: message.timestamp,
      );

      favoriteQAs.add(favoriteQA);
    }

    state = state.copyWith(
      favoriteMessageIds: favoriteIds,
      favoriteQAs: favoriteQAs,
    );

    // TODO: Repository를 통해 서버에 저장
    // if (!favoriteIds.contains(message.id)) {
    //   repository.addFavoriteMessage(message, state.selectedCategory?.id ?? 'general');
    // } else {
    //   repository.removeFavoriteMessage(message.id);
    // }
  }

  /// 메시지 전송
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final repository = ref.read(aiRepositoryProvider);

    // 사용자 메시지 추가
    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    
    // 사용자 메시지를 추가하고 타이핑 상태 시작
    state = state.copyWith(
      messages: updatedMessages,
      isTyping: true,
    );

    try {
      // Repository를 통해 AI 응답 받기 (펫 정보 포함)
      final aiResponse = await repository.sendMessageWithPetContext(
        content.trim(),
        petContext: state.selectedPet,
      );
      
      // 현재 메시지 목록에 AI 응답 추가 (중복 방지)
      final finalMessages = [...state.messages, aiResponse];

      state = state.copyWith(
        messages: finalMessages,
        isTyping: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(isTyping: false, error: error.toString());
    }
  }

  /// 개별 즐겨찾기 삭제
  void removeFavorite(String favoriteId) {
    final updatedFavoriteIds = List<String>.from(state.favoriteMessageIds)
      ..remove(favoriteId);
    final updatedFavoriteQAs = List<AiFavoriteQaEntity>.from(state.favoriteQAs)
      ..removeWhere((qa) => qa.id == favoriteId);

    state = state.copyWith(
      favoriteMessageIds: updatedFavoriteIds,
      favoriteQAs: updatedFavoriteQAs,
    );
  }

  /// 모든 즐겨찾기 삭제
  void clearAllFavorites() {
    state = state.copyWith(
      favoriteMessageIds: <String>[],
      favoriteQAs: <AiFavoriteQaEntity>[],
    );
  }

  /// 현재 채팅을 히스토리에 저장 (AI 요약 포함)
  Future<void> saveCurrentChatToHistory({bool isManualSave = false}) async {
    // 메시지가 없으면 저장하지 않음
    if (state.messages.isEmpty) return;

    final repository = ref.read(aiRepositoryProvider);

    try {
      // AI를 사용하여 채팅 내용을 요약
      final summary = await _generateChatSummary();
      
      // 채팅 히스토리 생성
      final chatHistory = AiChatHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: summary.title,
        summary: summary.content,
        messages: List.from(state.messages),
        pet: state.selectedPet,
        category: state.selectedCategory,
        createdAt: DateTime.now(),
        isManualSaved: isManualSave,
        messageCount: state.messages.length,
      );

      // 히스토리에 저장
      await repository.saveChatHistory(chatHistory);
      
    } catch (error) {
      debugPrint('채팅 저장 실패: $error');
    }
  }

  /// AI를 사용하여 채팅 요약 생성
  Future<AiChatSummary> _generateChatSummary() async {
    final repository = ref.read(aiRepositoryProvider);
    
    // 사용자 메시지만 추출하여 요약 요청
    final userMessages = state.messages
        .where((m) => m.isUser)
        .map((m) => m.content)
        .toList();

    if (userMessages.isEmpty) {
      return AiChatSummary(
        title: '${state.selectedPet?.name ?? 'ペット'}の相談',
        content: '${state.selectedCategory?.name ?? '一般的な'}相談',
      );
    }

    try {
      return await repository.generateChatSummary(
        userMessages: userMessages,
        petName: state.selectedPet?.name ?? 'ペット',
        category: state.selectedCategory?.name ?? '一般',
      );
    } catch (error) {
      // AI 요약 실패 시 기본 요약 생성
      final firstMessage = userMessages.first;
      final title = firstMessage.length > 20 
          ? '${firstMessage.substring(0, 20)}...' 
          : firstMessage;
          
      return AiChatSummary(
        title: title,
        content: '${state.selectedPet?.name ?? 'ペット'}の${state.selectedCategory?.name ?? '相談'}について',
      );
    }
  }

  /// 채팅 기록 초기화 (현재 채팅을 저장한 후 리셋)
  Future<void> clearChatHistory({bool saveBeforeClear = true}) async {
    final repository = ref.read(aiRepositoryProvider);

    try {
      // 현재 채팅이 있으면 히스토리에 저장
      if (saveBeforeClear && state.messages.isNotEmpty) {
        await saveCurrentChatToHistory();
      }

      await repository.clearChatHistory();

      // 완전히 초기 상태로 리셋
      state = const AiChatState();

      // 추천 질문만 다시 로드
      final suggestedQuestions = await repository.getSuggestedQuestions();
      state = state.copyWith(suggestedQuestions: suggestedQuestions);
    } catch (error) {
      state = state.copyWith(error: error.toString());
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
    await safeExecute(() async {
      final notifier = ref.read(aiChatNotifierProvider.notifier);
      await notifier.initializeChat();
    }, errorMessage: 'チャット初期化に失敗しました');
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    notifier.selectPet(pet);
  }

  /// 메시지 전송
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    await safeExecute(() async {
      final notifier = ref.read(aiChatNotifierProvider.notifier);
      await notifier.sendMessage(content);
    }, errorMessage: 'メッセージの送信に失敗しました');
  }

  /// 채팅 기록 초기화
  Future<void> clearChatHistory() async {
    await safeExecute(() async {
      final notifier = ref.read(aiChatNotifierProvider.notifier);
      await notifier.clearChatHistory();
    }, errorMessage: 'チャット履歴のクリアに失敗しました');
  }

  /// 현재 메시지 목록 가져오기
  List<AiMessageEntity> get messages => chatState.messages;

  /// 추천 질문 목록 가져오기
  List<AiSuggestedQuestionEntity> get suggestedQuestions =>
      chatState.suggestedQuestions;

  /// 타이핑 상태 확인
  bool get isTyping => chatState.isTyping;

  /// 에러 상태 확인
  String? get error => chatState.error;

  /// 선택된 펫 정보 확인
  PetProfileEntity? get selectedPet => chatState.selectedPet;

  /// 펫 선택 완료 상태 확인
  bool get hasPetSelected => chatState.hasPetSelected;

  /// 선택된 카테고리 확인
  AiCategoryEntity? get selectedCategory => chatState.selectedCategory;

  /// 카테고리 선택 완료 상태 확인
  bool get hasCategorySelected => chatState.hasCategorySelected;

  /// 즐겨찾기 메시지 ID 목록 확인
  List<String> get favoriteMessageIds => chatState.favoriteMessageIds;

  /// 메시지 즐겨찾기 여부 확인
  bool isFavorite(String messageId) =>
      chatState.favoriteMessageIds.contains(messageId);

  /// 카테고리 선택
  void selectCategory(AiCategoryEntity category) {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    notifier.selectCategory(category);
  }

  /// 즐겨찾기 토글
  void toggleFavorite(AiMessageEntity message) {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    notifier.toggleFavorite(message);
  }

  /// 현재 채팅을 히스토리에 수동 저장
  Future<void> saveCurrentChatManually() async {
    await safeExecute(() async {
      final notifier = ref.read(aiChatNotifierProvider.notifier);
      await notifier.saveCurrentChatToHistory(isManualSave: true);
    }, errorMessage: 'チャット履歴の保存に失敗しました');
  }

  /// 현재 채팅을 히스토리에 자동 저장 (탭 전환시)
  Future<void> saveCurrentChatOnTabSwitch() async {
    await safeExecute(() async {
      final notifier = ref.read(aiChatNotifierProvider.notifier);
      await notifier.saveCurrentChatToHistory(isManualSave: false);
    }, errorMessage: null); // 탭 전환시에는 에러 메시지를 보여주지 않음
  }
}
