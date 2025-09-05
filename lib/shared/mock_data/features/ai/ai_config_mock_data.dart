import 'package:flutter/material.dart';

import '../../../../features/ai/domain/domain.dart';

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
      const AiSuggestedQuestionEntity(
        id: '1',
        question: 'ペットが食事を拒否する時はどうしたらいいですか？',
        category: 'health',
        icon: Icons.restaurant,
      ),
      const AiSuggestedQuestionEntity(
        id: '2',
        question: '散歩の適切な時間はどのくらいですか？',
        category: 'exercise',
        icon: Icons.access_time,
      ),
      const AiSuggestedQuestionEntity(
        id: '3',
        question: 'ペットが夜泣きをやめないのですが？',
        category: 'behavior',
        icon: Icons.bedtime,
      ),
      const AiSuggestedQuestionEntity(
        id: '4',
        question: 'ワクチンの接種スケジュールを教えて',
        category: 'health',
        icon: Icons.medical_services,
      ),
      const AiSuggestedQuestionEntity(
        id: '5',
        question: 'ペットの毛玉を取る方法は？',
        category: 'grooming',
        icon: Icons.content_cut,
      ),
      const AiSuggestedQuestionEntity(
        id: '6',
        question: '適切な食事量を教えてください',
        category: 'feeding',
        icon: Icons.scale,
      ),
      const AiSuggestedQuestionEntity(
        id: '7',
        question: '雨の日の室内遊びのアイデアは？',
        category: 'exercise',
        icon: Icons.home,
      ),
      const AiSuggestedQuestionEntity(
        id: '8',
        question: 'ペットが他の動物を怖がります',
        category: 'behavior',
        icon: Icons.psychology,
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
  static List<AiSuggestedQuestionEntity> getQuestionsByCategory(String category) {
    final allQuestions = getMockSuggestedQuestions();
    return allQuestions.where((q) => q.category == category).toList();
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