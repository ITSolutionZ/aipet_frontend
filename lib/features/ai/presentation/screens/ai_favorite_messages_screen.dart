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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.amber, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'お気に入り',
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
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
      List<AiFavoriteQaEntity> favorites) {
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
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
      Map<String, List<AiFavoriteQaEntity>> groupedFavorites, WidgetRef ref) {
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
      String petName, List<AiFavoriteQaEntity> favorites, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        children: [
          // 펫 정보 헤더
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
              ),
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
                      Text(
                        petName,
                        style: AppFonts.titleMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${favorites.length}件のお気に入り',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.pointGray,
                ),
              ],
            ),
          ),
          
          // 즐겨찾기 질문-답변 목록
          ...favorites.asMap().entries.map((entry) {
            final index = entry.key;
            final favorite = entry.value;
            return _buildQAAccordion(favorite, index == favorites.length - 1, ref);
          }),
        ],
      ),
    );
  }

  Widget _buildQAAccordion(AiFavoriteQaEntity favorite, bool isLast, WidgetRef ref) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(
              color: AppColors.pointGray.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          childrenPadding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.blue,
              size: 16,
            ),
          ),
          title: Text(
            favorite.question,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 12,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pointBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      favorite.categoryName!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointBrown,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing: GestureDetector(
            onTap: () {
              _showDeleteDialog(favorite, ref);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 16,
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: AppColors.pointBrown,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'AI回答',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    favorite.answer,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _copyToClipboard(favorite.answer);
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('コピー'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.pointBrown,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _shareQA(favorite);
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('共有'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.pointBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
              ),
            ),
          ],
        ),
        content: Text(
          'このお気に入りを削除しますか？',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'キャンセル',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointGray,
              ),
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
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
              ),
            ),
          ],
        ),
        content: Text(
          '全てのお気に入りを削除しますか？\nこの操作は取り消せません。',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'キャンセル',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointGray,
              ),
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
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
    
    final shareText = '''$petInfo

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
}