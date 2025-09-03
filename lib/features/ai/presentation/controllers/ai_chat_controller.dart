import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/controllers/base_controller.dart';
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

  /// 초기 데이터 로드
  Future<void> initializeChat() async {
    final repository = ref.read(aiRepositoryProvider);

    try {
      final messages = await repository.getChatHistory();
      final suggestedQuestions = await repository.getSuggestedQuestions();

      // Mock 즐겨찾기 데이터 로드 (테스트용)
      final favoriteQAs = repository.getFavoriteQAs();
      final favoriteIds = favoriteQAs.map((qa) => qa.id).toList();

      state = state.copyWith(
        messages: messages,
        suggestedQuestions: suggestedQuestions,
        favoriteQAs: favoriteQAs,
        favoriteMessageIds: favoriteIds,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    state = state.copyWith(selectedPet: pet, hasPetSelected: true);
  }

  /// 카테고리 선택
  void selectCategory(AiCategoryEntity category) {
    state = state.copyWith(
      selectedCategory: category,
      hasCategorySelected: true,
    );
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
      // Repository를 통해 AI 응답 받기 (펫 정보 포함)
      final aiResponse = await repository.sendMessageWithPetContext(
        content.trim(),
        petContext: state.selectedPet,
      );
      final finalMessages = List<AiMessageEntity>.from([
        ...state.messages,
        aiResponse,
      ]);

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

  /// 채팅 기록 초기화 (완전 리셋)
  Future<void> clearChatHistory() async {
    final repository = ref.read(aiRepositoryProvider);

    try {
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
}
