import 'package:flutter/material.dart';

/// AI 상담 서브카테고리 엔티티
class AiSubCategoryEntity {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const AiSubCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// AI 상담 카테고리 엔티티
class AiCategoryEntity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<AiSubCategoryEntity>? subCategories;

  const AiCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.subCategories,
  });

  /// 기본 카테고리 목록
  static List<AiCategoryEntity> get defaults => [
    const AiCategoryEntity(
      id: 'health',
      name: '健康',
      description: '病気、怪我、健康管理',
      icon: Icons.medical_services,
      color: Colors.red,
      subCategories: [
        AiSubCategoryEntity(
          id: 'health_symptoms',
          name: '症状',
          description: '体調不良、症状の相談',
          icon: Icons.sick,
        ),
        AiSubCategoryEntity(
          id: 'health_vaccination',
          name: '予防接種',
          description: 'ワクチン、予防接種',
          icon: Icons.vaccines,
        ),
        AiSubCategoryEntity(
          id: 'health_checkup',
          name: '健康診断',
          description: '定期検診、健康チェック',
          icon: Icons.health_and_safety,
        ),
        AiSubCategoryEntity(
          id: 'health_medicine',
          name: '薬・サプリ',
          description: '投薬、サプリメント',
          icon: Icons.medication,
        ),
      ],
    ),
    const AiCategoryEntity(
      id: 'food',
      name: '食事',
      description: 'フード、栄養、給餌',
      icon: Icons.restaurant,
      color: Colors.orange,
      subCategories: [
        AiSubCategoryEntity(
          id: 'food_amount',
          name: '給餌量',
          description: '適切な食事量',
          icon: Icons.scale,
        ),
        AiSubCategoryEntity(
          id: 'food_recipe',
          name: '手作りレシピ',
          description: '手作りフード',
          icon: Icons.restaurant_menu,
        ),
        AiSubCategoryEntity(
          id: 'food_allergy',
          name: 'アレルギー',
          description: '食物アレルギー対応',
          icon: Icons.warning_amber,
        ),
        AiSubCategoryEntity(
          id: 'food_picky',
          name: '偏食',
          description: '食べムラ、好き嫌い',
          icon: Icons.no_food,
        ),
      ],
    ),
    const AiCategoryEntity(
      id: 'behavior',
      name: '行動',
      description: 'しつけ、問題行動',
      icon: Icons.psychology,
      color: Colors.purple,
      subCategories: [
        AiSubCategoryEntity(
          id: 'behavior_training',
          name: '基本しつけ',
          description: 'お座り、待て等',
          icon: Icons.school,
        ),
        AiSubCategoryEntity(
          id: 'behavior_barking',
          name: '吠え',
          description: '無駄吠え対策',
          icon: Icons.volume_up,
        ),
        AiSubCategoryEntity(
          id: 'behavior_toilet',
          name: 'トイレ',
          description: 'トイレトレーニング',
          icon: Icons.home,
        ),
        AiSubCategoryEntity(
          id: 'behavior_aggression',
          name: '攻撃性',
          description: '噛む、威嚇行動',
          icon: Icons.warning,
        ),
      ],
    ),
    const AiCategoryEntity(
      id: 'grooming',
      name: 'グルーミング',
      description: 'お手入れ、毛づくろい',
      icon: Icons.content_cut,
      color: Colors.pink,
      subCategories: [
        AiSubCategoryEntity(
          id: 'grooming_brush',
          name: 'ブラッシング',
          description: '毛並みのお手入れ',
          icon: Icons.brush,
        ),
        AiSubCategoryEntity(
          id: 'grooming_bath',
          name: 'お風呂',
          description: 'シャンプー、入浴',
          icon: Icons.bathtub,
        ),
        AiSubCategoryEntity(
          id: 'grooming_nail',
          name: '爪切り',
          description: '爪のお手入れ',
          icon: Icons.cut,
        ),
        AiSubCategoryEntity(
          id: 'grooming_teeth',
          name: '歯磨き',
          description: 'デンタルケア',
          icon: Icons.clean_hands,
        ),
      ],
    ),
    const AiCategoryEntity(
      id: 'exercise',
      name: '運動',
      description: '散歩、遊び',
      icon: Icons.directions_walk,
      color: Colors.green,
      subCategories: [
        AiSubCategoryEntity(
          id: 'exercise_walk',
          name: '散歩',
          description: 'お散歩の頻度や時間',
          icon: Icons.pets,
        ),
        AiSubCategoryEntity(
          id: 'exercise_play',
          name: '遊び',
          description: '室内遊び、おもちゃ',
          icon: Icons.sports_esports,
        ),
        AiSubCategoryEntity(
          id: 'exercise_training',
          name: 'トレーニング',
          description: '運動トレーニング',
          icon: Icons.fitness_center,
        ),
      ],
    ),
    const AiCategoryEntity(
      id: 'general',
      name: 'その他',
      description: '一般的な相談',
      icon: Icons.help_outline,
      color: Colors.blue,
      subCategories: [
        AiSubCategoryEntity(
          id: 'general_other',
          name: 'その他',
          description: '上記以外の相談',
          icon: Icons.question_mark,
        ),
      ],
    ),
  ];

  /// ID로 카테고리 찾기
  static AiCategoryEntity? findById(String id) {
    try {
      return defaults.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 카테고리 이름으로 찾기
  static AiCategoryEntity? findByName(String name) {
    try {
      return defaults.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }
}
