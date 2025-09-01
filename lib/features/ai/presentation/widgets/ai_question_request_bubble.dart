import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../../domain/entities/ai_category_entity.dart';

/// AI 메시지 버블 형태의 질문 요청 위젯
class AiQuestionRequestBubble extends StatelessWidget {
  final PetProfileEntity? selectedPet;
  final AiCategoryEntity? selectedCategory;
  final Function(String)? onQuestionTap;

  const AiQuestionRequestBubble({
    super.key,
    this.selectedPet,
    this.selectedCategory,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          
          // 메시지 버블
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium).copyWith(
                  bottomLeft: Radius.zero,
                ),
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
                  // AI 메시지 텍스트
                  Text(
                    '${selectedCategory?.name}について、どのような内容でしょうか？',
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  Text(
                    '${selectedPet?.name ?? 'ペット'}の状況を具体的に教えてください。より正確なアドバイスを提供します。',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // 질문 예시들
                  _buildQuestionExamples(),
                  
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

  Widget _buildQuestionExamples() {
    List<String> examples = [];
    
    // 카테고리별 질문 예시
    switch (selectedCategory?.id) {
      case 'health':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🍽️ お腹の調子が悪い',
          '🚶 散歩の時間はどれくらいかかりますか？',
          '💊 予防接種のスケジュールが気になります',
          '✂️ 毛づくりのマニュアル',
        ];
        break;
      case 'food':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🍽️ 適切なフードの量を教えて',
          '⏰ 食事の時間について',
          '🚫 食べてはいけないものは？',
          '💊 サプリメントについて',
        ];
        break;
      case 'training':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🎯 基本的なしつけ方法',
          '🚫 無駄吠えをやめさせたい',
          '🚶 散歩時の問題行動',
          '🏠 室内でのマナー',
        ];
        break;
      default:
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🍽️ お腹の調子が悪い',
          '🚶 散歩の時間はどれくらいかかりますか？',
          '💊 予防接種のスケジュールが気になります',
          '✂️ 毛づくりのマニュアル',
        ];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: examples.map((example) {
        if (example.startsWith('💡')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              example,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return _buildSuggestedQuestion(example);
        }
      }).toList(),
    );
  }

  Widget _buildSuggestedQuestion(String question) {
    // 아이콘을 제거하여 실제 질문 텍스트만 추출
    final questionText = question.replaceAll(RegExp(r'^[🍽️🚶💊✂️🎯🚫🏠]+\s*'), '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        onTap: onQuestionTap != null ? () {
          // 펫 이름을 포함한 완전한 질문으로 만들기
          final petName = selectedPet?.name ?? 'ペット';
          final fullQuestion = '$petNameの$questionText';
          onQuestionTap!(fullQuestion);
        } : null,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: onQuestionTap != null 
                ? AppColors.pointBrown.withValues(alpha: 0.1)
                : AppColors.pointBrown.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: onQuestionTap != null
                  ? AppColors.pointBrown.withValues(alpha: 0.2)
                  : AppColors.pointBrown.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            question,
            style: AppFonts.bodySmall.copyWith(
              color: onQuestionTap != null 
                  ? AppColors.pointBrown
                  : AppColors.pointDark,
            ),
          ),
        ),
      ),
    );
  }
}