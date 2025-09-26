import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_favorite_manager.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_message_manager.dart';
import 'package:aipet_frontend/features/ai/domain/services/message_pagination_service.dart';
import 'package:aipet_frontend/features/ai/presentation/controllers/ai_chat_controller.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/foundation.dart';

/// 🎛️ AI 채팅 상태 관리 서비스
///
/// AI 채팅의 전체 상태 관리 및 비즈니스 로직을 담당합니다.
/// - 상태 변경 로직
/// - 상태 검증
/// - 상태 복원 및 초기화
class AiChatStateManager {
  static const String _tag = 'AiChatStateManager';

  /// 펫 선택 상태 업데이트
  ///
  /// [currentState] 현재 상태
  /// [pet] 선택할 펫 (null이면 선택 해제)
  /// [newMessages] 펫 선택으로 인한 새 메시지들
  /// [return] 업데이트된 상태
  static Result<AiChatState> updatePetSelection({
    required AiChatState currentState,
    required PetProfileEntity? pet,
    List<AiMessageEntity> newMessages = const [],
  }) {
    try {
      // 메시지 추가 (있는 경우)
      var updatedMessages = currentState.messages;
      if (newMessages.isNotEmpty) {
        final messageResult = AiMessageManager.addMessages(updatedMessages, newMessages);
        if (messageResult.isSuccess) {
          updatedMessages = messageResult.dataOrNull!;
        }
      }

      final updatedState = currentState.copyWith(
        selectedPet: pet,
        hasPetSelected: true,
        messages: updatedMessages,
        error: null, // 에러 클리어
      );

      if (kDebugMode) {
        debugPrint('[$_tag] 🐕 Pet selected: ${pet?.name ?? 'None'} (messages: ${updatedMessages.length})');
      }

      return ResultFactory.success(updatedState, 'Pet selection updated');

    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error updating pet selection: $error\n$stackTrace');
      }
      return ResultFactory.failure('펫 선택 업데이트 중 오류 발생: $error');
    }
  }

  /// 카테고리 선택 상태 업데이트
  ///
  /// [currentState] 현재 상태
  /// [category] 선택할 카테고리
  /// [newMessages] 카테고리 선택으로 인한 새 메시지들
  /// [suggestedQuestions] 제안 질문들
  /// [return] 업데이트된 상태
  static Result<AiChatState> updateCategorySelection({
    required AiChatState currentState,
    required AiCategoryEntity category,
    List<AiMessageEntity> newMessages = const [],
    List<AiSuggestedQuestionEntity> suggestedQuestions = const [],
  }) {
    try {
      // 메시지 추가
      var updatedMessages = currentState.messages;
      if (newMessages.isNotEmpty) {
        final messageResult = AiMessageManager.addMessages(updatedMessages, newMessages);
        if (messageResult.isSuccess) {
          updatedMessages = messageResult.dataOrNull!;
        }
      }

      final updatedState = currentState.copyWith(
        selectedCategory: category,
        hasCategorySelected: true,
        messages: updatedMessages,
        suggestedQuestions: suggestedQuestions,
        error: null,
      );

      if (kDebugMode) {
        debugPrint('[$_tag] 📂 Category selected: ${category.name} (suggestions: ${suggestedQuestions.length})');
      }

      return ResultFactory.success(updatedState, 'Category selection updated');

    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error updating category selection: $error\n$stackTrace');
      }
      return ResultFactory.failure('카테고리 선택 업데이트 중 오류 발생: $error');
    }
  }

  /// 메시지 전송 상태 업데이트
  ///
  /// [currentState] 현재 상태
  /// [userMessage] 사용자 메시지
  /// [assistantMessage] AI 응답 메시지 (없으면 타이핑 상태만 업데이트)
  /// [return] 업데이트된 상태
  static Result<AiChatState> updateMessageExchange({
    required AiChatState currentState,
    AiMessageEntity? userMessage,
    AiMessageEntity? assistantMessage,
    bool isTyping = false,
    String? error,
  }) {
    try {
      var updatedMessages = currentState.messages;

      // 사용자 메시지 추가
      if (userMessage != null) {
        final userResult = AiMessageManager.addMessage(updatedMessages, userMessage);
        if (userResult.isSuccess) {
          updatedMessages = userResult.dataOrNull!;
        }
      }

      // AI 응답 메시지 추가
      if (assistantMessage != null) {
        final assistantResult = AiMessageManager.addMessage(updatedMessages, assistantMessage);
        if (assistantResult.isSuccess) {
          updatedMessages = assistantResult.dataOrNull!;
        }
      }

      final updatedState = currentState.copyWith(
        messages: updatedMessages,
        isTyping: isTyping,
        error: error,
      );

      if (kDebugMode) {
        final userAdded = userMessage != null ? 'user+' : '';
        final assistantAdded = assistantMessage != null ? 'assistant+' : '';
        final typingStatus = isTyping ? 'typing' : 'idle';
        debugPrint('[$_tag] 💬 Message exchange: $userAdded$assistantAdded [$typingStatus] (total: ${updatedMessages.length})');
      }

      return ResultFactory.success(updatedState, 'Message exchange updated');

    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error updating message exchange: $error\n$stackTrace');
      }
      return ResultFactory.failure('메시지 교환 업데이트 중 오류 발생: $error');
    }
  }

  /// 즐겨찾기 토글 상태 업데이트
  ///
  /// [currentState] 현재 상태
  /// [message] 토글할 메시지
  /// [userQuestion] 해당 메시지의 질문
  /// [return] 업데이트된 상태
  static Result<AiChatState> updateFavoriteToggle({
    required AiChatState currentState,
    required AiMessageEntity message,
    required String userQuestion,
  }) {
    try {
      final isCurrentlyFavorite = currentState.favoriteMessageIds.contains(message.id);

      Result<FavoriteUpdateResult> favoriteResult;

      if (isCurrentlyFavorite) {
        // 즐겨찾기에서 제거
        favoriteResult = AiFavoriteManager.removeFromFavorites(
          currentFavoriteIds: currentState.favoriteMessageIds,
          currentFavoriteQAs: currentState.favoriteQAs,
          messageId: message.id,
        );
      } else {
        // 즐겨찾기에 추가
        favoriteResult = AiFavoriteManager.addToFavorites(
          currentFavoriteIds: currentState.favoriteMessageIds,
          currentFavoriteQAs: currentState.favoriteQAs,
          message: message,
          userQuestion: userQuestion,
          selectedCategory: currentState.selectedCategory,
          selectedPet: currentState.selectedPet,
        );
      }

      if (!favoriteResult.isSuccess) {
        return ResultFactory.failure(favoriteResult.errorOrNull ?? 'Favorite operation failed');
      }

      final result = favoriteResult.dataOrNull!;
      final updatedState = currentState.copyWith(
        favoriteMessageIds: result.favoriteIds,
        favoriteQAs: result.favoriteQAs,
      );

      if (kDebugMode) {
        final action = isCurrentlyFavorite ? 'Removed from' : 'Added to';
        debugPrint('[$_tag] ⭐ $action favorites: ${message.id} (total: ${result.favoriteIds.length})');
      }

      return ResultFactory.success(updatedState, result.message);

    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error updating favorite toggle: $error\n$stackTrace');
      }
      return ResultFactory.failure('즐겨찾기 토글 중 오류 발생: $error');
    }
  }

  /// 상태 초기화
  ///
  /// [suggestedQuestions] 초기 제안 질문들
  /// [return] 초기화된 상태
  static Result<AiChatState> initializeState({
    List<AiSuggestedQuestionEntity> suggestedQuestions = const [],
  }) {
    try {
      final initialState = AiChatState(
        suggestedQuestions: suggestedQuestions,
      );

      if (kDebugMode) {
        debugPrint('[$_tag] 🔄 State initialized with ${suggestedQuestions.length} suggestions');
      }

      return ResultFactory.success(initialState, 'State initialized');

    } catch (error) {
      return ResultFactory.failure('상태 초기화 중 오류 발생: $error');
    }
  }

  /// 상태 검증 및 정리
  ///
  /// [currentState] 검증할 상태
  /// [return] 정리된 상태
  static Result<AiChatState> validateAndCleanState(AiChatState currentState) {
    try {
      final issues = <String>[];
      bool needsUpdate = false;

      // 1. 메시지 상태 검증
      var validatedMessages = currentState.messages;
      final messageCleanupResult = AiMessageManager.cleanupMessages(validatedMessages);

      if (messageCleanupResult.isSuccess &&
          messageCleanupResult.dataOrNull!.length != validatedMessages.length) {
        validatedMessages = messageCleanupResult.dataOrNull!;
        needsUpdate = true;
        issues.add('메시지 목록 정리됨');
      }

      // 2. 즐겨찾기 상태 검증
      final favoriteValidationResult = AiFavoriteManager.validateFavoriteState(
        favoriteIds: currentState.favoriteMessageIds,
        favoriteQAs: currentState.favoriteQAs,
      );

      if (favoriteValidationResult.isSuccess &&
          !favoriteValidationResult.dataOrNull!.isValid) {
        issues.addAll(favoriteValidationResult.dataOrNull!.issues);
        needsUpdate = true;
      }

      // 3. 상태 일관성 검증
      if (currentState.hasPetSelected && currentState.selectedPet == null) {
        issues.add('펫 선택 상태 불일치');
        needsUpdate = true;
      }

      if (currentState.hasCategorySelected && currentState.selectedCategory == null) {
        issues.add('카테고리 선택 상태 불일치');
        needsUpdate = true;
      }

      // 4. 메모리 상태 체크
      final memoryStatus = AiMessageManager.checkMemoryStatus(validatedMessages);
      if (memoryStatus.shouldCleanup) {
        issues.add(memoryStatus.recommendation);
      }

      // 5. 업데이트된 상태 생성
      var updatedState = currentState;
      if (needsUpdate) {
        updatedState = currentState.copyWith(
          messages: validatedMessages,
          hasPetSelected: currentState.selectedPet != null,
          hasCategorySelected: currentState.selectedCategory != null,
        );
      }

      final validationSummary = StateValidationSummary(
        isValid: issues.isEmpty,
        issues: issues,
        wasUpdated: needsUpdate,
        memoryStatus: memoryStatus,
      );

      if (kDebugMode && issues.isNotEmpty) {
        debugPrint('[$_tag] ⚠️ State validation issues: ${issues.length}');
        for (final issue in issues) {
          debugPrint('[$_tag]   - $issue');
        }
      }

      // 결과 데이터에 검증 요약 포함
      final resultData = StateValidationResult(
        state: updatedState,
        summary: validationSummary,
      );

      return ResultFactory.success(
        resultData.state,
        needsUpdate ? 'State validated and updated' : 'State validation passed',
      );

    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error validating state: $error\n$stackTrace');
      }
      return ResultFactory.failure('상태 검증 중 오류 발생: $error');
    }
  }

  /// 에러 상태 설정
  ///
  /// [currentState] 현재 상태
  /// [error] 에러 메시지
  /// [clearTyping] 타이핑 상태 클리어 여부
  /// [return] 에러가 설정된 상태
  static Result<AiChatState> setErrorState({
    required AiChatState currentState,
    required String error,
    bool clearTyping = true,
  }) {
    try {
      final updatedState = currentState.copyWith(
        error: error,
        isTyping: clearTyping ? false : currentState.isTyping,
      );

      if (kDebugMode) {
        debugPrint('[$_tag] ❌ Error state set: $error');
      }

      return ResultFactory.success(updatedState, 'Error state updated');

    } catch (error) {
      return ResultFactory.failure('에러 상태 설정 중 오류 발생: $error');
    }
  }

  /// 상태 스냅샷 생성 (디버깅/분석용)
  ///
  /// [currentState] 스냅샷을 생성할 상태
  /// [return] 상태 스냅샷
  static StateSnapshot createSnapshot(AiChatState currentState) {
    try {
      final messageStats = AiMessageManager.generateStatistics(currentState.messages);
      final favoriteStats = AiFavoriteManager.generateStatistics(currentState.favoriteQAs);
      final memoryStatus = AiMessageManager.checkMemoryStatus(currentState.messages);

      return StateSnapshot(
        timestamp: DateTime.now(),
        messageCount: currentState.messages.length,
        favoriteCount: currentState.favoriteQAs.length,
        hasSelectedPet: currentState.selectedPet != null,
        hasSelectedCategory: currentState.selectedCategory != null,
        isTyping: currentState.isTyping,
        hasError: currentState.error != null,
        messageStats: messageStats,
        favoriteStats: favoriteStats,
        memoryStatus: memoryStatus,
        suggestedQuestionsCount: currentState.suggestedQuestions.length,
      );

    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error creating snapshot: $error');
      }
      return StateSnapshot.empty();
    }
  }
}

