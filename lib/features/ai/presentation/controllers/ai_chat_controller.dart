import 'dart:async';

import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/app/services/local_storage_service.dart';
import 'package:aipet_frontend/features/home/home.dart';
import 'package:aipet_frontend/features/walk/walk.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';

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

  AiChatState({
    this.messages = const [],
    MessageStatistics? messageStats,
    this.suggestedQuestions = const [],
    this.isTyping = false,
    this.error,
    this.selectedPet,
    this.hasPetSelected = false,
    this.selectedCategory,
    this.hasCategorySelected = false,
    this.favoriteMessageIds = const [],
    this.favoriteQAs = const [],
  }) : messageStats = messageStats ?? MessageStatistics.empty();

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
        messageStats ?? AiMessageManager.generateStatistics(updatedMessages);

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
    return AiChatState();
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

        // ✅ 즐겨찾기 로드 기능 비활성화
        // // 로컬 저장소에서 즐겨찾기 로드
        // try {
        //   // AiLocalStorageService를 직접 사용
        //   final aiLocalStorageService = AiLocalStorageService();
        //   final favoriteQAs = await aiLocalStorageService.loadFavoriteQAs();
        //   final favoriteIds = favoriteQAs.map((qa) => qa.id).toList();

        //   state = state.copyWith(
        //     favoriteMessageIds: favoriteIds,
        //     favoriteQAs: favoriteQAs,
        //   );

        //   LoggerService.debug('⭐ 즐겨찾기 로컬 저장소에서 로드 완료: ${favoriteQAs.length}개');
        // } catch (e) {
        //   LoggerService.debug('⭐ 즐겨찾기 로컬 저장소 로드 실패: $e');
        // }
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

    if (result.isSuccess && result.dataOrNull != null) {
      // pet이 null이어도 (일반 상담) 메시지 생성
      final updateResult = AiChatStateManager.updatePetSelection(
        currentState: state,
        pet: pet, // null 허용
        newMessages: result.dataOrNull!,
      );

      if (updateResult.isSuccess) {
        state = updateResult.dataOrNull!;
        LoggerService.debug('✅ ペット選択完了: ${pet == null ? "一般相談" : pet.name}');
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

  // ✅ 즐겨찾기 토글 기능 비활성화 (Notifier)
  // Future<void> toggleFavorite(AiMessageEntity message) async {
  //   // 사용자 질문 찾기
  //   String userQuestion = '質問を見つけられませんでした';
  //   final messageIndex = state.messages.indexWhere((m) => m.id == message.id);
  //   if (messageIndex > 0) {
  //     final previousMessage = state.messages[messageIndex - 1];
  //     if (previousMessage.type == MessageType.user) {
  //       userQuestion = previousMessage.content;
  //     }
  //   }

  //   final updateResult = AiChatStateManager.updateFavoriteToggle(
  //     currentState: state,
  //     message: message,
  //     userQuestion: userQuestion,
  //   );

  //   if (updateResult.isSuccess) {
  //     state = updateResult.dataOrNull!;

  //     // 로컬 저장소에 즐겨찾기 저장/삭제
  //     try {
  //       final aiLocalStorageService = AiLocalStorageService();
  //       final isCurrentlyFavorite = state.favoriteMessageIds.contains(
  //         message.id,
  //       );
  //       if (isCurrentlyFavorite) {
  //         // 즐겨찾기에 추가된 경우 - 로컬 저장소에 저장
  //         final favoriteQA = AiFavoriteQaEntity(
  //           id: message.id,
  //           question: userQuestion.trim(),
  //           answer: message.content.trim(),
  //           pet: state.selectedPet,
  //           categoryId: state.selectedCategory?.id,
  //           categoryName: state.selectedCategory?.name,
  //           createdAt: DateTime.now(),
  //           originalTimestamp: message.timestamp,
  //         );

  //         await aiLocalStorageService.saveFavoriteQA(favoriteQA);
  //         LoggerService.debug('⭐ 즐겨찾기 로컬 저장소에 저장 완료: ${message.id}');
  //       } else {
  //         // 즐겨찾기에서 제거된 경우 - 로컬 저장소에서 삭제
  //         await aiLocalStorageService.removeFavoriteQA(message.id);
  //         LoggerService.debug('⭐ 즐겨찾기 로컬 저장소에서 삭제 완료: ${message.id}');
  //       }
  //     } catch (e) {
  //       LoggerService.debug('⭐ 즐겨찾기 로컬 저장소 저장/삭제 실패: $e');
  //     }
  //   } else {
  //     state =
  //         AiChatStateManager.setErrorState(
  //           currentState: state,
  //           error: updateResult.error?.toString() ?? 'Update failed',
  //         ).dataOrNull ??
  //         state;
  //   }
  // }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    LoggerService.debug('📤 [AI Chat] ユーザーメッセージ送信開始');
    LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    LoggerService.debug('👤 ユーザー質問: "$content"');

    // ✅ 펫이 선택되지 않은 상태에서 메시지를 보내면 자동으로 일반 상담으로 처리
    if (!state.hasPetSelected) {
      LoggerService.debug('🔄 ペット未選択 → 自動的に一般相談モードに切り替え');
      selectPet(null); // 일반 상담 선택

      // selectPet이 state를 업데이트할 시간을 주기 위해 짧은 지연 추가
      await Future.delayed(const Duration(milliseconds: 100));
      LoggerService.debug('✅ 一般相談モードに設定完了');
    }

    LoggerService.debug('📊 現在の状態:');
    LoggerService.debug('   - ペット: ${state.selectedPet?.name ?? "一般相談"}');
    LoggerService.debug('   - カテゴリ: ${state.selectedCategory?.name ?? "未選択"}');
    LoggerService.debug('   - hasPetSelected: ${state.hasPetSelected}');
    LoggerService.debug(
      '   - hasCategorySelected: ${state.hasCategorySelected}',
    );

    final useCase = ref.read(sendMessageUseCaseProvider);

    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
      petId: state.selectedPet?.id,
      petName: state.selectedPet?.name,
    );

    LoggerService.debug('');
    LoggerService.debug('🔨 ユーザーメッセージエンティティ作成:');
    LoggerService.debug('   - ID: ${userMessage.id}');
    LoggerService.debug('   - 内容: "${userMessage.content}"');
    LoggerService.debug('   - ペットID: ${userMessage.petId ?? "なし"}');

    // 사용자 메시지를 데이터베이스에 저장
    try {
      LoggerService.debug('');
      LoggerService.debug('💾 データベースに保存中...');
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
      LoggerService.debug('✅ データベース保存成功');
    } catch (e) {
      LoggerService.debug('❌ データベース保存失敗: $e');
    }

    // 사용자 메시지 추가
    LoggerService.debug('');
    LoggerService.debug('📝 UI状態に追加中...');
    final userMessageResult = AiChatStateManager.updateMessageExchange(
      currentState: state,
      userMessage: userMessage,
      isTyping: true,
    );

    if (userMessageResult.isSuccess) {
      state = userMessageResult.dataOrNull!;
      LoggerService.debug('✅ UI状態更新成功 (メッセージ数: ${state.messages.length}件)');
      LoggerService.debug('✅ タイピングインジケーター表示開始');
    } else {
      LoggerService.debug('❌ UI状態更新失敗: ${userMessageResult.error}');
    }

    // 날씨 및 산책 정보 가져오기 (캐시된 데이터만 사용, 새로 업데이트하지 않음)
    String? weatherAdvice;
    String? walkGuide;

    try {
      // ✅ 날씨 정보가 필요한 질문인지 먼저 확인
      final needsWeatherContext = _isWeatherRelatedQuery(content);

      if (needsWeatherContext) {
        LoggerService.debug('');
        LoggerService.debug('🌤️ コンテキスト情報収集中... (天気関連の質問)');

        // ✅ 캐시된 대시보드 데이터만 읽기 (업데이트 트리거하지 않음)
        final dashboardAsync = ref.read(homeDashboardProvider);
        if (dashboardAsync.hasValue && dashboardAsync.value != null) {
          final dashboard = dashboardAsync.value!;
          final weather = dashboard.weather;

          // 날씨 어드바이스
          weatherAdvice = weather.dogWalkingRecommendation;
          if (weatherAdvice.length > 50) {
            LoggerService.debug(
              '   ✓ 天気アドバイス: ${weatherAdvice.substring(0, 50)}...',
            );
          } else {
            LoggerService.debug('   ✓ 天気アドバイス: $weatherAdvice');
          }

          // 산책 가이드 (펫이 선택되어 있을 때만)
          if (state.selectedPet != null) {
            final recommendationService = WalkRecommendationService();
            final recommendation = await ComputeWalkRecommendationUseCase()
                .call(
                  pet: state.selectedPet!,
                  wbgt: weather.wbgt,
                  temperature: weather.temperature,
                );

            walkGuide = recommendationService.generateShortGuide(
              recommendation,
            );
            if (walkGuide.length > 50) {
              LoggerService.debug(
                '   ✓ 散歩ガイド: ${walkGuide.substring(0, 50)}...',
              );
            } else {
              LoggerService.debug('   ✓ 散歩ガイド: $walkGuide');
            }
          }
        } else {
          LoggerService.debug('   ⚠️ 天気情報なし (キャッシュなし)');
        }
      } else {
        LoggerService.debug('');
        LoggerService.debug('ℹ️ 天気情報不要な質問 - コンテキスト収集スキップ');
      }
    } catch (e) {
      LoggerService.debug('   ❌ コンテキスト情報収集失敗: $e');
    }

    LoggerService.debug('');
    LoggerService.debug('🤖 AI API呼び出し開始...');
    LoggerService.debug('   - エンドポイント: callWithPetContext');
    LoggerService.debug('   - 質問内容: "${content.trim()}"');
    LoggerService.debug(
      '   - ペットコンテキスト: ${state.selectedPet != null ? "あり (${state.selectedPet!.name})" : "なし"}',
    );
    LoggerService.debug('   - 天気情報: ${weatherAdvice != null ? "あり" : "なし"}');
    LoggerService.debug('   - 散歩ガイド: ${walkGuide != null ? "あり" : "なし"}');

    final result = await useCase.callWithPetContext(
      content.trim(),
      petContext: state.selectedPet,
      weatherAdvice: weatherAdvice,
      walkGuide: walkGuide,
    );

    LoggerService.debug('');
    LoggerService.debug(
      '🤖 AI API呼び出し結果: ${result.isSuccess ? "✅ 成功" : "❌ 失敗"}',
    );
    if (!result.isSuccess) {
      LoggerService.debug('   エラー: ${result.error}');
    }

    if (result.isSuccess && result.dataOrNull != null) {
      final aiResponse = result.dataOrNull!;
      final responsePreview = aiResponse.content.length > 100
          ? '${aiResponse.content.substring(0, 100)}...'
          : aiResponse.content;

      LoggerService.debug('');
      LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      LoggerService.debug('🤖 [AI Chat] AI応答受信完了');
      LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      LoggerService.debug('🤖 AI応答内容: "$responsePreview"');
      LoggerService.debug('   - 応答ID: ${aiResponse.id}');
      LoggerService.debug('   - 応答長さ: ${aiResponse.content.length}文字');

      // AI 응답을 데이터베이스에 저장
      try {
        LoggerService.debug('');
        LoggerService.debug('💾 AI応答をデータベースに保存中...');
        await LocalStorageService.instance.ai.saveChatMessage(
          conversationId: _getCurrentConversationId(),
          message: aiResponse.content,
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
        LoggerService.debug('✅ データベース保存成功');
      } catch (e) {
        LoggerService.debug('❌ データベース保存失敗: $e');
      }

      // AI 응답 추가
      LoggerService.debug('');
      LoggerService.debug('📝 UI状態に追加中...');
      final assistantMessageResult = AiChatStateManager.updateMessageExchange(
        currentState: state,
        assistantMessage: aiResponse,
        isTyping: false,
      );

      if (assistantMessageResult.isSuccess) {
        state = assistantMessageResult.dataOrNull!;
        LoggerService.debug('✅ UI状態更新成功 (メッセージ数: ${state.messages.length}件)');
        LoggerService.debug('✅ タイピングインジケーター非表示');
        LoggerService.debug('');
        LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        LoggerService.debug('✅ [AI Chat] メッセージ送受信完了');
        LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      } else {
        LoggerService.debug('❌ UI状態更新失敗: ${assistantMessageResult.error}');
        LoggerService.debug('');
        LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        LoggerService.debug('❌ [AI Chat] メッセージ送信失敗 (UI更新エラー)');
        LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
      LoggerService.debug('');
      LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      LoggerService.debug('❌ [AI Chat] AI API呼び出し失敗');
      LoggerService.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      LoggerService.debug('❌ エラー詳細: ${result.error}');
      LoggerService.debug('');
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
  // ✅ 즐겨찾기 삭제 기능 비활성화
  // void removeFavorite(String favoriteId) {
  //   final removeResult = AiFavoriteManager.removeFromFavorites(
  //     currentFavoriteIds: state.favoriteMessageIds,
  //     currentFavoriteQAs: state.favoriteQAs,
  //     messageId: favoriteId,
  //   );

  //   if (removeResult.isSuccess) {
  //     final result = removeResult.dataOrNull!;
  //     state = state.copyWith(
  //       favoriteMessageIds: result.favoriteIds,
  //       favoriteQAs: result.favoriteQAs,
  //     );
  //   }
  // }

  // ✅ 모든 즐겨찾기 삭제 기능 비활성화
  // /// 모든 즐겨찾기 삭제
  // void clearAllFavorites() {
  //   final clearResult = AiFavoriteManager.clearAllFavorites();
  //   if (clearResult.isSuccess) {
  //     final result = clearResult.dataOrNull!;
  //     state = state.copyWith(
  //       favoriteMessageIds: result.favoriteIds,
  //       favoriteQAs: result.favoriteQAs,
  //     );
  //   }
  // }

  // ✅ 히스토리 저장 기능 비활성화
  // Future<void> saveCurrentChatToHistory({bool isManualSave = false}) async {
  //   if (state.messages.isEmpty) return;

  //   final useCase = ref.read(saveChatHistoryUseCaseProvider);

  //   await useCase(
  //     messages: state.messages,
  //     selectedPet: state.selectedPet,
  //     selectedCategory: state.selectedCategory,
  //     isManualSave: isManualSave,
  //   );
  // }

  /// 현재 대화 ID 생성 또는 가져오기
  String _getCurrentConversationId() {
    // 현재 날짜를 기준으로 대화 ID 생성 (일별 대화)
    final now = DateTime.now();
    return ('conversation_${DateTimeUtils.formatDateKey(now).replaceAll('-', '_')}');
  }

  Future<void> clearChatHistory({bool saveBeforeClear = true}) async {
    try {
      // ✅ 히스토리 저장 기능 비활성화
      // if (saveBeforeClear && state.messages.isNotEmpty) {
      //   await saveCurrentChatToHistory();
      // }

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
              AiChatStateManager.initializeState().dataOrNull ?? AiChatState();
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
        LoggerService.debug(
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

  // ✅ 즐겨찾기 로드 기능 비활성화
  // /// ⭐ 로컬 저장소에서 즐겨찾기 다시 로드
  // Future<void> loadFavoritesFromStorage() async {
  //   try {
  //     final aiLocalStorageService = AiLocalStorageService();
  //     final favoriteQAs = await aiLocalStorageService.loadFavoriteQAs();
  //     final favoriteIds = favoriteQAs.map((qa) => qa.id).toList();

  //     state = state.copyWith(
  //       favoriteMessageIds: favoriteIds,
  //       favoriteQAs: favoriteQAs,
  //     );

  //     LoggerService.debug('⭐ 즐겨찾기 로드 완료: ${favoriteQAs.length}개');
  //   } catch (e) {
  //     LoggerService.debug('⭐ 즐겨찾기 로드 실패: $e');
  //   }
  // }

  /// 날씨 관련 질문인지 확인하는 헬퍼 메서드
  bool _isWeatherRelatedQuery(String query) {
    final lowerQuery = query.toLowerCase();

    // 날씨/산책 관련 키워드 (일본어/영어/한국어)
    final weatherKeywords = [
      // 일본어
      '天気', '天候', '気温', '暑', '寒', '雨', '雪', '風', '曇',
      '散歩', 'さんぽ', 'お散歩', '外出', '屋外',

      // 영어
      'weather', 'temperature', 'hot', 'cold', 'rain', 'snow', 'wind',
      'walk', 'walking', 'outside', 'outdoor', 'outdoors',
      'sunny', 'cloudy', 'rainy', 'windy', 'humid', 'humidity',
      'forecast', 'climate',

      // 한국어
      '날씨', '기온', '덥', '춥', '비', '눈', '바람', '흐림',
      '산책', '외출', '밖', '야외', '밖에',
      '맑', '흐', '습', '습도',
    ];

    // 하나라도 매칭되면 날씨 관련 질문으로 판단
    return weatherKeywords.any((keyword) => lowerQuery.contains(keyword));
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

  // ✅ 즐겨찾기 기능 비활성화
  // /// 즐겨찾기 토글
  // Future<void> toggleFavorite(AiMessageEntity message) async {
  //   final notifier = ref.read(aiChatProvider.notifier);
  //   await notifier.toggleFavorite(message);
  // }

  // ✅ 히스토리 저장 기능 비활성화
  // Future<Result<void>> saveCurrentChatManually() async {
  //   try {
  //     final notifier = ref.read(aiChatProvider.notifier);
  //     await notifier.saveCurrentChatToHistory(isManualSave: true);
  //     return Result.success('チャット履歴が保存されました', null);
  //   } catch (error) {
  //     return Result.failure('チャット履歴の保存に失敗しました: $error');
  //   }
  // }

  // Future<Result<void>> saveCurrentChatOnTabSwitch() async {
  //   try {
  //     final notifier = ref.read(aiChatProvider.notifier);
  //     await notifier.saveCurrentChatToHistory(isManualSave: false);
  //     return Result.success('チャット履歴が自動保存されました', null);
  //   } catch (error) {
  //     return Result.failure('チャット履歴の自動保存に失敗しました: $error');
  //   }
  // }
}
