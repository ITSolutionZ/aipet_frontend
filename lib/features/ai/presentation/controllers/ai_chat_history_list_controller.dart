import 'package:aipet_frontend/app/services/local_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_history_list_controller.g.dart';

/// AI 채팅 히스토리 상태
@immutable
class AiChatHistoryListState {
  final List<Map<String, dynamic>> allHistoryItems;
  final List<Map<String, dynamic>> savedHistoryItems;
  final List<Map<String, dynamic>> filteredAllItems;
  final List<Map<String, dynamic>> filteredSavedItems;
  final String searchQuery;
  final bool isLoading;

  const AiChatHistoryListState({
    this.allHistoryItems = const [],
    this.savedHistoryItems = const [],
    this.filteredAllItems = const [],
    this.filteredSavedItems = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  AiChatHistoryListState copyWith({
    List<Map<String, dynamic>>? allHistoryItems,
    List<Map<String, dynamic>>? savedHistoryItems,
    List<Map<String, dynamic>>? filteredAllItems,
    List<Map<String, dynamic>>? filteredSavedItems,
    String? searchQuery,
    bool? isLoading,
  }) {
    return AiChatHistoryListState(
      allHistoryItems: allHistoryItems ?? this.allHistoryItems,
      savedHistoryItems: savedHistoryItems ?? this.savedHistoryItems,
      filteredAllItems: filteredAllItems ?? this.filteredAllItems,
      filteredSavedItems: filteredSavedItems ?? this.filteredSavedItems,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// AI 채팅 히스토리 리스트 컨트롤러
@riverpod
class AiChatHistoryListNotifier extends _$AiChatHistoryListNotifier {
  @override
  AiChatHistoryListState build() {
    loadChatHistory();
    return const AiChatHistoryListState();
  }

  /// 채팅 히스토리 로드
  Future<void> loadChatHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final conversations = await LocalStorageService.instance.ai
          .getAllConversations();

      final allItems = conversations
          .map(
            (conv) => {
              'id': conv['conversation_id'],
              'title': 'AI チャット',
              'summary': '会話履歴',
              'lastMessage': '',
              'lastMessageTime': DateTime.parse(
                conv['last_message_time'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
              'timestamp': DateTime.parse(
                conv['last_message_time'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
              'isManualSaved': false,
              'petName': 'ペット',
              'category': '一般',
              'categoryName': '一般',
              'categoryIcon': Icons.chat,
              'categoryColor': AppColors.pointBrown,
              'hasFavorites': false,
              'messageCount': conv['message_count'] ?? 0,
            },
          )
          .toList();

      final savedItems = allItems
          .where((item) => item['isManualSaved'] == true)
          .toList();

      state = state.copyWith(
        allHistoryItems: allItems,
        savedHistoryItems: savedItems,
        filteredAllItems: allItems,
        filteredSavedItems: savedItems,
        isLoading: false,
      );
    } catch (e) {
      LoggerService.debug('Failed to load chat history: $e');
      state = state.copyWith(
        allHistoryItems: [],
        savedHistoryItems: [],
        filteredAllItems: [],
        filteredSavedItems: [],
        isLoading: false,
      );
    }
  }

  /// 검색어 업데이트 및 필터링
  void updateSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();

    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredAllItems: state.allHistoryItems,
        filteredSavedItems: state.savedHistoryItems,
      );
    } else {
      final filteredAll = state.allHistoryItems.where((item) {
        return _matchesQuery(item, lowerQuery);
      }).toList();

      final filteredSaved = state.savedHistoryItems.where((item) {
        return _matchesQuery(item, lowerQuery);
      }).toList();

      state = state.copyWith(
        searchQuery: query,
        filteredAllItems: filteredAll,
        filteredSavedItems: filteredSaved,
      );
    }
  }

  /// 검색어와 매칭 여부 확인
  bool _matchesQuery(Map<String, dynamic> item, String query) {
    final title = (item['title'] as String).toLowerCase();
    final summary = (item['summary'] as String).toLowerCase();
    final category = (item['category'] as String).toLowerCase();
    final petName = (item['petName'] as String).toLowerCase();

    return title.contains(query) ||
        summary.contains(query) ||
        category.contains(query) ||
        petName.contains(query);
  }

  /// 날짜/시간 포맷팅
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
