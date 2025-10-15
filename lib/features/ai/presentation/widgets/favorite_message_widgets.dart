import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 빈 즐겨찾기 상태 위젯
class EmptyFavoritesWidget extends StatelessWidget {
  const EmptyFavoritesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_border,
              size: 80,
              color: AppColors.pointBrown.withValues(alpha: 0.5),
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
}

/// 펫 섹션 카드
class PetSectionCard extends StatelessWidget {
  final String petName;
  final List<AiFavoriteQaEntity> favorites;
  final String Function(DateTime) formatTime;
  final String Function(List<AiFavoriteQaEntity>) getLatestActivityText;
  final Widget Function(AiFavoriteQaEntity, bool) buildQAAccordion;

  const PetSectionCard({
    required this.petName,
    required this.favorites,
    required this.formatTime,
    required this.getLatestActivityText,
    required this.buildQAAccordion,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: favorites.length <= 5,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: _buildHeader(),
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
                    child: buildQAAccordion(
                      favorite,
                      index == favorites.length - 1,
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

  Widget _buildHeader() {
    return Container(
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
                    petName.split(' ').first,
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
                              color: AppColors.pointBrown,
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
                            getLatestActivityText(favorites),
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
    );
  }
}

/// QA 아코디언 카드
class QAAccordionCard extends StatelessWidget {
  final AiFavoriteQaEntity favorite;
  final bool isLast;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const QAAccordionCard({
    required this.favorite,
    required this.isLast,
    required this.onDelete,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
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
            title: _buildQuestionSection(),
            children: [_buildAnswerSection()],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 질문 헤더
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.help_outline,
                color: AppColors.pointBlue,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '質問',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.pointRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.pointRed,
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
            color: AppColors.pointBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              color: AppColors.pointBlue.withValues(alpha: 0.2),
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
            const Icon(Icons.access_time, size: 14, color: AppColors.pointGray),
            const SizedBox(width: 4),
            Text(
              _formatTime(favorite.createdAt),
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
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
                    borderRadius: BorderRadius.circular(AppRadius.small),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '答弁 보기',
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
    );
  }

  Widget _buildAnswerSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
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
                    'assets/icons/logos/aipet_white.png',
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
                color: AppColors.pureWhite,
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
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('コピー'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.pointBrown,
                    side: BorderSide(color: AiColors.selectedBorderColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onShare,
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
    } else if (difference.inDays < 30) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
