import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// AI 후속 질문 제안 버블
class AiFollowUpQuestionsBubble extends StatelessWidget {
  final PetProfileEntity? selectedPet;
  final AiCategoryEntity? selectedCategory;
  final Function(String)? onQuestionTap;

  const AiFollowUpQuestionsBubble({
    super.key,
    this.selectedPet,
    this.selectedCategory,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            padding: const const EdgeInsets.all(AppSpacing.sm),
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
          const const SizedBox(width: AppSpacing.sm),

          // 메시지 버블
          Flexible(
            child: Container(
              padding: const const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppRadius.medium,
                ).copyWith(bottomLeft: Radius.zero),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 후속 질문 제안 메시지
                  Text(
                    '他に気になることはありませんか？ 🤔',
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    '${selectedPet?.name ?? 'ペット'}について、さらに詳しくお聞かせください。',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 후속 질문 예시들
                  _buildFollowUpQuestions(),

                  const SizedBox(height: AppSpacing.sm),

                  // 타임스탬프
                  Text(
                    '今',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpQuestions() {
    final List<String> questions = _getFollowUpQuestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 こんな質問はいかがですか？',
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...questions.map((question) => _buildQuestionButton(question)),
      ],
    );
  }

  List<String> _getFollowUpQuestions() {
    // 카테고리별 후속 질문 생성
    switch (selectedCategory?.id) {
      case 'health':
        return ['🏥 定期検診の頻度について', '💊 予防接種のスケジュール', '⚖️ 適正体重の維持方法'];
      case 'food':
        return ['🍽️ おやつの適切な量', '🥗 手作りフードのレシピ', '⏰ 食事の回数と時間'];
      case 'behavior':
        return ['🎯 基本的なしつけ方法', '🏠 室内でのマナー', '😰 ストレス解消法'];
      case 'grooming':
        return ['✂️ 毛玉予防のコツ', '🛁 シャンプーの頻度', '💅 爪切りの注意点'];
      default:
        return ['🏥 健康管理について', '🍽️ 食事の相談', '🎯 しつけのアドバイス'];
    }
  }

  Widget _buildQuestionButton(String question) {
    return Container(
      margin: const const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onQuestionTap != null
              ? () {
                  final petName = selectedPet?.name ?? 'ペット';
                  final fullQuestion = '$petName の$question';
                  onQuestionTap!(fullQuestion);
                }
              : null,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            width: double.infinity,
            padding: const const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.pointBrown.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
