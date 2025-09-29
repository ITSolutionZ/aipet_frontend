import 'package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// AI 추천 질문 위젯
class AiSuggestedQuestions extends StatelessWidget {
  final List<AiSuggestedQuestionEntity> questions;
  final Function(String) onQuestionTap;

  const AiSuggestedQuestions({
    super.key,
    required this.questions,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    // 디버그: 질문 목록 확인
    debugPrint(
      'AiSuggestedQuestions: Building with ${questions.length} questions',
    );
    for (int i = 0; i < questions.length; i++) {
      debugPrint(
        'Question $i: "${questions[i].question}" (icon: ${questions[i].icon})',
      );
    }

    return Container(
      padding: const const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 こんなコトを聞いてみてください',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: questions.map((question) {
              return GestureDetector(
                onTap: () {
                  debugPrint('Question tapped: "${question.question}"');
                  onQuestionTap(question.question);
                },
                child: Container(
                  padding: const const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        question.icon,
                        size: 16,
                        color: AppColors.pointBrown,
                      ),
                      const const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          question.question.isEmpty
                              ? 'No question text'
                              : question.question,
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.pointDark,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
