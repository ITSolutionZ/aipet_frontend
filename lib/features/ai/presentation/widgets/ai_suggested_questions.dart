import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/ai_message_entity.dart';

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
                onTap: () => onQuestionTap(question.question),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(
                      color: AppColors.pointBrown.withValues(alpha: 0.3),
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
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        question.question,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark,
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
