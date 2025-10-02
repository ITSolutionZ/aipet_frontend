import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class AiFavoriteCardWidget extends StatelessWidget {
  final AiFavoriteQaEntity favoriteQA;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const AiFavoriteCardWidget({
    super.key,
    required this.favoriteQA,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GenericInfoCard.withIcon(
      icon: Icons.star,
      iconColor: Colors.amber,
      iconBackgroundColor: Colors.amber.withValues(alpha: 0.1),
      title: _truncateText(favoriteQA.question, 40),
      subtitle: _formatDateTime(favoriteQA.createdAt),
      badge: favoriteQA.categoryName ?? 'AI',
      badgeColor: AppColors.pointBrown,
      trailing: _buildTrailing(context),
      onTap: onTap,
      onLongPress: onLongPress,
      showChevron: onTap != null,
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (favoriteQA.pet?.name != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.pointBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Text(
              favoriteQA.pet!.name,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBlue,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 16, color: AppColors.pointGray),
          onSelected: (value) {
            switch (value) {
              case 'share':
                onShare?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.share, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text('共有', style: AppFonts.bodySmall),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete, size: 16, color: AppColors.pointPink),
                  const SizedBox(width: AppSpacing.sm),
                  Text('削除', style: AppFonts.bodySmall.copyWith(color: AppColors.pointPink)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '今日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
