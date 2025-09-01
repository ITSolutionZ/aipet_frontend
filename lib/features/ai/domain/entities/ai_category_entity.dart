import 'package:flutter/material.dart';

/// AI 상담 카테고리 엔티티
class AiCategoryEntity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const AiCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// 기본 카테고리 목록
  static const List<AiCategoryEntity> defaultCategories = [
    AiCategoryEntity(
      id: 'health',
      name: '健康',
      description: '病気、怪我、健康管理について',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    AiCategoryEntity(
      id: 'food',
      name: '食事',
      description: 'フード、栄養、給餌について',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    AiCategoryEntity(
      id: 'toilet',
      name: '排便',
      description: 'トイレトレーニング、排便問題',
      icon: Icons.pets,
      color: Colors.brown,
    ),
    AiCategoryEntity(
      id: 'recipe',
      name: '手作りレシピ',
      description: 'ペット用手作り料理レシピ',
      icon: Icons.kitchen,
      color: Colors.green,
    ),
    AiCategoryEntity(
      id: 'behavior',
      name: '行動',
      description: 'しつけ、問題行動、トレーニング',
      icon: Icons.psychology,
      color: Colors.blue,
    ),
    AiCategoryEntity(
      id: 'grooming',
      name: 'グルーミング',
      description: '毛づくり、お風呂、ケア',
      icon: Icons.content_cut,
      color: Colors.purple,
    ),
    AiCategoryEntity(
      id: 'general',
      name: '一般相談',
      description: '上記以外の一般的な相談',
      icon: Icons.help_outline,
      color: Colors.grey,
    ),
    AiCategoryEntity(
      id: 'others',
      name: 'その他',
      description: 'その他のご相談やご質問',
      icon: Icons.more_horiz,
      color: Colors.blueGrey,
    ),
  ];
}