import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/ai_chat_history_list_controller.dart';
import '../widgets/chat_history_widgets.dart';

/// AI 채팅 히스토리 리스트 화면
class AiChatHistoryListScreen extends ConsumerStatefulWidget {
  const AiChatHistoryListScreen({super.key});

  @override
  ConsumerState<AiChatHistoryListScreen> createState() =>
      _AiChatHistoryListScreenState();
}

class _AiChatHistoryListScreenState
    extends ConsumerState<AiChatHistoryListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref
        .read(aiChatHistoryListProvider.notifier)
        .updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatHistoryListProvider);
    final notifier = ref.read(aiChatHistoryListProvider.notifier);

    // ✅ 디버그 로그 추가
    LoggerService.debug('📜 AiChatHistoryListScreen: Build');
    LoggerService.debug(
      '  - allHistoryItems count: ${state.allHistoryItems.length}',
    );
    LoggerService.debug(
      '  - savedHistoryItems count: ${state.savedHistoryItems.length}',
    );
    LoggerService.debug('  - isLoading: ${state.isLoading}');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pointBrown,
        elevation: 0,
        title: null,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          tooltip: '戻る',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 탭바
            Container(
              color: AppColors.pureWhite,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.pointDark,
                unselectedLabelColor: AppColors.pointGray,
                indicator: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppFonts.titleSmall,
                tabs: const [
                  Tab(height: 50, child: Text('すべて')),
                  Tab(height: 50, child: Text('保存済み')),
                ],
              ),
            ),

            // 검색 바
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'チャット履歴を検索...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.pointGray,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(
                      color: AppColors.pointGray.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: const BorderSide(color: AppColors.pointBrown),
                  ),
                  filled: true,
                  fillColor: AppColors.pureWhite,
                ),
              ),
            ),

            // 탭뷰 컨텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(
                    state.filteredAllItems,
                    'すべて',
                    state.searchQuery,
                    notifier.formatDateTime,
                  ),
                  _buildTabContent(
                    state.filteredSavedItems,
                    '保存済み',
                    state.searchQuery,
                    notifier.formatDateTime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    List<Map<String, dynamic>> items,
    String tabName,
    String searchQuery,
    String Function(DateTime) formatDateTime,
  ) {
    return Column(
      children: [
        // 검색 결과 수 표시
        if (searchQuery.isNotEmpty)
          SearchResultCountWidget(tabName: tabName, count: items.length),

        // 채팅 히스토리 리스트
        Expanded(
          child: items.isEmpty && searchQuery.isNotEmpty
              ? EmptySearchResultWidget(
                  searchQuery: searchQuery,
                  onClearSearch: () => _searchController.clear(),
                )
              : items.isEmpty
              ? EmptyTabWidget(tabName: tabName)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ChatHistoryItemCard(
                      item: item,
                      searchQuery: searchQuery,
                      formatDateTime: formatDateTime,
                      onTap: () => _openChatSession(item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openChatSession(Map<String, dynamic> item) {
    Navigator.of(context).pop();
    SnackBarService.showInfo(
      context,
      '「${item['title']}」のチャットを開きます',
      duration: const Duration(seconds: 2),
    );
  }
}