/// 상태 검증 결과
class StateValidationResult {
  final AiChatState state;
  final StateValidationSummary summary;

  const StateValidationResult({
    required this.state,
    required this.summary,
  });
}

/// 상태 검증 요약
class StateValidationSummary {
  final bool isValid;
  final List<String> issues;
  final bool wasUpdated;
  final MemoryStatus memoryStatus;

  const StateValidationSummary({
    required this.isValid,
    required this.issues,
    required this.wasUpdated,
    required this.memoryStatus,
  });

  @override
  String toString() {
    return 'StateValidationSummary('
           'valid: $isValid, '
           'issues: ${issues.length}, '
           'updated: $wasUpdated'
           ')';
  }
}

/// 상태 스냅샷 (디버깅/분석용)
class StateSnapshot {
  final DateTime timestamp;
  final int messageCount;
  final int favoriteCount;
  final bool hasSelectedPet;
  final bool hasSelectedCategory;
  final bool isTyping;
  final bool hasError;
  final MessageStatistics messageStats;
  final FavoriteStatistics favoriteStats;
  final MemoryStatus memoryStatus;
  final int suggestedQuestionsCount;

  const StateSnapshot({
    required this.timestamp,
    required this.messageCount,
    required this.favoriteCount,
    required this.hasSelectedPet,
    required this.hasSelectedCategory,
    required this.isTyping,
    required this.hasError,
    required this.messageStats,
    required this.favoriteStats,
    required this.memoryStatus,
    required this.suggestedQuestionsCount,
  });

  factory StateSnapshot.empty() {
    final now = DateTime.now();
    return StateSnapshot(
      timestamp: now,
      messageCount: 0,
      favoriteCount: 0,
      hasSelectedPet: false,
      hasSelectedCategory: false,
      isTyping: false,
      hasError: false,
      messageStats: const MessageStatistics(
        totalMessages: 0,
        userMessages: 0,
        assistantMessages: 0,
        totalCharacters: 0,
        memoryUsageBytes: 0,
        memoryUsageMB: 0.0,
        isMemoryHigh: false,
        needsCleanup: false,
      ),
      favoriteStats: FavoriteStatistics.empty(),
      memoryStatus: MemoryStatus.safe(),
      suggestedQuestionsCount: 0,
    );
  }

  @override
  String toString() {
    return 'StateSnapshot('
           'messages: $messageCount, '
           'favorites: $favoriteCount, '
           'pet: $hasSelectedPet, '
           'category: $hasSelectedCategory, '
           'typing: $isTyping, '
           'error: $hasError'
           ')';
  }
}