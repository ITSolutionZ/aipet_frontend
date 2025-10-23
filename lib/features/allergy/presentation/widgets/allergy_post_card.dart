import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/domain.dart';

/// 알레르기 게시글 카드
class AllergyPostCard extends StatelessWidget {
  final AllergyPostEntity post;

  const AllergyPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 게시글 상세 화면으로 이동 (구현 예정)
            LoggerService.debug('게시글 상세 화면 이동: ${post.title}');
          },
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 게시글 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 알레르기 타입 뱃지
                      _buildTypeBadge(),

                      const SizedBox(height: AppSpacing.xs),

                      // 제목
                      Text(
                        post.title,
                        style: AppFonts.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pointDark,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // 작성자 및 날짜
                      Row(
                        children: [
                          Text(
                            post.authorNickname,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointDark.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            width: 1,
                            height: 12,
                            color: AppColors.pointDark.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _formatDate(post.createdAt),
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointDark.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // 조회수 및 댓글 수
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.pointDark.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(post.viewCount),
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointDark.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.comment_outlined,
                            size: 14,
                            color: AppColors.pointDark.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.commentCount.toString(),
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointDark.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 오른쪽: 이미지 (있는 경우)
                if (post.imageUrls.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: AppColors.pointDark.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.image,
                        color: AppColors.pointDark,
                      ),
                    ),
                  ),
                ],

                // 댓글 수 뱃지 (오른쪽 상단)
                const SizedBox(width: AppSpacing.sm),
                _buildCommentBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 알레르기 타입 뱃지
  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: post.hasAllergy
            ? const Color(0xFFFF6B9D).withValues(alpha: 0.1)
            : const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        post.allergyType.displayName,
        style: AppFonts.bodySmall.copyWith(
          color: post.hasAllergy
              ? const Color(0xFFFF6B9D)
              : const Color(0xFF4CAF50),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  /// 댓글 수 뱃지
  Widget _buildCommentBadge() {
    if (post.commentCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.pointBrown,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        post.commentCount.toString(),
        style: AppFonts.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return DateFormat('yy.MM.dd').format(date);
    }
  }

  /// 숫자 포맷팅 (천 단위 구분)
  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
