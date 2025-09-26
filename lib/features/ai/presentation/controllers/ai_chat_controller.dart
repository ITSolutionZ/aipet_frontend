import 'dart:async';

import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/ai/data/providers/ai_usecase_providers.dart';
import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_message_service.dart';
import 'package:aipet_frontend/features/ai/domain/services/ai_chat_state_persistence.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_controller_refactored.g.dart';

/// 🎯 리팩토링된 AI 채팅 컨트롤러
///
/// 책임 분리 원칙에 따라 UI 상태 관리에만 집중하는 슬림한 컨트롤러
///
/// ## 아키텍처 개선사항
/// - 🔄 단일 책임 원칙 준수 (UI 상태 관리만)
/// - 📦 의존성 주입을 통한 서비스 사용
/// - 🎯 비즈니스 로직을 Service 계층으로 분리
/// - 💾 상태 영속화를 별도 서비스로 분리
/// - 🧪 테스트 친화적 구조
@riverpod
class AiChatController extends _$AiChatController {
  // 🏗️ 의존성 주입된 서비스들
  late final AiMessageService _messageService;
  late final AiChatStatePersistence _statePersistence;

  // 🔄 타이머 및 스트림 관리
  Timer? _typingTimer;
  StreamSubscription? _messageSubscription;

  @override
  AiChatState build() {
    // 서비스 초기화
    _messageService = AiMessageService(ref);
    _statePersistence = AiChatStatePersistence();

    // 컨트롤러가 dispose될 때 리소스 정리
    ref.onDispose(_dispose);

    return const AiChatState();
  }

  /// ✅ 펫 선택
  Future<void> selectPet(PetProfile pet) async {
    if (state.selectedPet?.id == pet.id) return;

    // UI 상태 즉시 업데이트 (반응성)
    state = state.copyWith(
      selectedPet: pet,
      hasPetSelected: true,
      messages: [], // 펫 변경 시 메시지 초기화
    );

    // 백그라운드에서 상태 저장 및 관련 데이터 로드
    _saveSelectedPetState(pet);
    await _loadPetRelatedData(pet);
  }

  /// ✅ 카테고리 선택
  Future<void> selectCategory(AiCategoryEntity? category) async {
    state = state.copyWith(
      selectedCategory: category,
      hasCategorySelected: category != null,
    );

    // 상태 영속화
    await _statePersistence.saveSelectedCategory(category);

    // 제안 질문 새로고침
    if (state.selectedPet != null) {
      await _refreshSuggestedQuestions();
    }
  }

  /// ✅ 메시지 전송 (핵심 기능)
  Future<void> sendMessage(String message) async {
    if (!_isReadyToSend()) return;

    // 입력 검증
    final validationResult = _messageService.validateMessage(message);
    if (!validationResult.isSuccess) {
      _setError(validationResult.message);
      return;
    }

    // UI 상태 업데이트 (타이핑 시작)
    _setTyping(true);
    _clearError();

    try {
      // 메시지 서비스를 통한 전송
      final result = await _messageService.sendMessage(
        message: message,
        selectedPet: state.selectedPet!,
        selectedCategory: state.selectedCategory,
      );

      if (result.isSuccess) {
        // 성공 시 메시지 목록에 추가
        _addMessage(result.dataOrNull!);
        await _updateMessageStatistics();

        // 캐시 업데이트
        await _statePersistence.cacheRecentMessages(state.messages);
      } else {
        _setError(result.message);
      }
    } finally {
      _setTyping(false);
    }
  }

  /// ✅ 메시지를 즐겨찾기에 추가/제거
  Future<void> toggleFavoriteMessage(String messageId) async {
    final isFavorite = state.favoriteMessageIds.contains(messageId);
    final updatedFavorites = List<String>.from(state.favoriteMessageIds);

    if (isFavorite) {
      updatedFavorites.remove(messageId);
    } else {
      updatedFavorites.add(messageId);
    }

    state = state.copyWith(favoriteMessageIds: updatedFavorites);

    // 즐겨찾기 상태를 UseCase를 통해 영속화
    final toggleUseCase = ref.read(toggleFavoriteUseCaseProvider);
    await toggleUseCase(ToggleFavoriteParams(
      messageId: messageId,
      isFavorite: !isFavorite,
    ));
  }

