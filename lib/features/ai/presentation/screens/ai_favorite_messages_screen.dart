import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/ai_favorite_qa_entity.dart';
import '../controllers/ai_chat_controller.dart';

/// AI 즐겨찾기 질문-답변 목록 화면 (펫별 그룹화)
class AiFavoriteMessagesScreen extends ConsumerWidget {
  const AiFavoriteMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatNotifierProvider);

    // 임시로 빈 목록 사용 (향후 실제 데이터로 교체)
    final favoriteQAs = chatState.favoriteQAs;

    // 펫별로 그룹화
    final groupedFavorites = _groupFavoritesByPet(favoriteQAs);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(
        title: 'お気に入り',
        actions: [
          if (favoriteQAs.isNotEmpty)
            IconButton(
              onPressed: () => _showClearAllDialog(context, ref),
              icon: const Icon(Icons.clear_all),
              tooltip: '全てクリア',
            ),
        ],
      ),
      body: SafeArea(
        child: favoriteQAs.isEmpty
            ? _buildEmptyState()
            : _buildFavoritesList(groupedFavorites, ref),
      ),
    );
  }

  /// 펫별로 즐겨찾기를 그룹화
  Map<String, List<AiFavoriteQaEntity>> _groupFavoritesByPet(
    List<AiFavoriteQaEntity> favorites,
  ) {
    final grouped = <String, List<AiFavoriteQaEntity>>{};

    for (final favorite in favorites) {
      final key = favorite.petGroupKey;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(favorite);
    }

    // 각 그룹을 최신 순으로 정렬
    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_border,
              size: 80,
              color: Colors.amber.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'お気に入りがありません',
            style: AppFonts.titleLarge.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'AIの回答を長押しして\nお気に入りに追加できます',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    Map<String, List<AiFavoriteQaEntity>> groupedFavorites,
    WidgetRef ref,
  ) {
    final petGroups = groupedFavorites.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: petGroups.length,
      itemBuilder: (context, index) {
        final petGroup = petGroups[index];
        final favorites = petGroup.value;
        final displayName = favorites.first.petDisplayName;

        return _buildPetSection(displayName, favorites, ref);
      },
    );
  }

  Widget _buildPetSection(
    String petName,
    List<AiFavoriteQaEntity> favorites,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: favorites.length <= 5, // 5개 이하일 때만 기본 열림
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    petName.contains('一般的') ? Icons.help : Icons.pets,
                    color: AppColors.pointBrown,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          petName.split(' ').first, // 펫 이름만 추출 (종류 정보 제거)
                          style: AppFonts.titleMedium.copyWith(
                            color: AppColors.pointDark,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AiColors.favoriteBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${favorites.length}件',
                                    style: AppFonts.bodySmall.copyWith(
                                      color: AppColors.pointBrown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'のお気に入り',
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.pointGray,
                              ),
                            ),
                            if (favorites.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '•',
                                style: AppFonts.bodySmall.copyWith(
                                  color: AppColors.pointGray,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  _getLatestActivityText(favorites),
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.pointGray,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 확장 상태 표시
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AiColors.petSelectionBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.pointBrown,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          // 즐겨찾기 질문-답변 목록
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
              ),
              child: Column(
                children: favorites.asMap().entries.map((entry) {
                  final index = entry.key;
                  final favorite = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: _buildQAAccordion(
                      favorite,
                      index == favorites.length - 1,
                      ref,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQAAccordion(
    AiFavoriteQaEntity favorite,
    bool isLast,
    WidgetRef ref,
  ) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pointDark.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(AppSpacing.md),
            childrenPadding: EdgeInsets.zero,
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            // 질문 부분
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 질문 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '질문',
                      style: AppFonts.bodySmall.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // 삭제 버튼
                    GestureDetector(
                      onTap: () => _showDeleteDialog(favorite, ref),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // 질문 내용
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    favorite.question,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // 메타 정보
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.pointGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(favorite.createdAt),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                    if (favorite.categoryName != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pointBrown.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                          child: Text(
                            favorite.categoryName!,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointBrown,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // 펼치기/접기 안내
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '답변 보기',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointBrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more,
                          size: 16,
                          color: AppColors.pointBrown,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // 답변 부분
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 답변 헤더
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AiColors.favoriteBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Image.asset(
                              'assets/icons/logo_notinclude_text.png',
                              width: 20,
                              height: 20,
                              color: AppColors.pointBrown,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'AI 답변',
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.pointBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // 답변 내용
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          border: Border.all(
                            color: AppColors.pointBrown.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          favorite.answer,
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.pointDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // 액션 버튼들
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: AppSpacing.sm,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              _copyToClipboard(favorite.answer);
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('コピー'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.pointBrown,
                              side: BorderSide(
                                color: AiColors.selectedBorderColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _shareQA(favorite);
                            },
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text('共有'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(AiFavoriteQaEntity favorite, WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'お気に入りを削除',
              style: AppFonts.titleMedium.copyWith(color: AppColors.pointDark),
            ),
          ],
        ),
        content: Text(
          'このお気に入りを削除しますか？',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'キャンセル',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFavorite(favorite, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '削除する',
              style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '確認',
              style: AppFonts.titleMedium.copyWith(color: AppColors.pointDark),
            ),
          ],
        ),
        content: Text(
          '全てのお気に入りを削除しますか？\nこの操作は取り消せません。',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'キャンセル',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllFavorites(ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '削除する',
              style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteFavorite(AiFavoriteQaEntity favorite, WidgetRef ref) {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    notifier.removeFavorite(favorite.id);
  }

  void _clearAllFavorites(WidgetRef ref) {
    final notifier = ref.read(aiChatNotifierProvider.notifier);
    notifier.clearAllFavorites();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Note: スナックバーは ref.context を使って表示する必要があります
    // この場合、UI 側で適切に処理되도록 간단히 클リップボードに복사만 수행합니다
  }

  void _shareQA(AiFavoriteQaEntity favorite) {
    final petInfo = favorite.pet != null
        ? '【${favorite.pet!.name} (${favorite.pet!.typeName})】'
        : '【一般的なペット相談】';

    final shareText =
        '''$petInfo

質問: ${favorite.question}

回答: ${favorite.answer}

--- AI Pet アプリより ---''';

    Share.share(shareText);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  String _getLatestActivityText(List<AiFavoriteQaEntity> favorites) {
    if (favorites.isEmpty) return '';

    // 최신 즐겨찾기 찾기
    final latest = favorites.reduce(
      (current, next) =>
          current.createdAt.isAfter(next.createdAt) ? current : next,
    );

    return '最新: ${_formatTime(latest.createdAt)}';
  }
}
