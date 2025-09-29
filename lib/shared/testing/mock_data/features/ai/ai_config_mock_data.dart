import 'package:aipet_frontend/features/ai/ai.dart';
import 'package:flutter/material.dart';

/// AI 설정 관련 Mock 데이터 서비스
///
/// AI 카테고리, 추천 질문, 응답 템플릿과 관련된 Mock 데이터를 제공합니다.
class AiConfigMockData {
  /// AI 카테고리 Mock 데이터
  static List<AiCategoryEntity> getMockCategories() {
    return [
      const AiCategoryEntity(
        id: 'health',
        name: '健康',
        description: '病気、怪我、健康管理について',
        icon: Icons.medical_services,
        color: Colors.red,
      ),
      const AiCategoryEntity(
        id: 'feeding',
        name: '食事',
        description: '食事量、食事時間、おやつについて',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      const AiCategoryEntity(
        id: 'behavior',
        name: '行動',
        description: 'しつけ、行動習慣、トレーニング',
        icon: Icons.pets,
        color: Colors.blue,
      ),
      const AiCategoryEntity(
        id: 'grooming',
        name: 'グルーミング',
        description: 'お手入れ、毛づくろい、爪切り',
        icon: Icons.content_cut,
        color: Colors.purple,
      ),
      const AiCategoryEntity(
        id: 'exercise',
        name: '運動',
        description: '散歩、遊び、エクササイズ',
        icon: Icons.directions_walk,
        color: Colors.green,
      ),
    ];
  }

  /// AI 추천 질문 Mock 데이터
  static List<AiSuggestedQuestionEntity> getMockSuggestedQuestions() {
    return [
      // 건강 관련 질문들
      const AiSuggestedQuestionEntity(
        id: '1',
        question: 'ペットが食事を拒否する時はどうしたらいいですか？',
        category: 'health',
        icon: Icons.restaurant,
      ),
      const AiSuggestedQuestionEntity(
        id: '4',
        question: 'ワクチンの接種スケジュールを教えて',
        category: 'health',
        icon: Icons.medical_services,
      ),
      const AiSuggestedQuestionEntity(
        id: '9',
        question: '体重管理はどのように行えばいいですか？',
        category: 'health',
        icon: Icons.monitor_weight,
      ),
      const AiSuggestedQuestionEntity(
        id: '10',
        question: '定期健康診断の頻度はどのくらいですか？',
        category: 'health',
        icon: Icons.health_and_safety,
      ),

      // 식사 관련 질문들
      const AiSuggestedQuestionEntity(
        id: '6',
        question: '適切な食事量を教えてください',
        category: 'food',
        icon: Icons.scale,
      ),
      const AiSuggestedQuestionEntity(
        id: '11',
        question: '手作りフードのレシピを教えて',
        category: 'food',
        icon: Icons.restaurant_menu,
      ),
      const AiSuggestedQuestionEntity(
        id: '12',
        question: 'おやつの与え方と注意点は？',
        category: 'food',
        icon: Icons.cookie,
      ),

      // 행동 관련 질문들
      const AiSuggestedQuestionEntity(
        id: '3',
        question: 'ペットが夜泣きをやめないのですが？',
        category: 'behavior',
        icon: Icons.bedtime,
      ),
      const AiSuggestedQuestionEntity(
        id: '8',
        question: 'ペットが他の動物を怖がります',
        category: 'behavior',
        icon: Icons.psychology,
      ),
      const AiSuggestedQuestionEntity(
        id: '13',
        question: '無駄吠えをやめさせる方法は？',
        category: 'behavior',
        icon: Icons.volume_off,
      ),
      const AiSuggestedQuestionEntity(
        id: '14',
        question: 'トイレトレーニングのコツを教えて',
        category: 'toilet',
        icon: Icons.home,
      ),

      // 그루밍 관련 질문들
      const AiSuggestedQuestionEntity(
        id: '5',
        question: 'ペットの毛玉を取る方法は？',
        category: 'grooming',
        icon: Icons.content_cut,
      ),
      const AiSuggestedQuestionEntity(
        id: '15',
        question: 'お風呂の入れ方と頻度は？',
        category: 'grooming',
        icon: Icons.bathtub,
      ),
      const AiSuggestedQuestionEntity(
        id: '16',
        question: '爪切りのタイミングと方法は？',
        category: 'grooming',
        icon: Icons.content_cut,
      ),

      // 일반 상담 질문들
      const AiSuggestedQuestionEntity(
        id: '17',
        question: '新しいペットを迎える準備は？',
        category: 'general',
        icon: Icons.pets,
      ),
      const AiSuggestedQuestionEntity(
        id: '18',
        question: 'ペット保険について教えて',
        category: 'general',
        icon: Icons.shield,
      ),

      // 기타 질문들
      const AiSuggestedQuestionEntity(
        id: '19',
        question: '旅行時のペットケアはどうしたら？',
        category: 'others',
        icon: Icons.travel_explore,
      ),
      const AiSuggestedQuestionEntity(
        id: '20',
        question: '高齢ペットのケア方法は？',
        category: 'others',
        icon: Icons.elderly,
      ),
    ];
  }

  /// AI 응답 템플릿 Mock 데이터
  static Map<String, String> getMockResponseTemplates() {
    return {
      'food': '''🍽️ お腹の調子が悪い理由はたくさんあります。

まず確認したいのは：
• 最近食事を変えましたか？
• 普段と違う行動をしていませんか？
• 体温や元気さはどうでしょうか？

心配な症状が続く場合は獣医師にご相談ください。''',

      'exercise': '''🚶‍♂️ ペットの散歩ガイド

年齢や体重によって適切な運動量は変わります：

小型犬：20-30分/日
中型犬：30-60分/日
大型犬：60-90分/日

天候や体調に合わせて調整してくださいね！''',

      'vaccination': '''💉 ペットの予防接種スケジュール

基本的なワクチン：
• 子犬・子猫：生後6-8週から開始
• 成犬・成猫：年1回の追加接種
• 狂犬病：年1回（法定義務）

詳しいスケジュールは獣医師と相談してください。''',

      'grooming': '''✂️ グルーミングのコツ

定期的なお手入れで健康維持：
• ブラッシング：毎日〜週2-3回
• 爪切り：月1-2回
• 耳掃除：週1回
• 歯磨き：毎日

無理をせず、少しずつ慣らしていきましょう。''',

      'behavior': '''🐾 行動に関するアドバイス

ペットの行動には必ず理由があります：
• ストレス
• 環境の変化
• 健康状態
• コミュニケーションの取り方

根気強く、愛情をもって向き合いましょう。''',

      'default': '''ペットについての質問ですね! 🐾

どんなことでもお気軽にお聞きください。
• 健康のこと
• 食事のこと
• 行動のこと
• お手入れのこと

より詳しい情報があると、具体的なアドバイスができます！''',
    };
  }

  /// 키워드 매핑 Mock 데이터
  static Map<String, List<String>> getMockKeywordMapping() {
    return {
      'food': ['食事', '食事量', '食事量が少ない', 'お腹', '食べない', '餌', 'フード', '食欲'],
      'exercise': ['散歩', '運動', '時間', '遊び', '走る', 'エクササイズ', '活動'],
      'vaccination': ['接種', 'ワクチン', '予防接種', '注射', '免疫'],
      'grooming': ['毛玉', 'ブラッシング', '爪切り', '耳掃除', '歯磨き', 'グルーミング'],
      'behavior': ['夜泣き', '吠える', '噛む', 'しつけ', '行動', 'ストレス', '怖がる'],
      'health': ['病気', '怪我', '体調', '症状', '健康', '獣医師', '診察'],
    };
  }

  /// 카테고리별 추천 질문 조회
  static List<AiSuggestedQuestionEntity> getQuestionsByCategory(
    String category,
  ) {
    final allQuestions = getMockSuggestedQuestions();
    return allQuestions.where((q) => q.category == category).toList();
  }

  /// 펫 정보 기반 맞춤형 추천 질문 조회
  static List<AiSuggestedQuestionEntity> getPersonalizedQuestions({
    String? category,
    String? petType,
    int? petAge,
  }) {
    var questions = category != null
        ? getQuestionsByCategory(category)
        : getMockSuggestedQuestions();

    // 펫 타입별 필터링
    if (petType != null) {
      final typeLowerCase = petType.toLowerCase();

      // 강아지 전용 질문들
      if (typeLowerCase == 'dog') {
        questions = questions
            .where(
              (q) =>
                  !q.question.contains('猫') && // 고양이 관련 제외
                  !q.question.contains('ネコ') &&
                  !q.question.contains('キャット'),
            )
            .toList();

        // 강아지 특화 질문 우선 순위
        questions.sort((a, b) {
          final aDogSpecific =
              a.question.contains('散歩') ||
              a.question.contains('吠え') ||
              a.question.contains('トイレトレーニング');
          final bDogSpecific =
              b.question.contains('散歩') ||
              b.question.contains('吠え') ||
              b.question.contains('トイレトレーニング');

          if (aDogSpecific && !bDogSpecific) return -1;
          if (!aDogSpecific && bDogSpecific) return 1;
          return 0;
        });
      }
      // 고양이 전용 질문들
      else if (typeLowerCase == 'cat') {
        questions = questions
            .where(
              (q) =>
                  !q.question.contains('散歩') && // 산책 관련 제외
                  !q.question.contains('吠え'), // 짖기 관련 제외
            )
            .toList();
      }
    }

    // 나이별 필터링
    if (petAge != null) {
      // 고령 펫 (7세 이상)
      if (petAge >= 7) {
        // 고령 관련 질문 우선 순위
        questions.sort((a, b) {
          final aAgeSpecific =
              a.question.contains('高齢') ||
              a.question.contains('体重管理') ||
              a.question.contains('健康診断');
          final bAgeSpecific =
              b.question.contains('高齢') ||
              b.question.contains('体重管理') ||
              b.question.contains('健康診断');

          if (aAgeSpecific && !bAgeSpecific) return -1;
          if (!aAgeSpecific && bAgeSpecific) return 1;
          return 0;
        });
      }
      // 어린 펫 (1세 미만)
      else if (petAge < 1) {
        // 새끼 관련 질문 우선 순위
        questions.sort((a, b) {
          final aPuppySpecific =
              a.question.contains('新しいペット') ||
              a.question.contains('トレーニング') ||
              a.question.contains('ワクチン');
          final bPuppySpecific =
              b.question.contains('新しいペット') ||
              b.question.contains('トレーニング') ||
              b.question.contains('ワクチン');

          if (aPuppySpecific && !bPuppySpecific) return -1;
          if (!aPuppySpecific && bPuppySpecific) return 1;
          return 0;
        });
      }
    }

    // 최대 6개까지만 반환
    return questions.take(6).toList();
  }

  /// 키워드로 응답 템플릿 찾기
  static String getResponseTemplateByKeyword(String keyword) {
    final keywordMapping = getMockKeywordMapping();
    final templates = getMockResponseTemplates();

    for (final entry in keywordMapping.entries) {
      if (entry.value.any((k) => keyword.contains(k))) {
        return templates[entry.key] ?? templates['default']!;
      }
    }

    return templates['default']!;
  }
}
