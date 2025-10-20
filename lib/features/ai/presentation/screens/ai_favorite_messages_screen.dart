import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../controllers/ai_chat_controller.dart';
import '../controllers/ai_favorite_messages_controller.dart';
import '../widgets/favorite_message_widgets.dart';

/// AI 즐겨찾기 질문-답변 목록 화면 (펫별 그룹화)
class AiFavoriteMessagesScreen extends ConsumerWidget {
  const AiFavoriteMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);
    final favoriteController = ref.read(aiFavoriteMessagesControllerProvider);

    // 채팅 상태에서 즐겨찾기 QA 목록 가져오기
    final favoriteQAs = chatState.favoriteQAs;

    // 펫별로 그룹화
    final groupedFavorites = favoriteController.groupFavoritesByPet(
      favoriteQAs,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pointBrown,
        elevation: 0,
        title: null,
        actions: [
          if (favoriteQAs.isNotEmpty)
            IconButton(
              onPressed: () => _showClearAllDialog(context, ref),
              icon: const Icon(Icons.clear_all, color: AppColors.pointDark),
              tooltip: '全てクリア',
            ),
        ],
      ),
      body: SafeArea(
        child: favoriteQAs.isEmpty
            ? const EmptyFavoritesWidget()
            : _buildFavoritesList(groupedFavorites, ref, favoriteController),
      ),
    );
  }

  Widget _buildFavoritesList(
    Map<String, List<AiFavoriteQaEntity>> groupedFavorites,
    WidgetRef ref,
    AiFavoriteMessagesController controller,
  ) {
    final petGroups = groupedFavorites.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: petGroups.length,
      itemBuilder: (context, index) {
        final petGroup = petGroups[index];
        final favorites = petGroup.value;
        final displayName = favorites.first.petDisplayName;

        return PetSectionCard(
          petName: displayName,
          favorites: favorites,
          formatTime: controller.formatTime,
          getLatestActivityText: controller.getLatestActivityText,
          buildQAAccordion: (favorite, isLast) => QAAccordionCard(
            favorite: favorite,
            isLast: isLast,
            onDelete: () => _showDeleteDialog(favorite, ref),
            onCopy: () => controller.copyToClipboard(favorite.answer),
            onShare: () => controller.shareQA(favorite),
          ),
        );
      },
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
          'このお気に入りを削除しますか?',
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
    ConfirmationDialogComponent.showClear(
      context: context,
      title: 'お気に入りクリア',
      message: '全てのお気に入りを削除しますか?\nこの操作は取り消せません。',
      onConfirm: () => _clearAllFavorites(ref),
    );
  }

  void _deleteFavorite(AiFavoriteQaEntity favorite, WidgetRef ref) {
    final notifier = ref.read(aiChatProvider.notifier);
    notifier.removeFavorite(favorite.id);
  }

  void _clearAllFavorites(WidgetRef ref) {
    final notifier = ref.read(aiChatProvider.notifier);
    notifier.clearAllFavorites();
  }
}
