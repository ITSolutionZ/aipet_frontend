import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 채팅 히스토리 아이템 카드
class ChatHistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String searchQuery;
  final String Function(DateTime) formatDateTime;
  final VoidCallback onTap;

  const ChatHistoryItemCard({
    required this.item,
    required this.searchQuery,
    required this.formatDateTime,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
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
                            const Icon(
                              Icons.pets,
                              size: 14,
                              color: AppColors.pointGray,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              item['petName'] as String,
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.pointGray,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (item['categoryColor'] as Color)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.small,
                                ),
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
                    const Icon(
                      Icons.star,
                      color: AppColors.pointBrown,
                      size: 18,
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // 요약 내용
              _buildHighlightedText(
                item['summary'] as String,
                AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointGray,
                  height: 1.4,
                ),
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
                    formatDateTime(item['lastMessageTime'] as DateTime),
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
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
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
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

  Widget _buildHighlightedText(String text, TextStyle style) {
    if (searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();

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
          text: text.substring(index, index + searchQuery.length),
          style: style.copyWith(
            backgroundColor: AppColors.pointBrown.withValues(alpha: 0.2),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + searchQuery.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}

/// 빈 탭 상태 위젯
class EmptyTabWidget extends StatelessWidget {
  final String tabName;

  const EmptyTabWidget({required this.tabName, super.key});

  @override
  Widget build(BuildContext context) {
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
            tabName == '保存済み'
                ? 'チャット中に保存ボタンを押して\n会話を保存してください'
                : 'AIアシスタントと会話を始めると\n履歴が表示されます',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 검색 결과 없음 위젯
class EmptySearchResultWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;

  const EmptySearchResultWidget({
    required this.searchQuery,
    required this.onClearSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.pointGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '検索結果が見つかりません',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '「$searchQuery」に一致する\nチャット履歴がありません',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onClearSearch,
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
}

/// 검색 결과 카운트 위젯
class SearchResultCountWidget extends StatelessWidget {
  final String tabName;
  final int count;

  const SearchResultCountWidget({
    required this.tabName,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: AppColors.pointGray),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$tabName: $count件のメッセージ',
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}