  /// ✅ 채팅 기록 로드
  Future<void> loadChatHistory() async {
    if (state.selectedPet == null) return;

    try {
      final result = await _messageService.loadChatHistory(
        petId: state.selectedPet!.id,
        limit: 50,
      );

      if (result.isSuccess) {
        state = state.copyWith(messages: result.dataOrNull!);
        await _updateMessageStatistics();
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('채팅 기록 로드 중 오류가 발생했습니다');
    }
  }

  /// ✅ 캐시된 상태 복원
  Future<void> restorePersistedState() async {
    // 선택된 펫 복원
    final petIdResult = await _statePersistence.loadSelectedPetId();
    if (petIdResult.isSuccess && petIdResult.dataOrNull != null) {
      // 펫 데이터를 가져와서 설정
      // Note: 실제 구현에서는 펫 프로바이더에서 가져와야 함
    }

    // 선택된 카테고리 복원
    final categoryResult = await _statePersistence.loadSelectedCategory();
    if (categoryResult.isSuccess) {
      state = state.copyWith(
        selectedCategory: categoryResult.dataOrNull,
        hasCategorySelected: categoryResult.dataOrNull != null,
      );
    }

    // 캐시된 메시지 복원 (빠른 UI 표시용)
    final messagesResult = await _statePersistence.loadCachedMessages();
    if (messagesResult.isSuccess) {
      state = state.copyWith(messages: messagesResult.dataOrNull!);
      await _updateMessageStatistics();
    }
  }

  /// ✅ 상태 초기화
  void clearChatState() {
    state = const AiChatState();
    _statePersistence.clearAllChatState();
  }

  // 🔒 Private Helper Methods

  void _setTyping(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);

    // 타이핑 타이머 관리
    _typingTimer?.cancel();
    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          state = state.copyWith(isTyping: false);
        }
      });
    }
  }

  void _setError(String? error) {
    state = state.copyWith(error: error);
  }

  void _clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void _addMessage(AiMessageEntity message) {
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
  }

  bool _isReadyToSend() {
    return state.selectedPet != null && !state.isTyping;
  }

  Future<void> _saveSelectedPetState(PetProfile pet) async {
    await _statePersistence.saveSelectedPet(pet);
  }

  Future<void> _loadPetRelatedData(PetProfile pet) async {
    // 채팅 기록 로드
    await loadChatHistory();

    // 제안 질문 로드
    await _refreshSuggestedQuestions();
  }

  Future<void> _refreshSuggestedQuestions() async {
    if (state.selectedPet == null) return;

    final result = await _messageService.getSuggestedQuestions(
      pet: state.selectedPet!,
      category: state.selectedCategory,
    );

    if (result.isSuccess) {
      state = state.copyWith(suggestedQuestions: result.dataOrNull!);
    }
  }

  Future<void> _updateMessageStatistics() async {
    final stats = _messageService.calculateMessageStatistics(state.messages);
    state = state.copyWith(messageStats: stats);
  }

  void _dispose() {
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _messageService.dispose();
  }
}

/// 🎯 간소화된 AI 채팅 상태 (리팩토링 후)
///
/// 필수 UI 상태만 포함하도록 최적화
class AiChatState {
  final List<AiMessageEntity> messages;
  final MessageStatistics messageStats;
  final List<AiSuggestedQuestionEntity> suggestedQuestions;
  final bool isTyping;
  final String? error;
  final PetProfile? selectedPet;
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
      aiMessages: 0,
      totalWords: 0,
      averageResponseTimeMs: 0.0,
      lastMessageTime: null,
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
    PetProfile? selectedPet,
    bool? hasPetSelected,
    AiCategoryEntity? selectedCategory,
    bool? hasCategorySelected,
    List<String>? favoriteMessageIds,
    List<AiFavoriteQaEntity>? favoriteQAs,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      messageStats: messageStats ?? this.messageStats,
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