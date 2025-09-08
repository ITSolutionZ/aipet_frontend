import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../settings/data/providers/settings_providers.dart';
import '../../../settings/domain/entities/user_profile_entity.dart';
import '../../domain/entities/ai_message_entity.dart';

/// AI 채팅 메시지 버블 위젯
class AiMessageBubble extends ConsumerWidget {
  final AiMessageEntity message;
  final Function(AiMessageEntity)? onFavoriteToggle;
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
    final userProfileAsync = ref.watch(userProfileNotifierProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.pointBrown,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/logo_notinclude_text.png',
                width: 20,
                height: 20,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.pointBrown : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium).copyWith(
                    bottomLeft: isUser
                        ? const Radius.circular(AppRadius.medium)
                        : Radius.zero,
                    bottomRight: isUser
                        ? Radius.zero
                        : const Radius.circular(AppRadius.medium),
                  ),
                  border: isFavorite && !isUser
                      ? Border.all(color: Colors.amber, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
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
                      style: AppFonts.bodyMedium.copyWith(
                        color: isUser ? Colors.white : AppColors.pointDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // 하단 메타 정보 (시간, 즐겨찾기 등)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: AppFonts.bodySmall.copyWith(
                            color: isUser ? Colors.white70 : AppColors.pointGray,
                          ),
                        ),
                        if (isFavorite && !isUser)
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildUserAvatar(userProfileAsync),
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
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
              ),
            ),
          ],
        ),
        content: Text(
          'この回答をお気に入りに追加しますか？\n後で参考リストから確認できます。',
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
              onFavoriteToggle?.call(message);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '追加する',
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(AsyncValue<UserProfileEntity> userProfileAsync) {
    return Container(
      padding: const EdgeInsets.all(2), // 이미지 주변에 여백
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SizedBox(
          width: 28, // 16에서 28로 증가
          height: 28,
          child: userProfileAsync.when(
            data: (userProfile) {
              if (userProfile.avatarPath != null && userProfile.avatarPath!.isNotEmpty) {
                final file = File(userProfile.avatarPath!);
                if (file.existsSync()) {
                  return Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultUserIcon();
                    },
                  );
                }
              }
              return _buildDefaultUserIcon();
            },
            loading: () => _buildDefaultUserIcon(),
            error: (_, __) => _buildDefaultUserIcon(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultUserIcon() {
    return Container(
      color: AppColors.pointGray.withValues(alpha: 0.3),
      child: const Icon(
        Icons.person,
        color: AppColors.pointGray,
        size: 20, // 16에서 20으로 증가
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
