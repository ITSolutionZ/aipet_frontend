import 'dart:async';

import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/ai/data/providers/ai_usecase_providers.dart';
import 'package:aipet_frontend/features/ai/data/services/ai_local_storage_service.dart';
import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_chat_state_manager.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_favorite_manager.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_message_manager.dart';
import 'package:aipet_frontend/features/ai/domain/services/message_pagination_service.dart';
import 'package:aipet_frontend/features/home/data/home_providers.dart';
import 'package:aipet_frontend/features/walk/domain/services/walk_recommendation_service.dart';
import 'package:aipet_frontend/features/walk/domain/usecases/compute_walk_recommendation_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_controller.g.dart';

/// 🎯 AI 채팅 상태 데이터
///
/// AI 채팅 화면에서 사용되는 모든 상태 정보를 관리합니다.
///
/// ## 주요 상태
/// - 메시지 목록 및 타이핑 상태
/// - 펫 선택 및 카테고리 선택 상태
/// - 즐겨찾기 메시지 관리
/// - 에러 상태 및 로딩 상태
class AiChatState {
  final List<AiMessageEntity> messages;
  final MessageStatistics messageStats;
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
    this.messageStats = const MessageStatistics(
      totalMessages: 0,
      userMessages: 0,
      assistantMessages: 0,
      totalCharacters: 0,
      memoryUsageBytes: 0,
      memoryUsageMB: 0.0,
      isMemoryHigh: false,
      needsCleanup: false,
    ),
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
    MessageStatistics? messageStats,
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
    final updatedMessages = messages ?? this.messages;
    final updatedStats =
        messageStats ??
        MessagePaginationService.generateStatistics(updatedMessages);

