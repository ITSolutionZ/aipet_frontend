import 'dart:async';

import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/ai/data/providers/ai_usecase_providers.dart';
import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
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
  ///
  /// ## 로드되는 데이터
  /// - 추천 질문 목록
  /// - 즐겨찾기 메시지 목록
  /// - 저장된 채팅 히스토리 (선택사항)
  ///
  /// ## 상태 초기화
  /// - 모든 선택 상태를 초기값으로 리셋
  /// - 에러 상태 클리어
  /// - 빈 메시지 목록으로 시작
  Future<void> initializeChat() async {
    final useCase = ref.read(initializeChatUseCaseProvider);

    final result = await useCase();

    if (result.isSuccess && result.dataOrNull != null) {
      state = state.copyWith(
        messages: <AiMessageEntity>[],
        suggestedQuestions: result.dataOrNull!,
        favoriteQAs: <AiFavoriteQaEntity>[],
        favoriteMessageIds: <String>[],
        selectedPet: null,
        hasPetSelected: false,
        selectedCategory: null,
        hasCategorySelected: false,
        error: null,
      );
    } else {
      state = state.copyWith(error: result.errorOrNull);
    }
  }

  /// 펫 선택 처리
  ///
  /// 사용자가 펫을 선택했을 때의 처리 로직입니다.
  ///
  /// ## 처리 과정
  /// 1. 선택된 펫 정보를 상태에 저장
  /// 2. 사용자 메시지로 "펫에 대해 상담하고 싶다" 메시지 추가
  /// 3. AI 응답으로 카테고리 선택 안내 메시지 추가
  /// 4. 상태 업데이트 (hasPetSelected = true)
  ///
  /// ## 매개변수
  /// - [pet] 선택된 펫 프로필 정보 (null이면 선택 해제)
  void selectPet(PetProfileEntity? pet) {
    final useCase = ref.read(selectPetUseCaseProvider);
    final result = useCase(pet);

    if (result.isSuccess && result.dataOrNull != null && pet != null) {
      final updatedMessages = [...state.messages, ...result.dataOrNull!];
      state = state.copyWith(
        selectedPet: pet,
        hasPetSelected: true,
        messages: updatedMessages,
      );
    } else if (pet == null) {
      state = state.copyWith(selectedPet: pet, hasPetSelected: true);
    } else {
      state = state.copyWith(error: result.errorOrNull);
    }
  }

  Future<void> selectCategory(AiCategoryEntity category) async {
    final useCase = ref.read(selectCategoryUseCaseProvider);

    final result = await useCase(
      category: category,
      selectedPet: state.selectedPet,
    );

    if (result.isSuccess && result.dataOrNull != null) {
      final updatedMessages = [...state.messages, ...result.dataOrNull!.messages];

      state = state.copyWith(
        selectedCategory: category,
        hasCategorySelected: true,
        messages: updatedMessages,
        suggestedQuestions: result.dataOrNull!.suggestedQuestions,
      );
    } else {
      state = state.copyWith(error: result.errorOrNull);
    }
  }

  Future<void> toggleFavorite(AiMessageEntity message) async {
    final useCase = ref.read(favoriteMessageUseCaseProvider);
    final favoriteIds = List<String>.from(state.favoriteMessageIds);
    final favoriteQAs = List<AiFavoriteQaEntity>.from(state.favoriteQAs);

    if (favoriteIds.contains(message.id)) {
      final result = await useCase.removeFavorite(message.id);
      if (result.isSuccess) {
        favoriteIds.remove(message.id);
        favoriteQAs.removeWhere((qa) => qa.id == message.id);
        state = state.copyWith(
          favoriteMessageIds: favoriteIds,
          favoriteQAs: favoriteQAs,
        );
      }
    } else {
      String userQuestion = '質問を見つけられませんでした';
      final messageIndex = state.messages.indexWhere((m) => m.id == message.id);
      if (messageIndex > 0) {
        final previousMessage = state.messages[messageIndex - 1];
        if (previousMessage.type == MessageType.user) {
          userQuestion = previousMessage.content;
        }
      }

      final result = await useCase.addFavorite(
        message: message,
        category: state.selectedCategory?.id ?? 'general',
        petId: state.selectedPet?.id,
        petName: state.selectedPet?.name,
      );

      if (result.isSuccess) {
        favoriteIds.add(message.id);
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
        state = state.copyWith(
          favoriteMessageIds: favoriteIds,
          favoriteQAs: favoriteQAs,
        );
      }
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

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages, isTyping: true);

    final result = await useCase.callWithPetContext(
      content.trim(),
      petContext: state.selectedPet,
    );

    if (result.isSuccess && result.dataOrNull != null) {
      final finalMessages = [...state.messages, result.dataOrNull!];
      state = state.copyWith(
        messages: finalMessages,
        isTyping: false,
        error: null,
      );
    } else {
      state = state.copyWith(isTyping: false, error: result.errorOrNull);
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

  Future<void> clearChatHistory({bool saveBeforeClear = true}) async {
    try {
      if (saveBeforeClear && state.messages.isNotEmpty) {
        await saveCurrentChatToHistory();
      }

      final clearUseCase = ref.read(clearChatHistoryUseCaseProvider);
      final clearResult = await clearUseCase();

      if (clearResult.isSuccess) {
        state = const AiChatState();

        final initUseCase = ref.read(initializeChatUseCaseProvider);
        final initResult = await initUseCase();

        if (initResult.isSuccess && initResult.dataOrNull != null) {
          state = state.copyWith(suggestedQuestions: initResult.dataOrNull!);
        }
      } else {
        state = state.copyWith(error: clearResult.errorOrNull);
      }
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

  Future<Result<void>> initializeChat() async {
    return await wrapAsync(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.initializeChat();
      },
      successMessage: 'チャットが初期化されました',
      failureMessage: 'チャット初期化に失敗しました',
    );
  }

  /// 펫 선택
  void selectPet(PetProfileEntity? pet) {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    notifier.selectPet(pet);
  }

  Future<Result<void>> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      return validationError('メッセージが空です');
    }

    return await wrapAsync(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.sendMessage(content);
      },
      successMessage: 'メッセージが送信されました',
      failureMessage: 'メッセージの送信に失敗しました',
    );
  }

  Future<Result<void>> clearChatHistory() async {
    return await wrapAsync(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.clearChatHistory();
      },
      successMessage: 'チャット履歴がクリアされました',
      failureMessage: 'チャット履歴のクリアに失敗しました',
    );
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
  Future<void> toggleFavorite(AiMessageEntity message) async {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    await notifier.toggleFavorite(message);
  }

  Future<Result<void>> saveCurrentChatManually() async {
    return await wrapAsync(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.saveCurrentChatToHistory(isManualSave: true);
      },
      successMessage: 'チャット履歴が保存されました',
      failureMessage: 'チャット履歴の保存に失敗しました',
    );
  }

  Future<Result<void>> saveCurrentChatOnTabSwitch() async {
    return await wrapAsync(
      () async {
        final notifier = ref.read(aiChatNotifierProvider.notifier);
        await notifier.saveCurrentChatToHistory(isManualSave: false);
      },
      successMessage: 'チャット履歴が自動保存されました',
      failureMessage: 'チャット履歴の自動保存に失敗しました',
    );
  }
}
