import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI 채팅 히스토리 리스트 화면
class AiChatHistoryListScreen extends ConsumerStatefulWidget {
  const AiChatHistoryListScreen({super.key});

  @override
  ConsumerState<AiChatHistoryListScreen> createState() => _AiChatHistoryListScreenState();
}

class _AiChatHistoryListScreenState extends ConsumerState<AiChatHistoryListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredAllItems = [];
  List<Map<String, dynamic>> _filteredSavedItems = [];
  List<Map<String, dynamic>> _allHistoryItems = [];
  List<Map<String, dynamic>> _savedHistoryItems = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allHistoryItems = AiChatHistoryMockData.getChatHistorySessions();
    _savedHistoryItems = _allHistoryItems.where((item) => item['isManualSaved'] == true).toList();
    _filteredAllItems = _allHistoryItems;
    _filteredSavedItems = _savedHistoryItems;
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
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAllItems = _allHistoryItems;
        _filteredSavedItems = _savedHistoryItems;
      } else {
        _filteredAllItems = _allHistoryItems.where((item) {
          return _matchesQuery(item, query);
        }).toList();

        _filteredSavedItems = _savedHistoryItems.where((item) {
          return _matchesQuery(item, query);
        }).toList();
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(
        title: 'チャット履歴',
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: '戻る',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 탭바
            Container(
              color: Colors.white,
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
                labelStyle: AppFonts.titleSmall.copyWith(fontWeight: FontWeight.bold),
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
                  prefixIcon: const Icon(Icons.search, color: AppColors.pointGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(color: AppColors.pointGray.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: const BorderSide(color: AppColors.pointBrown),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // 탭뷰 컨텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(_filteredAllItems, 'すべて'),
                  _buildTabContent(_filteredSavedItems, '保存済み'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> items, String tabName) {
    return Column(
      children: [
        // 검색 결과 수 표시
        if (_searchController.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.pointGray),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$tabName: ${items.length}件のメッセージ',
                  style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                ),
              ],
            ),
          ),

        // 채팅 히스토리 리스트
        Expanded(
          child: items.isEmpty && _searchController.text.isNotEmpty
              ? _buildEmptySearchResult()
              : items.isEmpty
              ? _buildEmptyTab(tabName)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildHistoryItem(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tabName == '保存済み' ? Icons.bookmark_border : Icons.history,
            size: 80,
            color: AppColors.pointGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            tabName == '保存済み' ? '保存済みの会話がありません' : '会話履歴がありません',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tabName == '保存済み' ? 'チャット中に保存ボタンを押して\n会話を保存してください' : 'AIアシスタントと会話を始めると\n履歴が表示されます',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: InkWell(
        onTap: () => _openChatSession(item),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 정보
              Row(
                children: [
                  _buildCategoryIcon(
                    item['categoryIcon'] as IconData,
                    item['categoryColor'] as Color,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHighlightedText(
                          item['title'] as String,
                          AppFonts.titleMedium.copyWith(
                            color: AppColors.pointDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(Icons.pets, size: 14, color: AppColors.pointGray),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              item['petName'] as String,
                              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (item['categoryColor'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Text(
                                item['category'] as String,
                                style: AppFonts.bodySmall.copyWith(
                                  color: item['categoryColor'] as Color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (item['hasFavorites'] as bool)
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // 요약 내용
              _buildHighlightedText(
                item['summary'] as String,
                AppFonts.bodyMedium.copyWith(color: AppColors.pointGray, height: 1.4),
              ),

              const SizedBox(height: AppSpacing.sm),

              // 메타 정보
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.pointGray.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatDateTime(item['lastMessageTime'] as DateTime),
                    style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: AppColors.pointGray.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${item['messageCount']}件のメッセージ',
                    style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Icon(iconData, size: 20, color: color),
    );
  }

  String _formatDateTime(DateTime dateTime) {
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

  Widget _buildHighlightedText(String text, TextStyle style) {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: style.copyWith(
            backgroundColor: AppColors.pointBrown.withValues(alpha: 0.2),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.pointGray.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text('検索結果が見つかりません', style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '「${_searchController.text}」に一致する\nチャット履歴がありません',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              _searchController.clear();
            },
            child: Text(
              '検索をクリア',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChatSession(Map<String, dynamic> item) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('「${item['title']}」のチャットを開きます'),
        backgroundColor: AppColors.pointBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