    return AiChatState(
      messages: updatedMessages,
      messageStats: updatedStats,
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

/// 🎯 AI 채팅 상태 프로바이더
///
/// Riverpod을 사용한 AI 채팅 상태 관리 클래스입니다.
///
/// ## 주요 기능
/// - 채팅 메시지 관리 (전송, 저장, 로드)
/// - 펫 선택 및 카테고리 선택 처리
/// - 즐겨찾기 메시지 관리
/// - 채팅 히스토리 저장 및 복원
///
/// ## 상태 관리
/// - 불변성 유지를 위한 copyWith 패턴 사용
/// - 에러 처리 및 로딩 상태 관리
/// - Repository 패턴을 통한 데이터 접근
@riverpod
class AiChatNotifier extends _$AiChatNotifier {
  @override
  AiChatState build() {
    // 초기 상태는 빈 상태로 시작하고, 실제 데이터는 repository를 통해 로드
    return const AiChatState();
  }

  /// 초기 데이터 로드
  ///
  /// 채팅 화면 진입 시 필요한 초기 데이터를 로드합니다.
  Future<void> initializeChat() async {
    final useCase = ref.read(initializeChatUseCaseProvider);
    final result = await useCase();

    if (result.isSuccess && result.dataOrNull != null) {
      final initResult = AiChatStateManager.initializeState(
        suggestedQuestions: result.dataOrNull!,
      );

      if (initResult.isSuccess) {
        state = initResult.dataOrNull!;

        // 로컬 저장소에서 즐겨찾기 로드
        try {
          // AiLocalStorageService를 직접 사용
          final aiLocalStorageService = AiLocalStorageService();
          final favoriteQAs = aiLocalStorageService.loadFavoriteQAs();
          final favoriteIds = favoriteQAs.map((qa) => qa.id).toList();

          state = state.copyWith(
            favoriteMessageIds: favoriteIds,
            favoriteQAs: favoriteQAs,
          );

          debugPrint('⭐ 즐겨찾기 로컬 저장소에서 로드 완료: ${favoriteQAs.length}개');
        } catch (e) {
          debugPrint('⭐ 즐겨찾기 로컬 저장소 로드 실패: $e');
        }
      } else {
        state =
            AiChatStateManager.setErrorState(
              currentState: state,
              error: initResult.error?.toString() ?? 'Init failed',
            ).dataOrNull ??
            state;
      }
    } else {
      state =
          AiChatStateManager.setErrorState(
            currentState: state,
            error: result.error?.toString() ?? 'Initialization failed',
          ).dataOrNull ??
          state;
    }
  }

  /// 펫 선택 처리
  void selectPet(PetProfileEntity? pet) {
    final useCase = ref.read(selectPetUseCaseProvider);
    final result = useCase(pet);

    if (result.isSuccess && result.dataOrNull != null && pet != null) {
      final updateResult = AiChatStateManager.updatePetSelection(
        currentState: state,
        pet: pet,
        newMessages: result.dataOrNull!,
      );

      if (updateResult.isSuccess) {
        state = updateResult.dataOrNull!;
        // 상태 검증 및 정리
        final validationResult = AiChatStateManager.validateAndCleanState(
          state,
        );
        if (validationResult.isSuccess) {
          state = validationResult.dataOrNull!;
        }
      } else {
        state =
            AiChatStateManager.setErrorState(
              currentState: state,
              error: updateResult.error?.toString() ?? 'Update failed',
            ).dataOrNull ??
            state;
      }
    } else if (pet == null) {
      final updateResult = AiChatStateManager.updatePetSelection(
        currentState: state,
        pet: null,
      );
      if (updateResult.isSuccess) {
        state = updateResult.dataOrNull!;
        // 상태 검증 및 정리
        final validationResult = AiChatStateManager.validateAndCleanState(
          state,
        );
        if (validationResult.isSuccess) {
          state = validationResult.dataOrNull!;
        }
      }
    } else {
      state =
          AiChatStateManager.setErrorState(
            currentState: state,
            error: result.error?.toString() ?? 'Pet selection failed',
          ).dataOrNull ??
          state;
    }
  }

  Future<void> selectCategory(AiCategoryEntity category) async {
    final useCase = ref.read(selectCategoryUseCaseProvider);

    final result = await useCase(
      category: category,
      selectedPet: state.selectedPet,
    );

    if (result.isSuccess && result.dataOrNull != null) {
      final updateResult = AiChatStateManager.updateCategorySelection(
        currentState: state,
        category: category,
        newMessages: result.dataOrNull!.messages,
        suggestedQuestions: result.dataOrNull!.suggestedQuestions,
      );

      if (updateResult.isSuccess) {
        state = updateResult.dataOrNull!;
      } else {
        state =
            AiChatStateManager.setErrorState(
              currentState: state,
              error: updateResult.error?.toString() ?? 'Update failed',
            ).dataOrNull ??
            state;
      }
    } else {
      state =
          AiChatStateManager.setErrorState(
            currentState: state,
            error: result.error?.toString() ?? 'Category selection failed',
          ).dataOrNull ??
          state;
    }
  }

  Future<void> toggleFavorite(AiMessageEntity message) async {
    // 사용자 질문 찾기
    String userQuestion = '質問を見つけられませんでした';
    final messageIndex = state.messages.indexWhere((m) => m.id == message.id);
    if (messageIndex > 0) {
      final previousMessage = state.messages[messageIndex - 1];
      if (previousMessage.type == MessageType.user) {
        userQuestion = previousMessage.content;
      }
    }

    final updateResult = AiChatStateManager.updateFavoriteToggle(
      currentState: state,
      message: message,
      userQuestion: userQuestion,
    );

    if (updateResult.isSuccess) {
      state = updateResult.dataOrNull!;

      // 로컬 저장소에 즐겨찾기 저장/삭제
      try {
        final aiLocalStorageService = AiLocalStorageService();
        final isCurrentlyFavorite = state.favoriteMessageIds.contains(
          message.id,
        );
        if (isCurrentlyFavorite) {
          // 즐겨찾기에 추가된 경우 - 로컬 저장소에 저장
          final favoriteQA = AiFavoriteQaEntity(
            id: message.id,
            question: userQuestion.trim(),
            answer: message.content.trim(),
            pet: state.selectedPet,
            categoryId: state.selectedCategory?.id,
            categoryName: state.selectedCategory?.name,
            createdAt: DateTime.now(),
            originalTimestamp: message.timestamp,
          );

          await aiLocalStorageService.saveFavoriteQA(favoriteQA);
          debugPrint('⭐ 즐겨찾기 로컬 저장소에 저장 완료: ${message.id}');
        } else {
          // 즐겨찾기에서 제거된 경우 - 로컬 저장소에서 삭제
          await aiLocalStorageService.removeFavoriteQA(message.id);
          debugPrint('⭐ 즐겨찾기 로컬 저장소에서 삭제 완료: ${message.id}');
        }
      } catch (e) {
        debugPrint('⭐ 즐겨찾기 로컬 저장소 저장/삭제 실패: $e');
      }
    } else {
      state =
          AiChatStateManager.setErrorState(
            currentState: state,
            error: updateResult.error?.toString() ?? 'Update failed',
          ).dataOrNull ??
          state;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final useCase = ref.read(sendMessageUseCaseProvider);

    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
      petId: state.selectedPet?.id,
      petName: state.selectedPet?.name,
    );

    // 사용자 메시지를 데이터베이스에 저장
    try {
      await LocalStorageService.instance.ai.saveChatMessage(
        conversationId: _getCurrentConversationId(),
        message: content.trim(),
        isUser: true,
        metadata: {
          'petId': state.selectedPet?.id,
          'petName': state.selectedPet?.name,
          'categoryId': state.selectedCategory?.id,
          'categoryName': state.selectedCategory?.name,
        },
      );
    } catch (e) {
      debugPrint('사용자 메시지 저장 실패: $e');
    }

    // 사용자 메시지 추가
    final userMessageResult = AiChatStateManager.updateMessageExchange(
      currentState: state,
      userMessage: userMessage,
      isTyping: true,
    );

    if (userMessageResult.isSuccess) {
      state = userMessageResult.dataOrNull!;
    }

    // 날씨 및 산책 정보 가져오기
    String? weatherAdvice;
    String? walkGuide;

    try {
      final dashboardAsync = ref.read(homeDashboardProvider);
      if (dashboardAsync.hasValue && dashboardAsync.value != null) {
        final dashboard = dashboardAsync.value!;
        final weather = dashboard.weather;

        // 날씨 어드바이스
        weatherAdvice = weather.dogWalkingRecommendation;

        // 산책 가이드 (펫이 선택되어 있을 때만)
        if (state.selectedPet != null) {
          final recommendationService = WalkRecommendationService();
          final recommendation = await ComputeWalkRecommendationUseCase().call(
            pet: state.selectedPet!,
            wbgt: weather.wbgt,
            temperature: weather.temperature,
          );

          walkGuide = recommendationService.generateShortGuide(recommendation);
        }
      }
    } catch (e) {
      debugPrint('날씨/산책 정보 가져오기 실패: $e');
    }

    final result = await useCase.callWithPetContext(
      content.trim(),
      petContext: state.selectedPet,
      weatherAdvice: weatherAdvice,
      walkGuide: walkGuide,
    );

    if (result.isSuccess && result.dataOrNull != null) {
      // AI 응답을 데이터베이스에 저장
      try {
        await LocalStorageService.instance.ai.saveChatMessage(
          conversationId: _getCurrentConversationId(),
          message: result.dataOrNull!.content,
          isUser: false,
          metadata: {
            'petId': state.selectedPet?.id,
            'petName': state.selectedPet?.name,
            'categoryId': state.selectedCategory?.id,
            'categoryName': state.selectedCategory?.name,
            'weatherAdvice': weatherAdvice,
            'walkGuide': walkGuide,
          },
        );
      } catch (e) {
        debugPrint('AI 응답 저장 실패: $e');
      }

      // AI 응답 추가
      final assistantMessageResult = AiChatStateManager.updateMessageExchange(
        currentState: state,
        assistantMessage: result.dataOrNull!,
        isTyping: false,
      );

      if (assistantMessageResult.isSuccess) {
        state = assistantMessageResult.dataOrNull!;
      } else {
        state =
            AiChatStateManager.setErrorState(
              currentState: state,
              error:
                  assistantMessageResult.error?.toString() ??
                  'Assistant message failed',
              clearTyping: true,
            ).dataOrNull ??
            state;
      }
    } else {
      state =
          AiChatStateManager.setErrorState(
            currentState: state,
            error: result.error?.toString() ?? 'Message send failed',
            clearTyping: true,
          ).dataOrNull ??
          state;
    }
  }

  /// 개별 즐겨찾기 삭제
  void removeFavorite(String favoriteId) {
    final removeResult = AiFavoriteManager.removeFromFavorites(
      currentFavoriteIds: state.favoriteMessageIds,
      currentFavoriteQAs: state.favoriteQAs,
      messageId: favoriteId,
    );

    if (removeResult.isSuccess) {
      final result = removeResult.dataOrNull!;
      state = state.copyWith(
        favoriteMessageIds: result.favoriteIds,
        favoriteQAs: result.favoriteQAs,
      );
    }
  }

  /// 모든 즐겨찾기 삭제
  void clearAllFavorites() {
    final clearResult = AiFavoriteManager.clearAllFavorites();
    if (clearResult.isSuccess) {
      final result = clearResult.dataOrNull!;
      state = state.copyWith(
        favoriteMessageIds: result.favoriteIds,
        favoriteQAs: result.favoriteQAs,
      );
    }
  }

  Future<void> saveCurrentChatToHistory({bool isManualSave = false}) async {
    if (state.messages.isEmpty) return;

    final useCase = ref.read(saveChatHistoryUseCaseProvider);

    await useCase(
      messages: state.messages,
      selectedPet: state.selectedPet,
      selectedCategory: state.selectedCategory,
      isManualSave: isManualSave,
    );
  }

  /// 현재 대화 ID 생성 또는 가져오기
  String _getCurrentConversationId() {
    // 현재 날짜를 기준으로 대화 ID 생성 (일별 대화)
    final now = DateTime.now();
    return 'conversation_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> clearChatHistory({bool saveBeforeClear = true}) async {
    try {
      if (saveBeforeClear && state.messages.isNotEmpty) {
        await saveCurrentChatToHistory();
      }

      final clearUseCase = ref.read(clearChatHistoryUseCaseProvider);
      final clearResult = await clearUseCase();

      if (clearResult.isSuccess) {
        final initUseCase = ref.read(initializeChatUseCaseProvider);
        final initResult = await initUseCase();

        if (initResult.isSuccess && initResult.dataOrNull != null) {
          final resetResult = AiChatStateManager.initializeState(
            suggestedQuestions: initResult.dataOrNull!,
          );

          if (resetResult.isSuccess) {
            state = resetResult.dataOrNull!;
          }
        } else {
          state =
              AiChatStateManager.initializeState().dataOrNull ??
              const AiChatState();
        }
      } else {
        state =
            AiChatStateManager.setErrorState(
              currentState: state,
              error: clearResult.error?.toString() ?? 'Clear chat failed',
            ).dataOrNull ??
            state;
      }
    } catch (error) {
      state =
          AiChatStateManager.setErrorState(
            currentState: state,
            error: error.toString(),
          ).dataOrNull ??
          state;
    }
  }

  /// 🧠 메모리 수동 최적화
  void optimizeMemoryUsage() {
    final optimizedResult = AiMessageManager.cleanupMessages(state.messages);

    if (optimizedResult.isSuccess) {
      state = state.copyWith(messages: optimizedResult.dataOrNull!);
      if (kDebugMode) {
        debugPrint(
          '[AiChatController] Manual memory optimization completed: ${optimizedResult.error?.toString() ?? 'Success'}',
        );
      }
    }
  }

  /// 🧠 메모리 통계 조회
  MessageStatistics getMemoryStatistics() {
    return AiMessageManager.generateStatistics(state.messages);
  }

  /// 🧠 자동 정리 필요 여부 확인
  bool shouldPerformCleanup() {
    final memoryStatus = AiMessageManager.checkMemoryStatus(state.messages);
    return memoryStatus.shouldCleanup;
  }
}

/// AI 채팅 컨트롤러 (BaseController 패턴)
///
/// UI와 Logic을 분리하여 UI에서는 이 Controller를 통해서만 데이터에 접근합니다.
class AiChatController extends BaseController {
  AiChatController(super.ref);

  /// 채팅 상태 스트림 제공 (UI에서 구독)
  AiChatState get chatState => ref.read(aiChatProvider);

  /// 채팅 상태 변경 감지 (UI에서 사용)
  AiChatState watchChatState() {
    return ref.watch(aiChatProvider);
  }

  Future<Result<void>> initializeChat() async {
    try {
      final notifier = ref.read(aiChatProvider.notifier);
      await notifier.initializeChat();
      return Result.success('チャットが初期化されました', null);
    } catch (error) {
      return Result.failure('チャット初期化に失敗しました: $error');
    }
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    final notifier = ref.read(aiChatProvider.notifier);
    notifier.selectPet(pet);
  }

  Future<Result<void>> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      return Result.failure('メッセージが空です');
    }

    try {
      final notifier = ref.read(aiChatProvider.notifier);
      await notifier.sendMessage(content);
      return Result.success('メッセージが送信されました', null);
    } catch (error) {
      return Result.failure('メッセージの送信に失敗しました: $error');
    }
  }

