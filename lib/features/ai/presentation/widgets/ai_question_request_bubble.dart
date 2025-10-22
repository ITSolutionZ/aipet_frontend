import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';

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
            child: Image.asset(
              'assets/icons/logos/aipet_white.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 메시지 버블
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                  // AI 메시지 텍스트
                  Text(
                    _getCategorySpecificTitle(),
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    _getCategorySpecificMessage(),
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

  String _getCategorySpecificTitle() {
    final petName = selectedPet?.name ?? 'ペット';

    switch (selectedCategory?.id) {
      case 'health':
        return '$petNameの健康について、どのような症状や心配事がありますか？';
      case 'food':
        return '$petNameの食事について、具体的にどんなことが気になりますか？';
      case 'behavior':
        return '$petNameの行動について、どのようなお悩みがありますか？';
      case 'grooming':
        return '$petNameのグルーミングについて、何かお困りのことはありますか？';
      case 'toilet':
        return '$petNameのトイレについて、どのような問題がありますか？';
      case 'recipe':
        return '$petNameの手作りレシピについて、何を知りたいですか？';
      case 'general':
        return '$petNameについて、何かご質問はありますか？';
      case 'others':
        return '$petNameについて、他に気になることはありますか？';
      default:
        return '${selectedCategory?.name ?? 'ペット'}について、どのような内容でしょうか？';
    }
  }

  String _getCategorySpecificMessage() {
    final petName = selectedPet?.name ?? 'ペット';
    final petAge = selectedPet != null ? '${selectedPet!.age}歳の' : '';
    final petType = selectedPet?.typeName ?? 'ペット';

    switch (selectedCategory?.id) {
      case 'health':
        return '$petAge$petTypeの$petNameの状況を詳しく教えてください。症状、期間、食欲の変化なども含めて説明していただけると、より正確なアドバイスができます。';
      case 'food':
        return '$petAge$petTypeの$petNameの体重や活動量も考慮して、最適な食事プランをご提案します。現在の食事状況を教えてください。';
      case 'behavior':
        return '$petAge$petTypeの$petNameの行動の詳細（いつ、どこで、どのような状況で起こるか）を教えてください。';
      case 'grooming':
        return '$petAge$petTypeの$petNameの毛質や皮膚の状態、現在のお手入れ方法を教えてください。';
      case 'toilet':
        return '$petAge$petTypeの$petNameの現在のトイレ状況と、具体的な問題を教えてください。';
      case 'recipe':
        return '$petAge$petTypeの$petNameに適した手作り料理のレシピをご提案します。好みやアレルギーがあれば教えてください。';
      default:
        return '$petNameの状況を具体的に教えてください。より正確なアドバイスを提供します。';
    }
  }

  Widget _buildQuestionExamples() {
    List<String> examples = [];

    // 디버그: 선택된 카테고리 확인
    debugPrint('Selected Category ID: ${selectedCategory?.id}');
    debugPrint('Selected Category Name: ${selectedCategory?.name}');

    // 카테고리별 질문 예시
    switch (selectedCategory?.id) {
      case 'health':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🏥 最近元気がないのですが',
          '🌡️ 体温が高いような気がします',
          '💊 ワクチンの接種時期について',
          '⚖️ 体重管理のアドバイスを',
          '🩺 定期検診の頻度を教えて',
        ];
        break;
      case 'food':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🍽️ 適切な食事量を教えて',
          '⏰ 食事の回数と時間帯について',
          '🚫 食べてはいけないものは？',
          '🥕 手作りフードのレシピを',
          '💊 サプリメントは必要ですか？',
        ];
        break;
      case 'behavior':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🎯 基本的なしつけ方法',
          '🔊 無駄吠えをやめさせたい',
          '🚶 散歩時の問題行動',
          '🏠 室内でのマナーについて',
          '😰 分離不安の対処法',
        ];
        break;
      case 'grooming':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '✂️ 毛玉の取り方を教えて',
          '🛁 お風呂の入れ方と頻度',
          '💅 爪切りのタイミング',
          '👂 耳掃除のやり方',
          '🦷 歯磨きのコツを教えて',
        ];
        break;
      case 'toilet':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🏠 トイレトレーニングのコツ',
          '💩 うんちの状態が気になります',
          '🚫 粗相をやめさせたい',
          '📍 トイレの場所を覚えない',
          '⏰ トイレのタイミングについて',
        ];
        break;
      case 'recipe':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🥘 簡単な手作りレシピを',
          '🥗 野菜を使ったメニュー',
          '🍖 お肉を使った料理',
          '🎂 特別な日のご飯',
          '🍼 子犬・子猫用の食事',
        ];
        break;
      case 'general':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🐾 新しいペットを迎える準備',
          '🛡️ ペット保険について',
          '🌡️ 季節ごとのケア方法',
          '👨‍⚕️ 良い獣医師の選び方',
          '📚 初心者向けのアドバイス',
        ];
        break;
      case 'others':
        examples = [
          '💡 こんなコトを聞いてみてください',
          '✈️ 旅行時のペットケア',
          '👴 高齢ペットのケア方法',
          '🏠 引っ越し時の注意点',
          '👶 赤ちゃんとペットの共生',
          '🎉 ストレス発散方法',
        ];
        break;
      default:
        examples = [
          '💡 こんなコトを聞いてみてください',
          '🏥 健康に関する心配事',
          '🍽️ 食事についてのアドバイス',
          '🎯 しつけや行動の相談',
          '✂️ お手入れの方法',
          '❓ その他気になることは？',
        ];
    }

    // 디버그: examples 배열 확인
    debugPrint('Examples count: ${examples.length}');
    for (int i = 0; i < examples.length; i++) {
      debugPrint('Example $i: ${examples[i]}');
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
    // 디버그: 질문 텍스트 확인
    debugPrint('Building question widget for: "$question"');

    // 이모지를 제거하여 실제 질문 텍스트만 추출 (전송용)
    final questionText = question.replaceAll(
      RegExp(
        r'^[🍽️🚶💊✂️🎯🚫🏠🏥🌡️💡⚖️🩺⏰🎯🔊🛁💅👂🦷💩📍🥘🥗🍖🎂🍼🐾🛡️📚✈️👴👶🎉❓]+\s*',
      ),
      '',
    );

    debugPrint('Cleaned question text: "$questionText"');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onQuestionTap != null
              ? () {
                  // 펫 이름을 포함한 완전한 질문으로 만들기 (이모지 포함된 원본 사용)
                  final petName = selectedPet?.name ?? 'ペット';
                  final fullQuestion = '$petNameの$question';
                  debugPrint('Sending question: "$fullQuestion"');
                  onQuestionTap!(fullQuestion);
                }
              : null,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
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
                    question, // 이모지 포함된 원본 질문 표시
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
