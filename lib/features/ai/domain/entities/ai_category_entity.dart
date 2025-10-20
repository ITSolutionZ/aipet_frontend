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
  static List<AiCategoryEntity> get defaults => [
    const AiCategoryEntity(
      id: 'health',
      name: '健康',
      description: '病気、怪我、健康管理',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    const AiCategoryEntity(
      id: 'food',
      name: '食事',
      description: 'フード、栄養、給餌',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    const AiCategoryEntity(
      id: 'behavior',
      name: '行動',
      description: 'しつけ、問題行動',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    const AiCategoryEntity(
      id: 'grooming',
      name: 'グルーミング',
      description: 'お手入れ、毛づくろい',
      icon: Icons.content_cut,
      color: Colors.pink,
    ),
    const AiCategoryEntity(
      id: 'exercise',
      name: '運動',
      description: '散歩、遊び',
      icon: Icons.directions_walk,
      color: Colors.green,
    ),
    const AiCategoryEntity(
      id: 'general',
      name: 'その他',
      description: '一般的な相談',
      icon: Icons.help_outline,
      color: Colors.blue,
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