  Future<Result<void>> clearChatHistory() async {
    try {
      final notifier = ref.read(aiChatProvider.notifier);
      await notifier.clearChatHistory();
      return Result.success('チャット履歴がクリアされました', null);
    } catch (error) {
      return Result.failure('チャット履歴のクリアに失敗しました: $error');
    }
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
    final notifier = ref.read(aiChatProvider.notifier);
    notifier.selectCategory(category);
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(AiMessageEntity message) async {
    final notifier = ref.read(aiChatProvider.notifier);
    await notifier.toggleFavorite(message);
  }

  Future<Result<void>> saveCurrentChatManually() async {
    try {
      final notifier = ref.read(aiChatProvider.notifier);
      await notifier.saveCurrentChatToHistory(isManualSave: true);
      return Result.success('チャット履歴が保存されました', null);
    } catch (error) {
      return Result.failure('チャット履歴の保存に失敗しました: $error');
    }
  }

  Future<Result<void>> saveCurrentChatOnTabSwitch() async {
    try {
      final notifier = ref.read(aiChatProvider.notifier);
      await notifier.saveCurrentChatToHistory(isManualSave: false);
      return Result.success('チャット履歴が自動保存されました', null);
    } catch (error) {
      return Result.failure('チャット履歴の自動保存に失敗しました: $error');
    }
  }
}
