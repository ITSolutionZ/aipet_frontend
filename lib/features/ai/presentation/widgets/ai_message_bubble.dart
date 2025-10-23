import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';

import '../../domain/domain.dart';

/// AI 채팅 메시지 버블 위젯
class AiMessageBubble extends ConsumerWidget {
  final AiMessageEntity message;
  final Future<void> Function(AiMessageEntity)? onFavoriteToggle;
  final bool isFavorite;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.isUser;
    // UserProfile 관련 코드는 현재 구현되지 않음
    // 향후 사용자 프로필 기능이 필요하면 구현 예정
    // final userProfileAsync = ref.watch(userProfileNotifierProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pointBrown,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/logos/aipet_white.png',
                width: 18,
                height: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: !isUser && onFavoriteToggle != null
                  ? () => _showFavoriteDialog(context)
                  : null,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.pointBrown : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isUser
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                    bottomRight: isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                  ),
                  border: isFavorite && !isUser
                      ? Border.all(color: AppColors.pointBrown, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메시지 내용
                    Text(
                      message.content,
                      style: AppFonts.bodySmall.copyWith(
                        color: isUser ? Colors.white : AppColors.pointDark,
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 하단 메타 정보 (시간, 즐겨찾기 등)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: AppFonts.bodySmall.copyWith(
                            color: isUser
                                ? Colors.white70
                                : AppColors.pointGray,
                            fontSize: 10,
                          ),
                        ),
                        if (isFavorite && !isUser) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppColors.pointBrown,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.pointGray,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFavoriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'お気に入りに追加',
              style: AppFonts.titleMedium.copyWith(color: AppColors.pointDark),
            ),
          ],
        ),
        content: Text(
          'この回答をお気に入りに追加しますか？\n後で参考リストから確認できます。',
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
            onPressed: () async {
              Navigator.of(context).pop();
              await onFavoriteToggle?.call(message);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '追加する',
              style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
